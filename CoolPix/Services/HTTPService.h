//
//  HTTPService.h
//  CoolPix
//
//  Created by Jimit Shah on 11/11/17.
//  Copyright © 2017 Jimit Shah. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^onComplete)(NSDictionary * _Nullable dataDict, NSString * _Nullable errMessage);

@interface HTTPService : NSObject

+ (id _Nullable) instance;
- (void) getImages:(NSString *_Nonnull)searchText :(nullable onComplete) completionHandler;
- (NSURL *_Nonnull)URLByAppendingQueryParameters:(NSString *_Nonnull)baseURL withQueryParameters:(NSDictionary *_Nullable)queryParameters;

@end
