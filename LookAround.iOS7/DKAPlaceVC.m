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
#import "DKAWeatherVC.h"
@interface DKAPlaceVC ()
{
    DKAPlaceMenuVC *placeMenu;
    UIScrollView *scrollView;
    
    NWFourSquareViewController *fourController;
    NWTwitterViewController *twitterController;
    InstagramCollectionViewController *instaController;
    DKAFoursquareInfoVC *foursquareInfoController;
    DKAWeatherVC *weatherVC;
    NSMutableArray *fourSquarePhotos;
    NSMutableArray *tweets;
    NSMutableArray *instagrams;
    UIView *foursquareView;
    UIView *foursquareInfoView;
    UIView *weatherVCview;

    UIView *instaView;
    UIView *tweetView;
    BOOL firstTime;
    GMSPanoramaView *panoramaView;
    NSInteger menuTappedCount;

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
    
    [self showHideBarView:YES];

    menuTappedCount = 0;
    /*[_lblName.layer removeAllAnimations];
    CATransition *animation = [CATransition animation];
    animation.duration = 1.0;
    animation.type = kCATransitionFade;
    animation.removedOnCompletion = NO;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [_lblName.layer addAnimation:animation forKey:@"changeTextTransition"];*/
    
    
    NSLog(@"%@", _placeObj);
    
    self.tabBarController.tabBar.hidden = YES;
    
    self.navigationController.navigationBar.hidden = YES;

    firstTime = YES;
    
    tweetView = [[UIView alloc] initWithFrame:_myStreetView.frame];
    instaView = [[UIView alloc] initWithFrame:_myStreetView.frame];
    
    coord = CLLocationCoordinate2DMake(_placeObj.latitude , _placeObj.longitude);
    
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
    foursquareInfoView = [self createFoursquareInfoView];
    
    [self load4sPhotos];
    //[self loadFacebook];
    weatherVCview = [self createWeatherView];
	// Do any additional setup after loading the view.
}



-(void)showHideBarView:(BOOL)show
{
    _bar1.hidden = show;
    _bar2.hidden = show;
    _bar3.hidden = show;
    _bar4.hidden = show;
    _bar5.hidden = show;
    
}

-(void)changeLabelText:(NSString *)str
{
    _lblName.text = str;
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];

    for(UIView *view in _myStreetView.subviews)
    {
        [view removeFromSuperview];
    }
    fourController = nil;
    twitterController = nil;
    instaController = nil;;
    foursquareInfoController = nil;
    weatherVC = nil;
    [fourSquarePhotos removeAllObjects];
    fourSquarePhotos = nil;
    [tweets removeAllObjects];
    tweets = nil;
    [instagrams removeAllObjects];
    instagrams = nil;
    foursquareView = nil;
    foursquareInfoView = nil;
    weatherVCview = nil;
    
    instaView = nil;
    tweetView = nil;
    panoramaView = nil;
    scrollView = nil;
    self.view = nil;
    //[[helper.session delegateQueue] setSuspended:YES];
    //[helper.session invalidateAndCancel];
}




- (IBAction)backToParent:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}




