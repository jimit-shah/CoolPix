//
//  collectionViewLayoutDelegate.m
//  CoolPix
//
//  Created by Jimit Shah on 11/16/17.
//  Copyright © 2017 Jimit Shah. All rights reserved.
//

#import "CollectionViewFlowLayout.h"
@interface CollectionViewFlowLayout() {
  CGFloat inset;
  CGFloat spacing;
  CGFloat lineSpacing;
}
@end

@implementation CollectionViewFlowLayout

- (void)prepareLayout {
  inset = 15.0;
  spacing = 10.0;
  lineSpacing = 15.0;
  self.collectionView.delegate = self;
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

@end
