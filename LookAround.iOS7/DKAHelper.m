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
#import "NWFourSquarePhoto.h"
#import "DKAPlace.h"
#import <Accounts/Accounts.h>
#import <Social/Social.h>
#import "NWtwitter.h"
#import "NWinstagram.h"

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
{
    
}

#pragma mark - Helper methods

-(BOOL)isIphone5
{
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
        if ([[UIScreen mainScreen] respondsToSelector: @selector(scale)]) {
            CGSize result = [[UIScreen mainScreen] bounds].size;
            CGFloat scale = [UIScreen mainScreen].scale;
            result = CGSizeMake(result.width * scale, result.height * scale);
            
            if(result.height == 960) {
                //NSLog(@"iPhone 4 Resolution");
                return NO;
            }
            if(result.height == 1136) {
                //NSLog(@"iPhone 5 Resolution");
                //[[UIScreen mainScreen] bounds].size =result;
                return YES;
            }
        }
        else{
            // NSLog(@"Standard Resolution");
            return NO;
        }
    }
    return NO;
}



-(void)populateAppDefaults
{
    
    if([self getPrefValueForKey:DKA_PREF_DATA_SOURCE] == nil)
    {
        [[NSUserDefaults standardUserDefaults] setObject:@"Factual" forKey:DKA_PREF_DATA_SOURCE];
        [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:DKA_PREF_APP_HAS_STARTED];
        
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    if([self getPrefValueForKey:DKA_PREF_REFRESH] == nil)
    {
        [[NSUserDefaults standardUserDefaults] setObject:@"Auto" forKey:DKA_PREF_REFRESH];
        
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    if([self getPrefValueForKey:DKA_PREF_STEPS_DAYS] == nil)
    {
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithDouble:10.0] forKey:DKA_PREF_STEPS_DAYS];
        
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

-(CGFloat)getLabelSizeWithWidth:(UILabel *)label fontSize:(NSInteger)fontSize width:(float)width
{
    
    
    NSDictionary *attributesDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                          [UIFont systemFontOfSize:fontSize], NSFontAttributeName,
                                          nil];
    
    CGRect frame = [label.text boundingRectWithSize:CGSizeMake(width, 2000.0)
                                            options:NSStringDrawingUsesLineFragmentOrigin
                                         attributes:attributesDictionary
                                            context:nil];
    
    CGSize size = frame.size;
    
    return size.height;
}

#pragma mark - Factual methods




-(void)doQueryWithLocation:(CLLocation *)location completion:(DKAFactualHelperCompletionBlock)completion
{
    if(_placemark)
    {
        [_searchPrefs setValue:[NSNumber numberWithBool:YES] forKey:PREFS_LOCALITY_FILTER_ENABLED];
        [_searchPrefs setValue:@"country" forKey:PREFS_LOCALITY_FILTER_TYPE];
        [_searchPrefs setValue:[_placemark.addressDictionary objectForKey:@"CountryCode"] forKey:PREFS_LOCALITY_FILTER_TEXT];
    }
    
    
    
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


-(void)getLocality
{
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:[[CLLocation alloc] initWithLatitude:_currentLocation.coordinate.latitude longitude:_currentLocation.coordinate.longitude] completionHandler:^(NSArray *placemarks, NSError *error) {
        if (error == nil) {

            NSLog(@"%@", [NSString stringWithFormat:@"%@,%@", [[placemarks objectAtIndex:0] locality], [[placemarks objectAtIndex:0] country]]);
            _placemark = [placemarks objectAtIndex:0];
            NSLog(@"%@", [_placemark.addressDictionary objectForKey:@"CountryCode"]);
            //self.location.address = ABCreateStringWithAddressDictionary([[placemarks objectAtIndex:0] addressDictionary], NO);
            
            
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:DKALocationMuchUpdated object:self userInfo:nil];

        //[MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        
    }];
}


-(void)getLocationsForSearchString:(NSString *)searchStr completionBlock:(DKAgetPOIsCompletionBlock)completionBlock
{
    
    DKAgetPOIsCompletionBlock cBlock = completionBlock;
    
    CLGeocoder *geo = [[CLGeocoder alloc] init];
    [geo geocodeAddressString:searchStr
            completionHandler:^(NSArray *placemarks, NSError *error) {
                /*NSMutableArray *filteredPlacemarks = [[NSMutableArray alloc] init];
                 for (CLPlacemark *placemark in placemarks) {
                 if ([placemark.location distanceFromLocation:centerLocation] <= maxDistance) {
                 [filteredPlacemarks addObject:placemark];
                 }
                 } */
                NSLog(@"results: %i", placemarks.count);
                if(cBlock)
                {
                    cBlock(placemarks, error);
                }
                
            }];
}


#pragma mark - Instagram methods

-(void)getInstagramAround:(double)lat lng:(double)lng completionBlock:(DKAgetPOIsCompletionBlock)completionBlock
{
    DKAgetPOIsCompletionBlock completeBlock = [completionBlock copy];
    
    
    NSString *connectionString = [NSString stringWithFormat:@"https://api.instagram.com/v1/media/search?lat=%f&lng=%f&client_id=e6c25413297343d087a7918f284ce83e&distance=300", lat, lng];
    NSLog(@"getInstagramAround %@", connectionString);
    NSURL *url = [NSURL URLWithString:connectionString];
    
    if(!_session)
    {
        [self refreshSession];
    }
    
    NSURLSessionDataTask *getTask =
    [_session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSError *jsonError;
        
        NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonError];
        NSLog(@"JSON insta: %@", JSON);
        
        if (!error) {
            
            NSMutableArray *instas = [[NSMutableArray alloc] init];
            

            NSMutableArray *items = [JSON objectForKey:@"data"];
            for (NSMutableDictionary *dict in items) {
                NWinstagram *item = [[NWinstagram alloc] initWithDictionary:dict];
                [instas addObject:item];
            }
            
            if(instas.count > 0)
            {
                completeBlock(instas, nil);

            }
            else
            {
                NSMutableDictionary* details = [NSMutableDictionary dictionary];
                [details setValue:@"No photos" forKey:NSLocalizedDescriptionKey];
                NSError *err = [NSError errorWithDomain:@"world" code:500 userInfo:details];
                completeBlock(nil, err);
            }
        }
        else
        {
            NSLog(@"error while instagram: %@", error.description);
            completeBlock(nil, error);
        }
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }];
    
    [getTask resume];
    
    
}



