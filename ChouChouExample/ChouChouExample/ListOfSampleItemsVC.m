//
//  ListOfSampleItemsVC.m
//  ChouChouExample
//
//  Created by Manju Kiran on 06/06/14.
//  Copyright (c) 2014 ibibo group. All rights reserved.
//

#import "ListOfSampleItemsVC.h"

@interface ListOfSampleItemsVC ()

@end

@implementation ListOfSampleItemsVC

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // It is best if you instantiate ChouChou Kit in AppDelegate
    
    [ChouChouKit initiateChouChou:keyForApp server:server_address storageType:CHOU_STORE_COUCHBASE_LITE debug:CHOU_DEBUG_FULL];
    [self checkKeyAndServerAreSet:self.navigationItem.rightBarButtonItem];
    
}

-(void) syncObjectsFromServer{
    NSDictionary *propertiesDictionary = @{@"name":@"nameofobject"};
    [SampleObject getAllObjectsFromServerForProperties:propertiesDictionary storeLocally:NO onError:^(ChouChouError *error) {
        NSLog(@"%@",error.userInfo);
    } onSuccess:^(NSArray * sampleObjectArray) {
        _arrayOfSampleItemObjects = [[NSMutableArray alloc]initWithArray:sampleObjectArray];
        [self.tableView reloadData];
    }];

}

-(IBAction)checkKeyAndServerAreSet :(id)sender {
    if([keyForApp isEqualToString:@"<SET KEY HERE>" ]|| [server_address isEqualToString:@"<SET SERVER URL HERE>"]){
        [[[UIAlertView alloc] initWithTitle:@"Keys not set"
                                    message:@"Please Set App key and server URL in the app delegate file prior to loading data from your server"
                                   delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
    }else{
        [self syncObjectsFromServer];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    if( _arrayOfSampleItemObjects){
    return _arrayOfSampleItemObjects.count;
    }else{
        return 0;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    // Configure the cell...
    SampleObject *sObject = [_arrayOfSampleItemObjects objectAtIndex:indexPath.row];
    cell.textLabel.text = sObject.name;
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
