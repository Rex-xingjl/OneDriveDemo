//
//  MSGraphAuthManager.h
//  OneDriveDemo
//
//  Created by Rex on 2021/3/4.
//

#import <Foundation/Foundation.h>
#import "MSAL.h"
#import "MSGraphClientSDK.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^GetAccountsCompletionBlock)(NSArray <MSALAccount*>* _Nullable accounts, NSError* _Nullable error);
typedef void (^GetTokenCompletionBlock)(MSALAccount * _Nullable account, NSString * _Nullable accessToken, NSError* _Nullable error);
typedef void (^SignOutCompletionBlock)(NSError* _Nullable error);

@interface MSGraphAuthManager : NSObject 

@property (nonatomic, strong) MSALPublicClientApplication * publicClient;

+ (id)manager;

- (void)getAllAccountsInCacheCompletionBlock:(GetAccountsCompletionBlock)completionBlock;

- (void)acquireTokenInteractivelyWithTarget:(UIViewController *)target completionBlock:(GetTokenCompletionBlock)completionBlock;
- (void)acquireTokenSilentlyWithId:(NSString *)identifier completionBlock:(GetTokenCompletionBlock)completionBlock;
- (void)signOutWithId:(NSString *)identifier target:(UIViewController *)target completionBlock:(SignOutCompletionBlock)completionBlock;

@end

NS_ASSUME_NONNULL_END