#pragma mark - Twitter methods

- (void)getTwitterAround:(double)lat lng:(double)lng completionBlock:(DKAgetPOIsCompletionBlock)completionBlock
{
    DKAgetPOIsCompletionBlock completeBlock = [completionBlock copy];
    
    NSMutableArray *result = [NSMutableArray new];
    // Request access to the Twitter accounts
    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    [accountStore requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL granted, NSError *error){
        if (granted) {
            NSArray *accounts = [accountStore accountsWithAccountType:accountType];
            // Check if the users has setup at least one Twitter account
            if (accounts.count > 0)
            {
                ACAccount *twitterAccount = [accounts objectAtIndex:0];
                // Creating a request to get the info about a user on Twitter
                
                //NSDateComponents *componentsToSubtract = [[NSDateComponents alloc] init];
                //[componentsToSubtract setDay:-5];
                
                //NSDate *yesterday = [[NSCalendar currentCalendar] dateByAddingComponents:componentsToSubtract  toDate:[NSDate date] options:0];
                
                //NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
                //[dateFormat setDateFormat:@"yyyy-MM-dd"];
                //NSString *dateString = [dateFormat stringFromDate:[NSDate date]];
                
                SLRequest *twitterInfoRequest = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodGET URL:[NSURL URLWithString:@"https://api.twitter.com/1.1/search/tweets.json?"] parameters:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%.6f,%.6f,0.2km", lat, lng], @"geocode", @"100", @"count", nil]];
                [twitterInfoRequest setAccount:twitterAccount];
                // Making the request
                [twitterInfoRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
                    //NSLog(@"twitter res  %@", [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding]);
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        // Check if we reached the reate limit
                        if ([urlResponse statusCode] == 429) {
                            NSLog(@"Rate limit reached");
                            return;
                        }
                        // Check if there was an error
                        if (error) {
                            NSLog(@"Error: %@", error.localizedDescription);
                            return;
                        }
                        // Check if there is some response data
                        if (responseData) {
                            NSError *error = nil;
                            NSArray *TWData = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&error];
                            // Filter the preferred data
                            //NSLog(@"%@", TWData);
                            
                            
                            NSMutableArray *results = [((NSDictionary *)TWData) objectForKey:@"statuses"];
                            for(NSMutableDictionary *dict in results)
                            {
                                NWtwitter *twi = [[NWtwitter alloc] initWithDictionary:dict];
                                [result addObject:twi];
                            }
                            
                            completeBlock(result, nil);
                            
                        }
                    });
                }];
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning!" message:@"To use twitter search around place please add twitter account to iOS settings" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                    [alert show];
                });
                
                completeBlock(nil, nil);
                
            }
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning!" message:@"To use twitter search around place please add twitter account to iOS settings" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alert show];
            });
            
            completeBlock(nil, nil);
        }
    }];
    
}

