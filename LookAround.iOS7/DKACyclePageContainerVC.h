//
//  DKACyclePageContainerVC.h
//  LookAround.iOS7
//
//  Created by Nero Wolfe on 19/11/13.
//  Copyright (c) 2013 Sergey Dikarev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GTCyclePageView.h"

@interface DKACyclePageContainerVC : UIViewController <GTCyclePageViewDataSource, GTCyclePageViewDelegate>
{
    GTCyclePageView *_cyclePageView;

}
@end
