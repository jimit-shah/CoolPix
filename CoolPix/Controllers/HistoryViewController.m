//
//  HistoryViewController.m
//  CoolPix
//
//  Created by Jimit Shah on 11/11/17.
//  Copyright © 2017 Jimit Shah. All rights reserved.
//

#import "HistoryViewController.h"
#import "HistoryCell.h"
//#import "Image+CoreDataClass.h"
#import "AppDelegate.h"


@interface HistoryViewController () {
  AppDelegate *appDelegate;
  NSManagedObjectContext *context;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;

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

  self.historyList = nil;
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
  dispatch_async(dispatch_get_main_queue(), ^{
    [self.tableView reloadData];
  });
}

-(void) getImages {
  NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Image"];
  
  NSError *error = nil;
  NSArray *results = [context executeFetchRequest:request error:&error];
  if (!results) {
    NSLog(@"Error fetching Employee objects: %@\n%@", [error localizedDescription], [error userInfo]);
    abort();
  }
  
      NSSet* newset = [NSSet setWithArray:results];
      NSSet* fetchedIDs = [newset valueForKey:@"imageId"];
      NSArray *arrList = [fetchedIDs allObjects];
      NSLog(@"arrayList prepareSegue: %@",arrList);

  self.historyList = arrList;
  [self.tableView reloadData];
}

@end
