//
//  DKAHelper.h
//  LookAround.iOS7
//
//  Created by Nero Wolfe on 15/10/13.
//  Copyright (c) 2013 Sergey Dikarev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FactualSDK/FactualAPI.h>
#import <CoreLocation/CoreLocation.h>
#import "Defines.h"

extern NSString * const PREFS_FACTUAL_TABLE;
extern NSString * const PLACES_TABLE_DESC;
extern NSString * const RESTAURANTS_TABLE_DESC;

extern NSString * const PREFS_GEO_ENABLED;
extern NSString * const PREFS_TRACKING_ENABLED;
extern NSString * const PREFS_LATITUDE;
extern NSString * const PREFS_LONGITUDE;
extern NSString * const PREFS_RADIUS;

extern NSString * const PREFS_LOCALITY_FILTER_ENABLED;
extern NSString * const PREFS_LOCALITY_FILTER_TYPE;
extern NSString * const PREFS_LOCALITY_FILTER_TEXT;

extern NSString * const PREFS_CATEGORY_FILTER_ENABLED;
extern NSString * const PREFS_CATEGORY_FILTER_TYPE;


@interface DKAHelper : NSObject <CLLocationManagerDelegate, NSURLSessionDelegate>

@property (nonatomic, strong) NSMutableDictionary *searchPrefs;
@property (nonatomic, readonly) FactualAPI* apiObject;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLLocation *currentLocation;
@property (nonatomic, strong) CLPlacemark *placemark;
@property (nonatomic, strong) NSURLSession *session;
+(id)sharedInstance;
-(void)doQueryWithLocation:(CLLocation *)location completion:(DKAFactualHelperCompletionBlock)completion;
-(void)doQueryWithSearchTerm:(NSString *)searchTerm completion:(DKAFactualHelperCompletionBlock)completion;
-(void)startUpdateLocation;
-(CGFloat)getLabelSize:(UILabel *)label fontSize:(NSInteger)fontSize;
-(id)getPrefValueForKey:(NSString *)key;
-(void)setPrefValueForKey:(NSString *)key val:(id)val;
- (UIImage *)radialGradientImage:(CGSize)size start:(float)start end:(float)end centre:(CGPoint)centre radius:(float)radius;
-(BOOL)isIphone5;
-(void)poisNearLocation:(CLLocationCoordinate2D)location completionBlock:(DKAgetPOIsCompletionBlock)completionBlock;
-(void)photosByVenueId:(NSString *)venueId completionBlock:(DKAphotosByVenueIdCompletionBlock)completionBlock;
-(void)poisByKeyword:(NSString *)keyword completionBlock:(DKAgetPOIsCompletionBlock)completionBlock;
- (void)getTwitterAround:(double)lat lng:(double)lng completionBlock:(DKAgetPOIsCompletionBlock)completionBlock;
-(void)getInstagramAround:(double)lat lng:(double)lng completionBlock:(DKAgetPOIsCompletionBlock)completionBlock;
- (void)getFacebookAround:(double)lat lng:(double)lng completionBlock:(DKAgetPOIsCompletionBlock)completionBlock;
-(void)getWeatherAround:(double)lat lng:(double)lng completionBlock:(DKAgetWeatherAroundCompletionBlock)completionBlock;
-(void)refreshSession;
-(CGFloat)getLabelSizeWithWidth:(UILabel *)label fontSize:(NSInteger)fontSize width:(float)width;
@end
