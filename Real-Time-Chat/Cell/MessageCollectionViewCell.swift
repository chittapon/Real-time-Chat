//
//  MessageCollectionViewCell.swift
//  Real Time Chat
//
//  Created by Chittapon Thongchim on 14/12/2561 BE.
//  Copyright © 2561 Chittapon Thongchim. All rights reserved.
//

import UIKit
import Reusable
import RxSwift
import Kingfisher

class MessageCollectionViewCell: UICollectionViewCell, NibReusable {
    
    @IBOutlet private var textView: UITextView!
    @IBOutlet private var profileImageView: UIImageView!
    @IBOutlet private var profileImageContainerView: UIView!
    @IBOutlet private var mediaImageView: UIImageView!
    
    static let textContainerInset = UIEdgeInsets(top: 6, left: 8, bottom: 6, right: 8)
    private let bag = DisposeBag()
    
    var viewModel: MessageViewModelType! {
        didSet {
            configCell()
        }
    }
    
    lazy var gradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.colors = [#colorLiteral(red: 0.4211239517, green: 0.7776346803, blue: 0.9756726623, alpha: 1).cgColor, #colorLiteral(red: 0.2226053774, green: 0.5345532298, blue: 0.8183222413, alpha: 1).cgColor]
        layer.startPoint = CGPoint(x: 0, y: 0.5)
        layer.endPoint = CGPoint(x: 1, y: 0.5)
        return layer
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // TextView
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.textColor = .white
        textView.textContainer.lineFragmentPadding = 0
        textView.textContainerInset = MessageCollectionViewCell.textContainerInset
        textView.contentInset = .zero
        textView.layer.insertSublayer(gradientLayer, at: 0)
        textView.layer.cornerRadius = 6
        
        // ProfileImageView
        profileImageView?.layer.cornerRadius = 56 / 2
        profileImageView?.layer.borderWidth = 2
        profileImageView?.layer.borderColor = UIColor.white.cgColor
        
        // ProfileContainerView
        profileImageContainerView?.layer.shadowColor = #colorLiteral(red: 0.1246279106, green: 0.6877170205, blue: 1, alpha: 1)
        profileImageContainerView?.layer.shadowRadius = 6
        profileImageContainerView?.layer.shadowOpacity = 0.2
        
        // MediaImageView
        mediaImageView?.clipsToBounds = true
        mediaImageView?.layer.cornerRadius = 6
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }
    
    func configCell() {
        
        func setTextView() {
            textView.isHidden = viewModel.output.isHiddenTextView
            textView.text = viewModel.output.text
        }
        
        func setMediaImageView() {
            mediaImageView?.isHidden = viewModel.output.isHiddenImageView

            guard let url = viewModel.output.mediaImageURL else { return }
            let resource = ImageResource(downloadURL: url)
            let options: KingfisherOptionsInfo = [.transition(.fade(1)),
                                                  .cacheOriginalImage]
            
            mediaImageView?.kf.setImage(with: resource, placeholder: nil, options: options, progressBlock: nil, completionHandler: { [weak self] (result) in
                
                switch result {
                    
                case .success(let value):
                    let newSize = value.image.size
                    self?.viewModel.input.setMediaImage(size: newSize)
                    
                case .failure(_):
                    break
                }
                
            })
        }
        
        func setProfileImageView() {
            guard let url = viewModel.output.profileImageURL else { return }
            let resource = ImageResource(downloadURL: url)
            let options: KingfisherOptionsInfo = [.transition(.fade(1)),
                                                  .cacheOriginalImage]
            
            profileImageView?.kf.setImage(with: resource, placeholder: nil, options: options, progressBlock: nil, completionHandler: { (_) in
                
            })
        }
        
        setTextView()
        setMediaImageView()
        setProfileImageView()

    }
}
