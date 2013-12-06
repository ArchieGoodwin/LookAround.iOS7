//
//  DKASearchVC.h
//  LookAround.iOS7
//
//  Created by Nero Wolfe on 09/11/13.
//  Copyright (c) 2013 Sergey Dikarev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DKASearchVC : UITableViewController <UISearchBarDelegate>
@property (strong, nonatomic) IBOutlet UISearchBar *searchbar;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *btnIcon;

@end