#pragma mark - Weather

-(void)getWeatherAround:(double)lat lng:(double)lng completionBlock:(DKAgetWeatherAroundCompletionBlock)completionBlock
{
    //http://free.worldweatheronline.com/feed/weather.ashx?q=34.00,43.00&format=json&num_of_days=2&key=b603d14d52054854131903
    
    DKAgetWeatherAroundCompletionBlock completeBlock = [completionBlock copy];
    
    
    NSString *connectionString = [NSString stringWithFormat:@"http://api.worldweatheronline.com/free/v1/weather.ashx?q=%f,%f&format=json&num_of_days=2&key=y63g6gb5zfkh84wjyheednaz", lat, lng];
    NSLog(@"%@", connectionString);
    NSURL *url = [NSURL URLWithString:connectionString];
    if(!_session)
    {
        [self refreshSession];
    }

    
    NSURLSessionDataTask *getTask =
    [_session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSError *jsonError;
        
        NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonError];
        NSLog(@"JSON weather: %@", JSON);
        
        if (!error) {
            
            NWWeather *item = [[NWWeather alloc] initWithDictionary:[JSON objectForKey:@"data"]];
            
            completeBlock(item, nil);
        }
        else
        {
            NSLog(@"error while weather: %@", error.description);
            completeBlock(nil, error);
        }
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }];
    
    [getTask resume];
    
    
    
    
}



#pragma mark - Facebook methods

