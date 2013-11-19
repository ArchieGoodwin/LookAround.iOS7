//
//  DKASearchVC.m
//  LookAround.iOS7
//
//  Created by Nero Wolfe on 09/11/13.
//  Copyright (c) 2013 Sergey Dikarev. All rights reserved.
//

#import "DKASearchVC.h"
#import "DKASpringyCollectionViewFlowLayout.h"
#import "DKAHelper.h"
#import "Defines.h"
#import <FactualSDK/FactualQuery.h>
#import "DKAPlaceVC.h"
@interface DKASearchVC ()
{
    FactualQueryResult *queryData;

}
@end

@implementation DKASearchVC

static NSString *CellIdentifier = @"Cell";


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self preferredStatusBarStyle];
    [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
    
    self.collectionView.backgroundColor = BLUE5;

    DKASpringyCollectionViewFlowLayout *layout = [[DKASpringyCollectionViewFlowLayout alloc] init];
    [self.collectionView setCollectionViewLayout:layout];
    
    
	// Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.tabBarController.tabBar.hidden = NO;
    self.navigationController.navigationBar.hidden = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)searchByKeywords:(NSString *)keyword
{
    [[DKAHelper sharedInstance] doQueryWithSearchTerm:keyword completion:^(FactualQueryResult *data, NSError *error) {
        queryData = data;
        [self.collectionView reloadData];
    }];
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    [self searchByKeywords:searchBar.text];
}

#pragma mark - UICollectionViewDataSource Methods



-(void)configureCell:(UICollectionViewCell *)cell forIndexPath:(NSIndexPath *)indexPath
{
    
    
    
    FactualRow* row = [queryData.rows objectAtIndex:indexPath.row];
    UILabel *lbl = (UILabel *)[cell.contentView viewWithTag:1001];
    
    CGRect frame = lbl.frame;
    frame.size.height = [[DKAHelper sharedInstance] getLabelSize:lbl fontSize:LOCATIONLISTFONTSIZE];
    lbl.frame = frame;
    
    lbl.text = [row valueForName:@"name"];
    
    
}



- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    FactualRow* row = [queryData.rows objectAtIndex:indexPath.row];
    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(7, 5, 306, 1000)];
    lbl.font = [UIFont systemFontOfSize:LOCATIONLISTFONTSIZE];
    lbl.numberOfLines = 0;
    lbl.lineBreakMode = NSLineBreakByWordWrapping;
    
    lbl.text = [row valueForName:@"name"];
    //NSLog(@"%@", NSStringFromCGSize(CGSizeMake(320, [[DKAHelper sharedInstance] getLabelSize:lbl fontSize:LOCATIONLISTFONTSIZE] + 12)));
    return CGSizeMake(320, [[DKAHelper sharedInstance] getLabelSize:lbl fontSize:LOCATIONLISTFONTSIZE] + 12);
    
    
    
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return queryData.rows.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    
    
    [self configureCell:cell forIndexPath:indexPath];
    
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    FactualRow* row = [queryData.rows objectAtIndex:indexPath.row];
    
    [self performSegueWithIdentifier:@"ShowPlace" sender:row];

}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"ShowPlace"])
    {
        DKAPlaceVC *vc = (DKAPlaceVC *)segue.destinationViewController;
        vc.placeObj = sender;
        
        
        
        
    }
}


/*- (UICollectionReusableView*)collectionView: (UICollectionView*)cv
 viewForSupplementaryElementOfKind:(NSString*)kind atIndexPath:(NSIndexPath*)indexPath
 {
 
 SearchHeaderView *headerView = [cv dequeueReusableSupplementaryViewOfKind: UICollectionElementKindSectionHeader withReuseIdentifier:@"SearchHeaderViewRoot" forIndexPath:indexPath];
 
 return headerView;
 }*/

@end
