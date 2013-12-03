//
//  NWFourSquareViewController.m
//  LookAround
//
//  Created by Sergey Dikarev on 2/26/13.
//  Copyright (c) 2013 Sergey Dikarev. All rights reserved.
//

#import "NWFourSquareViewController.h"
#import "StackedGridLayout.h"
#import "InstagramCell.h"
#import "Defines.h"
#import "NWFourSquarePhoto.h"
#import <QuartzCore/QuartzCore.h>
#import "DKAPlace.h"
@interface NWFourSquareViewController ()
{
    CAGradientLayer *maskLayer;
    float lastContentOffset;
    NSCache *imagesCache;
}
@end

@implementation NWFourSquareViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    maskLayer.position = CGPointMake(0, scrollView.contentOffset.y);
    [CATransaction commit];
    
    
    /*ScrollDirection scrollDirection;
    if (lastContentOffset > scrollView.contentOffset.y)
        scrollDirection = ScrollDirectionUp;
    else
        scrollDirection = ScrollDirectionDown;
    
    lastContentOffset = scrollView.contentOffset.y;
    
    if(scrollDirection == ScrollDirectionDown)
    {
        if(lastContentOffset > 20.0)
        {
            [UIView animateWithDuration:0.4 animations:^{
                _parentContr.barName.alpha = 0.0;
            }];
        }
        
    }
    if(scrollDirection == ScrollDirectionUp)
    {
        [UIView animateWithDuration:0.4 animations:^{
            _parentContr.barName.alpha = 1.0;
        }];
        
    }*/
}

-(void)fadeView
{
    if (!maskLayer)
    {
        maskLayer = [CAGradientLayer layer];
        
        CGColorRef outerColor = [[UIColor colorWithWhite:1.0 alpha:1.0] CGColor];
        CGColorRef innerColor = [[UIColor colorWithWhite:1.0 alpha:0.0] CGColor];
        
        maskLayer.colors = [NSArray arrayWithObjects:
                            (__bridge id)innerColor,
                            (__bridge id)innerColor,
                            (__bridge id)innerColor,
                            (__bridge id)innerColor,
                            (__bridge id)outerColor, nil];
        
        maskLayer.locations = [NSArray arrayWithObjects:
                               [NSNumber numberWithFloat:0.0],
                               [NSNumber numberWithFloat:0.175],
                               [NSNumber numberWithFloat:0.575],
                               [NSNumber numberWithFloat:0.875],
                               [NSNumber numberWithFloat:1.0], nil];
        
        //[maskLayer setStartPoint:CGPointMake(0, 0.5)];
        //[maskLayer setEndPoint:CGPointMake(1, 0.5)];
        
        maskLayer.bounds = self.collectionView.bounds;
        maskLayer.anchorPoint = CGPointZero;
        
        [self.collectionView.layer insertSublayer: maskLayer atIndex: 0];
    }
}


-(void)back
{
    self.collectionView = nil;
    [self.view removeFromSuperview];
    
    [self removeFromParentViewController];
    
}

