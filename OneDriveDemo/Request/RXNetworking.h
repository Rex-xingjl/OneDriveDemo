//
//  RXNetRequest.h
//
//
//  Created by Rex on 2017/6/7.
//  Copyright © 2017年 com.yunxiang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"
#import "RXNetHelper.h"
@class RXResponse;

#define MethodDeprecated(instead) NS_DEPRECATED(2_0, 2_0, 2_0, 2_0, instead)

extern NSString *const kRequestExceptionNotification;

typedef enum : NSUInteger {
    RXRequestMethodPost,
    RXRequestMethodGet,
    RXRequestMethodDelete,
    RXRequestMethodPut,
    RXRequestMethodPatch
} RXRequestMethod;

typedef void (^RXSucceedBlock)(id object);
typedef void (^RXFailedBlock)(NSInteger statusCode, id object);
typedef void (^RXUploadProgress)(NSProgress * progress);
typedef void (^RXCompleteBlock)(BOOL success, RXResponse * response);

#define kVerifyProperty @"code"
#define kDataProperty @"data"
#define kErrorMsgProperty @"errorMsg"

@interface RXNetworking : NSObject

//SINGLETON_H()
+ (id)shared;

/** Request Cancel */
+ (void)cancelAllRequest;

/** Request Cancel By Target Class */
+ (void)cancelRequestWithTarget:(id)target;

/** Network Connect Status */
@property (nonatomic, assign) AFNetworkReachabilityStatus status;
@property (nonatomic, copy) void (^networkStatusChange)(AFNetworkReachabilityStatus status);

/** Request Method */
@property (nonatomic, strong) NSString * requestMethod; // default is POST

/** Request SessionManager */
@property (nonatomic, strong, readonly) AFHTTPSessionManager *jsonSessionManager;
@property (nonatomic, strong, readonly) AFHTTPSessionManager *httpSessionManager;

/** Request taskQueue */
@property (nonatomic, strong) NSMutableDictionary * taskQueueCaches;

/** Request TotalCount */
@property (nonatomic, assign) NSInteger totalTaskCount;

#pragma mark - # Simplify Request Method #

//  Params Explain
//  AUTH: MORE Authorization Header beyound Default Authorization Header
//  Json: return Json Object or Data
//  Target: the Container of Request, probably is a ViewController

/**
 *  POST Request
 *  JSON:YES
 */
- (NSURLSessionDataTask *)Post_Params:(id)params
                                  Url:(NSString *)url
                                 Token:(id)token
                            Completed:(RXCompleteBlock)block
                               Target:(id)target;

- (NSURLSessionDataTask *)Post_Params:(id)params
                                  Url:(NSString *)url
                                Token:(id)token
                            Completed:(RXCompleteBlock)block;

/**
 *  Get Request
 *  JSON:YES
 */
- (NSURLSessionDataTask *)Get_Params:(id)params
                                 Url:(NSString *)url
                               Token:(id)token
                           Completed:(RXCompleteBlock)block
                              Target:(id)target;

- (NSURLSessionDataTask *)Get_Params:(id)params
                                 Url:(NSString *)url
                               Token:(id)token
                           Completed:(RXCompleteBlock)block;

/**
 *  Delete Request
 *  JSON:YES
 */
- (NSURLSessionDataTask *)Delete_Params:(id)params
                                    Url:(NSString *)url
                                  Token:(id)token
                              Completed:(RXCompleteBlock)block;
- (NSURLSessionDataTask *)Delete_Params:(id)params
                                    Url:(NSString *)url
                                  Token:(id)token
                              Completed:(RXCompleteBlock)block
                                 Target:(id)target;

- (NSURLSessionDataTask *)Patch_Params:(id)params
                                   Url:(NSString *)url
                                 Token:(id)token
                             Completed:(RXCompleteBlock)block;
- (NSURLSessionDataTask *)Patch_Params:(id)params
                                    Url:(NSString *)url
                                  Token:(id)token
                              Completed:(RXCompleteBlock)block
                                 Target:(id)target;

#pragma mark - # Main Request #

- (NSURLSessionDataTask *)request_Method:(RXRequestMethod)method
                                  Params:(id)params
                                     Url:(NSString *)url
                                    Json:(BOOL)isJson
                                   Token:(id)token
                                 Succeed:(RXSucceedBlock)finished
                                  Failed:(RXFailedBlock)failed
                                  Target:(id)target;

#pragma mark - # Upload & Download #

- (void)upload_File:(NSData *)fileData
                Url:(NSString *)url
              Token:(id)token
           FileName:(NSString *)fileName
             Params:(NSDictionary *)params
     UploadProgress:(RXUploadProgress)progress
          Completed:(RXCompleteBlock)block;

- (void)upload_File:(NSData *)fileData
                Url:(NSString *)url
              Token:(id)token
             Header:(NSDictionary *)header
           FileName:(NSString *)fileName
             Params:(NSDictionary *)params
     UploadProgress:(RXUploadProgress)progress
          Completed:(RXCompleteBlock)block
             Target:(id)target;

- (NSURLSessionDownloadTask *)download:(NSString *)url
                                 token:(NSString *)token
                                  path:(NSString *)savePath
                              progress:(void (^)(NSProgress * progress))downloadProgressBlock
                                 block:(void (^)(id result,NSString *error))block;


@end

@interface RXResponse: NSObject

+ (id)succeedWithObject:(id)object;

+ (id)failedWithStatusCode:(NSInteger)status object:(id)object;

/** HTTP请求状态码 */
@property (nonatomic, assign) RXHttpCode statusCode;

/** 请求到的数据 success：数据对象 fail：失败原因 */
@property (nonatomic, strong) id object;

@end
