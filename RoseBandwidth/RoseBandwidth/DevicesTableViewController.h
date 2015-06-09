//
//  DevicesTableViewController.h
//  Rose-Hulman Bandwidth
//
//  Created by Jonathan Jungck on 1/28/15.
//  Copyright (c) 2015 Jonathan Jungck and Anthony Minardo. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "RoseBandwidth-Swift.h"

@interface DevicesTableViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, retain) NSManagedObjectContext * managedObjectContext;
@property (nonatomic, strong) NSArray* devices;
@property (nonatomic, strong) NSArray* dataOverview;
@property (nonatomic, copy) NSString* devicesIdentifier;
@property (nonatomic, copy) NSString* dataIdentifier;
- (void)fetchData;
@end
