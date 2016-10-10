//
//  MSLibraryAssetCCollectionViewController.h
//  MSBoxPOC
//
//  Created by Lucas Pelizza on 10/10/16.
//  Copyright © 2016 Making Sense. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MSLibraryAssetCCollectionViewController : UICollectionViewController
@property (nonatomic, readwrite, strong) void (^assetSelectionCompletionBlock)(NSArray *selectedAssetLocalPaths);
@end
