//
//  DataDevice.h
//  RoseBandwidth
//
//  Created by Anthony Minardo on 2/9/15.
//  Copyright (c) 2015 edu.rosehulman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface DataDevice : NSManagedObject

@property (nonatomic, retain) NSString * addressIP;
@property (nonatomic, retain) NSString * hostName;
@property (nonatomic, retain) NSString * sentData;
@property (nonatomic, retain) NSString * recievedData;

@end
