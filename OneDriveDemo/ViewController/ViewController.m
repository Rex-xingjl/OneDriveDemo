//
//  ViewController.m
//  OneDriveDemo
//
//  Created by Rex on 2021/3/2.
//

#import "ViewController.h"
#import "MSGraphAuthManager.h"
#import "FilesViewController.h"
#import "UserInfoController.h"
#import "UserListCell.h"
#import "YXHUD.h"

@interface ViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextView *loggingTextView;

@property (nonatomic, strong) NSArray * accounts;

@property (nonatomic, strong) NSMutableDictionary * tokens;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"One Drive";
    self.tokens = [[NSMutableDictionary alloc] init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appCameToForeGround:) name:UIApplicationWillEnterForegroundNotification object:nil];
    
    [self reloadAccountsAndTable];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)reloadAccountsAndTable {
    [YXHUD show];
    [MSGraphAuthManager.manager getAllAccountsInCacheCompletionBlock:^(NSArray<MSALAccount *> * _Nullable accounts, NSError * _Nullable error) {
        [YXHUD hide];
        self.accounts = accounts;
        if ([NSThread isMainThread]) {
            [self.tableView reloadData];
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        }
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    for (MSALAccount * account in self.accounts) {
        [self acquireTokenSilently:account];
    }
}

- (void)appCameToForeGround:(NSNotification *)noti {
    for (MSALAccount * account in self.accounts) {
        [self acquireTokenSilently:account];
    }
}

- (void)updateLoggerText:(NSString *)text {
    if ([NSThread isMainThread]) {
        self.loggingTextView.text = text;
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.loggingTextView.text = text;
        });
    }
}

- (IBAction)signInAction:(id)sender {
    [self acquireTokenInteractively];
}

- (void)acquireTokenInteractively {
    [MSGraphAuthManager.manager acquireTokenInteractivelyWithTarget:self completionBlock:^(MSALAccount * _Nullable account, NSString * _Nullable accessToken, NSError * _Nullable error) {
        if (error) {
            [self updateLoggerText:[NSString stringWithFormat:@"Could not acquire token: %@", error]];
            return;
        }
        if (!accessToken) {
            [self updateLoggerText:@"Could not acquire token: No result returned"];
            return;
        }
        [self.tokens setValue:accessToken forKey:account.identifier];
        [self updateLoggerText:[NSString stringWithFormat:@"Got token interactively: %@", accessToken]];
        [self reloadAccountsAndTable];
    }];
}

- (void)acquireTokenSilently:(MSALAccount *)account {
    [YXHUD show];
    [MSGraphAuthManager.manager acquireTokenSilentlyWithId:account.identifier completionBlock:^(MSALAccount * _Nullable account, NSString * _Nullable accessToken, NSError * _Nullable error) {
        [YXHUD hide];
        if (error) {
            if (error.domain == MSALErrorDomain) {
                if (error.code == MSALErrorInteractionRequired) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self acquireTokenInteractively];
                    });
                }
            }
            [self updateLoggerText:[NSString stringWithFormat:@"Could not acquire token silently: %@", error]];
            return;
        }
        if (!accessToken) {
            [self updateLoggerText:@"Could not acquire token: No result returned"];
            return;
        }
        [self.tokens setValue:accessToken forKey:account.identifier];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.accounts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UserListCell * cell = [tableView dequeueReusableCellWithIdentifier:@"userListCell" forIndexPath:indexPath];
    MSALAccount * account = self.accounts[indexPath.row];
    cell.nickNameLabel.text = account.username;
    cell.idLabel.text = account.identifier;
    
    __weak typeof(self) weak = self;
    cell.signOutBtnBlock = ^{
        [MSGraphAuthManager.manager signOutWithId:account.identifier target:weak completionBlock:^(NSError * _Nullable error) {
            if (error) {
                [self updateLoggerText:error.localizedDescription];
                return;
            }
            [self updateLoggerText:@"Sign out completed successfully"];
            [weak reloadAccountsAndTable];
        }];
    };
    cell.myFilesBtnBlock = ^{
        NSString * token = [self.tokens valueForKey:account.identifier];
        if (!token) {
            [YXHUD showInfo:@"获取token中⌛️"]; return;
        }
        FilesViewController * fileVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"FilesViewController"];
        fileVC.token = token;
        fileVC.title = @"我的文件";
        [self.navigationController pushViewController:fileVC animated:YES];
    };
    cell.tapIconImageBlock = ^{
        NSString * token = [self.tokens valueForKey:account.identifier];
        if (!token) {
            [YXHUD showInfo:@"获取token中⌛️"]; return;
        }
        UserInfoController * fileVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"UserInfoController"];
        fileVC.token = token;
        [self.navigationController pushViewController:fileVC animated:YES];
    };
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 138;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
