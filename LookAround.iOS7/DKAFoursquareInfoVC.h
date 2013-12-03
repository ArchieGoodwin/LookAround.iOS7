//
//  DKAFoursquareInfoVC.h
//  LookAround.iOS7
//
//  Created by Nero Wolfe on 26/11/13.
//  Copyright (c) 2013 Sergey Dikarev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DKAPlace.h"
@interface DKAFoursquareInfoVC : UITableViewController <UIActionSheetDelegate>


@property (nonatomic, strong) DKAPlace *place;
@end
