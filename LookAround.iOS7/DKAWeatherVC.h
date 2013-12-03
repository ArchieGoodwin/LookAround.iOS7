//
//  DKAWeatherVC.h
//  LookAround.iOS7
//
//  Created by Nero Wolfe on 29/11/13.
//  Copyright (c) 2013 Sergey Dikarev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DKAPlace.h"
#import "LFGlassView.h"
@interface DKAWeatherVC : UIViewController
@property (strong, nonatomic) IBOutlet UIImageView *imgView;
@property (strong, nonatomic) IBOutlet UILabel *lblAddress;
@property (strong, nonatomic) IBOutlet UILabel *lblCurrentT;
@property (strong, nonatomic) IBOutlet UILabel *lblForecastT;
@property (nonatomic, strong) DKAPlace *place;
@property (nonatomic, strong) UIImageView *placeImage;
@property (strong, nonatomic) IBOutlet LFGlassView *weatherView;
@property (strong, nonatomic) IBOutlet UIImageView *imgWeather;
@end
