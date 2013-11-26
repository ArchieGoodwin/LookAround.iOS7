//
//  DKAPlace.h
//  LookAround.iOS7
//
//  Created by Nero Wolfe on 21/11/13.
//  Copyright (c) 2013 Sergey Dikarev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DKAHelper.h"
@interface DKAPlace : NSObject

@property (nonatomic, strong) NSString *placeName;
@property (nonatomic, strong) NSString *placeCategory;
@property (nonatomic, strong) NSString *placeId;
@property (nonatomic, strong) NSString *venueId;

@property (nonatomic, assign) NSInteger dataSourceType;
@property (nonatomic, assign) float latitude;
@property (nonatomic, assign) float longitude;
@property (nonatomic, assign) float distance;
@property (nonatomic, strong) NSString *address;
@property (nonatomic, strong) NSString *city;
@property (nonatomic, strong) NSString *postcode;
@property (nonatomic, strong) NSString *tel;
@property (nonatomic, strong) NSString *iconUrl;
@property (nonatomic, strong) NSString *canonicalUrl;
@property (nonatomic, strong) NSString *twitter;
@property (nonatomic, assign) NSInteger hereNow;
@property (nonatomic, strong) NSString *status;
@property (nonatomic, assign) NSInteger likes;
@property (nonatomic, strong) NSDictionary *location;
@property (nonatomic, assign) float rating;
@property (nonatomic, strong) NSString *reservationUrl;
@property (nonatomic, assign) NSInteger checkinsCount;
@property (nonatomic, assign) NSInteger userCount;
@property (nonatomic, strong) NSDictionary *menu;

-(DKAPlace *)initWithFactualData:(FactualRow *)row;
-(DKAPlace *)initWith4s:(NSMutableDictionary *)dict;

-(NSMutableArray *)getListOfFields;
@end
