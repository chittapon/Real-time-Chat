//
//  Extension.swift
//  Real Time Chat
//
//  Created by Chittapon Thongchim on 14/12/2561 BE.
//  Copyright © 2561 Chittapon Thongchim. All rights reserved.
//

import UIKit

extension UIView {
    
    static func calculateHeight(for attributes: NSAttributedString, width: CGFloat) -> CGFloat {
        let constraint = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        return attributes.boundingRect(with: constraint, options: [.usesFontLeading, .usesLineFragmentOrigin], context: nil).integral.height
    }

}
