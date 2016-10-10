//
//  MSItemTableViewCell.h
//  MSBoxPOC
//
//  Created by Lucas Pelizza on 10/10/16.
//  Copyright © 2016 Making Sense. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BOXContentSDK.h"

@interface MSItemTableViewCell : UITableViewCell

@property (nonatomic, readwrite, strong) BOXItem *item;
@property (nonatomic, readwrite, strong) BOXContentClient *client;

@end
