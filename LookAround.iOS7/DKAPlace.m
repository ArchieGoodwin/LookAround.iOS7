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


@end
