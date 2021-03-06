//
//  DKANavVC.m
//  LookAround.iOS7
//
//  Created by Nero Wolfe on 21/10/13.
//  Copyright (c) 2013 Sergey Dikarev. All rights reserved.
//

#import "DKANavVC.h"
#import "Defines.h"
#import "LFGlassView.h"
@interface DKANavVC ()

@end

@implementation DKANavVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

-(BOOL)prefersStatusBarHidden
{
    return NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    
    NSShadow *shadow = [[NSShadow alloc] init];
    shadow.shadowColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.8];
    shadow.shadowOffset = CGSizeMake(0, 1);
    [[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
                                                           [UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:245.0/255.0 alpha:1.0], NSForegroundColorAttributeName,
                                                           shadow, NSShadowAttributeName,
                                                           [UIFont fontWithName:@"HelveticaNeue-CondensedBlack" size:21.0], NSFontAttributeName, nil]];
    
    [[UINavigationBar appearance] setBarTintColor:BLUE0];

    [[UITabBar appearance] setTintColor:BLUE1];
    //self.tabBarController.tabBar.translucent = YES;
    //self.tabBarController.tabBar.barStyle = UIBarStyleBlack;
    //[[UITabBar appearance] setTranslucent:YES];
    //[[UITabBar appearance] setBarStyle:UIBarStyleBlack];
    
    //LFGlassView *frost  = [[LFGlassView alloc] initWithFrame:self.tabBarController.tabBar.frame];

    //[self.tabBarController.tabBar.layer insertSublayer:frost.layer atIndex:0];
    
    [self preferredStatusBarStyle];
    [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
    
    //facebook style bar
    /*[self.navigationBar setBackgroundImage:[UIImage new]
                             forBarMetrics:UIBarMetricsDefault];
    self.navigationBar.shadowImage = [UIImage new];
    self.navigationBar.translucent = YES;
    
    UIColor *barColour = [UIColor colorWithRed:0.24f green:0.20f blue:0.6f alpha:1.00f];
    UIView *colourView = [[UIView alloc] initWithFrame:CGRectMake(0.f, -20.f, 320.f, 64.f)];
    colourView.opaque = NO;
    colourView.alpha = .96f;
    colourView.backgroundColor = barColour;
    
    self.navigationBar.barTintColor = barColour;
    
    [self.navigationBar.layer insertSublayer:colourView.layer atIndex:1];*/
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
