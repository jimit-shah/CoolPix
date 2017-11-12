//
//  Image+CoreDataClass.m
//  CoolPix
//
//  Created by Jimit Shah on 11/11/17.
//  Copyright © 2017 Jimit Shah. All rights reserved.
//
//

#import "Image+CoreDataClass.h"

@implementation Image

- (void)awakeFromInsert
{
  [super awakeFromInsert];
  [self setCreatedAt:[NSDate date]];
}

@end
