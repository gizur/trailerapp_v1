//
//  PLSharedObject.m
//  Plunk
//
//  Created by Dev on 14/06/12.
//  Copyright (c) 2012 developer.gslab@gmail.com. All rights reserved.
//

#import "DCSharedObject.h"
#import "Const.h"
static DCSharedObject *sharedPreferences = nil;


@implementation DCSharedObject

@synthesize preferences = _preferences;


+(DCSharedObject *) sharedPreferences {
    @synchronized(self) {
        if (sharedPreferences == nil) {
            sharedPreferences = [[super allocWithZone:NULL] init];
            
        }
    }
    return sharedPreferences;
}

+(id) allocWithZone:(NSZone *)zone {
    return [[self sharedPreferences] retain];
}

-(id) copyWithZone:(NSZone *)zone {
    return self;
}

-(id) retain {
    return self;
}

-(NSUInteger) retainCount {
    return NSUIntegerMax;
}

-(oneway void) release {
    
}

-(id) autorelease {
    return self;
}

-(id) init {
    if (self = [super init]) {
        _preferences = [[NSMutableDictionary alloc] init];
        
    }
    return self;
}


-(void) dealloc {
    [_preferences release];
    [super dealloc];
}


+(void)showAlertWithMessage:(NSString *)alertMessage
{
	UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:nil
														 message:NSLocalizedString(alertMessage, @"")
														delegate:nil
											   cancelButtonTitle:NSLocalizedString(@"OK", @"")
											   otherButtonTitles:nil] autorelease];
	[alertView show];
	
}


@end
