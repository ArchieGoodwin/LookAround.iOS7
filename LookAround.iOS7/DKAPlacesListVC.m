//
//  DKAPlacesListVC.m
//  LookAround.iOS7
//
//  Created by Nero Wolfe on 20/11/13.
//  Copyright (c) 2013 Sergey Dikarev. All rights reserved.
//

#import "DKAPlacesListVC.h"
#import "DKAHelper.h"
#import "Defines.h"
//#import <FactualSDK/FactualQuery.h>
#import "DKAPlaceVC.h"
#import "DKAPlace.h"
@interface DKAPlacesListVC ()
{
    DKAPlace *selectedPlace;
    NSCache *imagesCache;
}

@end

@implementation DKAPlacesListVC
{
    //FactualQueryResult *queryData;

    NSArray *items;
}
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
    
    imagesCache = [[NSCache alloc] init];

    items = [NSMutableArray new];

    self.tableView.separatorInset = UIEdgeInsetsMake(0, 41, 0, 0);
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updatedLocation) name:DKALocationMuchUpdated object:nil];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.tabBarController.tabBar.hidden = NO;
    self.navigationController.navigationBar.hidden = NO;
}

-(void)reloadme
{
    [self.tableView reloadData];

}

-(void)updatedLocation
{
    CLLocation *loc = [[DKAHelper sharedInstance] currentLocation];
    

    [helper poisNearLocation:loc.coordinate completionBlock:^(NSArray *result, NSError *error) {
        NSLog(@"done!");
        items = result;
        
        [self performSelectorOnMainThread:@selector(reloadme) withObject:nil waitUntilDone:NO];
        
        
    }];
        
    

    
    
    
    
    /*[[DKAHelper sharedInstance] doQueryWithLocation:loc completion:^(FactualQueryResult *data, NSError *error) {
        
        queryData = data;
        [items removeAllObjects];
        [queryData.rows enumerateObjectsUsingBlock:^(FactualRow *obj, NSUInteger idx, BOOL *stop) {
            DKAPlace *place = [[DKAPlace alloc] initWithFactualData:obj];
            [items addObject:place];
        }];
        
        [self.tableView reloadData];
    }];*/
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


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
    

    
    UIImage *cacheImage =  [imagesCache objectForKey:place.iconUrl];
    
    if(!cacheImage)
    {
        NSURLSessionDownloadTask *getImageTask =
        [helper.session downloadTaskWithURL:[NSURL URLWithString:place.iconUrl]
                          completionHandler:^(NSURL *location, NSURLResponse *response,
                                              NSError *error) {
                              // 2
                              UIImage *downloadedImage = [UIImage imageWithData:
                                                          [NSData dataWithContentsOfURL:location]];
                              //3
                              
                              
                              dispatch_async(dispatch_get_main_queue(), ^{
                                  [imagesCache setObject:downloadedImage forKey:place.iconUrl];
                                  
                                  imgView.image = downloadedImage;
                              });
                          }];
        
        [getImageTask resume];
        
        
    }
    else
    {
        imgView.image = cacheImage;
        
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
        lbl.font = [UIFont systemFontOfSize:LOCATIONLISTFONTSIZE];
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
    DKAPlace *place = items[indexPath.row];
    selectedPlace = place;
    [self performSegueWithIdentifier:@"ShowPlace" sender:place];
    
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"ShowPlace"])
    {
        DKAPlaceVC *vc = (DKAPlaceVC *)segue.destinationViewController;
        vc.placeObj = selectedPlace;
        
    }
}



@end
