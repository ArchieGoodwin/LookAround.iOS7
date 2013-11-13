//
//  StreetViewVCViewController.h
//  chainges
//
//  Created by Nero Wolfe on 8/15/13.
//  Copyright (c) 2013 Sergey Dikarev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
@interface StreetViewVCViewController : UIViewController

@property (nonatomic)  CLLocationCoordinate2D coord;
@property (nonatomic, strong) CLLocation *location;
@end
