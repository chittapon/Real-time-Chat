//
//  MessageCollectionViewCell.swift
//  Real Time Chat
//
//  Created by Chittapon Thongchim on 14/12/2561 BE.
//  Copyright © 2561 Chittapon Thongchim. All rights reserved.
//

import UIKit
import Reusable

class MessageCollectionViewCell: UICollectionViewCell, NibReusable {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var profileImageContainerView: UIView!
    
    static let textContainerInset = UIEdgeInsets(top: 6, left: 8, bottom: 6, right: 8)
    
    var viewModel: MessageViewModelType! {
        didSet {
            configCell()
        }
    }
    
    func configCell() {

        textView.font = UIFont.systemFont(ofSize: 16)
        textView.textColor = .white
        textView.textContainer.lineFragmentPadding = 0
        textView.textContainerInset = MessageCollectionViewCell.textContainerInset
        textView.contentInset = .zero
        let gradientLayer = CAGradientLayer()
        layoutIfNeeded()
        gradientLayer.frame = bounds
        gradientLayer.colors = [#colorLiteral(red: 0.4211239517, green: 0.7776346803, blue: 0.9756726623, alpha: 1).cgColor, #colorLiteral(red: 0.2226053774, green: 0.5345532298, blue: 0.8183222413, alpha: 1).cgColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        textView.text = viewModel.output.text
        textView.layer.insertSublayer(gradientLayer, at: 0)
        textView.layer.cornerRadius = 6
        
        if viewModel.output.isOutgoing {
            
        }else {
            
            profileImageView.image = viewModel.output.profileImage
            profileImageView.layer.cornerRadius = 56 / 2
            profileImageView.layer.borderWidth = 2
            profileImageView.layer.borderColor = UIColor.white.cgColor
            
            profileImageContainerView.layer.shadowColor = #colorLiteral(red: 0.1246279106, green: 0.6877170205, blue: 1, alpha: 1)
            profileImageContainerView.layer.shadowRadius = 6
            profileImageContainerView.layer.shadowOpacity = 0.2
            profileImageContainerView.layer.shadowOffset = CGSize(width: 0, height: 3)
        }
        
    }
}
