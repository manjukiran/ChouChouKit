//
//  SampleObjectModel.m
//  ccDataManager
//
//  Created by Manju Kiran on 08/05/14.
//  Copyright (c) 2014 goIbibo. All rights reserved.
//

#import "SampleObject.h"
#import <ChouChouKit/ChouChouKit.h>
#import <ChouChouKit/ChouChou+NSDictionary.h>

@implementation SampleObject


-(NSString*) name{
    return self.contentData[@"title"];
}

/** 
 Override docname property to refer to type of document being accessed
 */

-(NSString*) docName{
    return @"sampleobjecttype";
}

-(NSString*) contenttype{
    if(self.data[@"contenttype"] && [(NSString*)self.data[@"contenttype"] length]){
        return self.data[@"contenttype"];
    }
    return self.docName;
}

-(void) setContenttype:(NSString *)contenttype{
    [self.data setObjectNilHandled:contenttype forKey:@"contenttype"];
}


+(SampleObject*) createSampleObjectForPostWithProperties :(NSDictionary*)propertyDict
                                                 onError:(void(^)(ChouChouError*))onError{

    SampleObject *clForPost = [[SampleObject alloc] initWithDictionary:propertyDict];
    return clForPost;
    
}


+(void) getAllObjectsFromServerForProperties:(NSDictionary *)propDict storeLocally:(BOOL)storeLocally onError:(void (^)(ChouChouError *))onError onSuccess:(void (^)(NSArray *))onSuccess{

    [[SampleObject new] getAllObjectsForProperties:propDict storeLocally:storeLocally onError:onError offlineData:nil onSuccess:onSuccess];
}

-(void) updateSampleObjectWithArray :(NSDictionary*)propertyDict shouldSyncWithServer:(BOOL)shouldSyncWithServer storeLocally :(BOOL) storeLocally onError:(void (^) (ChouChouError*))onError  onSuccess:(void (^) (NSDictionary*))onSuccess {

    self.data = nil;
    self.data = [[NSMutableDictionary alloc] initWithDictionary:propertyDict];
    
    if(shouldSyncWithServer){
        [self submitResourceWithSyncDict:propertyDict storeLocally:storeLocally onError:onError onSuccess:onSuccess];
    }
    
}

-(void) postSampleObjectToServer:(SampleObject*)sampleObject storeLocally:(BOOL)storeLocally
                      onError:(void(^)(ChouChouError*))onError
                    onSuccess:(void(^)(NSDictionary*))onSuccess{

    [self submitResourceWithSyncDict:sampleObject.data storeLocally:storeLocally onError:onError onSuccess:onSuccess];
    
}

-(void) updateSampleObjectFromServer:(SampleObject*)sampleObject storeLocally:(BOOL)storeLocally
                          onError:(void(^)(ChouChouError*))onError
                        onSuccess:(void(^)(NSDictionary*))onSuccess{
    
    [self getResourcewithSyncDict:[self syncUniqueKeysDictionary] storeLocally:storeLocally onError:onError dataOffline:nil dataOnline:onSuccess];
    
}

-(void) putSampleObjectUpdatesToServer:(SampleObject*)sampleObject storeLocally:(BOOL)storeLocally
                            onError:(void(^)(ChouChouError*))onError
                          onSuccess:(void(^)(NSDictionary*))onSuccess{
    
    [self submitResourceWithSyncDict:[self syncUniqueKeysDictionary] storeLocally:storeLocally onError:onError onSuccess:onSuccess];
}

-(void) deleteSampleObjectFromServer:(SampleObject*)sampleObject storeLocally:(BOOL)storeLocally
                          onError:(void(^)(ChouChouError*))onError
                        onSuccess:(void(^)(BOOL))onSuccess{
    
    [self deleteResourceByID:self.contentData[@"id"] onError:onError onSuccess:onSuccess];
}

//General Merge Logic
-(NSMutableDictionary*) getLatestContentMergedDict:(NSMutableDictionary*)locDict remDict:(NSMutableDictionary*)remDict {
    
    NSMutableDictionary *mergedDict = [[NSMutableDictionary alloc] initWithDictionary:locDict];
    
    NSDateFormatter *dictDateComparer = [[NSDateFormatter alloc] init];
    [dictDateComparer setDateFormat:@"yyyyMMddHHmmss"];
    NSString *locTimeString = [mergedDict lastUpdatedTimeStampChouChou];
    NSString *remTimeString = [remDict lastUpdatedTimeStampChouChou];
    
    if([[dictDateComparer dateFromString:locTimeString] compare:[dictDateComparer dateFromString:remTimeString]] == NSOrderedAscending){
        return remDict;
    }else if([[dictDateComparer dateFromString:locTimeString] compare:[dictDateComparer dateFromString:remTimeString]] == NSOrderedDescending){
        [mergedDict setObject:@"PUT" forKey:@"changeType"];
        return mergedDict;
    }else{
        return mergedDict;
    }
}

//Overriding method for getting custom identifier objects for posting in server
-(NSDictionary*) syncUniqueKeysDictionary{

    NSMutableDictionary *mutDict = [self.data mutableCopy];
    for(NSString *key in mutDict.allKeys){
        if(![key isEqualToString:@"id"] && ![key isEqualToString:@"id_goibibo"] && ![key isEqualToString:@"contenttype"]){
            [mutDict removeObjectForKey:key];
        }
    }
    
    return mutDict;
}


@end
