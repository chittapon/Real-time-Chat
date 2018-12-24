//
//  Message.swift
//  Real-Time-Chat
//
//  Created by Chittapon Thongchim on 23/12/2561 BE.
//  Copyright © 2561 Chittapon Thongchim. All rights reserved.
//

import Firebase

class Message {
    
    let id: String
    let text: String
    let userId: String
    let createdDate: Date
    let profileImage: String
    
    init(doc: QueryDocumentSnapshot) throws {
        let data = doc.data()
        guard let text = data["text"] as? String else { throw MessageError.invalidKey }
        guard let userId = data["userId"] as? String else { throw MessageError.invalidKey }
        guard let createdDate = data["createdDate"] as? Date else { throw MessageError.invalidKey }
        guard let profileImage = data["profileImage"] as? String else { throw MessageError.invalidKey }
        self.id = doc.documentID
        self.text = text
        self.userId = userId
        self.createdDate = createdDate
        self.profileImage = profileImage
    }
    
    enum MessageError: Error {
        case invalidKey
    }
}
