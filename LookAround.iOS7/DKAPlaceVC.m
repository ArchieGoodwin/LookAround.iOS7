//
//  DKAPlaceVC.m
//  LookAround.iOS7
//
//  Created by Nero Wolfe on 12/11/13.
//  Copyright (c) 2013 Sergey Dikarev. All rights reserved.
//

#import "DKAPlaceVC.h"
#import <GoogleMaps/GoogleMaps.h>
#import <FactualSDK/FactualQuery.h>
#import "DKAHelper.h"
#import "StreetViewVCViewController.h"
#import "MapAnnotation.h"
#import "STImageAnnotationView.h"
#import "DKAPlaceMenuVC.h"
#import "LiveFrost.h"
#import "LFGlassView.h"
#import "DKAPlace.h"
#import "NWFourSquareViewController.h"

#import "NWFourSquareViewController.h"
#import "NWTwitterViewController.h"
#import "InstagramCollectionViewController.h"
#import "DKAFoursquareInfoVC.h"
@interface DKAPlaceVC ()
{
    DKAPlaceMenuVC *placeMenu;
    UIScrollView *scrollView;
    
    NWFourSquareViewController *fourController;
    NWTwitterViewController *twitterController;
    InstagramCollectionViewController *instaController;
    DKAFoursquareInfoVC *foursquareInfoController;
    NSMutableArray *fourSquarePhotos;
    NSMutableArray *tweets;
    NSMutableArray *instagrams;
    UIView *foursquareView;
    UIView *foursquareInfoView;

    UIView *instaView;
    UIView *tweetView;
}
@end

@implementation DKAPlaceVC
{
    //GMSPanoramaView *panoView_;
    MKMapView *mapView;
    CLLocationCoordinate2D coord;
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSLog(@"%@", _placeObj);
    
    self.tabBarController.tabBar.hidden = YES;
    
    self.navigationController.navigationBar.hidden = YES;

    tweetView = [[UIView alloc] initWithFrame:_myStreetView.frame];
    instaView = [[UIView alloc] initWithFrame:_myStreetView.frame];
    
    coord = CLLocationCoordinate2DMake(((DKAPlace *)_placeObj).latitude , ((DKAPlace *)_placeObj).longitude);
    
    [_btnStreetView setBackgroundImage:[helper radialGradientImage:_btnStreetView.frame.size start:0.9 end:0.9 centre:CGPointMake(0.5, 0.5) radius:0.45] forState:UIControlStateNormal];
    [_btnMenu setBackgroundImage:[helper radialGradientImage:_btnMenu.frame.size start:0.9 end:0.9 centre:CGPointMake(0.5, 0.5) radius:0.45] forState:UIControlStateNormal];
    [_btnMap setBackgroundImage:[helper radialGradientImage:_btnMap.frame.size start:0.9 end:0.9 centre:CGPointMake(0.5, 0.5) radius:0.45] forState:UIControlStateNormal];
    [_btnBack setBackgroundImage:[helper radialGradientImage:_btnMap.frame.size start:0.9 end:0.9 centre:CGPointMake(0.5, 0.5) radius:0.45] forState:UIControlStateNormal];

    
    UIColor *bg = BLUE6;
    _barName.backgroundColor = bg;

    _lblName.text = ((DKAPlace *)_placeObj).placeName;
    
    [self showStreetView:nil];
    
    [self loadInstas];
    [self loadTweets];
    [self load4sPhotos];
    foursquareInfoView = [self createFoursquareInfoView];
	// Do any additional setup after loading the view.
}


-(void)changeLabelText:(NSString *)str
{
    _lblName.text = str;
}

-(void)viewDidDisappear:(BOOL)animated
{
    for(UIView *view in _myStreetView.subviews)
    {
        [view removeFromSuperview];
    }
    
}




- (IBAction)backToParent:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}




- (IBAction)showStreetView:(id)sender {
 
    //_myStreetView = [[GMSPanoramaView alloc] initWithFrame:CGRectZero];

    for(UIView *view in _myStreetView.subviews)
    {
        [view removeFromSuperview];
    }
    
    GMSPanoramaView *panoramaView = [[GMSPanoramaView alloc] initWithFrame:self.view.frame];
	
	[panoramaView setUserInteractionEnabled:YES];
	[panoramaView setDelegate:self];
	[panoramaView setStreetNamesHidden:NO];
	[panoramaView setNavigationLinksHidden:YES];
	
	[_myStreetView addSubview:panoramaView];

    
    self.lblName.text = @"Street view around";

    //_streetView.delegate = self;
   
    [panoramaView moveNearCoordinate:coord];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        return;
    }
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:actionSheet.title]];
}

