//
//  ChouChouLogger.m
//  ChouChouNative
//
//  Created by Sourabh Verma on 06/05/14.
//  Copyright (c) 2014 ibibo group. All rights reserved.
//

#import "ChouChouLogger.h"

@implementation ChouChouLogger

+(void)logEvent:(NSString*)event params:(NSDictionary*)params debug:(ChouChouDebug)debug{
    NSLog(@"#ChouChouLogger:%d Event:%@ Params:%@", debug, event, params);
    
    switch (debug) {
        case CHOU_DEBUG_NONE:
        {
            
        }
            break;
        case CHOU_DEBUG_ERRORS:
        {
            
        }
            break;
        case CHOU_DEBUG_ERR_AND_IMP:
        {
            
        }
            break;
        case CHOU_DEBUG_FULL:
        {
            
        }
            break;
        default:
            break;
    }
}

+(void)logException:(NSException*)exception method:(NSString*)method class:(NSString*)clsName{
    NSLog(@"#ChouChouLogger Exception:%@ Event:%@ Class:%@", exception, method, clsName);
}

+(void)logError:(NSError*)error{
    NSLog(@"#ChouChouLogger Error:%@", error);
}

@end
