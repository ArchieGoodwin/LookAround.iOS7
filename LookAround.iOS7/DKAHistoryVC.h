//
//  DKAHistoryVC.h
//  LookAround.iOS7
//
//  Created by Nero Wolfe on 10/11/13.
//  Copyright (c) 2013 Sergey Dikarev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASMediaFocusManager.h"
@interface DKAHistoryVC : UITableViewController  <ASMediasFocusDelegate>

@property (nonatomic, assign) BOOL isHistory;
@end
