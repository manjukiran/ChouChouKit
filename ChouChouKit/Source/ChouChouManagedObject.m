//
//  ChouChouManagedObject.m
//  ChouChouKit
//
//  Created by R Manju Kiran on 14/05/14.
//  Copyright (c) 2014 goIbibo. All rights reserved.
//

#import "ChouChouManagedObject.h"
#import "ChouChouKit.h"
#import "ChouChouKitPrivate.h"
#import "ChouChou+NSDictionary.h"

@implementation NSDictionary (ChouChouManagedObject)

-(NSString*)lastUpdatedTimeStampChouChou{
    NSString *timeStamp = [self objectForKey:@"ts"];
    
    if(timeStamp == nil){
        timeStamp = [self objectForKey:@"timestamp"];
    }
    return timeStamp;
}

@end

@implementation ChouChouManagedObject

- (id)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self) {
        if([dictionary isKindOfClass:[NSArray class]] && ([(NSArray*)dictionary count]>0)){
            self.contentData = [[NSMutableDictionary alloc] initWithDictionary:[self getMutableDictionaryForDict:[(NSArray*)dictionary objectAtIndex:0]]];
        }else if ([dictionary isKindOfClass:[NSDictionary class]]){
            self.contentData = [[NSMutableDictionary alloc] initWithDictionary:[self getMutableDictionaryForDict:dictionary]];
        }
    }
    return self;
}

/**
 It changes all dictionaries inside to mutable
 **/

-(NSMutableDictionary*) getMutableDictionaryForDict:(NSDictionary*) dictionary{
    
    @try {
        //Sanity check
        if (!dictionary || ![dictionary isKindOfClass:[NSDictionary class]]) {
            return [NSMutableDictionary dictionary];
        }
        
        //Convert to mutable
        NSMutableDictionary *mutableDic = [NSMutableDictionary dictionary];
        for (NSString *key in [dictionary allKeys]) {
            id dicObj = [dictionary objectForKey:key];
            if([dicObj isKindOfClass:[NSDictionary class]]){
                [mutableDic setObjectNilHandled:[self getMutableDictionaryForDict:dicObj] forKey:key];
            }
            else if([dicObj isKindOfClass:[NSArray class]]){
                [mutableDic setObjectNilHandled:[dicObj mutableCopy] forKey:key];
            }
            else{
                [mutableDic setObjectNilHandled:dicObj forKey:key];
            }
        }
        
        return mutableDic;
    }
    @catch (NSException *exception) {
        return [NSMutableDictionary dictionaryWithDictionary:dictionary];
    }
    
    /*
     
     NSMutableDictionary *reviewDictionary = [[NSMutableDictionary alloc] init];
     [reviewDictionary addEntriesFromDictionary:dictionary];
     if(reviewDictionary[@"content"]){
     NSMutableDictionary *sourceContentDict = [[NSMutableDictionary alloc]initWithDictionary:reviewDictionary[@"content"]];
     NSMutableDictionary *destContentDict = [[NSMutableDictionary alloc] init];
     
     for (NSString *key in sourceContentDict.allKeys){
     id contentData = sourceContentDict[key];
     if(![contentData isKindOfClass:[NSDictionary class]]){
     [destContentDict setObjectNilHandled:contentData forKey:key];
     }else{
     NSMutableDictionary *mutDict = [(NSDictionary*)contentData mutableCopy];
     [destContentDict setObjectNilHandled:mutDict forKey:key];
     }
     }
     [reviewDictionary setObjectNilHandled:destContentDict forKey:@"content"];
     }
     if(reviewDictionary[@"data"]){
     NSMutableDictionary *sourceContentDict = [[NSMutableDictionary alloc]initWithDictionary:reviewDictionary[@"data"]];
     NSMutableDictionary *destContentDict = [[NSMutableDictionary alloc] init];
     
     for (NSString *key in sourceContentDict.allKeys){
     id contentData = sourceContentDict[key];
     if(![contentData isKindOfClass:[NSDictionary class]]){
     [destContentDict setObjectNilHandled:contentData forKey:key];
     }else{
     NSMutableDictionary *mutDict = [(NSDictionary*)contentData mutableCopy];
     [destContentDict setObjectNilHandled:mutDict forKey:key];
     }
     }
     [reviewDictionary setObjectNilHandled:destContentDict forKey:@"data"];
     }
     
     return reviewDictionary;
     */
}

-(NSString*)docName{
    if ([self.contentData objectForKey:@"contenttype"] && [(NSString*)[self.contentData objectForKey:@"contenttype"] length]){
    return [self.contentData objectForKey:@"contenttype"];
    }else{
        return @"";
    }
}

-(void)syncMe:(BOOL)storeLocally onError:(void (^)(ChouChouError*))onError onSuccess:(void (^)())onSuccess{
    if(!self.uniqueIDKey.length){
        NSLog(@"Cant sync without unique ID key");
        onError(nil);
        return;
    }
    
    if(!self.uniqueID.length){
        NSLog(@"Cant sync without unique ID");
        onError(nil);
        return;
    }
    
    if(!self.docName.length){
        NSLog(@"Document name is needed");
        onError(nil);
        return;
    }
    
    [[ChouChouKit sharedInstance] submitResourceWithType:self.docName withProperties:self.contentData getIDDic:[self syncUniqueKeysDictionary] storeLocally:storeLocally onError:^(ChouChouError *error) {
        if(onError){
            onError(error);
        }
    } onSuccess:^(NSDictionary* onlineData) {
        if(onSuccess){
            onSuccess(onlineData);
        }
    }];
}

