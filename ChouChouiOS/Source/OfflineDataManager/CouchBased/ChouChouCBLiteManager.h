//
//  ChouChouCBLiteManager.h
//  ChouChouKit
//
//  Created by Sourabh Verma & Manju kiran on 15/05/14.
//  Copyright (c) 2014 ibibo group pvt ltd (http://www.goibibo.com/ && http://www.ibibo.com/). All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CouchbaseLite/CouchbaseLite.h>
#import "ChouChouOfflineManager.h"

@interface ChouChouCBLiteManager : ChouChouOfflineManager


@property (nonatomic, strong) CBLDatabase *localDatabase;
@property (nonatomic, strong) CBLManager *dataManager;

-(CBLDatabase *) currentLocalDatabase;


@end
