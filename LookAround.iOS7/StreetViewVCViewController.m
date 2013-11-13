//
//  StreetViewVCViewController.m
//  chainges
//
//  Created by Nero Wolfe on 8/15/13.
//  Copyright (c) 2013 Sergey Dikarev. All rights reserved.
//

#import "StreetViewVCViewController.h"
#import <GoogleMaps/GoogleMaps.h>
#import "Defines.h"
@interface StreetViewVCViewController ()
{
    
}
@end

@implementation StreetViewVCViewController
{
     GMSPanoramaView *panoView_;
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)loadView
{
    [super viewDidLoad];
   
    
    panoView_ = [[GMSPanoramaView alloc] initWithFrame:CGRectZero];
    self.view = panoView_;
    
    [panoView_ moveNearCoordinate:_coord];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