-(void)loadTweets
{
    [helper getTwitterAround:((DKAPlace *)_placeObj).latitude lng:((DKAPlace *)_placeObj).longitude completionBlock:^(NSArray *result, NSError *error) {
        
        tweets = [result mutableCopy];
        
        tweetView = [self createTwitterView];
        
    }];
}

-(void)loadInstas
{
    [helper getInstagramAround:((DKAPlace *)_placeObj).latitude lng:((DKAPlace *)_placeObj).longitude completionBlock:^(NSArray *result, NSError *error) {
        instagrams = [result mutableCopy];
        
        instaView = [self createInstagramView];
        
    }];
}


-(UIView *)createFoursquareInfoView
{
    foursquareInfoController = [[DKAFoursquareInfoVC alloc] init];
    foursquareInfoController.place = (DKAPlace *)_placeObj;
    
    
    return foursquareInfoController.view;
    
}


-(UIView *)createInstagramView
{
    instaController = [[InstagramCollectionViewController alloc] init];
    instaController.currentPageType = 0;
    instaController.parentContr = self;
    [instaController initCollectionViewWithRect:CGRectMake(0, 60, 320, [helper isIphone5] ? 508 : 420) instas:instagrams location:nil];
    
    
    return instaController.view;
    
}


-(UIView *)createTwitterView
{
    twitterController = [[NWTwitterViewController alloc] initMe:CGRectMake(0, 60, 320, [helper isIphone5] ? 508 : 420)];
    
    twitterController.tweets = tweets;
    
    twitterController.parentContr = self;
    
    [twitterController realInit];
    
    return twitterController.view;
    
}



-(void)load4sPhotos
{
    [helper photosByVenueId:((DKAPlace *)_placeObj).placeId completionBlock:^(NSArray *result, NSError *error) {
        if(!error)
        {
            fourSquarePhotos = [result mutableCopy];
            
            foursquareView = [self createFourSquareView];
            
            // [_cyclePageView reloadData];
            
        }
    }];
}


-(UIView *)createFourSquareView
{
    fourController = [[NWFourSquareViewController alloc] init];
    fourController.currentPageType = 0;
    fourController.parentContr = self;
    [fourController initCollectionViewWithRect:CGRectMake(0, 60, 320, [helper isIphone5] ? 508 : 420) instas:fourSquarePhotos location:nil];
    
    return fourController.view;
    
}


- (IBAction)showInfoPages:(id)sender
{
    for(UIView *view in _myStreetView.subviews)
    {
        if(view.tag != 2003)
        {
            [view removeFromSuperview];

        }
    }
    
    if(!scrollView)
    {
        CGRect frame = _myStreetView.frame;
        frame.origin.y = 60;
        frame.size.height = frame.size.height - 60;
        scrollView = [[UIScrollView alloc] initWithFrame:frame];
        scrollView.pagingEnabled = YES;
        scrollView.backgroundColor = [UIColor clearColor];
    }
    
    for (int i = 0; i < 4; i++) {
        CGRect frame;
        frame.origin.x = scrollView.frame.size.width * i;
        frame.origin.y = 0;
        frame.size = scrollView.frame.size;
        
        switch (i) {
            case 0:{
                foursquareInfoView.frame = frame;
                [scrollView addSubview:foursquareInfoView];
                break;}
            case 1:{
                tweetView.frame = frame;
                [scrollView addSubview:tweetView];
                break;}
            case 2:{
                instaView.frame = frame;
                [scrollView addSubview:instaView];
                break;}
            case 3:{
                foursquareView.frame = frame;
                [scrollView addSubview:foursquareView];
                break;}
            default:
                break;
        }
        
    }
    scrollView.contentSize = CGSizeMake(scrollView.frame.size.width * 4, scrollView.frame.size.height);

   
    [_myStreetView addSubview:scrollView];
    
}

