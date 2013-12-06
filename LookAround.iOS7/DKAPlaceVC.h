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
#import "DKAPlace.h"

@interface DKAPlaceVC : UIViewController <GMSPanoramaViewDelegate, MKMapViewDelegate, UIScrollViewDelegate>
@property (strong, nonatomic) IBOutlet UIButton *btnStreetView;
@property (strong, nonatomic) IBOutlet UIButton *btnMenu;
@property (strong, nonatomic) IBOutlet UIButton *btnMap;
@property (strong, nonatomic) DKAPlace *placeObj;
@property (strong, nonatomic) IBOutlet UIView *myStreetView;
@property (strong, nonatomic) IBOutlet UIButton *btnBack;
@property (strong, nonatomic) IBOutlet UILabel *lblName;
@property (strong, nonatomic) IBOutlet UIView *barName;
@property (strong, nonatomic) IBOutlet UIView *bar1;
@property (strong, nonatomic) IBOutlet UIView *bar2;
@property (strong, nonatomic) IBOutlet UIView *bar3;
@property (strong, nonatomic) IBOutlet UIView *bar4;
@property (strong, nonatomic) IBOutlet UIView *bar5;

- (IBAction)showMenu:(id)sender;
- (IBAction)showInfoPages:(id)sender;
-(void)changeLabelText:(NSString *)str;
@end
