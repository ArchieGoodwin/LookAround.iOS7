//
//  DKAHistoryVC.m
//  LookAround.iOS7
//
//  Created by Nero Wolfe on 10/11/13.
//  Copyright (c) 2013 Sergey Dikarev. All rights reserved.
//

#import "DKAHistoryVC.h"
#import <CoreMotion/CoreMotion.h>
#import "NSDate-Utilities.h"
#import <AssetsLibrary/AssetsLibrary.h>
@interface DKAHistoryVC ()
{
    NSMutableArray *items;
    NSMutableArray *photos;
    NSMutableArray *sections;
}
@end

@implementation DKAHistoryVC

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

    
    CMMotionActivityManager *motionManager = [[CMMotionActivityManager alloc] init];
    [motionManager queryActivityStartingFromDate:[[NSDate date] dateBySubtractingDays:3] toDate:[NSDate date] toQueue:[NSOperationQueue currentQueue] withHandler:^(NSArray *activities, NSError *error) {
        NSLog(@"activities: %@", activities);
        
        items = [activities mutableCopy];
        [self.tableView reloadData];
    }];
    
    [self getPhotos];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}


-(void)getPhotos
{
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    
    [library enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop)
     {
         [group setAssetsFilter:[ALAssetsFilter allPhotos]];
         if ([group numberOfAssets] > 0)
         {
             /*[group enumerateAssetsAtIndexes:[NSIndexSet indexSetWithIndex:[group numberOfAssets]-1] options:0
                                  usingBlock:^(ALAsset *alAsset, NSUInteger index, BOOL *innerStop)
              {
                  NSLog(@"alAsset: %@", [alAsset valueForProperty:ALAssetPropertyDate]);
              }];*/
             
             [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                 NSDate *date = [result valueForProperty:ALAssetPropertyDate];
                 
                 NSLog(@"alAsset: %@", [result valueForProperty:ALAssetPropertyDate]);

             }];
         }
     }
                         failureBlock: ^(NSError *error)
     {
         NSLog(@"No Photo");
     }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    
    CMMotionActivity *act = items[indexPath.row];
    
    UILabel *lbl = (UILabel *)[cell.contentView viewWithTag:101];
    lbl.text = [NSString stringWithFormat:@"%@, %hhd, %d", act.startDate, act.stationary, act.confidence];
    
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
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
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

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

@end
