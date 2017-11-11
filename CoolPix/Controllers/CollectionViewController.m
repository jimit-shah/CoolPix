//
//  ViewController.m
//  CoolPix
//
//  Created by Jimit Shah on 11/10/17.
//  Copyright © 2017 Jimit Shah. All rights reserved.
//

#import "CollectionViewController.h"
#import "HTTPService.h"
#import "Dog.h"
#import "ImageCell.h"

@interface CollectionViewController ()

#pragma mark - Properties
@property (strong, nonatomic) NSMutableArray *imageList;

#pragma mark - Outlets
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@end

@implementation CollectionViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  
  self.collectionView.dataSource = self;
  self.collectionView.delegate = self;
  
  if (_imageList == nil) {
    _imageList = [[NSMutableArray alloc]init];
  }
  
  [self getImages];
  
  // relooad collection view
  [[self collectionView]reloadData];
}

# pragma mark -getImages
-(void) getImages {
  
  [[HTTPService instance]getImages:^(NSDictionary * _Nullable dataDict, NSString * _Nullable errMessage) {
    if (dataDict) {
      //NSLog(@"Dictionary: %@", dataDict.debugDescription);
      
      NSMutableArray *array = [[NSMutableArray alloc]init];
      
      if(dataDict.count > 0) {
        NSArray *hits = [dataDict valueForKey:@"hits"];
        
        if(hits) {
          for (NSDictionary *images in hits) {
            Dog *image = [[Dog alloc]init];
            image.imageId = [images objectForKey:@"id"];
            image.imageURL = [images objectForKey:@"webformatURL"];
            
            [array addObject:image];
            
          }
        }
      }
      
      // Add to the list
      //self.imageList = array;
      
      //[self.imageList addObjectsFromArray:array];
      [self updateHistoryList:array];
      //NSLog(@"ImageList Count: %@",[@(self.imageList.count) stringValue]);
      
      [self updateCollectionViewData];
      
    } else if (errMessage){
      NSLog(@"Error: %@", errMessage);
    }
  }];
}

#pragma mark - Update HistoryList
-(void) updateHistoryList:(NSMutableArray *)images {
  
  if (_imageList.count > 0) {
    //Create NSSet from Array
    NSSet* oldset = [NSSet setWithArray:_imageList];
    NSSet* newset = [NSSet setWithArray:images];
    
    // retrieve the Name of the objects in oldset
    NSSet* existingIDs = [oldset valueForKey:@"imageId"];
    //NSLog(@"Existing IDs - %@", existingIDs);
    
    // only keep the objects of newset whose 'Name' are not in oldset_names
    //NSSet* newIDs = [newset valueForKey:@"imageId"];
    //NSLog(@"-----New IDs - %@", newIDs);
    NSSet* newMinusOldSet = [newset filteredSetUsingPredicate:
                             [NSPredicate predicateWithFormat:@"NOT imageId IN %@",existingIDs]];
    
    //Now convert back to Array from sets
    NSArray *newMinusOldArray = [newMinusOldSet allObjects];
    
    [_imageList addObjectsFromArray:newMinusOldArray];
    NSLog(@"%@ New-Old images added:",[@(newMinusOldArray.count) stringValue]);
  } else {
    // add all images to list.
    [_imageList addObjectsFromArray:images];
    NSLog(@"%@ NEW -Images added.",[@(images.count) stringValue]);
  }
}

#pragma mark - Helper methods
-(void) updateCollectionViewData {
  dispatch_async(dispatch_get_main_queue(), ^{
    [self.collectionView reloadData];
  });
}


#pragma mark - Collection view data source

#pragma mark numberOfItemsInSection
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
  return self.imageList.count;
}


#pragma mark cellForItemAtIndexPath
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
  
  NSString *cellIdentifier = @"ImageCell";
  ImageCell * cell = (ImageCell*)[collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
  
  if (!cell) {
    cell = [[ImageCell alloc]init];
  }
  
  Dog *dogImage = [self.imageList objectAtIndex:indexPath.row];
  [cell updateUI:dogImage];
  
  return cell;
}

#pragma mark - Collection view delegate

#pragma mark didSelectItemAtIndexPath

 - (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
// NSString *selected = [self.imageList objectAtIndex:indexPath.row];
// NSLog(@"selected=%@", selected);
 }



@end
