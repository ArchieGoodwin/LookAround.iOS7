//
//  NWTwitterViewController.m
//  LookAround
//
//  Created by Sergey Dikarev on 2/12/13.
//  Copyright (c) 2013 Sergey Dikarev. All rights reserved.
//

#import "NWTwitterViewController.h"
#import "Defines.h"
#import "NWtwitter.h"
#import "NWTwitterCell.h"
#import "NWLabel.h"
#import "DKAHelper.h"
#import <QuartzCore/QuartzCore.h>
#import "DKAPlace.h"
NSCache *imagesCache;

@interface NWTwitterViewController ()
{
    UIView *viewForLabel;
    CAGradientLayer *maskLayer;
    float lastContentOffset;
}
@end

@implementation NWTwitterViewController


-(id)initMe:(CGRect)frame
{
    self = [super init];
    if(self)
    {
        
        CGRect rect = frame;
        rect.origin.y = rect.origin.y - 60;
        rect.size.height = frame.size.height;
        self.tableView = [[UITableView alloc] initWithFrame:rect style:UITableViewStylePlain];
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.tableView.delegate = self;
        self.tableView.dataSource = self;

        [self.view addSubview:_tableView];
        

    }
    return self;

}

-(void)fadeView
{
    if (!maskLayer)
    {
        maskLayer = [CAGradientLayer layer];
        
        CGColorRef outerColor = [[UIColor colorWithWhite:1.0 alpha:0.0] CGColor];
        CGColorRef innerColor = [[UIColor colorWithWhite:1.0 alpha:1.0] CGColor];
        
        maskLayer.colors = [NSArray arrayWithObjects:
                            (__bridge id)innerColor,
                            (__bridge id)innerColor,
                            (__bridge id)innerColor,
                            (__bridge id)innerColor,
                            (__bridge id)outerColor, nil];
        
        maskLayer.locations = [NSArray arrayWithObjects:
                               [NSNumber numberWithFloat:0.0],
                               [NSNumber numberWithFloat:0.175],
                               [NSNumber numberWithFloat:0.575],
                               [NSNumber numberWithFloat:0.875],
                               [NSNumber numberWithFloat:1.0], nil];
        
        //[maskLayer setStartPoint:CGPointMake(0, 0.5)];
        //[maskLayer setEndPoint:CGPointMake(1, 0.5)];
        
        maskLayer.bounds = self.view.bounds;
        maskLayer.anchorPoint = CGPointZero;
        
        self.tableView.layer.mask = maskLayer;
    }
}

- (void)showMessageView {
    viewForLabel = [[UIView alloc] initWithFrame:CGRectMake(20, 200, 280, 40)];
    viewForLabel.backgroundColor = BLUE7;
    UILabel *lblMessage = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 280, 40)] ;
    lblMessage.backgroundColor = [UIColor clearColor];
    lblMessage.font = [UIFont fontWithName:@"HelveticaNeue" size:16];
    lblMessage.text = @"There are no tweets around there";
    lblMessage.textColor = [UIColor whiteColor];
    lblMessage.textAlignment = NSTextAlignmentCenter;
    [viewForLabel addSubview:lblMessage];
    [self.view addSubview:viewForLabel];
    
    
    
    
}


-(void)hideMessageView
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    [UIView beginAnimations:nil context:context];
    [UIView setAnimationCurve:UIViewAnimationCurveLinear];
    [UIView setAnimationDuration:3];
    [UIView setAnimationDelegate:self];
    
    viewForLabel.alpha = 0;
    
    [UIView commitAnimations];
    
    
}

- (void)viewDidLoad
{
    
    
    
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if(_tweets.count == 0)
    {
        [self showMessageView];
        //[self hideMessageView];
    }
    _parentContr.lblName.text = ((DKAPlace *)_parentContr.placeObj).placeName;
    
    [self fadeView];

}

-(void)viewDidDisappear:(BOOL)animated
{
    [imagesCache removeAllObjects];
}

-(void)realInit
{
    imagesCache = [[NSCache alloc] init];

    [helper getTwitterAround:_place.latitude lng:_place.longitude completionBlock:^(NSArray *result, NSError *error) {
        
        _tweets = [result mutableCopy];
        
        [self.tableView reloadData];

        if(_tweets.count == 0)
        {
            [self showMessageView];
        }
        
    }];
    

}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    maskLayer.position = CGPointMake(0, scrollView.contentOffset.y);
    [CATransaction commit];
    
    
    /*ScrollDirection scrollDirection;
    if (lastContentOffset > scrollView.contentOffset.y)
        scrollDirection = ScrollDirectionUp;
    else
        scrollDirection = ScrollDirectionDown;
    
    lastContentOffset = scrollView.contentOffset.y;
    
    if(scrollDirection == ScrollDirectionDown)
    {
        if(lastContentOffset > 20.0)
        {
            [UIView animateWithDuration:0.4 animations:^{
                _parentContr.barName.alpha = 0.0;
            }];
        }
        
    }
    if(scrollDirection == ScrollDirectionUp)
    {
        [UIView animateWithDuration:0.4 animations:^{
            _parentContr.barName.alpha = 1.0;
        }];
        
    }*/
    
    
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
    return _tweets.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 65;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NWTwitterCell *cell = [tableView  dequeueReusableCellWithIdentifier:@"TweetMessage"];
    
    
    if(cell == nil)
    {
        NSArray *toplevel = [[NSBundle mainBundle ] loadNibNamed:@"TwitterCell" owner:nil options:nil];
        for(id cObject in toplevel)
        {
            if([cObject isKindOfClass:[UITableViewCell class]])
            {
                cell = (NWTwitterCell *)cObject;
                break;
            }
        }
    }
    
    
    NWtwitter *tweet = _tweets[indexPath.row];
    cell.imagesCache = imagesCache;
    cell.tweet = tweet;
    //cell.lblText.text = tweet.message;
    

    
    
    
    
    return cell;
    
    
    
    
    
    
    /*static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell = nil;
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    NWtwitter *tweet = _tweets[indexPath.row];

    
    UILabel *lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(35, 1, 250, 25)];
    lblTitle.numberOfLines = 0;
    lblTitle.lineBreakMode = UILineBreakModeWordWrap;
    lblTitle.backgroundColor = [UIColor clearColor];
    lblTitle.text = tweet.author;
    lblTitle.font = [UIFont systemFontOfSize:15];
    lblTitle.textColor = [UIColor darkTextColor];
    
    
    UILabel *lblSubTitle = [[UILabel alloc] initWithFrame:CGRectMake(35, 30, 250, 25)];
    lblSubTitle.backgroundColor = [UIColor clearColor];
    lblSubTitle.text = tweet.message;
    lblSubTitle.font = [UIFont systemFontOfSize:15];
    lblSubTitle.textColor = [UIColor lightGrayColor];
    
    [cell.contentView addSubview:lblTitle];
    [cell.contentView addSubview:lblSubTitle];
    
    return cell;*/
    
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

#pragma mark - Table view delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        return;
    }
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:actionSheet.title]];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    
    NWtwitter *tweet = _tweets[indexPath.row];
    
    if(tweet.author)
    {
        [[[UIActionSheet alloc] initWithTitle:[NSString stringWithFormat:@"https://twitter.com/%@", tweet.author] delegate:_parentContr cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Open Link in Safari", nil), nil] showInView:_parentContr.view];
        
    }
    

}

@end
