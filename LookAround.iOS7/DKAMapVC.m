//
//  DKAMapVC.m
//  LookAround.iOS7
//
//  Created by Nero Wolfe on 30/11/13.
//  Copyright (c) 2013 Sergey Dikarev. All rights reserved.
//

#import "DKAMapVC.h"
#import "Defines.h"
#import "DKAHelper.h"
#import "MapAnnotation.h"
#import "STImageAnnotationView.h"
#import "DKAPlace.h"
#import "DKAPlaceVC.h"
#import "Search.h"
@interface DKAMapVC ()
{
    DKAPlace *selectedPlace;

}
@end

@implementation DKAMapVC

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
    
    [self addAnnotationsToMap];

    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.tabBarController.tabBar.hidden = NO;
    self.navigationController.navigationBar.hidden = NO;
    
    //[self centerMap2];
}



-(IBAction)findPlacesOnMap:(id)sender
{
    CLLocationCoordinate2D coord = [_mapView centerCoordinate];
    [helper poisNearLocation:coord completionBlock:^(NSArray *result, NSError *error) {
        if(!error)
        {
            //NSSortDescriptor *sortDescriptor;
            //sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"itemDistance" ascending:YES selector:@selector(compare:)];
            //NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
            [_items removeAllObjects];
            _items = [NSMutableArray arrayWithArray:result];
            
            [self addAnnotationsToMap];
            
            
            
        }
        
        
    }];
}


#pragma mark Map methods

- (void)centerMap2{
    
    if([_mapView.annotations count] == 0)
        return;
    
    MKMapRect zoomRect = MKMapRectNull;
    for (id <MKAnnotation> annotation in _mapView.annotations)
    {
        MKMapPoint annotationPoint = MKMapPointForCoordinate(annotation.coordinate);
        MKMapRect pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 1, 1);
        zoomRect = MKMapRectUnion(zoomRect, pointRect);
    }

    [_mapView setVisibleMapRect:zoomRect animated:YES];
    
}

-(void)addAnnotationsToMap
{
    for(MapAnnotation *m in _mapView.annotations)
    {
        if(![m isKindOfClass:[MKUserLocation class]])
        {
            [_mapView removeAnnotation:m];
        }
    }
    int i = 0;
    for(DKAPlace *item in _items)
    {
        CLLocationDegrees longitude = item.longitude;
        CLLocationDegrees latitude = item.latitude;
        CLLocationCoordinate2D placeLocation;
        placeLocation.latitude = latitude;
        placeLocation.longitude = longitude;
        
        
        
        MapAnnotation *m = [[MapAnnotation alloc] initWithUser:placeLocation name:item.placeName annotationType:WPMapAnnotationCategoryImage tagMe:i];
        i++;
        [_mapView addAnnotation:m];
    }
    
    
    
    
     [self centerMap2];
    
    
}


-(void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views
{
    //[self centerMap2];
    
   
}

- (MKAnnotationView *)mapView:(MKMapView *)mv viewForAnnotation:(id<MKAnnotation>)a
{
    MKAnnotationView* annotationView = nil;
    
    NSString* identifier = @"Image";
    
    STImageAnnotationView* imageAnnotationView = (STImageAnnotationView*)[mv dequeueReusableAnnotationViewWithIdentifier:identifier];
    if(nil == imageAnnotationView)
    {
        imageAnnotationView = [[STImageAnnotationView alloc] initWithAnnotation:a reuseIdentifier:identifier];
        
    }
    
    annotationView = imageAnnotationView;
    
    annotationView.canShowCallout = YES;
    UIButton *detailButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    MapAnnotation* csAnnotation = (MapAnnotation*)a;
    
    detailButton.tag = csAnnotation.tag;
    [detailButton addTarget:self action:@selector(goToPlace:) forControlEvents:UIControlEventTouchUpInside];
    annotationView.rightCalloutAccessoryView = detailButton;
    annotationView.calloutOffset = CGPointMake(0, 4);
    annotationView.centerOffset =  CGPointMake(0, 0);
    return annotationView;
}



-(IBAction)goToPlace:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    DKAPlace *place = _items[btn.tag];
    selectedPlace = place;
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"searchId = %@", selectedPlace.placeId];
    
    Search *srch = [Search getSingleObjectByPredicate:predicate];
    if(!srch)
    {
        Search *newSrch = [Search createEntityInContext];
        newSrch.searchId = selectedPlace.placeId;
        newSrch.searchString = selectedPlace.placeName;
        newSrch.searchDate = [NSDate date];
        NSMutableData *data = [[NSMutableData alloc] init];
        NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
        [archiver encodeObject:selectedPlace.sourceDict forKey:@"MyDict"];
        [archiver finishEncoding];
        newSrch.searchDict = data;
        
        [Search saveDefaultContext];
    }

    
    [self performSegueWithIdentifier:@"showPlace" sender:place];

    
    
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"showPlace"])
    {
        DKAPlaceVC *vc = (DKAPlaceVC *)segue.destinationViewController;
        vc.placeObj = selectedPlace;
        
    }
  
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

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