- (void)getFacebookAround:(double)lat lng:(double)lng completionBlock:(DKAgetPOIsCompletionBlock)completionBlock
{
    DKAgetPOIsCompletionBlock completeBlock = [completionBlock copy];
    
    NSMutableArray *result = [NSMutableArray new];
    // Request access to the Twitter accounts
    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    
    NSDictionary *options = @{
                              ACFacebookAppIdKey : @"630474416991234",
                              ACFacebookPermissionsKey : @[ @"email"],
                              ACFacebookAudienceKey: ACFacebookAudienceEveryone}; // Needed only when write permissions are requested

    
    ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
    [accountStore requestAccessToAccountsWithType:accountType options:options completion:^(BOOL granted, NSError *error){
        if (granted) {
            NSArray *accounts = [accountStore accountsWithAccountType:accountType];
            // Check if the users has setup at least one Twitter account
            if (accounts.count > 0)
            {
                ACAccount *fbAccount = [accounts objectAtIndex:0];
                // Creating a request to get the info about a user on Twitter
                
                //NSDateComponents *componentsToSubtract = [[NSDateComponents alloc] init];
                //[componentsToSubtract setDay:-5];
                
                //NSDate *yesterday = [[NSCalendar currentCalendar] dateByAddingComponents:componentsToSubtract  toDate:[NSDate date] options:0];
                
                //NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
                //[dateFormat setDateFormat:@"yyyy-MM-dd"];
                //NSString *dateString = [dateFormat stringFromDate:[NSDate date]];
                //q=coffee&type=place. ?
                
                //fbAccount.credential = [[ACAccountCredential alloc] initWithOAuthToken:@"89ad1034f4a379b242865948c1558313" tokenSecret:@"052f0fe96d616311211d43f95291bc97"];

                
                //SLRequest *twitterInfoRequest = [SLRequest requestForServiceType:SLServiceTypeFacebook requestMethod:SLRequestMethodGET URL:[NSURL URLWithString:@"https://graph.facebook.com/search?"] parameters:[NSDictionary dictionaryWithObjectsAndKeys:@"coffee", @"q", [NSString stringWithFormat:@"%.6f,%.6f", lat, lng], @"center", @"place", @"type", fbAccount.credential.oauthToken, @"access_token", nil]];
                NSString *acessToken = [NSString stringWithFormat:@"%@",fbAccount.credential.oauthToken];
                NSDictionary *parameters = @{@"access_token": acessToken, @"q": @"coffee", @"center": [NSString stringWithFormat:@"%.6f,%.6f", lat, lng]};
                NSURL *feedURL = [NSURL URLWithString:@"https://graph.facebook.com/search?"];
                SLRequest *twitterInfoRequest = [SLRequest
                                          requestForServiceType:SLServiceTypeFacebook
                                          requestMethod:SLRequestMethodGET
                                          URL:feedURL
                                          parameters:parameters];
                
                NSLog(@"access_token: %@",  parameters);
                [twitterInfoRequest setAccount:fbAccount];
                // Making the request
                [twitterInfoRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
                    //NSLog(@"twitter res  %@", [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding]);
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        // Check if we reached the reate limit
                        if ([urlResponse statusCode] == 429) {
                            NSLog(@"Rate limit reached");
                            return;
                        }
                        // Check if there was an error
                        if (error) {
                            NSLog(@"Error: %@", error.localizedDescription);
                            return;
                        }
                        // Check if there is some response data
                        if (responseData) {
                            NSError *error = nil;
                            NSDictionary *TWData = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&error];
                            // Filter the preferred data
                            NSLog(@"%@", TWData);
                            
                            
                            NSMutableArray *results = [((NSDictionary *)TWData) objectForKey:@"statuses"];
                            for(NSMutableDictionary *dict in results)
                            {
                                NWtwitter *twi = [[NWtwitter alloc] initWithDictionary:dict];
                                [result addObject:twi];
                            }
                            
                            completeBlock(result, nil);
                            
                        }
                    });
                }];
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning!" message:@"To use Facebook search around place please add Facebook account to iOS settings" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                    [alert show];
                });
                
                completeBlock(nil, nil);
                
            }
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning!" message:@"To use Facebook search around place please add Facebook account to iOS settings" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alert show];
            });
            
            completeBlock(nil, nil);
        }
    }];
    
}


#pragma mark - 4s methods


