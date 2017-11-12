//
//  HistoryCell.m
//  CoolPix
//
//  Created by Jimit Shah on 11/11/17.
//  Copyright © 2017 Jimit Shah. All rights reserved.
//

#import "HistoryCell.h"

@interface HistoryCell()
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end

@implementation HistoryCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)updateUI:(NSNumber *)item{

  [[self titleLabel]setText:[NSString stringWithFormat:@"dog-%@",item]];
}


@end
