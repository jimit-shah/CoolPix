//
//  Image+CoreDataProperties.h
//  CoolPix
//
//  Created by Jimit Shah on 11/11/17.
//  Copyright © 2017 Jimit Shah. All rights reserved.
//
//

#import "Image+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface Image (CoreDataProperties)

+ (NSFetchRequest<Image *> *)fetchRequest;

@property (nonatomic) int64_t imageId;
@property (nullable, nonatomic, copy) NSDate *createdAt;

@end

NS_ASSUME_NONNULL_END
