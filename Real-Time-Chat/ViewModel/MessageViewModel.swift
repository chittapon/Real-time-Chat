//
//  MessageViewModel.swift
//  Real Time Chat
//
//  Created by Chittapon Thongchim on 14/12/2561 BE.
//  Copyright © 2561 Chittapon Thongchim. All rights reserved.
//

import RxSwift
import RxCocoa
import Firebase

protocol MessageViewModelType {
    var input: MessageInput { get }
    var output: MessageOutput { get }
}

protocol MessageInput {
    func updateMessage(doc: QueryDocumentSnapshot)
    func setMediaImage(size: CGSize)
    var reloadImage: PublishRelay<Void> { get }
}

protocol MessageOutput {
    var text: String? { get }
    var mediaImageURL: URL? { get }
    var isHiddenTextView: Bool { get }
    var isHiddenImageView: Bool { get }
    var isOutgoing: Bool { get }
    var date: Date { get }
    var id: String { get }
    var profileImageURL: URL? { get }
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
    let profileImageURL: URL?
    var mediaImageURL: URL?
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
        profileImageURL = URL(string: message.profileImage)
        
        switch message.media {

        case .message(let text):
            isHiddenImageView = true
            isHiddenTextView = false
            mediaImageURL = nil
            self.text = text
            
        case .image(let url):
            isHiddenImageView = false
            isHiddenTextView = true
            mediaImageURL = url
            
        }
    }
    
    func updateMessage(doc: QueryDocumentSnapshot) {
        message.update(doc: doc)
        if case let .image(url) = message.media {
            mediaImageURL = url
        }
    }
    
    func setMediaImage(size: CGSize) {
        if imageSize == .zero {
            imageSize = size
            reloadImage.accept(())
        }
    }
}
