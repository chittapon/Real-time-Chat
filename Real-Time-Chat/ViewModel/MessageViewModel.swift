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
    var image: Observable<Data> { get }
    var isOutgoing: Bool { get }
    var date: Date { get }
    var id: String { get }
    var profileImage: Observable<Data> { get }
}

class MessageViewModel: MessageViewModelType, MessageInput, MessageOutput {
    
    var input: MessageInput { return self }
    var output: MessageOutput { return self }
    private let message: Message
    var text: String?
    var image = Observable<Data>.never()
    let isOutgoing: Bool
    let date: Date
    let id: String
    let profileImage: Observable<Data>
    private let network = Network()
    
    init(message: Message, userId: String) {
        self.message = message
        isOutgoing = message.userId == userId
        date = message.createdDate
        id = message.id
        profileImage = network.request(url: message.profileImage)
        
        switch message.media {

        case .message(let text):
            self.text = text
            
        case .image(let url):
            if let url = url {
                image = network.request(url: url)
            }
        }
    }
    
    func updateMessage(doc: QueryDocumentSnapshot) {
        message.update(doc: doc)
    }
}
