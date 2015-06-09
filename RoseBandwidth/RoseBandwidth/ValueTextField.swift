//
//  ValueTextField.swift
//  RoseBandwidth
//
//  Created by Jonathan Jungck on 4/14/15.
//  Copyright (c) 2015 edu.rosehulman. All rights reserved.
//

import Foundation
import UIKit

class ValueTextField: UITextField {
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.becomeFirstResponder()
    }
    
    func textFieldShouldReturn(textField: UITextField!) -> Bool // called when 'return' key pressed. return NO to ignore.
    {
        textField.resignFirstResponder()
        return true;
    }
}