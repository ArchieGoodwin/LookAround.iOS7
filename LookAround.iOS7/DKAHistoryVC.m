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
#import "Defines.h"
#import "NSDate-Utilities.h"
#import "DKAPhoto.h"
#import <ImageIO/ImageIO.h>
#import "DKAHelper.h"
#import "DKAPlace.h"
#import "DKAPlaceVC.h"
@interface DKAHistoryVC ()
{
    NSMutableArray *items;
    NSMutableArray *photos;
    NSMutableArray *sections;
    NSCache *imagesCache;
    UIRefreshControl *refreshControl;
    ASMediaFocusManager *mediaFocusManager;
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
    mediaFocusManager = [[ASMediaFocusManager alloc] init];
    mediaFocusManager.delegate = self;
    refreshControl = [[UIRefreshControl alloc]   init];
    refreshControl.tintColor = [UIColor grayColor];
    
    [refreshControl addTarget:self action:@selector(refreshSchedule) forControlEvents:UIControlEventValueChanged];
    
    [self.tableView addSubview:refreshControl];
    
    //self.tableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);


    imagesCache = [[NSCache alloc] init];

    photos = [NSMutableArray new];
    
    self.tableView.backgroundColor = BLUE5;

    /*CMMotionActivityManager *motionManager = [[CMMotionActivityManager alloc] init];
    [motionManager queryActivityStartingFromDate:[[NSDate date] dateBySubtractingDays:3] toDate:[NSDate date] toQueue:[NSOperationQueue currentQueue] withHandler:^(NSArray *activities, NSError *error) {
        NSLog(@"activities: %@", activities);
        
        items = [activities mutableCopy];
        [self.tableView reloadData];
    }];*/
    
    [self getPhotos];

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


-(void)refreshSchedule
{
    [imagesCache removeAllObjects];
    [sections removeAllObjects];
    [self getPhotos];
}

-(void)getPhotos
{
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    
    [library enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop)
     {
         [group setAssetsFilter:[ALAssetsFilter allPhotos]];
         if ([group numberOfAssets] > 0)
         {

             NSMutableArray *temp = [NSMutableArray new];
             [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                 
                 
                 if (result) {
                     

                     
                     NSDate *date = [result valueForProperty:ALAssetPropertyDate];
                     if([date daysBeforeDate:[NSDate date]] < 10)
                     {
                         
                         ALAssetRepresentation *representation = [result defaultRepresentation];
                         
                         CGImageRef im = [representation fullScreenImage];
                         
                         UIImage *imgFull = [UIImage imageWithCGImage:im];
                         
                         CGImageRef thumb = [result thumbnail];
                         
                         UIImage *imgThumb = [UIImage imageWithCGImage:thumb];
                         
                         
                         NSDictionary *imageMetadata = [representation metadata];
                         //NSLog(@"metadata: %@", imageMetadata);//[result valueForProperty:ALAssetPropertyDate]);
                         
                         DKAPhoto *photo = [[DKAPhoto alloc] init];
                         
                         photo.dateShot = [result valueForProperty:ALAssetPropertyDate];
                         
                         photo.name = @"";
                         
                         photo.image = imgFull;
                         
                         photo.thumbnail = imgThumb;
                         
                         if(![[imageMetadata objectForKey:@"{GPS}"] isEqual:[NSNull null]])
                         {
                             photo.latitude = [[[imageMetadata objectForKey:@"{GPS}"] objectForKey:@"Latitude"] floatValue];
                             
                             photo.longitude = [[[imageMetadata objectForKey:@"{GPS}"] objectForKey:@"Longitude"] floatValue];
                             
                             if(photo.latitude != 0.0 && photo.longitude != 0.0)
                             {
                                 [temp addObject:photo];

                             }

                         }
                         
                     }
                     // Do something interesting with the metadata.
                 }
                 
                 

             }];
             
             NSSortDescriptor *sortDescriptor;
             sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"dateShot" ascending:NO selector:@selector(compare:)];
             NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
             photos = [NSMutableArray arrayWithArray:[temp sortedArrayUsingDescriptors:sortDescriptors]];

             NSLog(@"photos: %i", photos.count);//[result valueForProperty:ALAssetPropertyDate]);
             
             [self splitPhotosByLocations];

         }
     }
                         failureBlock: ^(NSError *error)
     {
         NSLog(@"No Photo");
     }];
}

