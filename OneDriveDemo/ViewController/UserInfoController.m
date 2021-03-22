//
//  UserInfoController.m
//  OneDriveDemo
//
//  Created by Rex on 2021/3/5.
//

#import "UserInfoController.h"
#import "MSConstants.h"
#import "RXNetworking.h"
#import "MSGraphUser.h"
@interface UserInfoController ()

@property (weak, nonatomic) IBOutlet UILabel *infoLabel;

@end

@implementation UserInfoController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"User Info";
    [self updateText:@"Requesting..."];
    [self getUserInfoWithToken];
}

- (void)updateText:(NSString *)text {
    if ([NSThread isMainThread]) {
        self.infoLabel.text = text;
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.infoLabel.text = text;
        });
    }
}

- (void)getUserInfoWithToken {
    NSString * graphAPI = [NSString stringWithFormat:@"%@/me", MSGraphBaseURL];
    [[RXNetworking shared] Get_Params:nil Url:graphAPI Token:self.token Completed:^(BOOL success, RXResponse *response) {
        if (!success) {
            [self updateText:[NSString stringWithFormat:@"Couldn't get graph result: %@", response.object]];
            return;
        }
        [self updateText:[NSString stringWithFormat:@"Result from Graph: %@", response.object]];
    }];
}

@end
