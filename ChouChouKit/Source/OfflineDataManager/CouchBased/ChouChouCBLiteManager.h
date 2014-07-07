//
//  ChouChouCBLiteManager.h
//  ChouChouKit
//
//  Created by R Manju Kiran on 15/05/14.
//  Copyright (c) 2014 ibibo Web Pvt. Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CouchbaseLite/CouchbaseLite.h>
#import "ChouChouOfflineManager.h"

@interface ChouChouCBLiteManager : ChouChouOfflineManager


@property (nonatomic, strong) CBLDatabase *localDatabase;
@property (nonatomic, strong) CBLManager *dataManager;

-(CBLDatabase *) currentLocalDatabase;


@end
