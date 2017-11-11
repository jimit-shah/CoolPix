//
//  ImageCell.m
//  CoolPix
//
//  Created by Jimit Shah on 11/11/17.
//  Copyright © 2017 Jimit Shah. All rights reserved.
//

#import "ImageCell.h"

@interface ImageCell()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation ImageCell

- (void)awakeFromNib {
  [super awakeFromNib];
  self.layer.cornerRadius = 2.0;
  self.layer.shadowColor = [UIColor colorWithRed:157.0/255.0 green:157.0/255.0 blue:157.0/255.0 alpha:0.8].CGColor;
  self.layer.shadowOpacity = 0.8;
  self.layer.shadowRadius = 5.0;
  self.layer.shadowOffset = CGSizeMake(0.0,2.0);
}

-(void)updateUI:(nonnull Dog*)Image {
  
  UIImage *dogImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:Image.imageURL]]];
  self.imageView.image = dogImage;
}

@end