-(NSDateFormatter*)syncDateFormatter{
    NSDateFormatter *dictDateComparer = [[NSDateFormatter alloc] init];
    [dictDateComparer setDateFormat:@"yyyyMMddHHmmss"];
    return dictDateComparer;
}

//General Merge Logic
//To have your own sync logic override this method
-(NSDictionary*) getLatestContentMergedDictWithRemoteDict:(NSDictionary*)remDict{
    if(!self.contentData){
        NSLog(@"No Data set. Error in getLatestContentMergedDictWithRemoteDict");
        return nil;
    }
    
    NSMutableDictionary *mergedDict = [[NSMutableDictionary alloc] initWithDictionary:self.contentData];
    NSDateFormatter *syncDf = [self syncDateFormatter];
    
    NSString *locTimeString = [mergedDict lastUpdatedTimeStampChouChou];
    NSString *remTimeString = [remDict lastUpdatedTimeStampChouChou];
    
    if([[syncDf dateFromString:locTimeString] compare:[syncDf dateFromString:remTimeString]] == NSOrderedAscending){
        return remDict;
    }
    else if([[syncDf dateFromString:locTimeString] compare:[syncDf dateFromString:remTimeString]] == NSOrderedDescending){
        [mergedDict setObjectNilHandled:@"PUT" forKey:@"changeType"];
        return mergedDict;
    }
    else{
        return mergedDict;
    }
}


#pragma mark - Easy access methods

-(NSDate*)lastUpdatedDate{
    return [NSDate dateWithTimeIntervalSince1970:[[self.contentData lastUpdatedTimeStampChouChou] integerValue]];
}


/**
 Method: submitResource
 Usage: Exposed method which handles syncing data with server. It calls getResource followed by putResource or postResource to sync the data
 **/

-(NSDictionary*)syncUniqueKeysDictionary{
    NSMutableDictionary *mutDict = [self.contentData mutableCopy];
    for(NSString *key in mutDict.allKeys){
        if (![key isEqualToString:@"id"] && ![key hasPrefix:@"id_"]) {
            [mutDict removeObjectForKey:key];
        }
    }
    return mutDict;
}


-(void) getAllObjectsForProperties:(NSDictionary*) propertiesDict
                      storeLocally:(BOOL)storeLocally
                           onError:(void(^)(ChouChouError*))onError
                       offlineData: (void(^)(NSDictionary*))offlineData
                         onSuccess:(void(^)(NSArray*))onSuccess{
    
    [self getResourcewithSyncDict:propertiesDict storeLocally:storeLocally onError:onError dataOffline:offlineData dataOnline:^(id onlineData) {
        if([onlineData isKindOfClass:[NSArray class]]){
                    if(onSuccess){
            onSuccess(onlineData);
                    }
        }else if([onlineData isKindOfClass:[NSDictionary class]]){
                    if(onSuccess){
            onSuccess([NSArray arrayWithObject:onlineData]);
                    }
        }
    }];
}


-(void)getResourcewithSyncDict:(NSDictionary*)syncDict
                  storeLocally:(BOOL)storeLocally
                       onError:(void (^)(ChouChouError*))onError
                   dataOffline:(void (^)(id))dataOffline
                    dataOnline:(void (^)(id))dataOnline{
    
    if(self.docName.length){
        [[ChouChouKit sharedInstance] getResourceByID:self.docName withProperties:syncDict storeLocally:storeLocally onError:onError dataOffline:dataOffline dataOnline:dataOnline];
    }
    else{
        if (onError) {
            onError([ChouChouError chouchouErrorForNoResourceName]);
        }
    }
}



-(void)deleteResourceByID:(NSDictionary*)propertiesDic
                  onError:(void (^)(ChouChouError*))onError
                onSuccess:(void (^)(BOOL))onSuccess{
    if(self.docName.length){
        [[ChouChouKit sharedInstance] deleteResourceByID:propertiesDic resourceName:self.docName onError:onError onSuccess:onSuccess];
    }
    else{
        if (onError) {
            onError([ChouChouError chouchouErrorForNoResourceName]);
        }
    }
}

-(void)locallyUpdateResourcewithSyncDict:(NSDictionary*)syncDict
                            storeLocally:(BOOL)storeLocally
                                 onError:(void (^)(ChouChouError *))onError
                               onSuccess:(void (^)(id))onSuccess{
    
    if(self.docName.length){
        [[ChouChouKit sharedInstance] locallyUpdateResourceByID:self.docName idDict:syncDict updateDict:self.contentData onError:onError onSuccess:onSuccess];
    }
    else{
        if (onError) {
            onError([ChouChouError chouchouErrorForNoResourceName]);
        }
    }
}


-(void) submitResourceWithSyncDict:(NSDictionary*)syncDict
                      storeLocally:(BOOL)storeLocally
                           onError:(void (^)(ChouChouError *))onError
                         onSuccess:(void (^)(id))onSuccess{
    
    if(self.docName.length){
        [[ChouChouKit sharedInstance] submitResourceWithType:self.docName withProperties:self.contentData getIDDic:syncDict storeLocally:storeLocally onError:onError onSuccess:^(id data) {
            if([data isKindOfClass:[NSDictionary class]]){
                if(onSuccess){
                    onSuccess(data);
                }
            }else{
                if(onSuccess){
                    onSuccess((NSDictionary*) [(NSArray*)data objectAtIndex:0]);
                }
            }
        }];
    }
    else{
        if (onError) {
            onError([ChouChouError chouchouErrorForNoResourceName]);
        }
    }
}

+(void) clearAllObjectsOfMyResourceType :(ChouChouManagedObject*)object {
    [[ChouChouKit sharedInstance] deleteAllLocalResourcesOfType:object.docName];
}

@end
