//
//  Search.h
//  LookAround.iOS7
//
//  Created by Nero Wolfe on 01/12/13.
//  Copyright (c) 2013 Sergey Dikarev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Search : NSManagedObject

@property (nonatomic, retain) NSString * searchString;
@property (nonatomic, retain) NSDate * searchDate;
@property (nonatomic, retain) NSData * searchDict;
@property (nonatomic, retain) NSString * searchId;

@end
