//
//  CheckListModel.m
//  ccDataManager
//
//  Created by Manju Kiran on 08/05/14.
//  Copyright (c) 2014 goIbibo. All rights reserved.
//

#import "CheckListModel.h"
#import "ChouChouiOS.h"

@implementation CheckListModel


-(NSString*) contenttype{
    return @"checklist";
}
-(void) setContenttype:(NSString *)contenttype{
    self.contenttype = contenttype;
}

-(NSArray*) data {
    return self.contentData[@"data"];
}


-(NSString*) id_goibibo{
    return self.contentData[@"id_goibibo"];
}

-(NSString*) id_voyager{
    return self.contentData[@"id_voyager"];
}

-(NSString*) id_email{
    return self.contentData[@"id_email"];
}

-(NSString*) id_and{
    return self.contentData[@"id_and"];
}

-(NSString*) id_ios{
    return self.contentData[@"id_ios"];
}

-(NSString*) id_winph{
    return self.contentData[@"id_winph"];
}

-(NSString*) remID{
    return self.contentData[@"id"];
}


+(CheckListModel*) createCheckListForPostWithProperties :(NSDictionary*)propertyDict
                                                 onError:(void(^)(NSDictionary*))onError{
    CheckListModel *clForPost = [[CheckListModel alloc]init];
    
    if(!propertyDict[@"id_goibibo"] || !propertyDict[@"id_voyager"] || !propertyDict[@"id_email"]){
        NSDictionary*errorDict = @{@"message": @"Insufficient Data to create Review Object"};
        onError(errorDict);
        return nil;
    }
    
    NSDictionary *postDict = @{
                               @"data":propertyDict[@"data"]?propertyDict[@"data"]:@[],
                               @"id_goibibo" : propertyDict[@"id_goibibo"],
                               @"id_voyager" : propertyDict[@"id_voyager"],
                               @"id_email": propertyDict[@"id_email"],
                               @"id_ios": [[ChouChouiOS sharedInstance]deviceUUID],
                               };
    clForPost.contentData = [[NSDictionary alloc] initWithDictionary:postDict];
    return clForPost;
    
}

-(void) updateCheckListWithArray :(NSArray*)checkListArray shouldSyncWithServer:(BOOL)shouldSyncWithServer storeLocally :(BOOL) storeLocally onError:(void (^) (NSDictionary*))onError  onSuccess:(void (^) (NSDictionary*))onSuccess {
    self.data = nil;
    self.data = [[NSArray alloc] initWithArray:checkListArray];
    
    if(shouldSyncWithServer){
        [[ChouChouiOS sharedInstance] putResourceByID:self.id_goibibo resourceName:self.contenttype postDic:self .contentData storeLocally:storeLocally onError:^(NSDictionary *errorDict) {
            //
            onError(errorDict);
        } onSuccess:^(id data) {
            onSuccess((NSDictionary*) data);
        }];
    }
}

-(void) postCheckListToServer:(CheckListModel*)checklistObject storeLocally:(BOOL)storeLocally
                      onError:(void(^)(NSDictionary*))onError
                    onSuccess:(void(^)(NSDictionary*))onSuccess{

    [[ChouChouiOS sharedInstance] postResource:checklistObject.contenttype postDic:checklistObject.contentData storeLocally:storeLocally onError:^(NSDictionary *errorDict) {
        onError(errorDict);
    } onSuccess:^(NSDictionary *postedDict) {
        onSuccess(postedDict);
    }];
}

-(void) updateCheckListFromServer:(CheckListModel*)checklistObject storeLocally:(BOOL)storeLocally
                          onError:(void(^)(NSDictionary*))onError
                        onSuccess:(void(^)(NSDictionary*))onSuccess{
    
    NSMutableDictionary *mutDict = [checklistObject.contentData mutableCopy];
    for(NSString *key in mutDict.allKeys){
        if(![key isEqualToString:@"id"] && ![key isEqualToString:@"id_goibibo"] && ![key isEqualToString:@"contenttype"]){
            [mutDict removeObjectForKey:key];
        }
    }
    
    [[ChouChouiOS sharedInstance] getResourceByID:checklistObject.contenttype withProperties:mutDict storeLocally:storeLocally onError:^(NSDictionary *errorDict) {
        onError(errorDict);
    } dataOffline:^(NSDictionary *onlineData) {
        //
    } dataOnline:^(NSDictionary *onlineData) {
        onSuccess(onlineData);
    }];
    
}

-(void) putCheckListUpdatesToServer:(CheckListModel*)checklistObject storeLocally:(BOOL)storeLocally
                            onError:(void(^)(NSDictionary*))onError
                          onSuccess:(void(^)(NSDictionary*))onSuccess{
    
    NSMutableDictionary *mutDict = [checklistObject.contentData mutableCopy];
    for(NSString *key in mutDict.allKeys){
        if(![key isEqualToString:@"id"] && ![key isEqualToString:@"id_goibibo"] && ![key isEqualToString:@"contenttype"]){
            [mutDict removeObjectForKey:key];
        }
    }
    NSString *identifierType = checklistObject.contentData[@"id"]?@"id":checklistObject.contentData[@"id_goibibo"];

    [[ChouChouiOS sharedInstance] putResourceByID:identifierType resourceName:checklistObject.contenttype postDic:checklistObject.contentData storeLocally:storeLocally onError:^(NSDictionary *errorDict) {
        onError(errorDict);
    } onSuccess:^(NSDictionary *postedDict) {
        onSuccess(postedDict);
    }];
    
}

