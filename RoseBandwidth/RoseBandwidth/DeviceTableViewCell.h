//
//  DeviceTableViewCell.h
//  RoseBandwidth
//
//  Created by Jonathan Jungck on 2/11/15.
//  Copyright (c) 2015 edu.rosehulman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface DeviceTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *deviceLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UILabel *usageLabel;

@end