-(void)realInit:(CGRect)rect
{
    
    imagesCache = [[NSCache alloc] init];
    self.view = [[UIView alloc] initWithFrame:rect];
    
    self.view.backgroundColor = [UIColor clearColor];
    /* UIButton *btnBack = [UIButton buttonWithType:UIButtonTypeCustom];
     btnBack.frame = CGRectMake(7, 3, 44, 44);
     btnBack.backgroundColor = [UIColor clearColor];
     [btnBack setImage:[UIImage imageNamed:@"09-arrow-west.png"] forState:UIControlStateNormal];
     [btnBack addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
     [self.view addSubview:btnBack];*/
    
    
    isScrolling = NO;
    pageSize = 50;
    page = 1;
    isLoadingPage = YES;
    currentChaingeItemIndex = -1;
    CGRect frame = rect;
    frame.origin.y = rect.origin.y - 60;
    frame.size.height = rect.size.height;
    //self.view = [[UIView alloc] initWithFrame:frame];
    NSLog(@"frame %@", NSStringFromCGRect(frame));
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setItemSize:CGSizeMake(100, 100)];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    _collectionView = [[UICollectionView alloc] initWithFrame:frame collectionViewLayout:flowLayout];
    _collectionView.backgroundColor = [UIColor clearColor];
    
    
    [_collectionView setAllowsSelection:YES];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    
    
    self.layout3 = [[StackedGridLayout alloc] init];
    self.layout3.headerHeight = 0;
    self.layout3.footerHeight = 0;
    
    self.collectionView.collectionViewLayout = self.layout3;
    
    [self.collectionView registerClass:[InstagramCell class] forCellWithReuseIdentifier:@"myChaingeCell"];
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"FlickrPhotoHeaderView" bundle:[NSBundle mainBundle]] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"FlickrPhotoHeaderView"];
    
    [self.view addSubview:self.collectionView];
    
    
    /*UISwipeGestureRecognizer *showExtrasSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(cellSwipeRight:)];
    showExtrasSwipe.direction = UISwipeGestureRecognizerDirectionRight;
    [self.collectionView addGestureRecognizer:showExtrasSwipe];
    
    UISwipeGestureRecognizer *showExtrasSwipe2 = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(cellSwipeLeft:)];
    showExtrasSwipe2.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.collectionView addGestureRecognizer:showExtrasSwipe2];*/
    
    
    [helper photosByVenueId:_place.placeId completionBlock:^(NSArray *result, NSError *error) {
        if(!error)
        {
            _chainges = [result mutableCopy];
            [self.collectionView reloadData];
            if(_chainges.count == 0)
            {
                [self showMessageView];
            }
        }
        else
        {
            if(_chainges.count == 0)
            {
                [self showMessageView];
            }
        }
    }];
    
    
    
    
    //[self getChainges];
}

-(void)initCollectionViewWithRect:(CGRect)rect instas:(NSArray *)instas location:(CLLocation *)location
{
    
    
    _chainges = instas;
    
    [self realInit:rect];
}




- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
	// Do any additional setup after loading the view.
}



-(void)viewDidDisappear:(BOOL)animated
{
    [imagesCache removeAllObjects];
    _chainges = nil;
    self.collectionView = nil;
}


- (void)showMessageView {
    viewForLabel = [[UIView alloc] initWithFrame:CGRectMake(20, 200, 280, 40)];
    viewForLabel.backgroundColor = BLUE7;
    UILabel *lblMessage = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 280, 40)] ;
    lblMessage.backgroundColor = [UIColor clearColor];
    lblMessage.font = [UIFont fontWithName:@"HelveticaNeue" size:16];
    lblMessage.text = @"There are no photos for this place yet";
    lblMessage.textColor = [UIColor whiteColor];
    lblMessage.textAlignment = NSTextAlignmentCenter;
    [viewForLabel addSubview:lblMessage];
    [self.view addSubview:viewForLabel];
    
   
    
    
}


-(void)hideMessageView
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    [UIView beginAnimations:nil context:context];
    [UIView setAnimationCurve:UIViewAnimationCurveLinear];
    [UIView setAnimationDuration:3];
    [UIView setAnimationDelegate:self];
    
    viewForLabel.alpha = 0;
    
    [UIView commitAnimations];
    
    
}

- (void)addToArray:(NSArray *)array {
    /*BOOL hasRepeated = NO;
     for (Chainge *chainge in array) {
     if ([_chainges containsObject:chainge]) {
     hasRepeated = YES;
     //break;
     }
     else
     {
     [_chainges addObject:chainge];
     }
     }*/
    
}



- (void)refreshAll {
    if (_currentPageType == 0) {
        //[appDelegate.manager clearUploadedFlag];
                
        //[self addToArray:[appDelegate.manager getChaingesSortByDate:page pageSize:pageSize]];
        
        //[self addToArray:[appDelegate.manager getChaingesSortByDistanceWithPage:page pageSize:pageSize userId:appDelegate.manager.userId loc:_searchLocation]];
        
        //[self.collectionView reloadData];
        // isLoadingPage = NO;
        
        
    }
    [self stopActivityInFooter];
}




