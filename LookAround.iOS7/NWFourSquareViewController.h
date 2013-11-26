//
//  NWFourSquareViewController.h
//  LookAround
//
//  Created by Sergey Dikarev on 2/26/13.
//  Copyright (c) 2013 Sergey Dikarev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "StackedGridLayout.h"
#import "FlickrPhotoHeaderView.h"
#import "DKAPlaceVC.h"
@interface NWFourSquareViewController : UIViewController <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
{
    NSInteger page;
    NSInteger pageSize;
    BOOL isLoadingPage;
    BOOL isScrolling;
    NSInteger currentChaingeItemIndex;
    UIActivityIndicatorView *activityIndicator;
    
    UIView *viewForLabel;
}
@property (nonatomic, strong) DKAPlaceVC *parentContr;

@property (nonatomic, strong) CLLocation *searchLocation;
@property(nonatomic, strong)  UICollectionView *collectionView;
@property(nonatomic, strong) NSArray *chainges;
@property (nonatomic, strong) StackedGridLayout *layout3;
@property(nonatomic, assign) NSInteger currentPageType;

-(void)initCollectionViewWithRect:(CGRect)rect instas:(NSArray *)instas location:(CLLocation *)location;
@end
