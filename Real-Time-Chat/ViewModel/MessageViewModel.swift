//
//  MessageViewModel.swift
//  Real Time Chat
//
//  Created by Chittapon Thongchim on 14/12/2561 BE.
//  Copyright © 2561 Chittapon Thongchim. All rights reserved.
//

import UIKit
import RxSwift

protocol MessageViewModelType {
    var input: MessageInput { get }
    var output: MessageOutput { get }
}

protocol MessageInput {
    
}

protocol MessageOutput {
    var text: String { get }
    var isOutgoing: Bool { get }
    var profileImage: UIImage? { get }
    var date: Date { get }
    var id: String { get }
}

class MessageViewModel: MessageViewModelType, MessageInput, MessageOutput {
    
    var input: MessageInput { return self }
    var output: MessageOutput { return self }
    private let message: Message
    var text: String { return message.text }
    let isOutgoing: Bool
    var profileImage: UIImage?
    let date: Date
    let id: String
    
    init(message: Message, userId: String) {
        self.message = message
        isOutgoing = message.userId == userId
        date = message.createdDate
        id = message.id
    }
}
