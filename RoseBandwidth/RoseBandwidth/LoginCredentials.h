//
//  LoginCredentials.h
//  RoseBandwidth
//
//  Created by Jonathan Jungck on 2/11/15.
//  Copyright (c) 2015 edu.rosehulman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface LoginCredentials : NSManagedObject

@property (nonatomic, retain) NSString * password;
@property (nonatomic, retain) NSString * username;
@property (nonatomic, retain) NSNumber * isLoggedIn;

@end
