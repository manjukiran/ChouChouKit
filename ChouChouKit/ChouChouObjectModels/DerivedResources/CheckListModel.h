//
//  CheckListModel.h
//  ccDataManager
//
//  Created by Manju Kiran on 08/05/14.
//  Copyright (c) 2014 goIbibo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CouchbaseLite/CouchbaseLite.h>
#import "ChouChouReservedObject.h"

@interface CheckListModel : ChouChouReservedObject

@property (nonatomic,strong)  NSString              *contenttype;
@property (nonatomic, strong) NSArray               *data;

// Reserved Objects

@property (nonatomic, strong) NSString *id_goibibo;
@property (nonatomic, strong) NSString *id_voyager;
@property (nonatomic, strong) NSString *id_email;
@property (nonatomic, strong) NSString *id_and;
@property (nonatomic, strong) NSString *id_ios;
@property (nonatomic, strong) NSString *id_winph;
@property (nonatomic, strong) NSString *remID;


/** Updates the "data" array in checklist dictionary with the array of objects being passed 
 should sync with server: will call a PUT request on the chouchou shared instance's server
 Block : onError and onSuccess
 */

-(void) updateCheckListWithArray :(NSArray*)checkListArray
             shouldSyncWithServer:(BOOL)shouldSyncWithServer
                    storeLocally :(BOOL) storeLocally
                          onError:(void (^) (NSDictionary*))onError
                        onSuccess:(void (^) (NSDictionary*))onSuccess;


/** Creates a checklist object with properties from the dictionary passed into method.
    MUST HAVE in dictionary  {@"id_goibibo" : <PAYMENT ID>}
                            {@"id_voyager" : <VOYAGER ID >}
                            {@"id_email"   : <USER EMAIL ID>}
 */
+(CheckListModel*) createCheckListForPostWithProperties :(NSDictionary*)propertyDict
                                                 onError:(void(^)(NSDictionary*))onError;

-(void) postCheckListToServer:(CheckListModel*)checklistObject storeLocally:(BOOL)storeLocally
                      onError:(void(^)(NSDictionary*))onError
                    onSuccess:(void(^)(NSDictionary*))onSuccess;

-(void) updateCheckListFromServer:(CheckListModel*)checklistObject storeLocally:(BOOL)storeLocally
                          onError:(void(^)(NSDictionary*))onError
                    onSuccess:(void(^)(NSDictionary*))onSuccess;

-(void) putCheckListUpdatesToServer:(CheckListModel*)checklistObject storeLocally:(BOOL)storeLocally
                            onError:(void(^)(NSDictionary*))onError
                          onSuccess:(void(^)(NSDictionary*))onSuccess;

-(void) deleteCheckListFromServer:(CheckListModel*)checklistObject storeLocally:(BOOL)storeLocally
                            onError:(void(^)(NSDictionary*))onError
                          onSuccess:(void(^)(BOOL))onSuccess;



@end




/*
@interface CheckListModel : CBLModel

@property (nonatomic, strong) NSString              *id_goibibo;
@property (nonatomic, strong) NSString              *id_voyager;
@property (nonatomic, strong) NSString              *id_email;
@property (nonatomic, strong) NSString              *id_and;
@property (nonatomic, strong) NSString              *id_ios;
@property (nonatomic, strong) NSString              *id_winph;

@end
 */
