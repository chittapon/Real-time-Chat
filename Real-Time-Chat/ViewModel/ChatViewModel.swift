//
//  ChatViewModel.swift
//  Real Time Chat
//
//  Created by Chittapon Thongchim on 14/12/2561 BE.
//  Copyright © 2561 Chittapon Thongchim. All rights reserved.
//

import RxSwift
import RxCocoa
import Firebase

protocol ChatViewModelType {
    var input: ChatInput { get }
    var output: ChatOutput { get }
}

protocol ChatInput {
    func viewDidLoad()
    var sendMessage: PublishRelay<String> { get }
}

protocol ChatOutput {
    var messages: [MessageViewModelType] { get }
    var reloadData: PublishRelay<ReloadMessage> { get }
}

enum ReloadMessage {
    case insert(indexPath: IndexPath)
    case delete(indexPath: IndexPath)
    case update(indexPath: IndexPath)
}

class ChatViewModel: ChatViewModelType, ChatInput, ChatOutput {

    var input: ChatInput { return self }
    var output: ChatOutput { return self }
    var messages: [MessageViewModelType] = []
    private lazy var db = Firestore.firestore()
    private lazy var collection = db.collection("messages")
    private let userId = "wick"
    
    let reloadData = PublishRelay<ReloadMessage>()
    private let netWork = Network()
    var listener: ListenerRegistration?
    var sendMessage = PublishRelay<String>()
    private let bag = DisposeBag()
    
    init() {
        sendMessage.subscribe(onNext: { [weak self] (text) in
            guard let self = self else { return }
            var data: [String: Any] = [:]
            data["text"] = text
            data["userId"] = self.userId
            data["createdDate"] = Date()
            data["profileImage"] = "https://i.ytimg.com/vi/TtAMB2wv-8k/maxresdefault.jpg"
            self.collection.addDocument(data: data)
        }).disposed(by: bag)
    }
    
    func viewDidLoad() {
        
        listener = collection.addSnapshotListener { [weak self] (query, error) in
            
            guard let self = self, error == nil, let snapShot = query else {
                print(error?.localizedDescription ?? "")
                return
            }
            
            for docChange in snapShot.documentChanges {
                
                switch docChange.type {
                    
                case .added:
                    self.addMessage(doc: docChange.document)
                    
                case .modified:
                    break
                    
                case .removed:
                    self.deleteMessage(doc: docChange.document)
                    break
                }
            }
        }

    }
    
    func addMessage(doc: QueryDocumentSnapshot) {

        do {
            let message = try Message(doc: doc)
            let viewModel = MessageViewModel(message: message, userId: userId)
            messages.append(viewModel)
            let indexPath = IndexPath(item: messages.count - 1, section: 0)
            let reload: ReloadMessage = .insert(indexPath: indexPath)
            reloadData.accept(reload)
        } catch let error {
            print(error)
        }
        
    }
    
    func deleteMessage(doc: QueryDocumentSnapshot) {
        guard let index = messages.firstIndex(where: { $0.output.id == doc.documentID }) else { return }
        messages.remove(at: index)
        let indexPath = IndexPath(item: index, section: 0)
        let reload: ReloadMessage = .delete(indexPath: indexPath)
        reloadData.accept(reload)
    }
}
