//
//  HistoryViewController.m
//  CoolPix
//
//  Created by Jimit Shah on 11/11/17.
//  Copyright © 2017 Jimit Shah. All rights reserved.
//

#import "HistoryViewController.h"
#import "HistoryCell.h"

@interface HistoryViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSArray *historyList;
@end

@implementation HistoryViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  
  
  self.tableView.delegate = self;
  self.tableView.dataSource = self;
  
//  self.historyList = _array;
  [[self tableView]reloadData];
  
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  self.historyList = _array;
  [[self tableView]reloadData];
}

- (void)viewWillDisappear:(BOOL)animated {
  self.historyList = nil;
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



@end
