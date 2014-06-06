//
//  ChouChouOfflineManager.m
//  ChouChouKit
//
//  Created by Manju Kiran on 15/05/14.
//  Copyright (c) 2014 goIbibo. All rights reserved.
//

#import "ChouChouOfflineManager.h"

@implementation ChouChouOfflineManager

-(void) createDocWithData : (NSString*)docName withProperties:(NSDictionary*)propertiesDict
                   onError:(void (^)(ChouChouError*))onError
                 onSuccess:(void (^)(NSDictionary*))onSuccess{
    
}

-(void) getDocWithData :(NSString*) docName withProperties:(NSDictionary*)propertiesDict
                onError:(void (^)(ChouChouError*))onError
              onSuccess:(void (^)(NSArray*))onSuccess{
    
}

-(void) updateDocWithData : (NSString*)docName idDictionary:(NSDictionary*)idDict
            withProperties:(NSDictionary*)propertiesDict
                   onError:(void (^)(ChouChouError*))onError
                 onSuccess:(void (^)(NSDictionary*))onSuccess{
    
}

-(void) deleteDocWithIdentifier:(NSString*)docName idDictionary:(NSDictionary*)idDict
                        onError:(void (^)(ChouChouError*))onError
                      onSuccess:(void (^)(BOOL))onSuccess{
    
}

-(void) deleteAllLocalResourcesOfType:(NSString *)resourceName{
    
}
@end
