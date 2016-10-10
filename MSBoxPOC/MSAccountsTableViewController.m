//
//  MSAccountsTableViewController.m
//  MSBoxPOC
//
//  Created by Lucas Pelizza on 10/10/16.
//  Copyright © 2016 Making Sense. All rights reserved.
//

#import "MSAccountsTableViewController.h"
#import "BOXContentSDK.h"
#import "MSFolderTableViewController.H"

@interface MSAccountsTableViewController ()

@property (nonatomic, readwrite, strong) NSArray *users;

@end

@implementation MSAccountsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Accounts";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(barButtonPressed:)];
    
    NSMutableArray *users = [[NSMutableArray alloc]init];
    for (BOXUser *user in [BOXContentClient users]) {
        BOXContentClient *client = [BOXContentClient clientForUser:user];
        if ([client.session isKindOfClass:[BOXAppUserSession class]])
        {
            [users addObject:user];
        }
    }
    self.users = users;
    [self.tableView reloadData];
}

- (void)barButtonPressed:(UIBarButtonItem *)sender
{
    // Create a new client for the account we want to add.
    BOXContentClient *client = [BOXContentClient clientForNewSession];
    
    [client setAccessTokenDelegate:self];
    
    [client authenticateWithCompletionBlock:^(BOXUser *user, NSError *error) {
        if (error) {
            if ([error.domain isEqualToString:BOXContentSDKErrorDomain] ) {
                BOXLog(@"Authentication was cancelled, please try again.");
            } else {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                                    message:@"Login failed, please try again"
                                                                   delegate:nil
                                                          cancelButtonTitle:nil
                                                          otherButtonTitles:@"OK", nil];
                [alertView show];
            }
        } else {
            BOXContentClient *tmpClient = [BOXContentClient clientForUser:user];
            
            if ([tmpClient.user.modelID isEqualToString:client.user.modelID] && ![tmpClient.session.accessToken isEqualToString:client.session.accessToken]) {
                [tmpClient logOut];
                [self barButtonPressed:nil];
            } else {
                self.users = [self.users arrayByAddingObject:user];
                [self.tableView reloadData];
            }
        }
    }];
}

- (void)fetchAccessTokenWithCompletion:(void (^)(NSString *, NSDate *, NSError *))completion
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Info" ofType:@"plist"];
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:path];
    NSString* userToken = [dict objectForKey:@"UserTokenID"];
    completion(userToken, [NSDate dateWithTimeIntervalSinceNow:1000], nil);
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.users.count;
}

- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewRowAction *logoutButton = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive
                                                                            title:@"Log Out"
                                                                          handler:^(UITableViewRowAction *action, NSIndexPath *indexPath)
                                          {
                                              // Logout the user so that we remove any credential informations.
                                              BOXUser *user = self.users[indexPath.row];
                                              [[BOXContentClient clientForUser:user] logOut];
                                              
                                              NSMutableArray *mutableUsers = [self.users mutableCopy];
                                              [mutableUsers removeObject:user];
                                              self.users = [mutableUsers copy];
                                              [self.tableView reloadData];
                                          }];
    
    return @[logoutButton];
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *UserTableViewCellIdentifier = @"UserTableViewCellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:UserTableViewCellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:UserTableViewCellIdentifier];
    }
    
    BOXUser *user = self.users[indexPath.row];
    
    if (user.name.length > 0) {
        cell.textLabel.text = user.name;
        cell.detailTextLabel.text = user.login;
    } else {
        cell.textLabel.text = user.login;
    }
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

#pragma mark - UITableViewDelegate


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    BOXUser *user = self.users[indexPath.row];
    BOXContentClient *client = [BOXContentClient clientForUser:user];
    [client setAccessTokenDelegate:self];
    
    MSFolderTableViewController *folderListingController = [[MSFolderTableViewController alloc] initWithClient:client folderID:BOXAPIFolderIDRoot];
    [self.navigationController pushViewController:folderListingController animated:YES];
}

@end