- (IBAction)showStreetView:(id)sender {
 
    //_myStreetView = [[GMSPanoramaView alloc] initWithFrame:CGRectZero];

    [self showHideBarView:YES];
    
    for(UIView *view in _myStreetView.subviews)
    {
        [view removeFromSuperview];
    }
    
    panoramaView = [[GMSPanoramaView alloc] initWithFrame:self.view.frame];
	
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

-(void)loadFacebook
{
    [helper getFacebookAround:((DKAPlace *)_placeObj).latitude lng:((DKAPlace *)_placeObj).longitude completionBlock:^(NSArray *result, NSError *error) {
        
        tweets = [result mutableCopy];
        
        tweetView = [self createTwitterView];
        
    }];
}

-(void)loadTweets
{
    
    tweetView = [self createTwitterView];
    
}

-(void)loadInstas
{
    instaView = [self createInstagramView];
    
}


-(UIView *)createFoursquareInfoView
{
    foursquareInfoController = [self.storyboard instantiateViewControllerWithIdentifier:@"foursquareInfo"];
    foursquareInfoController.place = (DKAPlace *)_placeObj;
    
    
    return foursquareInfoController.view;
    
}



-(UIView *)createWeatherView
{
    weatherVC = [self.storyboard instantiateViewControllerWithIdentifier:@"weatherVC"];
    weatherVC.place = (DKAPlace *)_placeObj;
    
    
    return weatherVC.view;
    
}


-(UIView *)createInstagramView
{
    instaController = [[InstagramCollectionViewController alloc] init];
    instaController.currentPageType = 0;
    instaController.parentContr = self;
    instaController.place = _placeObj;
    [instaController initCollectionViewWithRect:CGRectMake(0, 60, 320, [helper isIphone5] ? 508 : 420) instas:nil location:nil];
    
    
    return instaController.view;
    
}


-(UIView *)createTwitterView
{
    twitterController = [[NWTwitterViewController alloc] initMe:CGRectMake(0, 60, 320, [helper isIphone5] ? 508 : 420)];
    
    //twitterController.tweets = tweets;
    
    twitterController.parentContr = self;
    
    twitterController.place = _placeObj;
    
    [twitterController realInit];
    
    return twitterController.view;
    
}



-(void)load4sPhotos
{
    foursquareView = [self createFourSquareView];
    
}


-(UIView *)createFourSquareView
{
    fourController = [[NWFourSquareViewController alloc] init];
    fourController.currentPageType = 0;
    fourController.parentContr = self;
    fourController.place = _placeObj;
    [fourController initCollectionViewWithRect:CGRectMake(0, 60, 320, [helper isIphone5] ? 508 : 420) instas:nil location:nil];
    
    return fourController.view;
    
}



- (IBAction)showInfoPages:(id)sender
{
    
    [self showHideBarView:NO];
    for (int i = 0; i < 5; i++) {
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
            case 4:{
                weatherVCview.frame = frame;
                [scrollView addSubview:weatherVCview];
                break;}
            default:
                break;
        }
        
    }
    scrollView.contentSize = CGSizeMake(scrollView.frame.size.width * 5, scrollView.frame.size.height);

   
    [_myStreetView addSubview:scrollView];
    
    [self changeBarBackground:1];
    
    if(firstTime)
    {
        CGPoint offset = scrollView.contentOffset;
        CGPoint newOffset = CGPointMake(offset.x+30, offset.y);
        
        [UIView animateWithDuration:0.4 delay:0.5 options:UIViewAnimationOptionCurveEaseIn   animations:^{
            //[UIView setAnimationRepeatCount: 1];
            [scrollView setContentOffset:newOffset animated: NO];
        } completion:^(BOOL finished) {
            if(finished)
            {
                [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseIn   animations:^{
                    //[UIView setAnimationRepeatCount: 1];
                    [scrollView setContentOffset:offset animated: NO];
                } completion:^(BOOL finished) {
                    
                }];
                
                

            }
        }];
    }
    

}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    /*CGPoint offset = scrollView.contentOffset;
    NSLog(@"offset %@", NSStringFromCGPoint(offset));

    CGPoint newOffset = CGPointMake(offset.x+15, offset.y);
    
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseIn   animations:^{
        //[UIView setAnimationRepeatCount: 1];
        [scrollView setContentOffset:newOffset animated: NO];
    } completion:^(BOOL finished) {
        if(finished)
        {
            [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseIn   animations:^{
                //[UIView setAnimationRepeatCount: 1];
                [scrollView setContentOffset:offset animated: NO];
            } completion:^(BOOL finished) {
                
            }];
            
            
            
        }
    }];*/
}


