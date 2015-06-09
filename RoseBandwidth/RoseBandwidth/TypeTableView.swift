//
//  TypeTableView.swift
//  RoseBandwidth
//
//  Created by Anthony Minardo on 2/7/15.
//  Copyright (c) 2015 edu.rosehulman. All rights reserved.
//

import UIKit

class TypeTableView: UITableView {

    @IBOutlet weak var optionPercent: UITableViewCell!
    @IBOutlet weak var optionGB: UITableViewCell!
    @IBOutlet weak var optionMB: UITableViewCell!
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

    func getSelected() -> NSString {
        var result = ""
        if optionPercent.selected {
            result = optionPercent.textLabel!.text!
        }
        if optionGB.selected {
            result = optionGB.textLabel!.text!
        }
        if optionMB.selected {
            result = optionMB.textLabel!.text!
        }
        
        return result
    }
    
    func getType() -> NSString {
        var result = ""
        if optionPercent.selected {
            result = "%"
        }
        if optionGB.selected {
            result = " GB"
        }
        if optionMB.selected {
            result = " MB"
        }
        
        return result
    }
    
    func getText(type: NSString) -> NSString {
        var result = ""
        if type == "%" {
            result = optionPercent.detailTextLabel!.text!
        } else if type == " GB" {
            result = optionGB.detailTextLabel!.text!
        } else {
            result = optionMB.detailTextLabel!.text!
        }
        
        return result
    }
    
    
}
