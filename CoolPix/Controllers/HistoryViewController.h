//
//  HistoryViewController.h
//  CoolPix
//
//  Created by Jimit Shah on 11/11/17.
//  Copyright © 2017 Jimit Shah. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HistoryViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSArray *array;

@end