-(void)changeBarBackground:(NSInteger)barNumber
{
    for(int i = 1; i < 6; i++)
    {
        
        _bar1.backgroundColor = BLUE4;
        _bar2.backgroundColor = BLUE4;
        _bar3.backgroundColor = BLUE4;
        _bar4.backgroundColor = BLUE4;
        _bar5.backgroundColor = BLUE4;
        if(barNumber == 1)
        {
            _bar1.backgroundColor = BLUE0;
        }
        if(barNumber == 2)
        {
            _bar2.backgroundColor = BLUE0;
        }
        if(barNumber == 3)
        {
            _bar3.backgroundColor = BLUE0;
        }
        if(barNumber == 4)
        {
            _bar4.backgroundColor = BLUE0;
        }
        if(barNumber == 5)
        {
            _bar5.backgroundColor = BLUE0;
        }
    }
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView1
{
    //static NSInteger previousPage = 0;
    CGFloat pageWidth = scrollView1.frame.size.width;
    float fractionalPage = scrollView1.contentOffset.x / pageWidth;
    NSInteger page = lround(fractionalPage);
    NSLog(@"Page %i", page);
    if(page == 0)
    {
        [self changeTextForTitleLabel:@"Place info"];
     
        [self changeBarBackground:1];
        [_myStreetView viewWithTag:2005].hidden = NO;

    }
    if(page == 1)
    {
        [self changeTextForTitleLabel:@"Tweets around location"];
        [self changeBarBackground:2];
        [_myStreetView viewWithTag:2005].hidden = NO;

    }
    if(page == 3)
    {
        [self changeTextForTitleLabel:@"Foursquare photos"];
        [self changeBarBackground:3];
        [_myStreetView viewWithTag:2005].hidden = NO;

    }
    if(page == 2)
    {
        [self changeTextForTitleLabel:@"Instagram photos"];
        [self changeBarBackground:4];
        [_myStreetView viewWithTag:2005].hidden = NO;
    }
    if(page == 4)
    {
        [self changeTextForTitleLabel:@"Weather in location"];
        [self changeBarBackground:5];
        
        [_myStreetView viewWithTag:2005].hidden = YES;
    }
}

-(void)changeTextForTitleLabel:(NSString *)newText
{
    /*[_lblName.layer removeAllAnimations];
    CATransition *animation = [CATransition animation];
    animation.duration = 1.0;
    animation.type = kCATransitionFade;
    animation.removedOnCompletion = NO;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [_lblName.layer addAnimation:animation forKey:@"changeTextTransition"];*/
    
    // Change the text
    _lblName.text = newText;
    
    
    //[self performSelector:@selector(returnPlaceName) withObject:nil afterDelay:4];
    
}

-(void)returnPlaceName
{
   /* [_lblName.layer removeAllAnimations];
    CATransition *animation = [CATransition animation];
    animation.duration = 1.0;
    animation.type = kCATransitionFade;
    animation.removedOnCompletion = NO;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [_lblName.layer addAnimation:animation forKey:@"changeTextTransitionBack"];*/
    
    // Change the text
    _lblName.text = ((DKAPlace *)_placeObj).placeName;
}


- (IBAction)showMenu:(id)sender {

    for(UIView *view in _myStreetView.subviews)
    {
        if(view.tag == 2005)
        {
            [view removeFromSuperview];
            
        }
        
    }
    if(scrollView)
    {
        firstTime = NO;
        for(UIView *view in scrollView.subviews)
        {
            
            [view removeFromSuperview];
            
        }
        //[scrollView removeFromSuperview];
    }
    else
    {
        CGRect frame = _myStreetView.frame;
        frame.origin.y = 60;
        frame.size.height = frame.size.height - 60;
        scrollView = [[UIScrollView alloc] initWithFrame:frame];
        scrollView.pagingEnabled = YES;
        scrollView.backgroundColor = [UIColor clearColor];
        scrollView.delegate = self;
        scrollView.tag = 2006;

    }
    
    
    
   
    UIGraphicsBeginImageContextWithOptions(_myStreetView.frame.size, YES, 4);
    
    [_myStreetView drawViewHierarchyInRect:_myStreetView.frame afterScreenUpdates:YES];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    UIImageView *img = [[UIImageView alloc] initWithImage:image];
    

    img.frame = _myStreetView.frame;
    img.tag = 2003;
    [_myStreetView addSubview:img];
    

    __block LFGlassView *frost  = [[LFGlassView alloc] initWithFrame:_myStreetView.frame];
    frost.tag = 2004;
    frost.alpha = 0.0;
    
    //placeMenu = [self.storyboard instantiateViewControllerWithIdentifier:@"placeMenu"];
    //placeMenu.view.frame = CGRectMake(10, 100, 300, 300);
    //placeMenu.view.tag = 2001;
    //placeMenu.parentVC = self;
    //placeMenu.view.alpha = 0.0;
    [UIView animateWithDuration:0.3 animations:^{

        [_myStreetView addSubview:frost];
        frost.alpha = 1.0;

    } completion:^(BOOL finished) {
        
        UIGraphicsBeginImageContextWithOptions(_myStreetView.frame.size, YES, 4);
        
        [_myStreetView drawViewHierarchyInRect:_myStreetView.frame afterScreenUpdates:YES];
        
        UIImage *image1 = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        weatherVC.placeImage = img;

        UIImageView *img1 = [[UIImageView alloc] initWithImage:image1];
        img1.tag = 2005;
        

        
        [_myStreetView addSubview:img1];


        [[_myStreetView viewWithTag:2003] removeFromSuperview];
        
        [frost removeFromSuperview];
        frost = nil;
        
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"weatherImage" object:nil userInfo:nil];
        
        
        [self showInfoPages:sender];

        
    }];

    
    
    
    
  
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
    
    
    [self showHideBarView:YES];
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
