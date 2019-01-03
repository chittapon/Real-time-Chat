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
import FirebaseStorage

protocol ChatViewModelType {
    var input: ChatInput { get }
    var output: ChatOutput { get }
}

protocol ChatInput {
    func viewDidLoad()
    var sendMessage: PublishRelay<MediaMessage> { get }
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
    private lazy var storage = Storage.storage()
    private lazy var storageRef = storage.reference(withPath: "messages")
    //jonathan
    private let userId = "wick"
    
    let reloadData = PublishRelay<ReloadMessage>()
    private let netWork = Network()
    var listener: ListenerRegistration?
    var sendMessage = PublishRelay<MediaMessage>()
    private let bag = DisposeBag()
    
    init() {
        sendMessage.subscribe(onNext: { [weak self] (media) in
            
            guard let self = self else { return }
            
            var data: [String: Any] = [:]
            data["userId"] = self.userId
            data["createdDate"] = Date()
            data["profileImage"] = "https://i.ytimg.com/vi/TtAMB2wv-8k/maxresdefault.jpg"
            
            switch media {
                
            case .message(let text):
                data["text"] = text
                data["mediaType"] = "text"
                self.collection.addDocument(data: data)
                
            case .image(let url):
                data["mediaType"] = "image"
                let doc = self.collection.document()
                doc.setData(data)
                guard let url = url else { return }
                self.uploadImage(id: doc.documentID, url: url)
            }
            
            
        }).disposed(by: bag)
    }
    
    func viewDidLoad() {
        
        listener = collection.order(by: "createdDate").addSnapshotListener { [weak self] (query, error) in
            
            guard let self = self, error == nil, let snapShot = query else {
                print(error?.localizedDescription ?? "")
                return
            }
            
            for docChange in snapShot.documentChanges {
                
                switch docChange.type {
                    
                case .added:
                    self.addMessage(doc: docChange.document)
                    
                case .modified:
                    self.updateMessage(doc: docChange.document)
                    
                case .removed:
                    self.deleteMessage(doc: docChange.document)
                }
            }
        }

    }
    
    func uploadImage(id: String, url: URL) {
        let imageRef = storageRef.child(id)
        imageRef.putFile(from: url, metadata: nil) { [weak self] (_, error) in
            guard let self = self else { return }
            if let error = error {
                print(error.localizedDescription)
            }else {
                imageRef.downloadURL(completion: { (imageURL, error) in
                    guard let url = imageURL else { return }
                    self.collection.document(id).updateData(["image": url.absoluteString])
                })
            }
        }
    }
    
    func addMessage(doc: QueryDocumentSnapshot) {

        do {
            let message = try Message(doc: doc)
            let viewModel = MessageViewModel(message: message, userId: userId)
            messages.append(viewModel)
            let indexPath = IndexPath(item: messages.count - 1, section: 0)
            
            viewModel.output.reloadImage.map({ ReloadMessage.update(indexPath: indexPath) }).bind(to: reloadData).disposed(by: bag)
            
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
    
    func updateMessage(doc: QueryDocumentSnapshot) {
        guard let index = messages.firstIndex(where: { $0.output.id == doc.documentID }) else { return }
        let indexPath = IndexPath(item: index, section: 0)
        let message = messages[index]
        
        message.input.updateMessage(doc: doc)
        
        message.output.reloadImage.map({ ReloadMessage.update(indexPath: indexPath) }).bind(to: reloadData).disposed(by: bag)
        
        let reload: ReloadMessage = .update(indexPath: indexPath)
        reloadData.accept(reload)
    }
}
