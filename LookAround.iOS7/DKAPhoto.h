//
//  DKAPhoto.h
//  LookAround.iOS7
//
//  Created by Nero Wolfe on 24/11/13.
//  Copyright (c) 2013 Sergey Dikarev. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DKAPhoto : NSObject


@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) float latitude;
@property (nonatomic, assign) float longitude;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) UIImage *thumbnail;

@property (nonatomic, strong) NSDate *dateShot;

@end
