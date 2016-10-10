//
//  MSFolderTableViewController.h
//  MSBoxPOC
//
//  Created by Lucas Pelizza on 10/10/16.
//  Copyright © 2016 Making Sense. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BOXContentSDK.h"

@interface MSFolderTableViewController : UITableViewController

- (instancetype)initWithClient:(BOXContentClient *)client folderID:(NSString *)folderID;

@end
