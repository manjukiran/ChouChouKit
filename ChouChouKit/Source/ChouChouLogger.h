//
//  ChouChouLogger.h
//  ChouChouKit
//
//  Created by Sourabh Verma on 06/05/14.
//  Copyright (c) 2014 ibibo Web Pvt. Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ChouChouKit.h"

@interface ChouChouLogger : NSObject

+(void)logEvent:(NSString*)event params:(NSDictionary*)params debug:(ChouChouDebug)debug;
+(void)logException:(NSException*)exception method:(NSString*)method class:(NSString*)clsName;
+(void)logError:(NSError*)error;

@end