- (void)viewWillAppear:(BOOL)animated {
    
    
    currentChaingeItemIndex = -1;
    
    
    
    [super viewWillAppear:animated];
    
   
    //[self updatedLocation];
    
    _parentContr.lblName.text = ((DKAPlace *)_parentContr.placeObj).placeName;

    
    [self fadeView];

    
    
}


- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}



#pragma mark - UICollectionView Datasource
// 1
- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    return [_chainges count];
}

// 2
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}
// 3

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    isScrolling = YES;
    isLoadingPage = NO;
}


- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        isScrolling = NO;
        //isLoadingPage = NO;
        NSLog(@"scrollViewDidEndDragging");
        
        //[self updatedLocation];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    isScrolling = NO;
    //isLoadingPage = NO;
    NSLog(@"scrollViewDidEndDecelerating");
    // [self updatedLocation];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    
    InstagramCell *cell = [cv dequeueReusableCellWithReuseIdentifier:@"myChaingeCell" forIndexPath:indexPath];


    NSInteger row = [indexPath row];
    NWFourSquarePhoto *ch = [_chainges objectAtIndex:row];
    cell.imagesCache = imagesCache;
    cell.four = ch;
    cell.fourController = self;
    
    cell.tag = indexPath.row;
    
    //NSLog(@"url = %@", ch.photoUrlFull);


   

    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    //NSInteger row = [indexPath row];
    //[appDelegate.mainViewController continueChainge:row chaingesArray:_chaingesArray];
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    // TODO: Deselect item
}


#pragma mark - StackedGridLayoutDelegate
- (NSInteger)collectionView:(UICollectionView *)cv
                     layout:(UICollectionViewLayout *)cvl
   numberOfColumnsInSection:(NSInteger)section {
    return 3;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)cv
                        layout:(UICollectionViewLayout *)cvl
   itemInsetsForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(6, 4, 6, 2);
}

- (CGSize)collectionView:(UICollectionView *)cv
                  layout:(UICollectionViewLayout *)cvl
    sizeForItemWithWidth:(CGFloat)width
             atIndexPath:(NSIndexPath *)indexPath {
    NSInteger row = [indexPath row];
    //Chainge *ch = [_chainges objectAtIndex:row];
    
    //ChaingeItem *item = [appDelegate.manager getf:ch];
    
    
    //UIImage *photo = [self imageRotated:[UIImage imageWithData:item.image.thumbvalue] c:ch];
    
    NWFourSquarePhoto *ch = [_chainges objectAtIndex:row];
    
    CGSize imageSize = CGSizeMake(100,
                                  100);
    if(ch.width > ch.height)
    {
        //horizontal
        float ratio = (float)ch.height / (float)ch.width;
        imageSize = CGSizeMake(100, ratio * 100);
    }
    else
    {
        //vertical
        float ratio = (float)ch.height / (float)ch.width;

        imageSize = CGSizeMake(100, ratio * 100);
        
    }
    
    

    
    CGSize picSize = imageSize;
    picSize.height += 10.0f;
    picSize.width += 10.0f;
    
    CGSize retval =
    CGSizeMake(width,
               picSize.height * width / picSize.width);
    return retval;
}

- (void)stopActivityInFooter {
    if (activityIndicator) {
        activityIndicator.hidden = YES;
        [activityIndicator stopAnimating];
    }
    
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)cv
           viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    FlickrPhotoHeaderView *headerView =
    [cv dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter
                           withReuseIdentifier:@"FlickrPhotoHeaderView" forIndexPath:indexPath];
    
    //NSLog(@"indexPath.row = %i, %i", indexPath.row, indexPath.section);
    /*if (!isLoadingPage) {
     
     headerView.activityIndicator.hidden = NO;
     [headerView.activityIndicator startAnimating];
     isLoadingPage = YES;
     page = page + 1;
     activityIndicator = headerView.activityIndicator;
     [self getChainges];
     
     
     }*/
    
    return headerView;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
