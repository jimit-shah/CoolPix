//
//  Image+CoreDataProperties.m
//  CoolPix
//
//  Created by Jimit Shah on 11/11/17.
//  Copyright © 2017 Jimit Shah. All rights reserved.
//
//

#import "Image+CoreDataProperties.h"

@implementation Image (CoreDataProperties)

+ (NSFetchRequest<Image *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"Image"];
}

@dynamic imageId;
@dynamic createdAt;

@end
