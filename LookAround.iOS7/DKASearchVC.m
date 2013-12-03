//
//  DKASearchVC.m
//  LookAround.iOS7
//
//  Created by Nero Wolfe on 09/11/13.
//  Copyright (c) 2013 Sergey Dikarev. All rights reserved.
//

#import "DKASearchVC.h"
#import "DKAHelper.h"
#import "Defines.h"
#import <FactualSDK/FactualQuery.h>
#import "DKAPlaceVC.h"
#import "DKAPlace.h"
#import "DKAMapVC.h"
#import "Search.h"
@interface DKASearchVC ()
{
    FactualQueryResult *queryData;
    NSMutableArray *items;

}
@end

@implementation DKASearchVC

static NSString *CellIdentifier = @"Cell";

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}



- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}


- (void)viewDidLoad
{
    [super viewDidLoad];

    items = [NSMutableArray new];

    self.tableView.separatorInset = UIEdgeInsetsMake(0, 41, 0, 0);
    
    [self preferredStatusBarStyle];
    [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
    

    
    
	// Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.tabBarController.tabBar.hidden = NO;
    self.navigationController.navigationBar.hidden = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)reloadme
{
    [self.tableView reloadData];
    
    
}

-(void)searchByKeywords:(NSString *)keyword
{
    
    [helper poisByKeyword:keyword completionBlock:^(NSArray *result, NSError *error) {
        [items removeAllObjects];
        items = [result mutableCopy];
        
        [self performSelectorOnMainThread:@selector(reloadme) withObject:nil waitUntilDone:NO];
    }];
    
    
    /*[[DKAHelper sharedInstance] doQueryWithSearchTerm:keyword completion:^(FactualQueryResult *data, NSError *error) {
        queryData = data;
        [items removeAllObjects];
        [queryData.rows enumerateObjectsUsingBlock:^(FactualRow *obj, NSUInteger idx, BOOL *stop) {
            DKAPlace *place = [[DKAPlace alloc] initWithFactualData:obj];
            [items addObject:place];
        }];
        
        [self.tableView reloadData];
    }];*/
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    [self searchByKeywords:searchBar.text];
}

#pragma mark - UICollectionViewDataSource Methods



-(void)configureCell:(UITableViewCell *)cell forIndexPath:(NSIndexPath *)indexPath
{
    
    //NSLog(@"configure cell %i", indexPath.row);
    DKAPlace *place = [items objectAtIndex:indexPath.row];
    UILabel *lbl = (UILabel *)[cell.contentView viewWithTag:1001];
    
    CGRect frame = lbl.frame;
    frame.size.height = [[DKAHelper sharedInstance] getLabelSize:lbl fontSize:LOCATIONLISTFONTSIZE];
    lbl.frame = frame;
    lbl.text = place.placeName;
    //NSLog(@" iconUrl %@", place.iconUrl);
    
    UIImageView *imgView = (UIImageView *)[cell.contentView viewWithTag:1002];
    if(imgView.image == nil)
    {
        if(place.iconUrl != nil)
        {
            
            if(!helper.session)
            {
                [helper refreshSession];
            }
            imgView.image = [UIImage imageNamed:@"Placeholder.png"];
            
            NSURLSessionDownloadTask *getImageTask =
            [helper.session downloadTaskWithURL:[NSURL URLWithString:place.iconUrl]
                              completionHandler:^(NSURL *location, NSURLResponse *response,
                                                  NSError *error) {
                                  if(!error)
                                  {
                                      UIImage *downloadedImage = [UIImage imageWithData:
                                                                  [NSData dataWithContentsOfURL:location]];
                                      
                                      dispatch_async(dispatch_get_main_queue(), ^{
                                          
                                          imgView.image = downloadedImage;
                                      });
                                  }
                                  else
                                  {
                                      NSLog(@"error with iconUrl %@", error.localizedDescription);
                                  }
                                  
                              }];
            
            [getImageTask resume];
        }
        
    }
    
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    if(items.count > 0)
    {
        
        self.tableView.separatorInset = UIEdgeInsetsMake(0, 41, 0, 0);
        
        return 1;
    }
    
    self.tableView.separatorInset = UIEdgeInsetsMake(0, 320, 0, 0);
    
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(items.count > 0)
    {
        return items.count;
        
    }
    return 0;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(items.count > 0)
    {
        DKAPlace *place = items[indexPath.row];
        
        //UILabel *lblT = (UILabel *)[[tableView cellForRowAtIndexPath:indexPath].contentView viewWithTag:1001];
        UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(41, 3, 272, 1000)];
        lbl.font = [UIFont fontWithName:@"HelveticaNeue" size:LOCATIONLISTFONTSIZE];
        lbl.numberOfLines = 0;
        lbl.lineBreakMode = NSLineBreakByWordWrapping;
        
        lbl.text = place.placeName;
        return [[DKAHelper sharedInstance] getLabelSize:lbl fontSize:LOCATIONLISTFONTSIZE] + 14;
    }
    return 40;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView  dequeueReusableCellWithIdentifier:@"Cell"];
    
    
    [self configureCell:cell forIndexPath:indexPath];
    
    return cell;
    
}



#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    DKAPlace *place = items[indexPath.row];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"searchId = %@", place.placeId];
    
    Search *srch = [Search getSingleObjectByPredicate:predicate];
    if(!srch)
    {
        Search *newSrch = [Search createEntityInContext];
        newSrch.searchId = place.placeId;
        newSrch.searchString = place.placeName;
        newSrch.searchDate = [NSDate date];
        NSMutableData *data = [[NSMutableData alloc] init];
        NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
        [archiver encodeObject:place.sourceDict forKey:@"MyDict"];
        [archiver finishEncoding];
        newSrch.searchDict = data;
        
        [Search saveDefaultContext];
    }
    
    
    
    [self performSegueWithIdentifier:@"ShowPlace" sender:place];
    
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"ShowPlace"])
    {
        DKAPlaceVC *vc = (DKAPlaceVC *)segue.destinationViewController;
        vc.placeObj = sender;
        
    }
    if([segue.identifier isEqualToString:@"showMap"])
    {
        DKAMapVC *vc = (DKAMapVC *)segue.destinationViewController;
        
        vc.items = [@[items[0]] mutableCopy];
    }
}



@end
