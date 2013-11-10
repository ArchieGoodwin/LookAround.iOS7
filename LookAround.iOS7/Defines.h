#import "DKAAppDelegate.h"
#import <FactualSDK/FactualQuery.h>
#import <FactualSDK/FactualAPI.h>

#define DKALocationUpdated @"LocationUpdated"
#define DKALocationMuchUpdated @"LocationMuchUpdated"
#define LOCATIONLISTFONTSIZE 18

#define DKA_PREF_DATA_SOURCE @"DKA_PREF_DATA_SOURCE"
#define DKA_PREF_APP_HAS_STARTED @"DKA_PREF_APP_HAS_STARTED"


typedef void (^DKAFactualHelperCompletionBlock)  (FactualQueryResult *data, NSError *error);

#define helper ((DKAHelper *)[DKAHelper sharedInstance])
#define appDelegate ((DKAAppDelegate *)[[UIApplication sharedApplication] delegate])

