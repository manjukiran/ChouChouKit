//
//  ChouChouKit.h
//  ChouChouNative
//
//  Created by R Manju Kiran on 06/05/14.
//  Copyright (c) 2014 ibibo Web Pvt. Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ChouChouManagedObject.h"
#import "ChouChouError.h"

typedef enum ChouChouDebug{
    CHOU_DEBUG_NONE,
    CHOU_DEBUG_ERRORS,
    CHOU_DEBUG_ERR_AND_IMP,
    CHOU_DEBUG_FULL
}ChouChouDebug;

typedef enum ChouChouStorageType{
    CHOU_STORE_NO_LOCAL_STORAGE,
    CHOU_STORE_COUCHBASE_LITE,
    CHOU_STORE_SQLITE,
}ChouChouStorageType;

@interface ChouChouKit : NSObject

//Initiate
+(ChouChouKit*)initiateChouChou:(NSString*)key server:(NSString*)server storageType:(ChouChouStorageType)storageType debug:(ChouChouDebug)debug;

+(ChouChouKit*)sharedInstance;

//Set header Data
-(void)setIDMobile:(NSString*)mobile;
-(void)setIDDevice:(NSString*)deviceID;
-(void)setIDEmail:(NSString*)email;
-(void)setIDApp:(NSString*)appID;
- (NSString*)deviceUUID;



@end
