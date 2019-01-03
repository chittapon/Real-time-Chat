//
//  MessageViewModel.swift
//  Real Time Chat
//
//  Created by Chittapon Thongchim on 14/12/2561 BE.
//  Copyright © 2561 Chittapon Thongchim. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Firebase

protocol MessageViewModelType {
    var input: MessageInput { get }
    var output: MessageOutput { get }
}

protocol MessageInput {
    func updateMessage(doc: QueryDocumentSnapshot)
}

protocol MessageOutput {
    var text: String? { get }
    var image: UIImage? { get }
    var isHiddenTextView: Bool { get }
    var isHiddenImageView: Bool { get }
    var isOutgoing: Bool { get }
    var date: Date { get }
    var id: String { get }
    var profileImage: Observable<Data> { get }
    var imageSize: CGSize { get }
    var reloadImage: PublishRelay<Void> { get }
}

class MessageViewModel: MessageViewModelType, MessageInput, MessageOutput {
    
    var input: MessageInput { return self }
    var output: MessageOutput { return self }
    private let message: Message
    var text: String?
    let isOutgoing: Bool
    let date: Date
    let id: String
    let profileImage: Observable<Data>
    var image: UIImage? = nil
    let isHiddenTextView: Bool
    let isHiddenImageView: Bool
    var imageSize: CGSize = .zero
    var reloadImage: PublishRelay<Void> = PublishRelay()
    private let network = Network()
    private let bag = DisposeBag()
    
    init(message: Message, userId: String) {
        self.message = message
        isOutgoing = message.userId == userId
        date = message.createdDate
        id = message.id
        profileImage = network.request(url: message.profileImage)
        
        switch message.media {

        case .message(let text):
            self.isHiddenImageView = true
            self.isHiddenTextView = false
            self.text = text
            
        case .image(let url):
            self.isHiddenImageView = false
            self.isHiddenTextView = true
            fetchImage(url: url)
            
        }
    }
    
    func updateMessage(doc: QueryDocumentSnapshot) {
        message.update(doc: doc)
        
        if case let .image(url) = message.media {
            fetchImage(url: url)
        }
    }
    
    
    func fetchImage(url: URL?) {
        if let url = url?.absoluteString, url.hasPrefix("http") || url.hasPrefix("https") {
            network.request(url: url).subscribe(onNext: { [weak self] (data) in
                guard let self = self, let image = UIImage(data: data) else { return }
                self.imageSize = image.size
                self.image = image
                self.reloadImage.accept(())
                
            }).disposed(by: bag)
        }
    }
}
