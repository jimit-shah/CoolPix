//
//  HistoryViewController.m
//  CoolPix
//
//  Created by Jimit Shah on 11/11/17.
//  Copyright © 2017 Jimit Shah. All rights reserved.
//

#import "HistoryViewController.h"
#import "HistoryCell.h"
#import "AppDelegate.h"

@interface HistoryViewController () {
  AppDelegate *appDelegate;
  NSManagedObjectContext *context;
}

#pragma mark - Outlets
@property (weak, nonatomic) IBOutlet UITableView *tableView;

#pragma mark - Properties
@property (nonatomic, strong) NSArray *historyList;

@end

@implementation HistoryViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  
  // Get Context
  appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
  context = appDelegate.persistentContainer.viewContext;
  
  self.tableView.delegate = self;
  self.tableView.dataSource = self;
  
  self.historyList = [[NSArray alloc]init];
  
  [self getImages];
  
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  [self getImages];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return self.historyList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  
  HistoryCell *cell = (HistoryCell*)[tableView dequeueReusableCellWithIdentifier:@"HistoryCell" forIndexPath:indexPath];
  
  if (!cell) {
    cell = [[HistoryCell alloc]init];
  }
  
  return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
  NSNumber *item = [self.historyList objectAtIndex:indexPath.row];
  HistoryCell *histCell = (HistoryCell*)cell;
  [histCell updateUI:item];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

#pragma mark - Helper methods
-(void) updateTableViewData {
  //if initiated in background queue.
  dispatch_async(dispatch_get_main_queue(), ^{
    [self.tableView reloadData];
  });
}

# pragma mark - getImages (fetch from Database)
-(void) getImages {
  NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Image"];
  
  NSError *error = nil;
  NSArray *results = [context executeFetchRequest:request error:&error];
  if (!results) {
    NSLog(@"Error fetching Image objects: %@\n%@", [error localizedDescription], [error userInfo]);
    abort();
  }
  
  // pick IDs from fetch result and store in array list.
  NSSet* newset = [NSSet setWithArray:results];
  NSSet* fetchedIDs = [newset valueForKey:@"imageId"];
  NSArray *arrList = [fetchedIDs allObjects];
  
  self.historyList = arrList;
  [self updateTableViewData];
}


@end
