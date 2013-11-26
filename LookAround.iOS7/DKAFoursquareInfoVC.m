//
//  DKAFoursquareInfoVC.m
//  LookAround.iOS7
//
//  Created by Nero Wolfe on 26/11/13.
//  Copyright (c) 2013 Sergey Dikarev. All rights reserved.
//

#import "DKAFoursquareInfoVC.h"

@interface DKAFoursquareInfoVC ()
{
    NSMutableArray *fields;
}
@end

@implementation DKAFoursquareInfoVC

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

    fields = [_place getListOfFields];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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
    return fields.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView  dequeueReusableCellWithIdentifier:@"Cell"];
    
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"Cell"];
        cell.textLabel.textColor = BLUE0;
        cell.detailTextLabel.textColor = BLUE3;
    }
    cell.textLabel.textColor = BLUE0;
    cell.detailTextLabel.textColor = BLUE3;
    NSDictionary *dict = fields[indexPath.row];
    
    cell.textLabel.text = [dict objectForKey:@"title"];
    
    if([[dict objectForKey:@"type"] isEqualToString:@"text"])
    {
        cell.detailTextLabel.text = [dict objectForKey:@"fieldValue"];
    }
    if([[dict objectForKey:@"type"] isEqualToString:@"float"])
    {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%.2f", [[dict objectForKey:@"fieldValue"] floatValue]];
    }
    if([[dict objectForKey:@"type"] isEqualToString:@"int"])
    {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%i", [[dict objectForKey:@"fieldValue"] intValue]];
    }
    if([[dict objectForKey:@"type"] isEqualToString:@"link"])
    {
        cell.detailTextLabel.text = @"Link";
    }
    
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

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
