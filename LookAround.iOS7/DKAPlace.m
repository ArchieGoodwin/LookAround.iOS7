//
//  DKAPlace.m
//  LookAround.iOS7
//
//  Created by Nero Wolfe on 21/11/13.
//  Copyright (c) 2013 Sergey Dikarev. All rights reserved.
//

#import "DKAPlace.h"
#import <FactualSDK/FactualQuery.h>


@implementation DKAPlace

/*
 FactualRow rowId:f948952f-be60-4ca1-b7ba-34cfbd70313b facetName:(null) valueCount:14
 Cell:neighborhood Value:(
 "Theatre District",
 Midtown,
 "Midtown West"
 )
 Cell:category_ids Value:(
 162
 )
 Cell:$distance Value:19.716684
 Cell:longitude Value:-73.984404
 Cell:address Value:701 7th Ave
 Cell:latitude Value:40.759216
 Cell:category_labels Value:(
 (
 Retail,
 "Music, Video and DVD"
 )
 )
 Cell:region Value:NY
 Cell:locality Value:New York
 Cell:name Value:Easy Mo Records
 Cell:postcode Value:10036
 Cell:country Value:us
 Cell:tel Value:(646) 912-9466
 Cell:factual_id Value:f948952f-be60-4ca1-b7ba-34cfbd70313b
 */

-(DKAPlace *)initWithFactualData:(FactualRow *)row
{
    _placeName = [row valueForName:@"name"];
    _dataSourceType = 0;
    _placeId = [row valueForName:@"factual_id"];
    _latitude = [[row valueForName:@"latitude"] floatValue];
    _longitude = [[row valueForName:@"longitude"] floatValue];
    _distance = [[row valueForName:@"distance"] floatValue];
    _city = [row valueForName:@"locality"];
    _address = [row valueForName:@"address"];
    _postcode = [row valueForName:@"postcode"];
    _tel = [row valueForName:@"tel"];

    
    return self;
}


-(NSMutableArray *)getListOfFields
{
    NSMutableArray *temp = [NSMutableArray new];
    
    
    NSDictionary *f1 = @{@"title": @"Name", @"fieldValue":_placeName, @"type":@"text"};
    NSDictionary *f3 = @{@"title": @"Rating", @"fieldValue":[NSNumber numberWithFloat:_rating], @"type":@"float"};
    NSDictionary *f4 = @{@"title": @"Likes", @"fieldValue":[NSNumber numberWithInt:_likes], @"type":@"int"};
    NSDictionary *f5 = @{@"title": @"Here now", @"fieldValue":[NSNumber numberWithInt:_hereNow], @"type":@"int"};
    NSDictionary *f6 = _status == nil ? nil : @{@"title": @"Status", @"fieldValue":_status, @"type":@"text"};
    NSDictionary *f7 = @{@"title": @"Checkins", @"fieldValue":[NSNumber numberWithInt:_checkinsCount], @"type":@"int"};
    NSDictionary *f8 = @{@"title": @"Users count", @"fieldValue":[NSNumber numberWithInt:_userCount], @"type":@"int"};
    NSDictionary *f9 = _canonicalUrl == nil ? nil : @{@"title": @"Web page", @"fieldValue":_canonicalUrl, @"type":@"link"};
    NSDictionary *f10 = @{@"title": @"Distance", @"fieldValue":[NSNumber numberWithFloat:_distance], @"type":@"float"};
    NSDictionary *f11 = @{@"title": @"Address", @"fieldValue":[NSString stringWithFormat:@"%@ %@", _address == nil ? @"" : _address, _city == nil ? @"" : _city], @"type":@"text"};
    NSDictionary *f12 = @{@"title": @"Directions", @"fieldValue":@"", @"type":@"directions"};
    NSDictionary *f13 = _reservationUrl == nil? nil : @{@"title": @"Reserve", @"fieldValue":@"Table Here", @"type":@"reservation"};


    if(f1)
    {
        [temp addObject:f1];
    }
    if(![[f11 objectForKey:@"fieldValue"] isEqualToString:@" "])
    {
        [temp addObject:f11];
    }
    if(f13)
    {
        [temp addObject:f13];
    }
    if(f10)
    {
        [temp addObject:f10];
    }
    if(f9)
    {
        [temp addObject:f9];
    }
    if(f3)
    {
        [temp addObject:f3];
    }
    if(f4)
    {
        [temp addObject:f4];
    }
    if(f5)
    {
        [temp addObject:f5];
    }
    if(f6)
    {
        [temp addObject:f6];
    }
    if(f7)
    {
        [temp addObject:f7];
    }
    if(f8)
    {
        [temp addObject:f8];
    }
    if(f12)
    {
        [temp addObject:f12];
    }

    
    return temp;
}