-(double)distanceBetweenCoordinates:(CLLocationCoordinate2D)loc1 loc2:(CLLocationCoordinate2D)loc2
{

    CLLocation * clLoc1 = [[CLLocation alloc] initWithLatitude:loc1.latitude longitude:loc1.longitude];
    CLLocation * clLoc2 = [[CLLocation alloc] initWithLatitude:loc2.latitude longitude:loc2.longitude];
    
    double kilometers = [clLoc1 distanceFromLocation:clLoc2];
    
    return kilometers;
}

-(void)checkLocationInDictionary:(CLLocationCoordinate2D)loc photo:(DKAPhoto *)photo
{
    if(sections.count > 0)
    {
        BOOL hasThisPoint = NO;
        for(NSMutableDictionary *dict in sections)
        {
            CLLocation *location = (CLLocation *)[dict objectForKey:@"location"];
            if([self distanceBetweenCoordinates:location.coordinate loc2:loc] < 50)
            {
                hasThisPoint = YES;
                NSMutableArray *temp = [dict objectForKey:@"items"];
                [temp addObject:photo];
                [dict setValue:temp forKey:@"items"];
                break;
            }
            
        }
        if(!hasThisPoint)
        {
            CLLocation *location = [[CLLocation alloc] initWithLatitude:loc.latitude longitude:loc.longitude];
            NSMutableArray *temp = [NSMutableArray new];
            [temp addObject:photo];
            NSMutableDictionary *dictTemp = [[NSMutableDictionary alloc] initWithObjects:@[location, temp] forKeys:@[@"location", @"items"]];

            [sections addObject:dictTemp];
        }
    }
    else
    {
        sections = [NSMutableArray new];
        CLLocation *location = [[CLLocation alloc] initWithLatitude:loc.latitude longitude:loc.longitude];
        NSMutableArray *temp = [NSMutableArray new];
        [temp addObject:photo];
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithObjects:@[location, temp] forKeys:@[@"location", @"items"]];
        [sections addObject:dict];

    }
    
}

-(void)splitPhotosByLocations
{
    for(DKAPhoto *photo in photos)
    {
        CLLocationCoordinate2D loc = CLLocationCoordinate2DMake(photo.latitude, photo.longitude);
        [self checkLocationInDictionary:loc photo:photo];
        
    }
    
    [self.tableView reloadData];
    
    [refreshControl endRefreshing];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source


-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 60)];
    
    UIScrollView *scroll = [[UIScrollView alloc] initWithFrame:header.frame];
    scroll.pagingEnabled = YES;
    scroll.backgroundColor = [UIColor clearColor];
    
    NSMutableDictionary *dict = sections[section];
    
    float x = 5;
    int i = 0;
    for(DKAPhoto *photo in [dict objectForKey:@"items"])
    {
        UIImageView *imgView = [[UIImageView alloc] initWithImage:photo.image];
        imgView.frame = CGRectMake(x, 5, 50, 50);
        imgView.contentMode = UIViewContentModeScaleAspectFit;
        imgView.clipsToBounds = YES;
        

        [mediaFocusManager installOnViews:@[imgView]];
        
        [scroll addSubview:imgView];
        
        //UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(x, 5, 50, 50)];
        //btn.tag = section;
        //btn addTarget:self action:@selector(<#selector#>) forControlEvents:<#(UIControlEvents)#>
        
        x += 55;
        i++;
    }
    
    scroll.contentSize = CGSizeMake(55 * i, scroll.frame.size.height);
    [header addSubview:scroll];
    
    if (section % 2 == 0) {
        [header setBackgroundColor:BLUE5];
    } else {
        [header setBackgroundColor:[UIColor whiteColor]];
    }
    
    
    return header;
}


