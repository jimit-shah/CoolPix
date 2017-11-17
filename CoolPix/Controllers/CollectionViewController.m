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
#import "CollectionViewFlowLayout.h"

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
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *historyButton;
@property (weak, nonatomic) IBOutlet CollectionViewFlowLayout *flowLayout;
@property (weak, nonatomic) IBOutlet UIButton *fetchImagesButton;
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
  
  [self createSearchBar];
  
  // configure UI
  [self configureUI];
  
  if (_imageList == nil) {
    _imageList = [[NSMutableArray alloc]init];
  }
  
  [self getImages:nil];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
  
  [self.collectionView.collectionViewLayout invalidateLayout];
}


#pragma mark - Actions

#pragma mark fetchAnimals
- (IBAction)fetchAnimals:(id)sender {
  [self getImages:self.searchBar.text];
}

- (IBAction)showHistory:(id)sender {
  [self performSegueWithIdentifier:@"historySegue" sender:sender];
}

#pragma mark clearHistory
- (IBAction)clearHistory:(id)sender {
  
  [self initializeFetchedResultsController];
  
  if (self.fetchedResultsController.fetchedObjects.count > 0) {
    UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:nil
                                 message:@"Are you sure you want to clear history!"
                                 preferredStyle:UIAlertControllerStyleActionSheet];
    
    //Add Buttons
    UIAlertAction* yesButton = [UIAlertAction
                                actionWithTitle:@"Yes"
                                style:UIAlertActionStyleDestructive
                                handler:^(UIAlertAction * action) {
                                  [self deleteAllData];
                                }];
    
    UIAlertAction* noButton = [UIAlertAction
                               actionWithTitle:@"No"
                               style:UIAlertActionStyleCancel
                               handler:^(UIAlertAction * action) {
                                 //Handle no, thanks button
                               }];
    
    //Add actions to alert controller
    [alert addAction:yesButton];
    [alert addAction:noButton];
    
    [self presentViewController:alert animated:YES completion:nil];
  } else {
    [self showAlert:nil :@"Nothing to delete!"];
  }
  
}

-(void)createSearchBar {
  self.navigationController.navigationBar.prefersLargeTitles = false;
  
  self.searchBar.showsCancelButton = true;
  self.searchBar.placeholder = @"Search Name";
  self.searchBar.delegate = self;
  [self searchBar].searchBarStyle = UISearchBarIconClear;
}

#pragma mark deleteAllData
  -(void)deleteAllData {
    int count = 0;
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
  }

# pragma mark -GET Images (HTTP Get)
-(void) getImages :(nullable NSString *)searchText {
  
  if (searchText == nil) {
    searchText = @"";
  }
  // first fetch data from db.
  [self disableButtons];
  [self initializeFetchedResultsController];
  [[HTTPService instance]getImages:searchText :^(NSDictionary * _Nullable dataDict, NSString * _Nullable errMessage) {
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

#pragma mark disableButtons
- (void)disableButtons {
  [[self fetchImagesButton]setEnabled:false];
  [[self clearHistoryButton]setEnabled:false];
  [[self historyButton]setEnabled:false];
  [self startSpinner:self :[self spinner]];
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
        [self getImages:nil];
      });
    }
  } else {
    if (images.count > 0) {
      // add all images to list.
      [_imageList addObjectsFromArray:images];
      //save all IDs to entity
      [self saveData:newIDs];
      NSLog(@"%@ NEW Images added to list.",[@(images.count) stringValue]);
    } else {
      [self showAlert:nil :@"No images found, please try again."];
    }
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
  self.fetchImagesButton.layer.cornerRadius = 5.0;
  
  self.spinner = [[UIActivityIndicatorView alloc]init];
}

# pragma mark updateUI
-(void) updateUI {
  dispatch_async(dispatch_get_main_queue(), ^{
    [self.collectionView reloadData];
    [self stopSpinner:self :[self spinner]];
    [[self historyButton]setEnabled:true];
    [[self fetchImagesButton]setEnabled:true];
    [[self clearHistoryButton]setEnabled:true];
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

#pragma mark - Search Text Controller Delegates

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
  [self getImages:searchBar.text];
  [searchBar resignFirstResponder];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
  [searchBar resignFirstResponder];
}


#pragma mark - Text Field Delegates

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
  [textField resignFirstResponder];
  return true;
}

@end
