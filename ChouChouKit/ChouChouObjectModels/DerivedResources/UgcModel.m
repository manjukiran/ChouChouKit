//
//  UgcModel.m
//  ChouChouExample
//
//  Created by Sourabh Verma on 14/05/14.
//  Copyright (c) 2014 ibibo group. All rights reserved.
//

#import "UgcModel.h"

@implementation UgcModel

@synthesize  contenttype, content,entitytype,entityname,entityid, parentid, location,ownerid,ownername,source,timestamp;


-(NSString*) contenttype{
    return self.contentData[@"contenttype"];
}

-(NSString*) entitytype{
    return self.contentData[@"entitytype"];
}

-(NSString*) entityid{
    return self.contentData[@"entityid"];
}

-(NSString*) entityname{
    return self.contentData[@"entityname"];
}

-(NSString*) parentid{
    return self.contentData[@"parentid"];
}

-(NSString*) location{
    return self.contentData[@"location"];
}

-(NSString*) ownerid{
    return self.contentData[@"ownerid"];
}

-(NSString*) ownername{
    return self.contentData[@"ownername"];
}

-(NSString*) source{
    return self.contentData[@"source"];
}

-(NSString*) timestamp{
    return self.contentData[@"timestamp"];
}


-(void) postUGCToServer:(UgcModel*)ugcObject storeLocally:(BOOL)storeLocally
                onError:(void(^)(NSDictionary*))onError
              onSuccess:(void(^)(NSDictionary*))onSuccess{
    
    [[ChouChouiOS sharedInstance] postResource:@"ugc" postDic:ugcObject.contentData storeLocally:storeLocally onError:^(NSDictionary *errorDict) {
        onError(errorDict);
    } onSuccess:^(NSDictionary *postedDict) {
        onSuccess(postedDict);
    }];
}

-(void) updateUGCFromServer:(UgcModel*)ugcObject storeLocally:(BOOL)storeLocally
                    onError:(void(^)(NSDictionary*))onError
                    offlineData: (void(^)(NSDictionary*))offlineData
                  onSuccess:(void(^)(NSDictionary*))onSuccess{
    
    NSMutableDictionary *mutDict = [ugcObject.contentData mutableCopy];
    for(NSString *key in mutDict.allKeys){
        if(![key isEqualToString:@"id"] && ![key isEqualToString:@"entityid"] && ![key isEqualToString:@"contenttype"] &&![key isEqualToString:@"ownerid"]){
            [mutDict removeObjectForKey:key];
        }
    }
    
    [[ChouChouiOS sharedInstance] getResourceByID:@"ugc" withProperties:mutDict storeLocally:storeLocally onError:^(NSDictionary *errorDict) {
        onError(errorDict);
    } dataOffline:^(NSDictionary *offData) {
            offlineData(offData);
    } dataOnline:^(NSDictionary *onlineData) {
        onSuccess(onlineData);
    }];
    
}

-(void) putUGCUpdatesToServer:(UgcModel *)ugcObject storeLocally:(BOOL)storeLocally onError:(void (^)(NSDictionary *))onError onSuccess:(void (^)(NSDictionary *))onSuccess{
    
    NSMutableDictionary *mutDict = [ugcObject.contentData mutableCopy];
    for(NSString *key in mutDict.allKeys){
        if(![key isEqualToString:@"id"] && ![key isEqualToString:@"entityid"] && ![key isEqualToString:@"contenttype"] &&![key isEqualToString:@"ownerid"]){
            [mutDict removeObjectForKey:key];
        }
    }
    if(!ugcObject.contentData[@"id"]){
        NSDictionary *errorDic = @{@"message": @"Insuficient Data to post updates, please check if the object has been originally posted to the server, else post the data, obtain ID and assign the same to UGC object"};
        onError(errorDic);
        return;
    }

    NSString *identifierType = ugcObject.contentData[@"id"];
    [[ChouChouiOS sharedInstance] putResourceByID:identifierType resourceName:@"ugc" postDic:ugcObject.contentData storeLocally:storeLocally onError:^(NSDictionary *errorDict) {
        onError(errorDict);
    } onSuccess:^(NSDictionary *postedDict) {
        onSuccess(postedDict);
    }];
    
}

-(void) deleteUGCFromServer:(UgcModel *)ugcObject storeLocally:(BOOL)storeLocally onError:(void (^)(NSDictionary *))onError onSuccess:(void (^)(BOOL))onSuccess{
    
    NSMutableDictionary *mutDict = [ugcObject.contentData mutableCopy];
    for(NSString *key in mutDict.allKeys){
        if(![key isEqualToString:@"id"] && ![key isEqualToString:@"entityid"] && ![key isEqualToString:@"contenttype"] &&![key isEqualToString:@"ownerid"]){
            [mutDict removeObjectForKey:key];
        }
    }
    
    [[ChouChouiOS sharedInstance] deleteResourceByID:mutDict resourceName:@"ugc" onError:^(NSDictionary *errorDict) {
        onError(errorDict);
    } onSuccess:^(BOOL success) {
        onSuccess(success);
    }];
    
}


@end
