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
#import "HistoryViewController.h"

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
  
  // Get Context
  appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
  context = appDelegate.persistentContainer.viewContext;
  
  self.collectionView.dataSource = self;
  self.collectionView.delegate = self;
  
  if (_imageList == nil) {
    _imageList = [[NSMutableArray alloc]init];
  }
  
  [self initializeFetchedResultsController];
  [self getImages];
  
}

#pragma mark - Actions

#pragma mark fetchDogs
- (IBAction)fetchDogs:(id)sender {
  [self getImages];
}

- (IBAction)showHistory:(id)sender {
  [self performSegueWithIdentifier:@"historySegue" sender:sender];
}

#pragma mark clearHistory
- (IBAction)clearHistory:(id)sender {
  [[self imageList]removeAllObjects];
  
//  for (NSManagedObject *image in [[self fetchedResultsController]fetchedObjects]) {
//    [image isDeleted];
//  }
//
  [context deletedObjects];

//  NSError *error = nil;
//  if(![context save:&error]) {
//    NSLog(@"Failed to save after delete- error: %@", [error localizedDescription]);
//  }

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
      
      // refresh data in collection view
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
  
  //Create NSSet from Array
  NSSet* oldset = [NSSet setWithArray:results];
  NSSet* newset = [NSSet setWithArray:images];
  
  // retrieve the Name of the objects in oldset
  NSSet* newIDs = [newset valueForKey:@"imageId"];
  NSSet* existingIDs = [oldset valueForKey:@"imageId"];
  
  if (results.count > 0) {
    
    NSSet* newMinusOldSet = [newset filteredSetUsingPredicate:
                             [NSPredicate predicateWithFormat:@"NOT imageId IN %@",existingIDs]];
    
    //Now convert back to Array from sets
    NSArray *newMinusOldArray = [newMinusOldSet allObjects];
    
    if (newMinusOldSet.count > 0) {
    [_imageList addObjectsFromArray:newMinusOldArray];
    NSLog(@"%@ New-Old images added:",[@(newMinusOldArray.count) stringValue]);

    // save only new IDs entity
    NSSet* newMinusOldIds = [newMinusOldSet valueForKey:@"imageId"];
    [self saveData:newMinusOldIds];
    }
    
  } else {
    
    // add all images to list.
    [_imageList addObjectsFromArray:images];
    
    //save all IDs to entity
    [self saveData:newIDs];
    NSLog(@"%@ NEW -Images added.",[@(images.count) stringValue]);
  }
}

- (void) saveData :(NSSet *)images {
  
  for (NSSet *imageID in images) {
    NSLog(@"Saving data for imageID: %@", imageID);
    
    NSManagedObject *object = [NSEntityDescription insertNewObjectForEntityForName:@"Image" inManagedObjectContext:context];
    [object setValue:imageID forKey:@"imageId"];
    
//    NSError *error = nil;
//    if(![context save:&error]) {
//      NSLog(@"Failed to save - error: %@", [error localizedDescription]);
//    }
    [appDelegate saveContext];
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


#pragma mark - Initialize fetched results controller
- (void)initializeFetchedResultsController
{
  NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Image"];
  
  NSSortDescriptor *dateSort = [NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:NO];
  
  [request setSortDescriptors:@[dateSort]];
  
  [self setFetchedResultsController:[[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:context sectionNameKeyPath:nil cacheName:nil]];
  [[self fetchedResultsController] setDelegate:self];
  
  NSError *error = nil;
  if (![[self fetchedResultsController] performFetch:&error]) {
    NSLog(@"Failed to initialize FetchedResultsController: %@\n%@", [error localizedDescription], [error userInfo]);
    abort();
  }
}

#pragma mark - Prepare for segue
//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//  if ([[segue identifier] isEqualToString:@"historySegue"]) {
//    
//    HistoryViewController *vc = (HistoryViewController *)segue.destinationViewController;
//    NSArray *results = self.fetchedResultsController.fetchedObjects;
//    NSSet* newset = [NSSet setWithArray:results];
//    NSSet* newIDs = [newset valueForKey:@"imageId"];
//    NSArray *arrList = [newIDs allObjects];
//    NSLog(@"arrayList prepareSegue: %@",arrList);
//    vc.array = arrList;
//  }
//}



@end
