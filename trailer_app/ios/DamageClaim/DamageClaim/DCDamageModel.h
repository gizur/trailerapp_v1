//
//  DCDamageModel.h
//  DamageClaim
//
//  Created by Dev on 19/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DCDamageModel : NSObject

@property (nonatomic, retain) NSString *damageType;
@property (nonatomic, retain) NSString *damagePosition;
@property (nonatomic, retain) NSMutableArray *damageImages;

@end
