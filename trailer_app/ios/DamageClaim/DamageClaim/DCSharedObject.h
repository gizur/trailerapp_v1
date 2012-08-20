//
//  PLSharedObject.h
//  Plunk
//
//  Created by Dev on 14/06/12.
//  Copyright (c) 2012 developer.gslab@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DCSharedObject : NSObject
+(DCSharedObject *) sharedPreferences;
+(void)showAlertWithMessage:(NSString *)alertMessage;
@property(nonatomic, retain) NSMutableDictionary *preferences;
@end
