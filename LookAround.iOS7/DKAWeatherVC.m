//
//  DKAWeatherVC.m
//  LookAround.iOS7
//
//  Created by Nero Wolfe on 29/11/13.
//  Copyright (c) 2013 Sergey Dikarev. All rights reserved.
//

#import "DKAWeatherVC.h"
#import "DKAHelper.h"
#import "Defines.h"
@interface DKAWeatherVC ()

@end

@implementation DKAWeatherVC

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
    
    
    UIColor *bg = BLUE7;
    _weatherView.backgroundColor = bg;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(setImage)
												 name:@"weatherImage"
											   object:nil];
    
    [helper getWeatherAround:_place.latitude lng:_place.longitude completionBlock:^(NWWeather *weather, NSError *error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLocale *locale = [NSLocale currentLocale];
            BOOL isMetric = [[locale objectForKey:NSLocaleUsesMetricSystem] boolValue];
            _lblAddress.text = _place.address;
            _imgWeather.image = [UIImage imageNamed:@"Placeholder.png"];
            _lblForecastT.text = weather.forecast;
            NSURLSessionDownloadTask *getImageTask =
            [helper.session downloadTaskWithURL:[NSURL URLWithString:weather.weatherIconUrl]
                              completionHandler:^(NSURL *location, NSURLResponse *response,
                                                  NSError *error) {
                                  // 2
                                  UIImage *downloadedImage = [UIImage imageWithData:
                                                              [NSData dataWithContentsOfURL:location]];
                                  //3
                                  
                                  
                                  dispatch_async(dispatch_get_main_queue(), ^{
                                      
                                      _imgWeather.image = downloadedImage;
                                  });
                              }];
            
            [getImageTask resume];
            if(isMetric)
            {

                _lblCurrentT.text = [NSString stringWithFormat:@"%@, %@", weather.currentConditions, weather.temp_C];
            }
            else
            {
                _lblCurrentT.text = [NSString stringWithFormat:@"%@, %@", weather.currentConditions, weather.temp_F];
            }
        });
        
    }];
    // Do any additional setup after loading the view.
}


-(void)setImage
{
    _imgView.image = _placeImage.image;
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