-(void) deleteCheckListFromServer:(CheckListModel*)checklistObject storeLocally:(BOOL)storeLocally
                          onError:(void(^)(NSDictionary*))onError
                        onSuccess:(void(^)(BOOL))onSuccess{
    
    NSMutableDictionary *mutDict = [checklistObject.contentData mutableCopy];
    for(NSString *key in mutDict.allKeys){
        if(![key isEqualToString:@"id"] && ![key isEqualToString:@"id_goibibo"]){
            [mutDict removeObjectForKey:key];
        }
    }
    
    [[ChouChouiOS sharedInstance] deleteResourceByID:mutDict resourceName:checklistObject.contenttype onError:^(NSDictionary *errorDict) {
        onError(errorDict);
    } onSuccess:^(BOOL success) {
        onSuccess(success);
    }];
    
}


// Checklist Merge Logic

// Do not call super. Overridden method for custom sync logic
-(NSDictionary*) getLatestContentMergedDictWithRemoteDict:(NSDictionary*)remDict{
    NSDateFormatter *dictDateComparer = [[NSDateFormatter alloc] init];
    [dictDateComparer setDateFormat:@"yyyyMMddHHmmss"];
    NSString *keyForComparison;
    NSMutableDictionary *mergedDict = [[NSMutableDictionary alloc] initWithDictionary:self.contentData];
    NSMutableArray *clDataArray = [[mergedDict objectForKey:@"data"] mutableCopy];
    BOOL shouldPut = NO;
    
    if(!clDataArray){
        clDataArray = [NSMutableArray new];
    }
    for(NSDictionary *remCheckListItem in [remDict objectForKey:@"data"]){
        BOOL dictFound = NO;
        for (NSDictionary *locCheckListItem in clDataArray){
            NSMutableDictionary *mutableLocCheckListItem = [locCheckListItem mutableCopy];
            if([[[remCheckListItem allKeys]objectAtIndex:0]isEqualToString:[[locCheckListItem allKeys]objectAtIndex:0]]){
                dictFound = YES;
                keyForComparison = [[remCheckListItem allKeys]objectAtIndex:0];
                if([[dictDateComparer dateFromString:[locCheckListItem lastUpdatedTimeStampChouChou]] compare:[dictDateComparer dateFromString:[remCheckListItem lastUpdatedTimeStampChouChou]]] == NSOrderedAscending){
                    if([remDict lastUpdatedTimeStampChouChou]){
                        [mergedDict setObject:[remDict lastUpdatedTimeStampChouChou] forKey:@"ts"];
                    }
                    [mutableLocCheckListItem setValue:[remCheckListItem objectForKey:keyForComparison] forKey:keyForComparison];
                    [mutableLocCheckListItem setValue:[remCheckListItem lastUpdatedTimeStampChouChou] forKey:@"ts"];
                    [clDataArray replaceObjectAtIndex:[clDataArray indexOfObject:locCheckListItem] withObject:mutableLocCheckListItem];
                    break;
                }else if([[dictDateComparer dateFromString:[locCheckListItem lastUpdatedTimeStampChouChou]] compare:[dictDateComparer dateFromString:[remCheckListItem lastUpdatedTimeStampChouChou]]] == NSOrderedDescending){
                    if([self.contentData lastUpdatedTimeStampChouChou]){
                        [mergedDict setObject:[self.contentData lastUpdatedTimeStampChouChou] forKey:@"ts"];
                    }
                    [clDataArray replaceObjectAtIndex:[clDataArray indexOfObject:locCheckListItem] withObject:mutableLocCheckListItem];
                    shouldPut = YES;
                    break;
                }
                ;
            }
        }
        if(dictFound==NO){
            NSMutableArray *dataArray = [[NSMutableArray alloc] initWithArray:[mergedDict objectForKey:@"data"]];
            [dataArray addObject:remCheckListItem];
            [mergedDict setObject:dataArray forKey:@"data"];
        }
        
    }
    if(shouldPut){
        [mergedDict setObject:@"PUT" forKey:@"changeType"];
    }
    [mergedDict setObject:clDataArray forKey:@"data"];
    return mergedDict;
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


/*@dynamic data, id_goibibo, id_voyager, id_email, id_and, id_ios, id_winph;
 
 -(NSString*) contenttype{
 return @"checklist";
 }
 -(void) setContenttype:(NSString *)contenttype{
 self.contenttype = contenttype;
 }
 
 -(NSString*) remID{
 return [[self document].properties objectForKey:@"id"];
 }
 
 -(void) setRemID:(NSString *)remID{
 self.remID = [[self document].properties objectForKey:@"id"];
 }
 
 */



@end
