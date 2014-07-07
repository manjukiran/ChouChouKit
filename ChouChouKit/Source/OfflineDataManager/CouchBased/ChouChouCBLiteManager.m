//
//  ChouChouCBLiteManager.m
//  ChouChouKit
//
//  Created by R Manju Kiran on 15/05/14.
//  Copyright (c) 2014 ibibo Web Pvt. Ltd. All rights reserved.
//

#import "ChouChouCBLiteManager.h"
#import <ChouChouKit/ChouChou+NSDictionary.h>

@implementation ChouChouCBLiteManager

- (id)init
{
    self = [super init];
    if (self) {
        self.dataManager = [[CBLManager alloc] init];
        if(self.dataManager){
         [self initiateDatabaseAndMapViews:^(NSError *error) {
             NSLog(@"Could Not initiate database \nError:%@", [error localizedDescription]);
         } onSuccess:^(BOOL success) {
             
         }];
        }
    }
    return self;
}

-(CBLDatabase*) currentLocalDatabase{
    if(self.localDatabase){
        return self.localDatabase;
    }else{
        NSError *error =nil;
        self.localDatabase = [_dataManager databaseNamed:localDatabaseName error:&error];
        if(self.localDatabase){
            [[self.localDatabase viewNamed: @"_id"] setMapBlock: MAPBLOCK({
                id idKey = doc[@"_id"];
                if (idKey)
                    emit(CBLTextKey(idKey), doc);
            }) reduceBlock: nil version: [NSString stringWithFormat:@"%f",1.0]];
        }
        return self.localDatabase;
    }
}

-(void) initiateDatabaseAndMapViews :(void (^)(NSError*))onError onSuccess:(void (^)(BOOL))onSuccess{
    NSError *error =nil;
    self.localDatabase = [_dataManager databaseNamed:localDatabaseName error:&error];
    if(self.localDatabase){
        [[self.localDatabase viewNamed: @"_id"] setMapBlock: MAPBLOCK({
            id idKey = doc[@"_id"];
            if (idKey)
                emit(CBLTextKey(idKey), doc);
        }) reduceBlock: nil version: [NSString stringWithFormat:@"%f",1.0]];
        
        CBLQuery *query = [[self.localDatabase viewNamed:@"_id"] createQuery];
        NSError *getError=nil;
        
        for (CBLQueryRow* row in [query run:&getError]) {
            NSLog(@"%@",row.document.properties);
        }
        if(onSuccess){
        onSuccess(YES);
        }
    }else{
        if(onError){
        onError(error);
        }
    }
}

-(void) createDocWithData : (NSString*)docName withProperties:(NSDictionary*)propertiesDict onError:(void (^)(ChouChouError*))onError onSuccess:(void (^)(NSDictionary*))onSuccess{
    
    NSMutableDictionary *dataDictionary = [[NSMutableDictionary alloc] initWithDictionary:propertiesDict];
    if([docName isEqualToString:@"checklist"]){
        [dataDictionary setObjectNilHandled:docName forKey:@"contenttype"];
    }
    CBLDocument *doc = [self.localDatabase createDocument];
    NSError *putError=nil;
    if(![doc putProperties:dataDictionary error:&putError]){
        if(onError){
        onError([ChouChouError chouchouErrorWithCouchBaseError:putError]);
        }
    }else{
        if(onSuccess){
        onSuccess(dataDictionary);
        }
    }
}

-(void) getDocWithData :(NSString*)docName withProperties:(NSDictionary*)propertiesDict onError:(void (^)(ChouChouError*))onError onSuccess:(void (^)(NSArray*))onSuccess{

    NSMutableArray *dataArray = [[NSMutableArray alloc] init];
    CBLQuery *query = [[self.localDatabase viewNamed:@"_id"] createQuery];
    NSError *getError=nil;
    
    for (CBLQueryRow* row in [query run:&getError]) {
        NSMutableDictionary* rowDict = [[NSMutableDictionary alloc] initWithDictionary:row.document.properties];
        if([rowDict[@"contenttype"] isEqualToString:propertiesDict[@"contenttype"]]){
            BOOL exactMatchFound = [self doDictionariesMatch:propertiesDict  destDict:rowDict];
            if(exactMatchFound){
                [rowDict removeObjectsForKeys:@[@"_id",@"_rev"]];
                [dataArray addObject:rowDict];
            }
        }
    }
    if(dataArray.count >0){
                if(onSuccess){
        onSuccess(dataArray);
                }
    }else{
        NSError *locError = [[NSError alloc] initWithDomain:@"Database Error" code:404 userInfo:@{@"message": @"No matching data found locally"}];
        if(onError){
        onError([ChouChouError chouchouErrorWithCouchBaseError:locError]);
        }
    }
}



