//
//  DKAPlaceVC.h
//  LookAround.iOS7
//
//  Created by Nero Wolfe on 12/11/13.
//  Copyright (c) 2013 Sergey Dikarev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleMaps/GoogleMaps.h>
#import <MapKit/MapKit.h>

@interface DKAPlaceVC : UIViewController <GMSPanoramaViewDelegate, MKMapViewDelegate>
@property (strong, nonatomic) IBOutlet UIButton *btnStreetView;
@property (strong, nonatomic) IBOutlet UIButton *btnMenu;
@property (strong, nonatomic) IBOutlet UIButton *btnMap;
@property (strong, nonatomic) id placeObj;
@property (strong, nonatomic) IBOutlet UIView *myStreetView;
@property (strong, nonatomic) IBOutlet UIButton *btnBack;

@end
