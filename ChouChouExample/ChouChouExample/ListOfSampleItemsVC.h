//
//  ListOfSampleItemsVC.h
//  ChouChouExample
//
//  Created by Manju Kiran on 06/06/14.
//  Copyright (c) 2014 ibibo group. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ChouChouKit/ChouChouKit.h>
#import "SampleObject.h"

@interface ListOfSampleItemsVC : UITableViewController

//#define keyForApp  @"<SET KEY HERE>"
//#define server_address  @"<SET SERVER URL HERE>"

#define keyForApp  @"b26761306839281d858eb48594682ce3"
#define server_address  @"https://baas.goibibo.com"


@property (nonatomic, retain) NSMutableArray *arrayOfSampleItemObjects;

-(IBAction)checkKeyAndServerAreSet :(id)sender;

@end
