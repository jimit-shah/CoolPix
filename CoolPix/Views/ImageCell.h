//
//  ImageCell.h
//  CoolPix
//
//  Created by Jimit Shah on 11/11/17.
//  Copyright © 2017 Jimit Shah. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Dog.h"

@interface ImageCell : UICollectionViewCell
-(void)updateUI:(nonnull Dog*)DogImage;
@end
