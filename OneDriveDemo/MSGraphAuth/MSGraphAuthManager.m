//
//  MSGraphAuthManager.m
//  OneDriveDemo
//
//  Created by Rex on 2021/3/4.
//

#import "MSGraphAuthManager.h"

@interface MSGraphAuthManager()

@property (nonatomic, strong) NSString * appId;
@property (nonatomic, strong) NSArray <NSString *>* graphScopes;

@end

@implementation MSGraphAuthManager

+ (id)manager {
    static MSGraphAuthManager *singleInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^ {
        singleInstance = [[self alloc] init];
    });
    
    return singleInstance;
}

- (id)init {
    if (self = [super init]) {
            // Get app ID and scopes from AuthSettings.plist
        NSString * authConfigPath =
        [NSBundle.mainBundle pathForResource:@"GraphAuthSettings" ofType:@"plist"];
        NSDictionary * authConfig = [NSDictionary dictionaryWithContentsOfFile:authConfigPath];
        
        self.appId = authConfig[@"AppId"];
        self.graphScopes = authConfig[@"GraphScopes"];
        
            // Create the MSAL client
        self.publicClient = [[MSALPublicClientApplication alloc] initWithClientId:self.appId error:nil];
    }
    return self;
}

- (void)getAllAccountsInCacheCompletionBlock:(GetAccountsCompletionBlock)completionBlock {
    NSError * error;
    NSArray * allAccounts = [self.publicClient allAccounts:&error];
    if (error) {
        if (completionBlock) completionBlock(nil, error);
    } else {
        if (completionBlock) completionBlock(allAccounts, nil);
    }
}

- (void)acquireTokenInteractivelyWithTarget:(UIViewController *)target completionBlock:(GetTokenCompletionBlock)completionBlock {
    MSALWebviewParameters * webParameters = [[MSALWebviewParameters alloc] initWithAuthPresentationViewController:target];
    MSALInteractiveTokenParameters * interactiveParameters = [[MSALInteractiveTokenParameters alloc] initWithScopes:self.graphScopes webviewParameters:webParameters];
    
        // Call acquireToken to open a browser so the user can sign in
    [self.publicClient acquireTokenWithParameters:interactiveParameters
     completionBlock:^(MSALResult * _Nullable result, NSError * _Nullable error) {
        // Check error
        if (error) {
            if (completionBlock) completionBlock(nil, nil, error);
            return;
        }
        // Check result
        if (!result) {
            NSMutableDictionary* details = [NSMutableDictionary dictionary];
            [details setValue:@"No result was returned" forKey:NSLocalizedDescriptionKey];
            if (completionBlock) completionBlock(nil, nil, [NSError errorWithDomain:NSStringFromClass(self.class) code:0 userInfo:details]);
            return;
        }
        NSLog(@"Got token interactively: %@", result.accessToken);
        if (completionBlock) completionBlock(result.account, result.accessToken, nil);
    }];
}

- (void)acquireTokenSilentlyWithId:(NSString *)identifier completionBlock:(GetTokenCompletionBlock)completionBlock {
        // Check if there is an account in the cache
    NSError * msalError;
    MSALAccount* account = [self.publicClient accountForIdentifier:identifier error:&msalError];
    
    if (msalError || !account) {
        NSMutableDictionary* details = [NSMutableDictionary dictionary];
        [details setValue:@"Could not retrieve account from cache" forKey:NSLocalizedDescriptionKey];
        if (completionBlock) completionBlock(nil, nil, [NSError errorWithDomain:NSStringFromClass(self.class) code:0 userInfo:details]);
        return;
    }
    
    MSALSilentTokenParameters* silentParameters = [[MSALSilentTokenParameters alloc] initWithScopes:self.graphScopes account:account];
    
    // Attempt to get token silently
    [self.publicClient acquireTokenSilentWithParameters:silentParameters completionBlock:^(MSALResult * _Nullable result, NSError * _Nullable error) {
            // Check error
        if (error) {
            if (completionBlock) completionBlock(nil, nil, error);
            return;
        }
            // Check result
        if (!result) {
            NSMutableDictionary* details = [NSMutableDictionary dictionary];
            [details setValue:@"No result was returned" forKey:NSLocalizedDescriptionKey];
            if (completionBlock) completionBlock(nil, nil, [NSError errorWithDomain:NSStringFromClass(self.class) code:0 userInfo:details]);
            return;
        }
        NSLog(@"Got token silently: %@", result.accessToken);
        if (completionBlock) completionBlock(result.account, result.accessToken, nil);
    }];
}

- (void)signOutWithId:(NSString *)identifier target:(UIViewController *)target completionBlock:(SignOutCompletionBlock)completionBlock {
    NSError* msalError;
    MSALAccount* account = [self.publicClient accountForIdentifier:identifier error:&msalError];
    if (msalError || !account) {
        NSMutableDictionary* details = [NSMutableDictionary dictionary];
        [details setValue:@"Could not retrieve account from cache" forKey:NSLocalizedDescriptionKey];
        if (completionBlock) completionBlock([NSError errorWithDomain:NSStringFromClass(self.class) code:0 userInfo:details]);
        return;
    }
    
    MSALWebviewParameters * webParameters = [[MSALWebviewParameters alloc] initWithAuthPresentationViewController:target];
    MSALSignoutParameters * signOutParams = [[MSALSignoutParameters alloc] initWithWebviewParameters: webParameters];
    signOutParams.signoutFromBrowser = NO;
    [self.publicClient signoutWithAccount:account signoutParameters:signOutParams completionBlock:^(BOOL success, NSError * _Nullable error) {
        if (error) {
            if (completionBlock) completionBlock(error);
            return;
        }
        NSError * rerror;
        [self.publicClient removeAccount:account error:&rerror];
        if (completionBlock) completionBlock(rerror);
    }];
}

@end
