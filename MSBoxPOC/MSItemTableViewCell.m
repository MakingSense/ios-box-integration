//
//  MSItemTableViewCell.m
//  MSBoxPOC
//
//  Created by Lucas Pelizza on 10/10/16.
//  Copyright © 2016 Making Sense. All rights reserved.
//

#import "MSItemTableViewCell.h"
#import "MSThumbnailsHelper.h"
#import "BOXContentSDK.h"
#import "BoxContentSDKConstants.h"


@interface MSItemTableViewCell()

@property (nonatomic, readwrite, strong) BOXFileThumbnailRequest *request;

@end

@implementation MSItemTableViewCell

- (void)prepareForReuse
{
    [self.request cancel];
    self.request = nil;
}

- (void)setItem:(BOXItem *)item
{
    if (item == nil) {
        return;
    }
    
    _item = item;
    self.textLabel.text = item.name;
    
    [self updateThumbnail];
}

- (void)updateThumbnail
{
    UIImage *icon = nil;
    
    if ([self.item isKindOfClass:[BOXFolder class]]) {
        if (((BOXFolder *) self.item).hasCollaborations == BOXAPIBooleanYES) {
            if (((BOXFolder *) self.item).isExternallyOwned == BOXAPIBooleanYES) {
                icon = [UIImage imageNamed:@"icon-folder-external"];
            } else {
                icon = [UIImage imageNamed:@"icon-folder-shared"];
            }
        } else {
            icon = [UIImage imageNamed:@"icon-folder"];
        }
    } else {
        MSThumbnailsHelper *thumbnailsHelper = [MSThumbnailsHelper sharedInstance];
        
        // Try to retrieve the thumbnail from our in memory cache
        UIImage *image = [thumbnailsHelper thumbnailForItemWithID:self.item.modelID userID:self.client.user.modelID];
        
        if (image) {
            icon = image;
        }
        else {
            icon = [UIImage imageNamed:@"icon-file-generic"];
            
            if ([thumbnailsHelper shouldDownloadThumbnailForItemWithName:self.item.name]) {
                self.request = [self.client fileThumbnailRequestWithID:self.item.modelID size:(BOXThumbnailSize)2];
                __weak MSItemTableViewCell *weakSelf = self;
                
                [self.request performRequestWithProgress:nil completion:^(UIImage *image, NSError *error) {
                    if (error == nil) {
                        [thumbnailsHelper storeThumbnailForItemWithID:self.item.modelID userID:self.client.user.modelID thumbnail:image];
                        
                        weakSelf.imageView.image = image;
                        CATransition *transition = [CATransition animation];
                        transition.duration = 0.3f;
                        transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
                        transition.type = kCATransitionFade;
                        [weakSelf.imageView.layer addAnimation:transition forKey:nil];
                    }
                }];
            }
        }
    }
    self.imageView.image = icon;
}

@end
