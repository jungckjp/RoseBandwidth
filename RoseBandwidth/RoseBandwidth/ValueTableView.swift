//
//  ValueTableView.swift
//  RoseBandwidth
//
//  Created by Anthony Minardo on 2/7/15.
//  Copyright (c) 2015 edu.rosehulman. All rights reserved.
//

import UIKit

class ValueTableView: UITableView {

    @IBOutlet weak var valueField: UITextField!

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

    func getSelected() -> NSString {
        return valueField.text
    }
    
    func getValue() -> NSString {
        return valueField.text
    }
}
