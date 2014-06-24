//
//  UgcModel.h
//  ChouChouExample
//
//  Created by Sourabh Verma on 14/05/14.
//  Copyright (c) 2014 ibibo group. All rights reserved.
//

#import "ChouChouReservedObject.h"


@interface UgcModel : ChouChouReservedObject

@property (nonatomic,strong)  NSString              *contenttype;
@property (nonatomic, strong) NSDictionary          *content;
@property (nonatomic,strong)  NSString              *entitytype;
@property (nonatomic,strong)  NSString              *entityname;
@property (nonatomic,strong)  NSString              *entityid;
@property (nonatomic,strong)  NSString              *parentid;

@property (nonatomic,strong)  NSDictionary          *location;
@property (nonatomic,strong)  NSString              *ownerid;
@property (nonatomic,strong)  NSString              *ownername;
@property (nonatomic,strong)  NSString              *source;
@property (nonatomic,strong)  NSString              *timestamp;



-(void) postUGCToServer:(UgcModel*)ugcObject storeLocally:(BOOL)storeLocally
                onError:(void(^)(NSDictionary*))onError
              onSuccess:(void(^)(NSDictionary*))onSuccess;

-(void) updateUGCFromServer:(UgcModel*)ugcObject storeLocally:(BOOL)storeLocally
                    onError:(void(^)(NSDictionary*))onError
                offlineData: (void(^)(NSDictionary*))offlineData
                  onSuccess:(void(^)(NSDictionary*))onSuccess;

-(void) putUGCUpdatesToServer:(UgcModel*)ugcObject storeLocally:(BOOL)storeLocally
                      onError:(void(^)(NSDictionary*))onError
                    onSuccess:(void(^)(NSDictionary*))onSuccess;

-(void) deleteUGCFromServer:(UgcModel*)ugcObject storeLocally:(BOOL)storeLocally
                    onError:(void(^)(NSDictionary*))onError
                        onSuccess:(void(^)(BOOL))onSuccess;


@end

/*
{
    "contenttype": "review",
    "entitytype": "hotel",
    "entityid": "_405567540117778649",
    "parentid": "",
    "content": {
        "rating": [
                   {
                       "vfm": 3
                   },
                   {
                       "servqual": 2
                   },
                   {
                       "fnd": 1
                   },
                   {
                       "loc": 5
                   },
                   {
                       "amenities": 4
                   },
                   {
                       "cleanliness": 4
                   }
                   ],
        "reco" : [
                  {
                      "adv": 1
                  },
                  {
                      "backpack": 0
                  },
                  {
                      "buss": 1
                  },
                  {
                      "family": 0
                  },
                  {
                      "luxury": 1
                  },
                  {
                      "art": 1
                  },
                  {
                      "budget": 1
                  },
                  {
                      "green": 0
                  },
                  {
                      "history": 1
                  },
                  {
                      "local": 0
                  },
                  {
                      "foodie": 0
                  },
                  {
                      "romantic": 1
                  }
                  ],
        "title" : "good place to stay for family outings",
        "content" : "Room is good and quite spacious. Service is very fast. The adjacent restaurant serves good food too.",
        "tips" : "don't take the rooms on the ground floor",
        "pics": [
                 "http://google.com/flight.jpg"
                 ]
    },
    "location" : {},
    "ownerid": 12345,
    "ownername": "rithish",
    "source": "goibibo",
    "timestamp": 1379673290
}
*/