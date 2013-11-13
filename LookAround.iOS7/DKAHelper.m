//
//  DKAHelper.m
//  LookAround.iOS7
//
//  Created by Nero Wolfe on 15/10/13.
//  Copyright (c) 2013 Sergey Dikarev. All rights reserved.
//

#import "DKAHelper.h"
#import <FactualSDK/FactualAPI.h>
#import <FactualSDK/FactualQuery.h>
#import "DKAFactualHelper.h"
#import "Defines.h"


NSString * const PREFS_FACTUAL_TABLE = @"factual_table";
NSString * const SANDBOX_TABLE_DESC = @"US POI Sandbox";

NSString * const PREFS_GEO_ENABLED = @"enable_geo";
NSString * const PREFS_TRACKING_ENABLED = @"enable_track";
NSString * const PREFS_LATITUDE = @"lat";
NSString * const PREFS_LONGITUDE = @"lng";
NSString * const PREFS_RADIUS = @"radius";

NSString * const PREFS_LOCALITY_FILTER_ENABLED = @"enable_locality";
NSString * const PREFS_LOCALITY_FILTER_TYPE = @"locality_type";
NSString * const PREFS_LOCALITY_FILTER_TEXT = @"locality_filter";

NSString * const PREFS_CATEGORY_FILTER_ENABLED = @"enable_category";
NSString * const PREFS_CATEGORY_FILTER_TYPE = @"category_filter";

static NSString* localityFields[] = {
    @"locality",
    @"region",
    @"country",
    @"postcode"
};

static NSString* topLevelCategories[] = {
    @"Automotive",
    @"Community and Government",
    @"Healthcare",
    @"Landmarks",
    @"Retail",
    @"Services and Supplies",
    @"Social",
    @"Sports and Recreation",
    @"Transportation",
    @"Travel"
};


@implementation DKAHelper


#pragma mark - Helper methods


-(void)populateAppDefaults
{
    
    if([self getPrefValueForKey:DKA_PREF_DATA_SOURCE] == nil)
    {
        [[NSUserDefaults standardUserDefaults] setObject:@"Factual" forKey:DKA_PREF_DATA_SOURCE];
        [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:DKA_PREF_APP_HAS_STARTED];
        
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
   
}

-(void)setPrefValueForKey:(NSString *)key val:(id)val
{
    [[NSUserDefaults standardUserDefaults] setObject:val forKey:key];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}


-(id)getPrefValueForKey:(NSString *)key
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:key];
}

-(void) populateQueryDefaults {
    [_searchPrefs setValue:[NSNumber numberWithInt:0 ] forKey:PREFS_FACTUAL_TABLE];
    
    [_searchPrefs setValue:[NSNumber numberWithBool:YES ] forKey:PREFS_GEO_ENABLED];
    [_searchPrefs setValue:[NSNumber numberWithBool:YES ] forKey:PREFS_TRACKING_ENABLED];
    [_searchPrefs setValue:[NSNumber numberWithDouble:34.059] forKey:PREFS_LATITUDE];
    [_searchPrefs setValue:[NSNumber numberWithDouble:-118.418] forKey:PREFS_LONGITUDE];
    [_searchPrefs setValue:[NSNumber numberWithDouble:1000.0] forKey:PREFS_RADIUS];
    
    [_searchPrefs setValue:[NSNumber numberWithBool:YES] forKey:PREFS_LOCALITY_FILTER_ENABLED];
    [_searchPrefs setValue:@"country" forKey:PREFS_LOCALITY_FILTER_TYPE];
    [_searchPrefs setValue:@"US" forKey:PREFS_LOCALITY_FILTER_TEXT];
    
    [_searchPrefs setValue:[NSNumber numberWithBool:NO] forKey:PREFS_CATEGORY_FILTER_ENABLED];
    [_searchPrefs setValue:@"Food & Beverage" forKey:PREFS_CATEGORY_FILTER_TYPE];
}

-(CGFloat)getLabelSize:(UILabel *)label fontSize:(NSInteger)fontSize
{
    
    
    NSDictionary *attributesDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                          [UIFont systemFontOfSize:fontSize], NSFontAttributeName,
                                          nil];
    
    CGRect frame = [label.text boundingRectWithSize:CGSizeMake(306, 2000.0)
                                            options:NSStringDrawingUsesLineFragmentOrigin
                                         attributes:attributesDictionary
                                            context:nil];
    
    CGSize size = frame.size;
    
    return size.height;
}

#pragma mark - Factual methods

-(void)doQueryWithLocation:(CLLocation *)location completion:(DKAFactualHelperCompletionBlock)completion
{
    
    NSLog(@"%@", _searchPrefs);
    DKAFactualHelper *fHelper = [[DKAFactualHelper alloc] initWithPreferences:_searchPrefs];
    [fHelper doQueryWithSearchTermAndLocation:nil location:location completeBlock:^(FactualQueryResult *data, NSError *error) {
        NSLog(@"Factual data received");
        if(!error)
        {
            if(completion)
            {
                completion(data, nil);
            }
        }
        else
        {
            if(completion)
            {
                completion(nil, error);
            }
        }
    }];
}


