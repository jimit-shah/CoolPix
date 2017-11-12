//
//  ViewController.m
//  CoolPix
//
//  Created by Jimit Shah on 11/10/17.
//  Copyright © 2017 Jimit Shah. All rights reserved.
//

#import "CollectionViewController.h"
#import "AppDelegate.h"
#import "HTTPService.h"
#import "Dog.h"
#import "ImageCell.h"

@interface CollectionViewController () {
  AppDelegate *appDelegate;
  NSManagedObjectContext *context;
}

#pragma mark - Properties
@property (nonatomic,strong)NSFetchedResultsController *fetchedResultsController;
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
  
}

#pragma mark - Actions

- (IBAction)fetchDogs:(id)sender {
  [self getImages];
}
- (IBAction)clearHistory:(id)sender {
  [[self imageList]removeAllObjects];
  
  for (NSManagedObject *image in [[self fetchedResultsController]fetchedObjects]) {
    [image isDeleted];
  }
  [appDelegate saveContext];
  
  // relooad collection view after delete.
  [self updateCollectionViewData];
  NSLog(@"All history deleted.");
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
      [self updateHistoryList:array];
      //NSLog(@"ImageList Count: %@",[@(self.imageList.count) stringValue]);
      
      [self updateCollectionViewData];
      
    } else if (errMessage){
      NSLog(@"Error: %@", errMessage);
    }
  }];
}

#pragma mark - Update HistoryList
- (void) updateHistoryList :(NSArray *)images
{
  NSArray *results = [self fetchedResultsController].fetchedObjects;
  
  if (results.count > 0) {
    //Create NSSet from Array
    NSSet* oldset = [NSSet setWithArray:results];
    NSSet* newset = [NSSet setWithArray:images];
    
    // retrieve the Name of the objects in oldset
    NSSet* existingIDs = [oldset valueForKey:@"imageId"];
    NSSet* newMinusOldSet = [newset filteredSetUsingPredicate:
                             [NSPredicate predicateWithFormat:@"NOT imageId IN %@",existingIDs]];
    
    //Now convert back to Array from sets
    NSArray *newMinusOldArray = [newMinusOldSet allObjects];
    
    [_imageList addObjectsFromArray:newMinusOldArray];
    NSLog(@"%@ New-Old images added:",[@(newMinusOldArray.count) stringValue]);
    
    for (NSSet *image in newMinusOldSet) {
      NSManagedObject *object = [NSEntityDescription insertNewObjectForEntityForName:@"Images" inManagedObjectContext:context];
      [object setValue:image forKey:@"imageId"];
      [appDelegate saveContext];
    }
    
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


#pragma mark Initialize fetched results controller
- (void)initializeFetchedResultsController
{
  NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Images"];
  
  NSSortDescriptor *dateSort = [NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:NO];
  
  [request setSortDescriptors:@[dateSort]];
  
  [self setFetchedResultsController:[[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:context sectionNameKeyPath:nil cacheName:nil]];
//  [[self fetchedResultsController] setDelegate:self];
  
  NSError *error = nil;
  if (![[self fetchedResultsController] performFetch:&error]) {
    NSLog(@"Failed to initialize FetchedResultsController: %@\n%@", [error localizedDescription], [error userInfo]);
    abort();
  }
}



@end