-(void)poisByKeyword:(NSString *)keyword completionBlock:(DKAgetPOIsCompletionBlock)completionBlock
{
    
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    [self poisByKeywords:keyword near:@"" completionBlock:^(NSArray *result, NSError *error) {
        if(!error)
        {
            NSSortDescriptor *sortDescriptor;
            sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"distance" ascending:YES selector:@selector(compare:)];
            NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
            if(completionBlock)
            {
                completionBlock([NSMutableArray arrayWithArray:[result sortedArrayUsingDescriptors:sortDescriptors]], nil);
            }
            
        }
        else
        {
            if(completionBlock)
            {
                completionBlock(nil, error);
            }
        }
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }];

    
    
    /*[self getLocationsForSearchString:keyword completionBlock:^(NSArray *result, NSError *error) {
     
        if(result.count > 0)
        {
     
            NSMutableArray *temp = [[keyword componentsSeparatedByString:@","] mutableCopy];
            

            
            CLPlacemark  *placem = [result objectAtIndex:0];
            
            NSString *loc = [NSString stringWithFormat:@"%.10f,%.10f", placem.location.coordinate.latitude, placem.location.coordinate.longitude];

            
            NSLog(@"Placemark: %@", placem.addressDictionary);
            if(YES)
            {

                [self poisByKeywords:keyword near:loc completionBlock:^(NSArray *result, NSError *error) {
                    if(!error)
                    {
                        NSSortDescriptor *sortDescriptor;
                        sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"distance" ascending:YES selector:@selector(compare:)];
                        NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
                        if(completionBlock)
                        {
                            completionBlock([NSMutableArray arrayWithArray:[result sortedArrayUsingDescriptors:sortDescriptors]], nil);
                        }

                    }
                    else
                    {
                        if(completionBlock)
                        {
                            completionBlock(nil, error);
                        }
                    }
                    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                }];
                
            }
            else
            {

                [self poisNearLocation:CLLocationCoordinate2DMake(placem.location.coordinate.latitude, placem.location.coordinate.longitude) completionBlock:^(NSArray *result, NSError *error) {
                    if(!error)
                    {
                        NSSortDescriptor *sortDescriptor;
                        sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"distance" ascending:YES selector:@selector(compare:)];
                        NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
                        if(completionBlock)
                        {
                            completionBlock([NSMutableArray arrayWithArray:[result sortedArrayUsingDescriptors:sortDescriptors]], nil);
                        }
                        
                        
                        
                    }
                    else
                    {
                        if(completionBlock)
                        {
                            completionBlock(nil, error);
                        }
                    }
                    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                    
                    
                }];
            }
            
            
            
            
        }
        else
        {
            completionBlock(nil, nil);
            
        }
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];

        
        
        
    }];*/
    
    
}

-(NSString*)stringWithPercentEscape:(NSString *)str {
    return (NSString *) CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)[str mutableCopy], NULL, CFSTR("￼=,!$&'()*+;@?\n\"<>#\t :/"),kCFStringEncodingUTF8));
}


-(void)poisByKeywords:(NSString *)keyword near:(NSString *)near completionBlock:(DKAgetPOIsCompletionBlock)completionBlock
{
    
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    DKAgetPOIsCompletionBlock completeBlock = [completionBlock copy];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
	[dateFormat setDateFormat:@"yyyyMMdd"];
	NSString *dateString = [dateFormat stringFromDate:[NSDate date]];
    
    
    
    NSString *connectionString = [NSString stringWithFormat:@"%@query=%@&intent=global&client_id=%@&client_secret=%@&v=%@&limit=%@", PATH_TO_4SERVER_SEEARCH, [self stringWithPercentEscape:keyword], CLIENT_ID, CLIENT_SECRET, dateString, @"50"];
    NSLog(@"connect to: %@",connectionString);
    
    
    if(!_session)
    {
        [self refreshSession];
    }

    
    
    NSURLSessionDataTask *getTask =
    [_session dataTaskWithURL:[NSURL URLWithString:connectionString] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSError *jsonError;
        
        NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonError];
        NSLog(@"JSON: %@", JSON);
        NSMutableArray *pois = [[NSMutableArray alloc] init];
        
        if (!error) {
            
            NSMutableArray *items = [[JSON objectForKey:@"response"] objectForKey:@"venues"];
            for (NSMutableDictionary *dict in items) {
                DKAPlace *item = [[DKAPlace alloc] initWith4s:dict];
                [pois addObject:item];
            }
            
            if(pois.count > 0)
            {
                
                NSSortDescriptor * sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"distance" ascending:YES];
                if(completeBlock)
                {
                    completeBlock([pois sortedArrayUsingDescriptors:[NSMutableArray arrayWithObjects:sortDescriptor, nil]], nil);
                    
                }
            }
            else
            {
                completeBlock(pois, nil);
            }
        }
        else
        {
            NSLog(@"error while searching by keywprd: %@", error.description);
            completeBlock(nil, error);
        }
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }];
    
    [getTask resume];
    
    
}


