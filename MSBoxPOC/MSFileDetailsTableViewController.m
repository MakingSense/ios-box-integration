//
//  MSFileDetailsTableViewController.m
//  MSBoxPOC
//
//  Created by Lucas Pelizza on 10/10/16.
//  Copyright © 2016 Making Sense. All rights reserved.
//

#import "MSFileDetailsTableViewController.h"
#import "MSProgressView.h"

NS_ENUM(NSInteger, FileDetailsControllerSection) {
    FileDetailsControllerSectionFileInfo = 0,
    FileDetailsControllerSectionOwnerInfo,
    FileDetailsControllerSectionDownload,
    FileDetailsControllerSectionCount
};

@interface MSFileDetailsTableViewController ()

@property (nonatomic, readwrite, strong) NSString *itemID;
@property (nonatomic, readwrite, strong) BOXItem *item;
@property (nonatomic ,readwrite, strong) BOXAPIItemType *itemType;
@property (nonatomic, readwrite, strong) BOXContentClient *client;


@end

@implementation MSFileDetailsTableViewController

- (instancetype)initWithClient:(BOXContentClient *)client itemID:(NSString *)itemID itemType:(BOXAPIItemType *)itemType
{
    if (self = [super initWithStyle:UITableViewStyleGrouped]) {
        _client = client;
        _itemID = itemID;
        _itemType = itemType;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ([self.itemType isEqualToString:BOXAPIItemTypeFile]) {
        
        BOXFileRequest *request = [self.client fileInfoRequestWithID:self.itemID];
        request.requestAllFileFields = YES;
        [request performRequestWithCompletion:^(BOXFile *file, NSError *error) {
            if (error == nil) {
                self.item = file;
                [self.tableView reloadData];
            }
        }];
        
    } else if ([self.itemType isEqualToString:BOXAPIItemTypeWebLink]) {
        
        BOXBookmarkRequest *request = [self.client bookmarkInfoRequestWithID:self.itemID];
        request.requestAllBookmarkFields = YES;
        [request performRequestWithCompletion:^(BOXBookmark *bookmark, NSError *error) {
            if (error == nil) {
                self.item = bookmark;
                [self.tableView reloadData];
            }
        }];
        
    } else {
        BOXLog(@"Unknown file type");
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.item ==nil) {
        return 0;
    }
    return FileDetailsControllerSectionCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.item ==nil) {
        return 0;
    }
    
    NSInteger rows = 0;
    
    switch (section) {
        case FileDetailsControllerSectionFileInfo:
            rows = 6;
            break;
        case FileDetailsControllerSectionOwnerInfo:
            rows = 2;
            break;
        case FileDetailsControllerSectionDownload:
            rows = 1;
            break;
        default:
            break;
    }
    return rows;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *title = nil;
    
    switch (section) {
        case FileDetailsControllerSectionFileInfo:
            title = @"General informations";
            break;
        case FileDetailsControllerSectionOwnerInfo:
            title = @"Owner";
            break;
        default:
            break;
    }
    
    return title;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *UserTableViewCellIdentifier = @"UserTableViewCellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:UserTableViewCellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:UserTableViewCellIdentifier];
    }
    
    switch (indexPath.section) {
        case FileDetailsControllerSectionFileInfo:
            if (indexPath.row == 0) {
                cell.textLabel.text = [NSString stringWithFormat:@"Name: %@", self.item.name];
            } else if (indexPath.row == 1) {
                cell.textLabel.text = [NSString stringWithFormat:@"Description: %@", self.item.itemDescription];
            } else if (indexPath.row == 2) {
                cell.textLabel.text = [NSString stringWithFormat:@"Created at: %@", self.item.createdDate];
            } else if (indexPath.row == 3) {
                cell.textLabel.text = [NSString stringWithFormat:@"Modified at: %@", self.item.modifiedDate];
            } else if (indexPath.row == 4) {
                cell.textLabel.text = [NSString stringWithFormat:@"%ld KB", ([self.item.size integerValue] / (long)1024)];
            } else if (indexPath.row == 5) {
                NSNumber *numberOfComments = nil;
                if ([self.item isKindOfClass:[BOXFile class]]) {
                    numberOfComments = ((BOXFile *)self.item).commentCount;
                } else {
                    numberOfComments = ((BOXBookmark *)self.item).commentCount;
                }
                cell.textLabel.text = [NSString stringWithFormat:@"%@ comment(s)", numberOfComments];
            }
            break;
            
        case FileDetailsControllerSectionOwnerInfo:
            if (indexPath.row == 0) {
                cell.textLabel.text = [NSString stringWithFormat:@"Name: %@",self.item.owner.name];
            } else if (indexPath.row == 1) {
                cell.textLabel.text = [NSString stringWithFormat:@"Login: %@",self.item.owner.login];
            }
            break;
            
        case FileDetailsControllerSectionDownload:
            if (indexPath.row == 0) {
                cell.textLabel.text = @"Download";
                if ([self.item isKindOfClass:[BOXFile class]]) {
                    cell.textLabel.textColor = [UIColor blackColor];
                } else {
                    cell.textLabel.textColor = [UIColor lightGrayColor];
                }
            }
            break;
        default:
            break;
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == FileDetailsControllerSectionDownload && [self.item isKindOfClass:[BOXFile class]]) {
        return indexPath;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self downloadCurrentItem];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Private Helpers

- (void)downloadCurrentItem
{
    MSProgressView *progressHeaderView = [[MSProgressView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.tableView.bounds), 50.0f)];
    self.tableView.tableHeaderView = progressHeaderView;
    
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentRootPath = [documentPaths objectAtIndex:0];
    NSString *finalPath = [documentRootPath stringByAppendingPathComponent:((BOXFile *)self.item).name];
    
    BOXFileDownloadRequest *request = [self.client fileDownloadRequestWithID:self.itemID toLocalFilePath:finalPath];
    [request performRequestWithProgress:^(long long totalBytesTransferred, long long totalBytesExpectedToTransfer) {
        float progress = (float)totalBytesTransferred / (float)totalBytesExpectedToTransfer;
        [progressHeaderView.progressView setProgress:progress animated:YES];
        
    } completion:^(NSError *error) {
        if (error == nil) {
            self.tableView.tableHeaderView = nil;
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"Your file was downloaded in the documents directory." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
            [alertView show];
        }
    }];
}

@end
