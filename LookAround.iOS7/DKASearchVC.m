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
    NSMutableArray *cities;
    NSMutableArray *selectedItems;

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

    //_btnIcon.enabled = NO;
    
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


-(BOOL)checkIfCityIsInArray:(NSString *)city
{
    for(NSString *c in cities)
    {
        if([c isEqualToString:city])
        {
            return YES;
        }
    }
    return NO;
}

-(void)filterCities
{
    cities = [NSMutableArray new];
    for(DKAPlace *pl in items)
    {
        if(pl.city)
        {
            if(![self checkIfCityIsInArray:pl.city])
            {
                [cities addObject:pl.city];
            }
        }
        
        
    }
}

-(NSMutableArray *)getPlacesWithCity:(NSString *)city
{
    NSMutableArray *temp = [NSMutableArray new];
    for(DKAPlace *pl in items)
    {
        if(pl.city)
        {
            if([pl.city isEqualToString:city])
            {
                [temp addObject:pl];
            }
        }
        
       
    }
    
    return temp;
}

-(void)reloadme
{
    if(items.count > 0)
    {
        //_btnIcon.enabled = YES;
        
        [self filterCities];
        [self.tableView reloadData];
    }

    
    
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
    
    NSString *city = cities[indexPath.section];
    
    
    DKAPlace *place = [[self getPlacesWithCity:city] objectAtIndex:indexPath.row];
    
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
        
        return cities.count;
    }
    
    self.tableView.separatorInset = UIEdgeInsetsMake(0, 320, 0, 0);
    
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(items.count > 0)
    {
        NSString *city = cities[section];
        
        return [self getPlacesWithCity:city].count;
        
    }
    return 0;
}


-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSString *city = cities[section];
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
    view.backgroundColor = BLUE4;
    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 200, 30)];
    lbl.backgroundColor = [UIColor clearColor];
    lbl.font = [UIFont fontWithName:@"" size:19];
    lbl.textColor = BLUE0;
    lbl.text = city;
    [view addSubview:lbl];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    btn.frame = CGRectMake(270, 5, 30, 30);
    [btn setImage:[UIImage imageNamed:@"map"] forState:UIControlStateNormal];
    btn.tintColor = BLUE1;
    [btn addTarget:self action:@selector(showMap:) forControlEvents:UIControlEventTouchUpInside];
    btn.tag = section;
    [view addSubview:btn];
    
    return view;
}

-(IBAction)showMap:(id)sender
{

    UIButton *btn = (UIButton *)sender;
    
    NSString *city = [cities objectAtIndex:btn.tag];
    NSMutableArray *temp = [self getPlacesWithCity:city];
    
    selectedItems = temp;
    
    
    [self performSegueWithIdentifier:@"showMap" sender:nil];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(items.count > 0)
    {
        
        NSString *city = cities[indexPath.section];
        
        DKAPlace *place = [self getPlacesWithCity:city][indexPath.row];
        
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
    
    NSString *city = cities[indexPath.section];
    
    DKAPlace *place = [self getPlacesWithCity:city][indexPath.row];
    
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
        
        if(sender == nil)
        {
            vc.items = selectedItems;
        }
        else
        {
            vc.items = [@[items[0]] mutableCopy];
            
        }
        
        
    }
}



@end