-(void)poisNearLocation:(CLLocationCoordinate2D)location completionBlock:(DKAgetPOIsCompletionBlock)completionBlock
{
    
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    DKAgetPOIsCompletionBlock completeBlock = [completionBlock copy];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
	[dateFormat setDateFormat:@"yyyyMMdd"];
	NSString *dateString = [dateFormat stringFromDate:[NSDate date]];
    
    NSString *loc = [NSString stringWithFormat:@"%.10f,%.10f", location.latitude, location.longitude];
    
    
    NSString *connectionString = [NSString stringWithFormat:@"%@ll=%@&client_id=%@&client_secret=%@&v=%@&limit=%@&radius=%@", PATH_TO_4SERVER, loc, CLIENT_ID, CLIENT_SECRET, dateString, LIMIT, RADIUS];
    NSLog(@"connect to: %@",connectionString);
    
    if(!_session)
    {
        [self refreshSession];
    }

    
    NSURLSessionDataTask *getTask =
    [_session dataTaskWithURL:[NSURL URLWithString:connectionString] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSError *jsonError;
        
        NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonError];
        NSMutableArray *pois = [[NSMutableArray alloc] init];
        
        if (!jsonError) {
            
            NSMutableArray *items = [[[[JSON objectForKey:@"response"] objectForKey:@"groups"] objectAtIndex:0] objectForKey:@"items"];
            for (NSMutableDictionary *dict in items) {
                DKAPlace *item = [[DKAPlace alloc] initWith4s:[dict objectForKey:@"venue"]];
                [pois addObject:item];
            }
            
            if(pois.count > 0)
            {
                
                NSSortDescriptor * sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"distance" ascending:YES];
                if(completeBlock)
                {
                    completeBlock([pois sortedArrayUsingDescriptors:[NSMutableArray arrayWithObjects:sortDescriptor, nil]], nil);
                    
                }
            }
            else
            {
                completeBlock(pois, nil);
            }
        }
        else
        {
            completeBlock(nil, jsonError);
        }
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }];
    
    [getTask resume];
    

}




-(void)photosByVenueId:(NSString *)venueId completionBlock:(DKAphotosByVenueIdCompletionBlock)completionBlock
{
    
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    DKAphotosByVenueIdCompletionBlock completeBlock = [completionBlock copy];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
	[dateFormat setDateFormat:@"yyyyMMdd"];
	NSString *dateString = [dateFormat stringFromDate:[NSDate date]];
    
    
    NSString *connectionString = [NSString stringWithFormat:@"https://api.foursquare.com/v2/venues/%@/photos?group=venue&client_id=%@&client_secret=%@&v=%@", venueId, CLIENT_ID, CLIENT_SECRET, dateString];
    NSLog(@"connect to: %@",connectionString);
    
    if(!_session)
    {
        [self refreshSession];
    }

 
 
    NSURLSessionDataTask *getTask =
    [_session dataTaskWithURL:[NSURL URLWithString:connectionString] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSError *jsonError;

        NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonError];
        NSMutableArray *pois = [[NSMutableArray alloc] init];
        NSLog(@"JSON: %@", JSON);

        if (!error) {
            
            NSMutableArray *items = [[[JSON objectForKey:@"response"] objectForKey:@"photos"] objectForKey:@"items"];
            for (NSMutableDictionary *dict in items) {
                NWFourSquarePhoto *item = [[NWFourSquarePhoto alloc] initWithDictionary:dict];
                [pois addObject:item];
            }
            
            if(pois.count > 0)
            {
                
                if(completeBlock)
                {
                    completeBlock(pois, nil);
                    
                }
            }
            else
            {
                completeBlock(nil, nil);
            }
        }
        else
        {
            completeBlock(nil, error);
        }
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }];

    [getTask resume];
    

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
        
        
        [self refreshSession];
    }
    
    return self;
    
}

-(void)refreshSession
{
    NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    //[sessionConfig setHTTPAdditionalHeaders: @{@"Accept": @"application/json"}];
    sessionConfig.timeoutIntervalForRequest = 30.0;
    sessionConfig.timeoutIntervalForResource = 30.0;
    sessionConfig.HTTPMaximumConnectionsPerHost = 15;
    
    _session = [NSURLSession sessionWithConfiguration:sessionConfig delegate:self delegateQueue:nil];
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

    if(distance > 20)
    {
        NSLog(@"SIGNIFICANTSHIFT");
        
        [self getLocality];
        
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