-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 60;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return sections.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    
    NSMutableDictionary *dict = sections[indexPath.section];
    
    if (indexPath.section % 2 == 0) {
        [cell.contentView setBackgroundColor:BLUE5];
    } else {
        [cell.contentView setBackgroundColor:[UIColor whiteColor]];
    }
    

    NSString *locc = [NSString stringWithFormat:@"%.10f%.10f%i", ((CLLocation *)[dict objectForKey:@"location"]).coordinate.latitude, ((CLLocation *)[dict objectForKey:@"location"]).coordinate.longitude, indexPath.row];
    
    DKAPlace *cachePlace =  [imagesCache objectForKey:locc];
    
    if(!cachePlace)
    {
        
        [helper poisNearLocation:((CLLocation *)[dict objectForKey:@"location"]).coordinate completionBlock:^(NSArray *result, NSError *error) {
            NSLog(@"done!");
            
            if(result.count > 0)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    DKAPlace *place = result[0];
                   
                    
                    if(place)
                    {
                        [imagesCache setObject:place forKey:locc];
                        UILabel *lbl = (UILabel *)[cell.contentView viewWithTag:101];
                        lbl.text = place.placeName;

                        
                    }
                    
                });
            }
            
            
            
        }];
        
        
        
    }
    else
    {
        UILabel *lbl = (UILabel *)[cell.contentView viewWithTag:101];
        lbl.text = cachePlace.placeName;;
        
    }
        
        

    
    
    
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableDictionary *dict = sections[indexPath.section];
    NSString *locc = [NSString stringWithFormat:@"%.10f%.10f%i", ((CLLocation *)[dict objectForKey:@"location"]).coordinate.latitude, ((CLLocation *)[dict objectForKey:@"location"]).coordinate.longitude, indexPath.row];
    
    DKAPlace *cachePlace =  [imagesCache objectForKey:locc];
    [self performSegueWithIdentifier:@"ShowPlace" sender:cachePlace];
    
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"ShowPlace"])
    {
        DKAPlaceVC *vc = (DKAPlaceVC *)segue.destinationViewController;
        vc.placeObj = sender;
        
    }
}

#pragma mark - ASMediaFocusDelegate
- (UIImage *)mediaFocusManager:(ASMediaFocusManager *)mediafocus imageForView:(UIView *)view
{
    //NSLog(@"%@",((UIImageView *)view).image);
    return ((UIImageView *)view).image;
    //ChaingeItem *item = _chaingeItems[currentIndex];
    //return [self imageRotated:[UIImage imageWithData:item.image.value] c:item.chainge];
}

- (CGRect)mediaFocusManager:(ASMediaFocusManager *)mediafocus finalFrameforView:(UIView *)view
{
    //return appDelegate.mainViewController.view.bounds;
    return [helper isIphone5] ? CGRectMake(0, 0, 320, 568) :  CGRectMake(0, 0, 320, 480);
    
}

- (UIViewController *)parentViewControllerForMediaFocusManager:(ASMediaFocusManager *)mediafocus
{
    //NWAppDelegate* myDelegate = (((NWAppDelegate*) [UIApplication sharedApplication].delegate));
    
    //NSLog(@"%@", [_controller.storyboard instantiateViewControllerWithIdentifier:@"locationController"]);
    self.navigationController.navigationBar.hidden = YES;
    self.tabBarController.tabBar.hidden = YES;
    
    return self;
}

- (NSString *)mediaFocusManager:(ASMediaFocusManager *)mediafocus mediaPathForView:(UIView *)view
{
    
    return @"";
}


@end
