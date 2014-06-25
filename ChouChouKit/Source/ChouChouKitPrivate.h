//
//  ChouChouKitPrivate.h
//  ChouChouLite_iOS
//
//  Created by R Manju Kiran on 08/05/14.
//  Copyright (c) 2014 goIbibo. All rights reserved.
//

#ifndef ChouChouLite_iOS_ChouChouKitPrivate_h
#define ChouChouLite_iOS_ChouChouKitPrivate_h


@interface ChouChouKit (chouchouprivate)
{
    
}

// Should have been in private chouchouprivate file

//+(ChouChouKit*)sharedInstance;

@property (nonatomic, copy) NSString *idMobile;
@property (nonatomic, copy) NSString *idDevice;
@property (nonatomic, copy) NSString *idEmail;
//
@property (nonatomic, strong) NSString *serverUrl;
@property (nonatomic, strong) NSString *idKey;
@property (nonatomic, strong) NSString *idApp;
@property (nonatomic, readwrite) ChouChouDebug debugLevel;


//Fetch Resources

/**
 Creates a generic @b PULL request for the resource from the REMOTE server
 
 @param  resourceName   : name / type of resource
 @param  storeLocally   : Set whether to locally store the remote data
 @param  onError        : when an error is encountered : @b passes >> ChouChou error object
 @param  dataOffline    : gets all LOCAL objects for type : resourceName  : @b passes >> matching LOCAL data
 @param  dataOnline     : gets all REMOTE objects for type :resourceName : @b passes >> matching REMOTE data propertiesDic
 
 @discussion Why __deprecated? Its a generic request. This shouldnt be available in production mode. Use it just for debugging. Its just way too powerful because it can fetch huge amount of data
 
 @also Also See : ChouchouOfflineDataManager : for Offline Storage
 
 **/

-(void)getResource:(NSString*)resourceName withProperties:(NSDictionary*)propertiesDic
      storeLocally:(BOOL)storeLocally
           onError:(void (^)(ChouChouError*))onError
       dataOffline:(void (^)(id))dataOffline
        dataOnline:(void (^)(id))dataOnline __deprecated;


/**
 Creates a @b PULL request for the resource from the REMOTE server
 
 @param  resourceName   : name / type of resource
 @param  propertiesDic  : all objects on remore server with these properties will be fetched
 @param  storeLocally   : Set whether to locally store the remote data
 @prram  onlyOnline     : Return data only with online connection
 @param  onError        : when an error is encountered : @b passes >> ChouChou error object
 @param  dataOffline    : when matching LOCAL object is found : @b passes >> matching LOCAL data
 @param  dataOnline     : when matching REMOTE object is found : @b passes >> matching REMOTE data propertiesDic
 
 @also Also See : ChouchouOfflineDataManager : for Offline Storage
 **/

-(void)getResourceByID:(NSString*)resourceName withProperties:(NSDictionary*)propertiesDic
          storeLocally:(BOOL)storeLocally
               onError:(void (^)(ChouChouError*))onError
           dataOffline:(void (^)(id))dataOffline
            dataOnline:(void (^)(id))dataOnline;

/**
 Creates a @b DELETE request for the resource from the REMOTE server
 
 @param  propertiesDic  : all objects on remore server with these properties will be DELETED
 @param  storeLocally   : Set whether to locally store the remote data
 @param  resourceName   : name / type of resource
 @param  onError        : when an error is encountered : @b passes >> ChouChou error object
 @param  onSuccess      : when matching data in @b both LOCAL and REMOTE storage is found,  data is Deleted
 
 @also Also See : ChouchouOfflineDataManager : for Offline Storage
 **/


-(void)deleteResourceByID:(NSDictionary*)propertiesDic resourceName:(NSString*)resourceName
                  onError:(void (^)(ChouChouError*))onError
                onSuccess:(void (^)(BOOL))onSuccess;

/**
 Creates a @b PUT request for the resource to the @b LOCAL server
 
 @param  resourceName    : name / type of resource
 @param  idDict          : all objects on remore server with these properties will be UPDATED
 @param  updateDict      : the content of the data that needs to be updated LOCALLY
 @param  onError         : when an error is encountered : @b passes >> ChouChou error object
 @param  onSuccess       : when matching data in @b LOCAL is found >> @b Passes : LOCAL DATA
 
 @also Also See : ChouchouOfflineDataManager : for Offline Storage
 **/

-(void)locallyUpdateResourceByID:(NSString*)resourceName
                          idDict:(NSDictionary*)idDict
                      updateDict:(NSDictionary*)updateDict
                         onError:(void (^)(ChouChouError*))onError
                       onSuccess:(void (^)(id))onSuccess;


/**
 Creates a @b Smart PUT / PULL @@b request for the resource to the @b LOCAL server
 
 @also Why this is smart call ? This methods generates a PULL request to server to check if data exists. If data exists, it generates a PUT request for the object. Else, it creates a POST request for the object
 
 @param  resourceName    : name / type of resource
 @param  getIDDic        : all objects on remore server with these properties will be UPDATED
 @param  storeLocally   : Set whether to locally store the remote data
 @param  propertiesDic   : the content of the data that needs to be updated LOCALLY
 @param  onError         : when an error is encountered : @b passes >> ChouChou error object
 @param  onSuccess       : when matching data in @b LOCAL is found >> @b Passes : LOCAL DATA
 
 @also Also See : ChouchouOfflineDataManager : for Offline Storage
 **/

-(void) submitResourceWithType:(NSString *)resourceName
                withProperties:(NSDictionary *)propertiesDic
                      getIDDic:(NSDictionary*)getIDDic
                  storeLocally:(BOOL)storeLocally
                       onError:(void (^)(ChouChouError *))onError
                     onSuccess:(void (^)(id))onSuccess;



/** deletes all local data of type resource name provided
 @param resourceType : type of resources to be deleted in local storage
 */

-(void) deleteAllLocalResourcesOfType :(NSString*) resourceName;

@end

#endif