- (IBAction)showMenu:(id)sender {
    
    if(![_myStreetView viewWithTag:2001])
    {
        UIGraphicsBeginImageContextWithOptions(_myStreetView.frame.size, YES, 4);
        
        [_myStreetView drawViewHierarchyInRect:_myStreetView.frame afterScreenUpdates:YES];
        
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        UIImageView *img = [[UIImageView alloc] initWithImage:image];
        
        img.alpha = 0.0;
        img.frame = _myStreetView.frame;
        img.tag = 2003;
        LFGlassView *frost  = [[LFGlassView alloc] initWithFrame:_myStreetView.frame];
        frost.alpha = 0.0;
        
        placeMenu = [self.storyboard instantiateViewControllerWithIdentifier:@"placeMenu"];
        placeMenu.view.frame = CGRectMake(10, 100, 300, 300);
        placeMenu.view.tag = 2001;
        placeMenu.parentVC = self;
        placeMenu.view.alpha = 0.0;
        [UIView animateWithDuration:0.3 animations:^{

            [_myStreetView addSubview:img];
            
            img.alpha = 1.0;
           
            [_myStreetView addSubview:frost];
            frost.alpha = 1.0;
           
            [_myStreetView addSubview:placeMenu.view];
            placeMenu.view.alpha = 1.0;
        }];
        
        self.lblName.text = @"Choose info card";

        
    }
    
    
    
  
}

#pragma mark Map methods

- (void)centerMap2{
    
    if([mapView.annotations count] == 0)
        return;
    
    CLLocationCoordinate2D topLeftCoord;
    topLeftCoord.latitude = -90;
    topLeftCoord.longitude = 180;
    
    CLLocationCoordinate2D bottomRightCoord;
    bottomRightCoord.latitude = 90;
    bottomRightCoord.longitude = -180;
    
    for(id <MKAnnotation> annotation in mapView.annotations)
    {
        topLeftCoord.longitude = fmin(topLeftCoord.longitude, annotation.coordinate.longitude);
        topLeftCoord.latitude = fmax(topLeftCoord.latitude, annotation.coordinate.latitude);
        
        bottomRightCoord.longitude = fmax(bottomRightCoord.longitude, annotation.coordinate.longitude);
        bottomRightCoord.latitude = fmin(bottomRightCoord.latitude, annotation.coordinate.latitude);
    }
    
    MKCoordinateRegion region;
    region.center.latitude = topLeftCoord.latitude - (topLeftCoord.latitude - bottomRightCoord.latitude) * 0.5;
    region.center.longitude = topLeftCoord.longitude + (bottomRightCoord.longitude - topLeftCoord.longitude) * 0.5;
    region.span.latitudeDelta = 0.001; // Add a little extra space on the sides
    region.span.longitudeDelta = 0.001; // Add a little extra space on the sides
    
    region = [mapView regionThatFits:region];
    [mapView setRegion:region animated:YES];
    
}

-(void)addAnnotationsToMap
{
    for(MapAnnotation *m in mapView.annotations)
    {
        if(![m isKindOfClass:[MKUserLocation class]])
        {
            [mapView removeAnnotation:m];
        }
    }

    
    MapAnnotation *m = [[MapAnnotation alloc] initWithUser:coord name:((DKAPlace *)_placeObj).placeName annotationType:WPMapAnnotationCategoryImage];
    
    [mapView addAnnotation:m];

    
     [self centerMap2];
}



-(void)mapView:(MKMapView *)mapView1 didAddAnnotationViews:(NSArray *)views
{
    //[self centerMap2];
}

- (MKAnnotationView *)mapView:(MKMapView *)mv viewForAnnotation:(id<MKAnnotation>)a
{
    MKAnnotationView* annotationView = nil;
    
    NSString* identifier = @"Image";
    
    STImageAnnotationView* imageAnnotationView = (STImageAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
    if(nil == imageAnnotationView)
    {
        imageAnnotationView = [[STImageAnnotationView alloc] initWithAnnotation:a reuseIdentifier:identifier];
        
    }
    
    annotationView = imageAnnotationView;
    
    annotationView.canShowCallout = YES;
    //UIButton *detailButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    //[detailButton addTarget:self action:@selector(loadWebView) forControlEvents:UIControlEventTouchUpInside];
    //annotationView.rightCalloutAccessoryView = detailButton;
    annotationView.calloutOffset = CGPointMake(0, 4);
    annotationView.centerOffset =  CGPointMake(0, 0);
    return annotationView;
}

- (IBAction)showMap:(id)sender {
    
    for(UIView *view in _myStreetView.subviews)
    {
        [view removeFromSuperview];
    }
    
    mapView = [[MKMapView alloc] initWithFrame:_myStreetView.frame];
    mapView.delegate = self;
    
    [self addAnnotationsToMap];

    self.lblName.text = @"Map around";

    
    [_myStreetView addSubview:mapView];
    
}





- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