-(DKAPlace *)initWith4s:(NSMutableDictionary *)dict
{
    
    //NSLog(@"%@", dict);
    if(dict != nil)
    {
        _sourceDict = dict;

        
        /*NSMutableData *data = [[NSMutableData alloc] init];
        NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
        [archiver encodeObject:_sourceDict forKey:@"MyDict"];
        [archiver finishEncoding];
        
        
        NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
        NSDictionary *myDictionary = [unarchiver decodeObjectForKey:@"MyDict"];
        [unarchiver finishDecoding];*/
        
        
        @try {
            _dataSourceType = 1;
            self.placeName = [dict  objectForKey:@"name"];
            self.placeId = [dict objectForKey:@"id"];
            if([dict objectForKey:@"categories"] != nil && ((NSArray *)[dict objectForKey:@"categories"]).count > 0)
            {
                NSString *url = [[[[dict objectForKey:@"categories"] objectAtIndex:0] objectForKey:@"icon"] objectForKey:@"prefix"];
                NSString *ext = [[[[dict objectForKey:@"categories"] objectAtIndex:0] objectForKey:@"icon"] objectForKey:@"suffix"];
                NSString *fullUrl = [NSString stringWithFormat:@"%@_32%@", [url substringToIndex:[url length]-1], ext];
                self.iconUrl = fullUrl;
                
            }
            
            if([[dict objectForKey:@"location"] objectForKey:@"distance"] != [NSNull null])
            {
                self.distance = [[[dict objectForKey:@"location"] objectForKey:@"distance"] floatValue];
                
            }
            if([[dict objectForKey:@"location"] objectForKey:@"lat"] != [NSNull null])
            {
                self.latitude = [[[dict objectForKey:@"location"] objectForKey:@"lat"] doubleValue];
                self.longitude = [[[dict objectForKey:@"location"] objectForKey:@"lng"] doubleValue];
            }
            
            
            if(![[dict objectForKey:@"menu"] isEqual:[NSNull null]])
            {
                _menu = [dict objectForKey:@"menu"];
            }
            else
            {
                _menu = nil;
            }
            
            if(![[dict objectForKey:@"reservations"] isEqual:[NSNull null]])
            {
                if(![[[dict objectForKey:@"reservations"] objectForKey:@"url"] isEqual:[NSNull null]])
                {
                    _reservationUrl = [[dict objectForKey:@"reservations"] objectForKey:@"url"];

                }
                else
                {
                    _reservationUrl = nil;
                }
            }
            else
            {
                _reservationUrl = nil;
            }
            
            _canonicalUrl = [dict objectForKey:@"url"];
            _tel = [[dict objectForKey:@"contact"] objectForKey:@"formattedPhone"];
            _twitter = [[dict objectForKey:@"contact"] objectForKey:@"twitter"];
            _hereNow = [[[dict objectForKey:@"hereNow"] objectForKey:@"count"] integerValue];
            _status = [[dict objectForKey:@"hours"] objectForKey:@"status"];
            _likes = [[[dict objectForKey:@"likes"] objectForKey:@"count"] integerValue];
            _location = [dict objectForKey:@"location"];
            _rating = [[dict objectForKey:@"rating"] floatValue];
            _checkinsCount = [[[dict objectForKey:@"stats"] objectForKey:@"checkinsCount"] integerValue];
            _userCount = [[[dict objectForKey:@"stats"] objectForKey:@"usersCount"] integerValue];
            _city = [[dict objectForKey:@"location"] objectForKey:@"city"];
            if(!_city)
            {
                _city = @"Unknown";
            }
            _address = [[dict objectForKey:@"location"] objectForKey:@"address"];
            self.venueId = [[dict objectForKey:@"venuePage"] objectForKey:@"id"];

            _postcode = [[dict objectForKey:@"location"] objectForKey:@"postalCode"];
            
            NSLog(@"%@  %@", _placeId, _venueId);

            
            return self;
        }
        @catch (NSException *exception) {
            NSLog(@"Error while creating NWItem %@", exception.description);
            return nil;
        }
        @finally {
            
        }
        
        
        
    }
    
    
    return nil;
}



@end