-(void)doQueryWithSearchTerm:(NSString *)searchTerm completion:(DKAFactualHelperCompletionBlock)completion
{
    
    NSLog(@"%@", _searchPrefs);
    DKAFactualHelper *fHelper = [[DKAFactualHelper alloc] initWithPreferences:_searchPrefs];
    [fHelper doQueryWithSearchTermAndLocation:searchTerm location:nil completeBlock:^(FactualQueryResult *data, NSError *error) {
        NSLog(@"Factual data received");
        if(!error)
        {
            if(completion)
            {
                completion(data, nil);
            }
        }
        else
        {
            if(completion)
            {
                completion(nil, error);
            }
        }
    }];
}


#pragma mark - Init methods

- (id)init {
    self = [super init];
    
    
#if !(TARGET_IPHONE_SIMULATOR)
    
    
#else
    
    
#endif
    if(self)
    {
        //_apiObject = [[FactualAPI alloc] initWithAPIKey:@"G1onplQoOqNrWt8lH4osdfZWwHXFdFLW9zy9vs9u" secret:@"4ZFCD4TaSlyjHBzOu2xl7E88lU3oiQfaVxFRCOYU"];

        _searchPrefs = [NSMutableDictionary new];
        [self populateQueryDefaults];
        [self populateAppDefaults];
        
        
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        _locationManager.delegate = self;
        
    }
    
    return self;
    
}


-(void)startUpdateLocation
{
    [_locationManager startUpdatingLocation];
}


-(void) locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation {
    //NSLog(@"Location updated to = %@",newLocation);
    
    
    NSTimeInterval locationAge = -[newLocation.timestamp timeIntervalSinceNow];
    if (locationAge > 5.0) return;
    //NSLog(@"time: %f", locationAge);
    
    if (newLocation.horizontalAccuracy < 0) return;
    
	// Needed to filter cached and too old locations
    //NSLog(@"Location updated to = %@", newLocation);
    CLLocation *loc1 = [[CLLocation alloc] initWithLatitude:_currentLocation.coordinate.latitude longitude:_currentLocation.coordinate.longitude];
    CLLocation *loc2 = [[CLLocation alloc] initWithLatitude:newLocation.coordinate.latitude longitude:newLocation.coordinate.longitude];
    double distance = [loc1 distanceFromLocation:loc2];
    _currentLocation = newLocation;

    if(distance > 5)
    {
        NSLog(@"SIGNIFICANTSHIFT");
        [[NSNotificationCenter defaultCenter] postNotificationName:DKALocationMuchUpdated object:self userInfo:nil];
        
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:DKALocationUpdated object:self userInfo:nil];
    
    
    
}



#pragma mark - Design methods

- (UIImage *)radialGradientImage:(CGSize)size start:(float)start end:(float)end centre:(CGPoint)centre radius:(float)radius {
	// Render a radial background
	// http://developer.apple.com/library/ios/#documentation/GraphicsImaging/Conceptual/drawingwithquartz2d/dq_shadings/dq_shadings.html
    
	// Initialise
	UIGraphicsBeginImageContextWithOptions(size, NO, 1);
    
	// Create the gradient's colours
	size_t num_locations = 2;
	CGFloat locations[2] = { 0.0, 1.0 };
	CGFloat components[8] = { start,start,start, 1.0,  // Start color
		end,end,end, 0.0 }; // End color
	
	CGColorSpaceRef myColorspace = CGColorSpaceCreateDeviceRGB();
	CGGradientRef myGradient = CGGradientCreateWithColorComponents (myColorspace, components, locations, num_locations);
	
	// Normalise the 0-1 ranged inputs to the width of the image
	CGPoint myCentrePoint = CGPointMake(centre.x * size.width, centre.y * size.height);
	float myRadius = MIN(size.width, size.height) * radius;
	
	// Draw it!
	CGContextDrawRadialGradient (UIGraphicsGetCurrentContext(), myGradient, myCentrePoint,
								 0, myCentrePoint, myRadius,
								 kCGGradientDrawsAfterEndLocation);
	
	// Grab it as an autoreleased image
	UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
	
	// Clean up
	CGColorSpaceRelease(myColorspace); // Necessary?
	CGGradientRelease(myGradient); // Necessary?
	UIGraphicsEndImageContext(); // Clean up
	return image;
}




+(id)sharedInstance
{
    static dispatch_once_t pred;
    static DKAHelper *sharedInstance = nil;
    dispatch_once(&pred, ^{
        sharedInstance = [[DKAHelper alloc] init];
    });
    return sharedInstance;
}

- (void)dealloc
{
    
    abort();
}


@end
