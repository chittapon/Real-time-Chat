//
//  ToolBarContentView.swift
//  Real Time Chat
//
//  Created by Chittapon Thongchim on 14/12/2561 BE.
//  Copyright © 2561 Chittapon Thongchim. All rights reserved.
//

import UIKit
import Reusable

class ToolBarContentView: UIView, NibLoadable {

    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var sendButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()

        layer.shadowColor = #colorLiteral(red: 0.1048645601, green: 0.5270022154, blue: 0.7749804854, alpha: 1)
        layer.shadowRadius = 18
        layer.shadowOpacity = 0.2
        
    }
}
