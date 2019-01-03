//
//  Message.swift
//  Real-Time-Chat
//
//  Created by Chittapon Thongchim on 23/12/2561 BE.
//  Copyright © 2561 Chittapon Thongchim. All rights reserved.
//

import Firebase

enum MediaMessage {
    case message(text: String)
    case image(url: URL?)
}

class Message {
    
    let id: String
    var media: MediaMessage
    let userId: String
    var createdDate: Date
    var profileImage: String
    
    init(doc: QueryDocumentSnapshot) throws {
        let data = doc.data()
        
        guard let userId = data["userId"] as? String else { throw MessageError.invalidKey }
        guard let createdDate = data["createdDate"] as? Date else { throw MessageError.invalidKey }
        guard let profileImage = data["profileImage"] as? String else { throw MessageError.invalidKey }
        guard let type = data["mediaType"] as? String else { throw MessageError.invalidKey }
        
        self.id = doc.documentID
        self.userId = userId
        self.createdDate = createdDate
        self.profileImage = profileImage
        
        switch type {
            
        case "text":
            guard let text = data["text"] as? String else { throw MessageError.invalidKey }
            media = MediaMessage.message(text: text)
            
        case "image":
            guard let imageURL = data["image"] as? String,
                let url = URL(string: imageURL) else { throw MessageError.noImageURL }
            media = MediaMessage.image(url: url)
            
        default:
            throw MessageError.invalidKey
        }
    }
    
    func update(doc: QueryDocumentSnapshot) {
        let data = doc.data()
        
        guard let createdDate = data["createdDate"] as? Date,
            let profileImage = data["profileImage"] as? String,
            let type = data["mediaType"] as? String else { return }
        
        self.createdDate = createdDate
        self.profileImage = profileImage
        
        switch type {
            
        case "text":
            guard let text = data["text"] as? String else { return }
            media = MediaMessage.message(text: text)
            
        case "image":
            guard let imageURL = data["image"] as? String else { return }
            let url = URL(string: imageURL)
            media = MediaMessage.image(url: url)
            
        default:
            break
        }
    }
    
    enum MessageError: Error {
        case invalidKey
        case noImageURL
    }
}
