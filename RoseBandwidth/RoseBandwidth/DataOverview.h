//
//  DataOverview.h
//  RoseBandwidth
//
//  Created by Anthony Minardo on 2/9/15.
//  Copyright (c) 2015 edu.rosehulman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface DataOverview : NSManagedObject

@property (nonatomic, retain) NSString * bandwidthClass;
@property (nonatomic, retain) NSString * recievedData;
@property (nonatomic, retain) NSString * sentData;

@end