-(void) updateDocWithData : (NSString*)docName idDictionary:(NSDictionary*)idDict withProperties:(NSDictionary*)propertiesDict onError:(void (^)(ChouChouError*))onError onSuccess:(void (^)(NSDictionary*))onSuccess{
    
    BOOL exactMatchFound=NO;
    CBLQuery *query = [[self.localDatabase viewNamed:@"_id"] createQuery];
    NSError *getError=nil;
    for (CBLQueryRow* row in [query run:&getError]) {
        NSDictionary* rowDict = [[NSDictionary alloc] initWithDictionary:row.document.properties];
        if([rowDict[@"contenttype"] isEqualToString:docName]){
            exactMatchFound = [self doDictionariesMatch:idDict  destDict:rowDict];
            if(exactMatchFound){
                CBLDocument *doc = [self.localDatabase documentWithID:rowDict[@"_id"]];
                NSMutableDictionary *editedDict = [[NSMutableDictionary alloc] initWithDictionary:rowDict];
                for( NSString*key in propertiesDict.allKeys){
                    [editedDict setObjectNilHandled:propertiesDict[key] forKey:key];
                }
                NSString *docID = rowDict[@"_id"];
                [editedDict removeObjectsForKeys:@[@"_id",@"_rev"]];
                NSError *updateError=nil;;
                if(![doc putProperties:editedDict error:&updateError]){
                    [doc deleteDocument:&updateError];
                    doc = [self.localDatabase documentWithID:docID];
                    if(![doc putProperties:editedDict error:&updateError]){
                        if(onError){
                        onError([ChouChouError chouchouErrorWithCouchBaseError:updateError]);
                        }
                    }
                }
                if(onSuccess){
                    onSuccess(rowDict);
                }
                break;
            }
        }
    }
    if(!exactMatchFound){
        [self createDocWithData:docName withProperties:propertiesDict onError:^(NSError * error) {
            NSError *locError = [[NSError alloc] initWithDomain:@"Database Error" code:404 userInfo:@{@"message": @"No matching data found locally"}];
            if(onError){
            onError([ChouChouError chouchouErrorWithCouchBaseError:locError]);
            }
        } onSuccess:^(NSDictionary *dataDict) {
            NSLog(@"No Original entry found in Database, creating one newly");
            if(onSuccess){
                onSuccess(dataDict);
            }
        }];
    }
}

-(void) deleteAllLocalResourcesOfType:(NSString *)resourceName{
    CBLQuery *query = [[self.localDatabase viewNamed:@"_id"] createQuery];
    NSError *getError=nil;
    for (CBLQueryRow* row in [query run:&getError]) {
        if(row.document.properties && row.document.properties[@"contenttype"]){
            if([resourceName isEqualToString:row.document.properties[@"contenttype"]]){
                [row.document deleteDocument:nil];
            }
        }
    }
}

// Utils Method
-(void) deleteDocWithIdentifier:(NSString*)docName idDictionary:(NSDictionary*)idDict onError:(void (^)(ChouChouError*))onError onSuccess:(void (^)(BOOL))onSuccess{
    
    BOOL exactMatchFound=NO;
    CBLQuery *query = [[self.localDatabase viewNamed:@"_id"] createQuery];
    NSError *getError=nil;
    for (CBLQueryRow* row in [query run:&getError]) {
        NSDictionary* rowDict = [[NSDictionary alloc] initWithDictionary:row.document.properties];
        if([rowDict[@"contenttype"] isEqualToString:docName]){
            exactMatchFound = [self doDictionariesMatch:idDict  destDict:rowDict];
            if(exactMatchFound){
                CBLDocument *doc = [self.localDatabase documentWithID:rowDict[@"_id"]];
                NSError *deleteError = nil;
                if(![doc deleteDocument:&deleteError]){
                    if(onError){
                    onError([ChouChouError chouchouErrorWithCouchBaseError:deleteError]);
                    }
                }else{
                            if(onSuccess){
                    onSuccess(YES);
                            }
                }
                break;
            }
        }
    }
    
    if(!exactMatchFound){
        NSError *locError = [[NSError alloc] initWithDomain:@"Database Error" code:404 userInfo:@{@"message": @"No matching data found locally"}];
        if(onError){
        onError([ChouChouError chouchouErrorWithCouchBaseError:locError]);
        }
    }

}

-(BOOL) doDictionariesMatch :(NSDictionary*)sourceDict destDict:(NSDictionary*)destDict{
    BOOL matchFound = YES;
    
    for(NSString *sourceKey in sourceDict.allKeys){
        if(![sourceDict[sourceKey] isKindOfClass:[destDict[sourceKey] class]]){
            
        }
        if([sourceDict[sourceKey] isKindOfClass:[NSNumber class]]){
            if(!([sourceDict[sourceKey] intValue] ==[destDict[sourceKey]intValue])){
                matchFound = NO;
            }
        }else if([sourceDict[sourceKey] isKindOfClass:[NSString class]]){
            if(![sourceDict[sourceKey] isEqualToString:destDict[sourceKey]]){
                matchFound = NO;
                break;
            }
        }
    }
    return matchFound;
}

@end
