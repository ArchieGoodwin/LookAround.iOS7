//
//  DKAFoursquareInfoVC.m
//  LookAround.iOS7
//
//  Created by Nero Wolfe on 26/11/13.
//  Copyright (c) 2013 Sergey Dikarev. All rights reserved.
//

#import "DKAFoursquareInfoVC.h"
#import "Defines.h"
#import <MapKit/MapKit.h>
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
    
    UIColor *bg = BLUE6;
    self.tableView.backgroundColor = bg;
    self.view.backgroundColor = [UIColor clearColor];
    
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

-(void)configureCell:(UITableViewCell *)cell forIndexPath:(NSIndexPath *)indexPath
{
    UILabel *title = (UILabel *)[cell.contentView viewWithTag:301];
    UILabel *detail = (UILabel *)[cell.contentView viewWithTag:302];
    
    //title.textColor = BLUE0;
    //detail.textColor = BLUE3;
    
    UIColor *bg = WHITE1;
    cell.backgroundColor = [UIColor clearColor];
    cell.contentView.backgroundColor = bg;
    
    NSDictionary *dict = fields[indexPath.row];
    
    title.text = [dict objectForKey:@"title"];
    
    if([[dict objectForKey:@"type"] isEqualToString:@"text"])
    {
        detail.text = [dict objectForKey:@"fieldValue"];
    }
    if([[dict objectForKey:@"type"] isEqualToString:@"float"])
    {
        detail.text = [NSString stringWithFormat:@"%.2f", [[dict objectForKey:@"fieldValue"] floatValue]];
    }
    if([[dict objectForKey:@"type"] isEqualToString:@"int"])
    {
        detail.text = [NSString stringWithFormat:@"%i", [[dict objectForKey:@"fieldValue"] intValue]];
    }
    if([[dict objectForKey:@"type"] isEqualToString:@"link"])
    {
        detail.text = [NSString stringWithFormat:@"%@", [dict objectForKey:@"fieldValue"]];
        cell.contentView.backgroundColor = [UIColor whiteColor];

    }
    if([[dict objectForKey:@"type"] isEqualToString:@"directions"])
    {
        title.text = @"Directions";
        detail.text = @"To Location";
        cell.contentView.backgroundColor = [UIColor whiteColor];
    }
    if([[dict objectForKey:@"type"] isEqualToString:@"reservation"])
    {
        detail.text = [dict objectForKey:@"fieldValue"];
        cell.contentView.backgroundColor = [UIColor whiteColor];

    }
    //detail.numberOfLines = 0;
    //detail.lineBreakMode = NSLineBreakByWordWrapping;
    //CGRect frame = detail.frame;
    //frame.size.height = [helper getLabelSizeWithWidth:detail fontSize:17  width:160] + 5;
    //detail.frame = frame;
    
    
    //NSLog(@"details %@", NSStringFromCGRect(frame));
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView  dequeueReusableCellWithIdentifier:@"Cell"];

    
    [self configureCell:cell forIndexPath:indexPath];
    

    return cell;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dict = fields[indexPath.row];
    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(150, 5, 160, 1000)];
    lbl.font = [UIFont fontWithName:@"HelveticaNeue" size:17];
    lbl.numberOfLines = 0;
    lbl.lineBreakMode = NSLineBreakByWordWrapping;
    
    if([[dict objectForKey:@"type"] isEqualToString:@"text"])
    {
        lbl.text = [dict objectForKey:@"fieldValue"];
    }
    if([[dict objectForKey:@"type"] isEqualToString:@"float"])
    {
        lbl.text = [NSString stringWithFormat:@"%.2f", [[dict objectForKey:@"fieldValue"] floatValue]];
    }
    if([[dict objectForKey:@"type"] isEqualToString:@"int"])
    {
        lbl.text = [NSString stringWithFormat:@"%i", [[dict objectForKey:@"fieldValue"] intValue]];
    }
    if([[dict objectForKey:@"type"] isEqualToString:@"link"])
    {
        lbl.text = [NSString stringWithFormat:@"%@", [dict objectForKey:@"fieldValue"]];
    }
    if([[dict objectForKey:@"type"] isEqualToString:@"directions"])
    {
        lbl.text = @"To Location";
    }
    if([[dict objectForKey:@"type"] isEqualToString:@"reservation"])
    {
        lbl.text = [dict objectForKey:@"fieldValue"];
    }
    
    NSLog(@"%f", [helper getLabelSizeWithWidth:lbl fontSize:17  width:160] + 14);
    
    return [helper getLabelSizeWithWidth:lbl fontSize:17 width:160] + 14;
    
    
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(actionSheet.tag == 600)
    {
        if(actionSheet)
            if (buttonIndex == actionSheet.cancelButtonIndex) {
                return;
            }
        
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:actionSheet.title]];
    }
    if(actionSheet.tag == 601)
    {
        if(actionSheet)
            if (buttonIndex == actionSheet.cancelButtonIndex) {
                return;
            }
        
        [self showDirections];
    }
    if(actionSheet.tag == 602)
    {
        if(actionSheet)
            if (buttonIndex == actionSheet.cancelButtonIndex) {
                return;
            }
        
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:actionSheet.title]];
    }
  
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dict = fields[indexPath.row];

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if([[dict objectForKey:@"type"] isEqualToString:@"link"])
    {
        UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:[NSString stringWithFormat:@"%@", [dict objectForKey:@"fieldValue"]] delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Open Link in Safari", nil), nil];

            
        action.tag = 600;
        [action showInView:self.view];
    }
    if([[dict objectForKey:@"type"] isEqualToString:@"directions"])
    {
        UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:[NSString stringWithFormat:@"%@", _place.placeName] delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Show Directions in Maps", nil), nil];
        action.tag = 601;
        [action showInView:self.view];
        
        
    }
    if([[dict objectForKey:@"type"] isEqualToString:@"reservation"])
    {
        UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:[NSString stringWithFormat:@"%@", _place.reservationUrl] delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Reserve Table", nil), nil];
        action.tag = 602;
        [action showInView:self.view];
        
        
    }
    
}


-(void)showDirections
{
    
    
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(_place.latitude,_place.longitude);
    
    //create MKMapItem out of coordinates
    MKPlacemark* placeMark = [[MKPlacemark alloc] initWithCoordinate:coordinate addressDictionary:nil];
    MKMapItem* destination =  [[MKMapItem alloc] initWithPlacemark:placeMark];
    
    [destination openInMapsWithLaunchOptions:@{MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeWalking}];
    
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
