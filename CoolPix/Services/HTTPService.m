//
//  HTTPService.m
//  CoolPix
//
//  Created by Jimit Shah on 11/11/17.
//  Copyright © 2017 Jimit Shah. All rights reserved.
//

#import "HTTPService.h"

#define URL_BASE "https://pixabay.com/api/"
#define URL_API "6942607-aa411bac9ca95e58352e7a19a"
#define URL_KEYWORD "dogs"
#define URL_IMAGE_TYPE "photo"
#define URL_CAT "animals"

@implementation HTTPService

# pragma mark - Get shared Instance
+ (id) instance {
  static HTTPService *sharedInstance = nil;
  
  @synchronized(self) {
    if (sharedInstance == nil) {
      sharedInstance = [[self alloc]init];
    }
  }
  return sharedInstance;
}

# pragma mark - getImages (GET)
- (void) getImages:(nullable onComplete)completionHandler {
  
  NSURLSession *session = [NSURLSession sharedSession];
  
  // generate random number for page number
  int randomInt = arc4random_uniform(25);
  
  NSDictionary *parameters = @{
                               @"key": @URL_API,
                               @"q": @URL_KEYWORD,
                               @"image_type": @URL_IMAGE_TYPE,
                               @"category": @URL_CAT,
                               @"page": [@(randomInt) stringValue]
                               };
  
  // call helper method to build url with parameters
  NSURL *url = [self URLByAppendingQueryParameters:@URL_BASE withQueryParameters:parameters];
  NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:url];
  request.HTTPMethod = @"GET";
  
  NSLog(@"Request %@",request.debugDescription);
  
  NSURLSessionDataTask *downloadTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
    
    if (data != nil) {
      NSError *err;
      NSHTTPURLResponse *httpResp = (NSHTTPURLResponse*) response;
      
      if (httpResp.statusCode >= 200 && httpResp.statusCode <= 299) {
        
        NSDictionary* json = [NSJSONSerialization
                              JSONObjectWithData:data
                              options:kNilOptions
                              error:&err];
        
        if (err == nil) {
          completionHandler(json, nil);
        } else {
          completionHandler(nil, @"Data parsing error.");
        }
      } else {
        completionHandler(nil, @"Your request returned a status code other than 2xx!, please try again.");
      }
    } else {
      NSLog(@"Network Error: %@", error.debugDescription);
      completionHandler(nil, @"Problem connecting to the server, please try again later.");
    }
  }];
  [downloadTask resume];
}

#pragma mark - URLByAppendingQueryParamters
- (NSURL *_Nonnull)URLByAppendingQueryParameters:(NSString *_Nonnull)baseURL withQueryParameters:(NSDictionary *)queryParameters
{
  NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@",baseURL]];
  if (queryParameters == nil) {
    return url;
  } else if (queryParameters.count == 0) {
    return url;
  }
  
  NSArray *queryKeys = [queryParameters allKeys];
  NSURLComponents *components = [[NSURLComponents alloc] initWithURL:url resolvingAgainstBaseURL:NO];
  NSMutableArray * newQueryItems = [NSMutableArray arrayWithCapacity:1];
  
  for (NSURLQueryItem * item in components.queryItems) {
    if (![queryKeys containsObject:item.name]) {
      [newQueryItems addObject:item];
    }
  }
  
  for (NSString *key in queryKeys) {
    NSURLQueryItem * newQueryItem = [[NSURLQueryItem alloc] initWithName:key value:queryParameters[key]];
    [newQueryItems addObject:newQueryItem];
  }
  
  [components setQueryItems:newQueryItems];
  
  return [components URL];
}


@end
