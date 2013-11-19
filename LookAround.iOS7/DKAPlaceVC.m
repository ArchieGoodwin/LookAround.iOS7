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
#import "DKACyclePageContainerVC.h"
@interface DKAPlaceVC ()
{
    DKAPlaceMenuVC *placeMenu;
    DKACyclePageContainerVC *cycleContainer;
}
@end

@implementation DKAPlaceVC
{
    //GMSPanoramaView *panoView_;
    MKMapView *mapView;
    CLLocationCoordinate2D coord;
    FactualRow *row;
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
     row = (FactualRow *)_placeObj;

    coord = CLLocationCoordinate2DMake([[row valueForName:@"latitude"] doubleValue] , [[row valueForName:@"longitude"] doubleValue]);
    
    [_btnStreetView setBackgroundImage:[helper radialGradientImage:_btnStreetView.frame.size start:0.9 end:0.9 centre:CGPointMake(0.5, 0.5) radius:0.45] forState:UIControlStateNormal];
    [_btnMenu setBackgroundImage:[helper radialGradientImage:_btnMenu.frame.size start:0.9 end:0.9 centre:CGPointMake(0.5, 0.5) radius:0.45] forState:UIControlStateNormal];
    [_btnMap setBackgroundImage:[helper radialGradientImage:_btnMap.frame.size start:0.9 end:0.9 centre:CGPointMake(0.5, 0.5) radius:0.45] forState:UIControlStateNormal];
    [_btnBack setBackgroundImage:[helper radialGradientImage:_btnMap.frame.size start:0.9 end:0.9 centre:CGPointMake(0.5, 0.5) radius:0.45] forState:UIControlStateNormal];


    
    [self showStreetView:nil];
	// Do any additional setup after loading the view.
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

    //_streetView.delegate = self;
   
    [panoramaView moveNearCoordinate:coord];
}

- (IBAction)showInfoPages:(id)sender
{
    for(UIView *view in _myStreetView.subviews)
    {
        [view removeFromSuperview];
    }
    cycleContainer = [DKACyclePageContainerVC new];
    
    [_myStreetView addSubview:cycleContainer.view];
    
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

    
    MapAnnotation *m = [[MapAnnotation alloc] initWithUser:coord name:[row valueForName:@"name"] annotationType:WPMapAnnotationCategoryImage];
    
    [mapView addAnnotation:m];

}



-(void)mapView:(MKMapView *)mapView1 didAddAnnotationViews:(NSArray *)views
{
    [self centerMap2];
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

    [_myStreetView addSubview:mapView];
    
}





- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
