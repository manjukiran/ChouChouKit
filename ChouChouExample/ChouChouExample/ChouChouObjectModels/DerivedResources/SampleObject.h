//
//  SampleObjectModel.h
//  ccDataManager
//
//  Created by Manju Kiran on 08/05/14.
//  Copyright (c) 2014 goIbibo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CouchbaseLite/CouchbaseLite.h>
#import <ChouCHouKit/ChouChouManagedObject.h>

@interface SampleObject : ChouChouManagedObject

@property (nonatomic,strong)  NSString              *name;
@property (nonatomic,strong)  NSString              *contenttype;
@property (nonatomic,strong)  NSDate                *timestamp;
@property (nonatomic, strong) NSMutableDictionary   *data;


/** Updates the "data" array in SampleObject dictionary with the array of objects being passed 
 should sync with server: will call a PUT request on the chouchou shared instance's server
 Block : onError and onSuccess
 */

-(void) updateSampleObjectWithArray :(NSArray*)SampleObjectArray
             shouldSyncWithServer:(BOOL)shouldSyncWithServer
                    storeLocally :(BOOL) storeLocally
                          onError:(void (^) (ChouChouError*))onError
                        onSuccess:(void (^) (NSDictionary*))onSuccess;


+(void) getAllObjectsFromServerForProperties :(NSDictionary*)propDict storeLocally:(BOOL)storeLocally
                                      onError:(void(^)(ChouChouError*))onError
                                    onSuccess:(void(^)(NSArray*))onSuccess;

+(SampleObject*) createSampleObjectForPostWithProperties :(NSDictionary*)propertyDict
                                                 onError:(void(^)(ChouChouError*))onError;

-(void) postSampleObjectToServer:(SampleObject*)sampleObject storeLocally:(BOOL)storeLocally
                      onError:(void(^)(ChouChouError*))onError
                    onSuccess:(void(^)(NSDictionary*))onSuccess;

-(void) updateSampleObjectFromServer:(SampleObject*)sampleObject storeLocally:(BOOL)storeLocally
                          onError:(void(^)(ChouChouError*))onError
                    onSuccess:(void(^)(NSDictionary*))onSuccess;

-(void) putSampleObjectUpdatesToServer:(SampleObject*)sampleObject storeLocally:(BOOL)storeLocally
                            onError:(void(^)(ChouChouError*))onError
                          onSuccess:(void(^)(NSDictionary*))onSuccess;

-(void) deleteSampleObjectFromServer:(SampleObject*)sampleObject storeLocally:(BOOL)storeLocally
                            onError:(void(^)(ChouChouError*))onError
                          onSuccess:(void(^)(BOOL))onSuccess;



@end



