#import "DKAAppDelegate.h"
#import <FactualSDK/FactualQuery.h>
#import <FactualSDK/FactualAPI.h>

#define DKALocationUpdated @"LocationUpdated"
#define DKALocationMuchUpdated @"LocationMuchUpdated"
#define LOCATIONLISTFONTSIZE 18

#define DKA_PREF_DATA_SOURCE @"DKA_PREF_DATA_SOURCE"
#define DKA_PREF_APP_HAS_STARTED @"DKA_PREF_APP_HAS_STARTED"

typedef void (^DKAphotosByVenueIdCompletionBlock)        (NSArray *result, NSError *error);
typedef void (^DKAgetPOIsCompletionBlock)        (NSArray *result, NSError *error);

typedef void (^DKAFactualHelperCompletionBlock)  (FactualQueryResult *data, NSError *error);

#define CLIENT_ID @"4AI4XUE0BZQ2G1PFEIUITRMTNHQ45I353UMKWF30TPNLAVLK"
#define CLIENT_SECRET @"XJEEEUDB25ATGNQFHN04AGWTCTN0INXEXLBJOMOU25BRM20I"
#define PATH_TO_4SERVER @"https://api.foursquare.com/v2/venues/explore?"
#define PATH_TO_4SERVER_SEEARCH @"https://api.foursquare.com/v2/venues/search?"



#define LIMIT @"50"
#define RADIUS @"500"


#define helper ((DKAHelper *)[DKAHelper sharedInstance])
#define appDelegate ((DKAAppDelegate *)[[UIApplication sharedApplication] delegate])


#define BLUE0 [UIColor colorWithRed:44 / 255 green:85 / 255 blue:103 / 255 alpha:1]
#define BLUE1 [UIColor colorWithRed:255 / 255 green:168 / 255 blue:108 / 255 alpha:1]
#define BLUE2 [UIColor colorWithRed:108 / 255 green:210 / 255 blue:255 / 255 alpha:1]
#define BLUE3 [UIColor colorWithRed:255 / 255 green:212 / 255 blue:181 / 255 alpha:1]
#define BLUE4 [UIColor colorWithRed:218 / 255 green:244 / 255 blue:255 / 255 alpha:1]
#define BLUE5 [UIColor colorWithRed:248.0 / 255 green:252.0 / 255 blue:255.0 / 255 alpha:1]
#define BLUE6 [UIColor colorWithRed:255.0 / 255 green:168.0 / 255 blue:108.0 / 255 alpha:0.5]




#define BROWN0 [UIColor colorWithRed:94 / 255 green:63 / 255 blue:55 / 255 alpha:1]
#define BROWN1 [UIColor colorWithRed:177 / 255 green:131 / 255 blue:104 / 255 alpha:1]
#define BROWN2 [UIColor colorWithRed:255 / 255 green:206 / 255 blue:149 / 255 alpha:1]
#define BROWN3 [UIColor colorWithRed:255 / 255 green:221 / 255 blue:149 / 255 alpha:1]
#define BROWN4 [UIColor colorWithRed:255 / 255 green:233 / 255 blue:149 / 255 alpha:1]


typedef enum ScrollDirection {
    ScrollDirectionNone,
    ScrollDirectionRight,
    ScrollDirectionLeft,
    ScrollDirectionUp,
    ScrollDirectionDown,
    ScrollDirectionCrazy,
} ScrollDirection;