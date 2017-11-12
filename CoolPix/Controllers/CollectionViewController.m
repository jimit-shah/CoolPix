//
//  CollectionViewController.m
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
  CGFloat inset;
  CGFloat spacing;
  CGFloat lineSpacing;
}

#pragma mark - Properties
@property (nonatomic,strong)NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSMutableArray *imageList;
@property (strong, nonatomic) UIActivityIndicatorView *spinner;

#pragma mark - Outlets
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *historyButton;
@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *flowLayout;
@property (weak, nonatomic) IBOutlet UIButton *fetchDogsButton;
@property (weak, nonatomic) IBOutlet UIButton *clearHistoryButton;

@end

@implementation CollectionViewController

#pragma mark - Lifecycle
- (void)viewDidLoad {
  [super viewDidLoad];
  
  // Get Context
  appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
  context = appDelegate.persistentContainer.viewContext;
  
  self.collectionView.dataSource = self;
  self.collectionView.delegate = self;
  
  // configure UI
  [self configureUI];
  
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
  int count = 0;
  
  [self initializeFetchedResultsController];
  if (self.fetchedResultsController.fetchedObjects.count > 0) {
    [[self imageList]removeAllObjects];
    for (NSManagedObject *image in [[self fetchedResultsController]fetchedObjects]) {
      [context deleteObject:image];
      count = count + 1;
    }
    [appDelegate saveContext];
    // relooad collection view after delete.
    [self updateUI];
    NSLog(@"All history deleted %@", [@(count) stringValue]);
    [self showAlert:nil :@"All history deleted!"];
  } else {
    [self showAlert:nil :@"Nothing to delete!"];
  }
}

# pragma mark -GET Images (HTTP Get)
-(void) getImages {
  
  [[self historyButton]setEnabled:false];
  [self startSpinner:self :[self spinner]];
  
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
      [self updateUI];
      
    } else if (errMessage){
      NSLog(@"Error: %@", errMessage);
      
      [self updateUI];
      [self showAlert:@"Error" :@"Something went wrong, please try again."];
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
    
    if (newMinusOldSet.count == 20) {
      // save only new IDs entity
      NSSet* newMinusOldIds = [newMinusOldSet valueForKey:@"imageId"];
      [_imageList addObjectsFromArray:newMinusOldArray];
      [self saveData:newMinusOldIds];
    } else {
      //fetch images again from main queue.
      dispatch_async(dispatch_get_main_queue(), ^{
        [self getImages];
      });
    }
  } else {
    // add all images to list.
    [_imageList addObjectsFromArray:images];
    NSLog(@"%@ NEW Images added to list.",[@(images.count) stringValue]);
    
    //save all IDs to entity
    [self saveData:newIDs];
  }
}

- (void) saveData :(NSSet *)images {
  int count = 0;
  for (NSSet *imageID in images) {
    if (count <= 20 ) {
      NSManagedObject *object = [NSEntityDescription insertNewObjectForEntityForName:@"Image" inManagedObjectContext:context];
      [object setValue:imageID forKey:@"imageId"];
      
      [appDelegate saveContext];
      count = count + 1;
    }
  }
  NSLog(@"Images saved on disk: %@", [@(count) stringValue]);
}

#pragma mark - Helper methods

# pragma makr configureUI
- (void)configureUI {
  inset = 15.0;
  spacing = 10.0;
  lineSpacing = 15.0;
  
  self.clearHistoryButton.layer.cornerRadius = 5.0;
  self.fetchDogsButton.layer.cornerRadius = 5.0;
  
  self.spinner = [[UIActivityIndicatorView alloc]init];
}

# pragma mark updateUI
-(void) updateUI {
  dispatch_async(dispatch_get_main_queue(), ^{
    [self.collectionView reloadData];
    [self stopSpinner:self :[self spinner]];
    [[self historyButton]setEnabled:true];
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
  // no need.
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

#pragma mark Start/Show spinner
-(void) startSpinner:(UIViewController *)controller :(UIActivityIndicatorView*)activityIndicator {
  [activityIndicator setCenter:(controller.view.center)];
  [activityIndicator setHidesWhenStopped:true];
  [activityIndicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
  
  [[self collectionView]setAlpha:0.6];
  
  [[self collectionView]setBackgroundColor:[UIColor darkGrayColor]];
  [controller.view addSubview:activityIndicator];
  [activityIndicator setAlpha:1.0];
  [activityIndicator startAnimating];
}

#pragma mark Stop/Hide spinner
-(void) stopSpinner:(UIViewController *)controller :(UIActivityIndicatorView*)activityIndicator {
  if (activityIndicator.isAnimating) {
    
    [[self collectionView]setBackgroundColor:[UIColor whiteColor]];
    [[self collectionView]setAlpha:1.0];
    [activityIndicator stopAnimating];
  }
}

#pragma mark showAlert
-(void) showAlert :(nullable NSString *)title :(nonnull NSString *)message {
  UIAlertController * alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
  
  UIAlertAction* okButton = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
  
  [alert addAction:okButton];
  [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - UICollection View Flow Layout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
  
  CGRect screenRect = [[UIScreen mainScreen] bounds];
  CGFloat screenWidth = screenRect.size.width;
  float cellWidth = ((screenWidth) / 2.0 - (inset + spacing));
  CGSize size = CGSizeMake(cellWidth, cellWidth);
  return size;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
  
  return UIEdgeInsetsMake(inset, inset, inset, inset);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
  
  return inset;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
  
  return inset;
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
  
  [self.collectionView.collectionViewLayout invalidateLayout];
}

@end
