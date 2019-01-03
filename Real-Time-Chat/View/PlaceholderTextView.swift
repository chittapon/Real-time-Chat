//
//  PlaceholderTextView.swift
//  Real Time Chat
//
//  Created by Chittapon Thongchim on 22/12/2561 BE.
//  Copyright © 2561 Chittapon Thongchim. All rights reserved.
//

import UIKit
import RxSwift

class PlaceholderTextView: UITextView {

    let insets = UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0)
    let bag = DisposeBag()
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        if text.count == 0 {
            let attributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15),
                              NSAttributedString.Key.foregroundColor: UIColor.lightGray]
            
            ("Type your messages" as NSString).draw(in: rect.inset(by: insets), withAttributes: attributes)
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        textContainerInset = insets
        autocorrectionType = .no
        NotificationCenter.default.rx.notification(UITextView.textDidChangeNotification, object: self).subscribe(onNext: { [weak self] (_) in
            self?.setNeedsDisplay()
        }).disposed(by: bag)
    }
}
