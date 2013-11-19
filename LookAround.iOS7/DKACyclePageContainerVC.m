//
//  DKACyclePageContainerVC.m
//  LookAround.iOS7
//
//  Created by Nero Wolfe on 19/11/13.
//  Copyright (c) 2013 Sergey Dikarev. All rights reserved.
//

#import "DKACyclePageContainerVC.h"

@interface DKACyclePageContainerVC ()

@end

@implementation DKACyclePageContainerVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _cyclePageView = [[GTCyclePageView alloc] initWithFrame:self.view.bounds];
    _cyclePageView.dataSource = self;
    _cyclePageView.delegate = self;
    [self.view addSubview:_cyclePageView];
    
    [_cyclePageView reloadData];
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - GTCyclePageViewDataSource

- (NSUInteger)numberOfPagesInCyclePageView:(GTCyclePageView *)cyclePageView
{
    return 5;
}

- (GTCyclePageViewCell *)cyclePageView:(GTCyclePageView *)cyclePageView index:(NSUInteger)index
{
    static NSString *cellIdentifier = @"cellIdentifier";
    GTCyclePageViewCell *cell = [cyclePageView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[GTCyclePageViewCell alloc] initWithReuseIdentifier:cellIdentifier];
    }
    
    switch (index) {
        case 0: {
            cell.backgroundColor = [UIColor purpleColor];
            break;
        }
        case 1: {
            cell.backgroundColor = [UIColor redColor];
            break;
        }
        case 2: {
            cell.backgroundColor = [UIColor blueColor];
            break;
        }
        case 3: {
            cell.backgroundColor = [UIColor yellowColor];
            break;
        }
        case 4: {
            cell.backgroundColor = [UIColor greenColor];
            break;
        }
        default:
            break;
    }
    
    return cell;
}

#pragma mark - GTCyclePageViewDelegate

- (void)cyclePageView:(GTCyclePageView *)cyclePageView didTouchCellAtIndex:(NSUInteger)index
{
    NSLog(@"tap: %i", index);
}

@end
