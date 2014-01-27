//
//  ViewController.m
//  FavoritePhotos
//
//  Created by Matthew Graham on 1/27/14.
//  Copyright (c) 2014 Matthew Graham. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UISearchBarDelegate>
{
    NSMutableArray *imageInfoArray;
    NSMutableArray *images;
    NSString *searchNoSpaces;
    NSMutableArray *favoriteImagesArray;
    
    __weak IBOutlet UICollectionView *photoCollectionView;    
    __weak IBOutlet UISearchBar *searchBar;

}

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    searchBar.delegate = self;
    searchBar.text = @"Chicago";
    searchNoSpaces = searchBar.text;
    self.searchDisplayController.displaysSearchBarInNavigationBar=YES;
    photoCollectionView.allowsMultipleSelection = NO;
    [self getImages];
    
}

-(void)getImages
{
    images = [NSMutableArray new];
    NSURL *imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://api.flickr.com/services/rest/?method=flickr.photos.search&text=%@&format=json&sort=relevance&api_key=54a39eab97daecaa119b39a9fb486fd3&per_page=10&nojsoncallback=1",searchNoSpaces]];
    NSURLRequest *imageRequest = [[NSURLRequest alloc] initWithURL:imageURL];
    
    [NSURLConnection sendAsynchronousRequest:imageRequest queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError)
     {
         NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&connectionError];
         NSDictionary *responseDictionary = [json objectForKey:@"photos"];
         NSMutableArray *photos = [responseDictionary objectForKey:@"photo"];
         for (NSDictionary *photo in photos)
         {
             // Array full of image dictionary objects
             [imageInfoArray addObject:photo];
             NSURL *photoURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://farm%@.staticflickr.com/%@/%@_%@_z.jpg",[photo objectForKey:@"farm"], [photo objectForKey:@"server"], [photo objectForKey:@"id"], [photo objectForKey:@"secret"]]];
             [images addObject:[UIImage imageWithData:[NSData dataWithContentsOfURL:photoURL]]];
         }
         
         [photoCollectionView reloadData];
     }];
}


-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return images.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CollectionCellReuseIdentifier" forIndexPath:indexPath];
    
    
    UIImageView * imageView = (UIImageView *)[cell viewWithTag:100];
    imageView.image = [images objectAtIndex:indexPath.row];
    
    UIButton* favoriteButton = (UIButton*)[cell viewWithTag:200];
    
    favoriteButton.alpha = 0;
    
    return cell;
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(320.0, 320.0);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(5.0, 5.0, 5.0, 5.0);
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)mySearchBar
{
    searchNoSpaces = [searchBar.text stringByReplacingOccurrencesOfString:@" " withString:@"_"];
    [searchBar resignFirstResponder];
    [self getImages];
}

- (IBAction)onFavoriteButtonPressed:(id)sender
{
    NSLog(@"Favorite Button Pushed");
    NSIndexPath *indexPath = photoCollectionView.indexPathsForSelectedItems.firstObject;
    UICollectionViewCell *cell = [photoCollectionView cellForItemAtIndexPath:indexPath];
    UIButton *favoriteButton = (UIButton*)[cell viewWithTag:200];
    if ([favoriteImagesArray isEqual:[images objectAtIndex:indexPath.row]]);
    {
        [favoriteImagesArray removeObjectIdenticalTo:[images objectAtIndex:indexPath.row]];
        [favoriteButton setBackgroundImage:[UIImage imageNamed:@"notfavorite"] forState:UIControlStateNormal];
    }
    else
    {
        [favoriteImagesArray addObject:[images objectAtIndex:indexPath.row]];
        [favoriteButton setBackgroundImage:[UIImage imageNamed:@"favorite"] forState:UIControlStateNormal];
    }
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [photoCollectionView cellForItemAtIndexPath:indexPath];
    UIButton *favoriteButton = (UIButton *)[cell viewWithTag:200];
    favoriteButton.alpha = 1;
    if ([favoriteImagesArray containsObject:[images objectAtIndex:indexPath.row]])
    {
        [favoriteButton setBackgroundImage:[UIImage imageNamed:@"favorite"] forState:UIControlStateNormal];
    }
    else
    {
        [favoriteButton setBackgroundImage:[UIImage imageNamed:@"notfavorite"] forState:UIControlStateNormal];
    }
}

-(void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [photoCollectionView cellForItemAtIndexPath:indexPath];
    UIButton *favoriteButton = (UIButton *)[cell viewWithTag:200];
    favoriteButton.alpha = 0;
}

@end
