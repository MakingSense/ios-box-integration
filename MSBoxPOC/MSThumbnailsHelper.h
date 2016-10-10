//
//  MSThumbnailsHelper.h
//  MSBoxPOC
//
//  Created by Lucas Pelizza on 10/10/16.
//  Copyright © 2016 Making Sense. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BOXContentSDK.h"

@interface MSThumbnailsHelper : NSObject

+ (instancetype)sharedInstance;

- (void)storeThumbnailForItemWithID:(NSString *)itemID userID:(NSString *)userID thumbnail:(UIImage *)thumbnail;
- (UIImage *)thumbnailForItemWithID:(NSString *)itemID userID:(NSString *)userID;

- (BOOL)shouldDownloadThumbnailForItemWithName:(NSString *)itemName;

@end
