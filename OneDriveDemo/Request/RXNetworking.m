//
//  RXNetRequest.m
//  RXDataLayer
//
//  Created by Rex on 2017/6/7.
//  Copyright © 2017年 com.yunxiang. All rights reserved.
//

#import "RXNetworking.h"

#define Mega  *(1024 * 1024)

#define SetJsonSerializer(isJson) \
if (!isJson) { \
\
} else { \
_sessionManager.requestSerializer = [AFJSONRequestSerializer serializer]; \
_sessionManager.responseSerializer = [AFJSONResponseSerializer serializer]; \
if ([_sessionManager.responseSerializer isKindOfClass:[AFJSONResponseSerializer class]]) { \
AFJSONResponseSerializer *jsonSerializer = (AFJSONResponseSerializer *)_sessionManager.responseSerializer; \
jsonSerializer.removesKeysWithNullValues = YES; \
}\
}

#define SetUrl(url) [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet characterSetWithCharactersInString:@"`#%^{}\"[]|\\<> "].invertedSet]

#define ManageTaskQueue(task, target)  \
NSString * className = NSStringFromClass(target) ? : @"rx_default_tasks"; \
NSMutableArray * classArray = [self.taskQueueCaches objectForKey:className]; \
if (!classArray) { \
classArray = [[NSMutableArray alloc] init]; \
[self.taskQueueCaches setObject:classArray forKey:className]; \
} \
if (task.state == NSURLSessionTaskStateCompleted) { \
if ([classArray containsObject:task]) [classArray removeObject:task]; \
} else { \
if (task != nil) [classArray addObject:task]; \
}

#define kNetWork_PrintLine @"\n--------------------------------------------------------------------------------------------\n"

#define WriteTaskLog(task, param) NSLog(@"%@ RXNetworking START > %ld < \n\n url \t: %@ \n params : %@ \n %@ ", kNetWork_PrintLine,(unsigned long)task.taskIdentifier, task.originalRequest.URL, param, kNetWork_PrintLine);
#define WriteErrorLog(task, systemCode ,httpCode, description)  NSLog(@"%@ RXNetworking FAILED > %ld < \n\n systemCode : %ld \n httpCode\t: %ld \n reason \t: %@ \n url    \t: %@ \n header \t: %@ %@", kNetWork_PrintLine, (unsigned long)task.taskIdentifier,  systemCode, httpCode, description, task.currentRequest.URL, task.currentRequest.allHTTPHeaderFields, kNetWork_PrintLine);

@interface RXNetworking ()

@property (nonatomic, strong) AFHTTPSessionManager *jsonSessionManager;
@property (nonatomic, strong) AFHTTPSessionManager *httpSessionManager;

@end

@implementation RXNetworking

#pragma mark - # Shared #

+ (id)shared {
    static RXNetworking *singleInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^ {
        singleInstance = [[self alloc] init];
    });
    
    return singleInstance;
}

- (NSMutableDictionary *)taskQueueCaches {
    if (!_taskQueueCaches) {
        _taskQueueCaches = [[NSMutableDictionary alloc] init];
    }
    return _taskQueueCaches;
}

- (AFHTTPSessionManager *)jsonSessionManager {
    if (!_jsonSessionManager) {
        _jsonSessionManager = [self getManager];
        _jsonSessionManager.requestSerializer = [AFJSONRequestSerializer serializer];
    }
    return _jsonSessionManager;
}

- (AFHTTPSessionManager *)httpSessionManager {
    if (!_httpSessionManager) {
        _httpSessionManager = [self getManager];
        _httpSessionManager.requestSerializer = [AFHTTPRequestSerializer serializer];
    }
    return _httpSessionManager;
}

- (AFHTTPSessionManager *)getManager {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer.cachePolicy = NSURLRequestUseProtocolCachePolicy;
    manager.requestSerializer.timeoutInterval = 10;
    manager.responseSerializer.acceptableContentTypes = [self acceptableContentTypes];
    manager.securityPolicy.allowInvalidCertificates = NO;
    
    if ([manager.responseSerializer isKindOfClass:[AFJSONResponseSerializer class]]) {
        AFJSONResponseSerializer *jsonSerializer = (AFJSONResponseSerializer *)manager.responseSerializer;
        jsonSerializer.removesKeysWithNullValues = YES;
    }
    return manager;
}

#pragma mark - # NetConfig Method #

+ (void)cancelAllRequest {
    NSDictionary * allTaskDict = [[self shared] taskQueueCaches];
    for (NSString * key in allTaskDict) {
        if (key.length) {
            NSArray * object = allTaskDict[key];
            for (id task in object) {
                if ([task respondsToSelector:@selector(cancel)]) {
                    [task cancel];
                }
            }
        }
    }
}

+ (void)cancelRequestWithTarget:(id)target {
    if (!target) return;
    NSDictionary * allTaskDict = [[self shared] taskQueueCaches];
    NSString * className = NSStringFromClass(target);
    if (className.length) {
        NSArray * taskArray = allTaskDict[className];
        for (id task in taskArray) {
            if ([task respondsToSelector:@selector(cancel)]) {
                [task cancel];
            }
        }
    }
}

- (NSSet *)acceptableContentTypes {
    return [NSSet setWithObjects:
            @"text/html",
            @"text/json",
            @"application/json",
            @"text/javascript",
            @"image/jpeg",
            @"image/jpg",
            @"image/heic",
            @"text/plain", nil];
}

- (NSString *)contentTypeForData:(NSData *)data {
    uint8_t c;
    [data getBytes:&c length:1];
    switch (c) {
        case 0xFF: return @"image/jpeg";
        case 0x89: return @"image/png";
        case 0x47: return @"image/gif";
        case 0x49:
        case 0x4D: return @"image/tiff";
    }
    return @"multipart/form-data";
}

#pragma mark - # Simplify Request Method #

- (NSURLSessionDataTask *)Post_Params:(id)params Url:(NSString *)url Token:(id)token Completed:(RXCompleteBlock)block {
    return [self Post_Params:params Url:url Token:(id)token Completed:block Target:nil];
}

- (NSURLSessionDataTask *)Post_Params:(id)params Url:(NSString *)url Token:(id)token Completed:(RXCompleteBlock)block Target:(id)target {
    return [self request_Method:RXRequestMethodPost
                         Params:params Url:url
                           Json:YES
                          Token:(id)token
                        Succeed:^(id object) {
                            if (block) block(YES, [RXResponse succeedWithObject:object]);
                        } Failed:^(NSInteger statusCode, id object) {
                            if (block) block(NO, [RXResponse failedWithStatusCode:statusCode object:object]);
                        } Target:target];
}

- (NSURLSessionDataTask *)Get_Params:(id)params Url:(NSString *)url Token:(id)token Completed:(RXCompleteBlock)block {
    return [self Get_Params:params Url:url Token:(id)token Completed:block Target:nil];
}

- (NSURLSessionDataTask *)Get_Params:(id)params Url:(NSString *)url Token:(id)token Completed:(RXCompleteBlock)block Target:(id)target {
    return [self request_Method:RXRequestMethodGet
                         Params:params
                            Url:url
                           Json:YES
                          Token:(id)token
                        Succeed:^(id object) {
                            if (block) block(YES, [RXResponse succeedWithObject:object]);
                        } Failed:^(NSInteger statusCode, id object) {
                            if (block) block(NO, [RXResponse failedWithStatusCode:statusCode object:object]);
                        } Target:target];
}

- (NSURLSessionDataTask *)Delete_Params:(id)params Url:(NSString *)url Token:(id)token Completed:(RXCompleteBlock)block {
    return [self Delete_Params:params Url:url Token:(id)token Completed:block Target:nil];
}

- (NSURLSessionDataTask *)Delete_Params:(id)params Url:(NSString *)url Token:(id)token Completed:(RXCompleteBlock)block Target:(id)target {
    return [self request_Method:RXRequestMethodDelete
                         Params:params
                            Url:url
                           Json:YES
                          Token:(id)token
                        Succeed:^(id object) {
        if (block) block(YES, [RXResponse succeedWithObject:object]);
    } Failed:^(NSInteger statusCode, id object) {
        if (block) block(NO, [RXResponse failedWithStatusCode:statusCode
                                                       object:object]);
    } Target:target];
}

- (NSURLSessionDataTask *)Patch_Params:(id)params Url:(NSString *)url Token:(id)token Completed:(RXCompleteBlock)block {
    return [self Patch_Params:params Url:url Token:(id)token Completed:block Target:nil];
}

- (NSURLSessionDataTask *)Patch_Params:(id)params Url:(NSString *)url Token:(id)token Completed:(RXCompleteBlock)block Target:(id)target {
    return [self request_Method:RXRequestMethodPatch
                         Params:params
                            Url:url
                           Json:YES
                          Token:(id)token
                        Succeed:^(id object) {
        if (block) block(YES, [RXResponse succeedWithObject:object]);
    } Failed:^(NSInteger statusCode, id object) {
        if (block) block(NO, [RXResponse failedWithStatusCode:statusCode
                                                       object:object]);
    } Target:target];
}

#pragma mark - # Request Method #

- (NSURLSessionDataTask *)request_Method:(RXRequestMethod)method
                                  Params:(id)params
                                     Url:(NSString *)url
                                    Json:(BOOL)isJson
                                   Token:(id)token
                                 Succeed:(RXSucceedBlock)succeed
                                  Failed:(RXFailedBlock)failed
                                  Target:(id)target {
    
    NSMutableDictionary * auths = [[NSMutableDictionary alloc] init];
    if (token) [auths setValue:[NSString stringWithFormat:@"Bearer %@", token] forKey:@"Authorization"];
    
    AFHTTPSessionManager * manager = isJson ? self.jsonSessionManager : self.httpSessionManager;
    NSURLSessionDataTask * task;

    NSString * fixURL = SetUrl(url);
    switch (method) {
        case RXRequestMethodGet: {
            task = [manager GET:fixURL parameters:params headers:auths progress:^(NSProgress * _Nonnull downloadProgress) {
                
            } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                [self Succeed_Object:responseObject Task:task Json:isJson Succeed:succeed Failed:failed Target:target];
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                [self Failed_Task:task SystemError:error HttpError:nil Failed:failed Target:target];
            }];
        } break;
        case RXRequestMethodPost: {
            task = [manager POST:fixURL parameters:params headers:auths progress:^(NSProgress * _Nonnull downloadProgress) {
                
            } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                [self Succeed_Object:responseObject Task:task Json:isJson Succeed:succeed Failed:failed Target:target];
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                [self Failed_Task:task SystemError:error HttpError:nil Failed:failed Target:target];
            }];
        } break;
        case RXRequestMethodDelete: {
            task = [manager DELETE:fixURL parameters:params headers:auths success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                if (succeed) {
                    ManageTaskQueue(task, target);
                    succeed(responseObject);
                }
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                [self Failed_Task:task SystemError:error HttpError:nil Failed:failed Target:target];
            }];
        } break;
        case RXRequestMethodPatch: {
            task = [manager PATCH:fixURL parameters:params headers:auths success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                [self Succeed_Object:responseObject Task:task Json:isJson Succeed:succeed Failed:failed Target:target];
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                [self Failed_Task:task SystemError:error HttpError:nil Failed:failed Target:target];
            }];
        } break;
        
        default: break;
    }
    
    self.totalTaskCount = task.taskIdentifier;
    ManageTaskQueue(task, target)
    WriteTaskLog(task, params)
    return task;
}

#pragma mark - # Request Method Elements #

#pragma mark Succeed / Failed

- (void)Succeed_Object:(id _Nullable)responseObject
                  Task:(NSURLSessionDataTask * _Nonnull)task
                  Json:(BOOL)isJson
               Succeed:(RXSucceedBlock)succeed
                Failed:(RXFailedBlock)failed
                Target:(id)target {
    ManageTaskQueue(task, target)

    if (!isJson) {  // data
        [self DataObject:responseObject
                    Task:task
                 Succeed:succeed
                  Failed:failed
                  Target:target];
    } else {  // json
        [self JsonObject:responseObject
                    Task:task
                 Succeed:succeed
                  Failed:failed
                  Target:target];
    }
}

- (void)Failed_Task:(NSURLSessionDataTask * _Nonnull)task
        SystemError:(NSError * __nullable)system
          HttpError:(NSError * __nullable)http
             Failed:(RXFailedBlock)failed
             Target:(id)target {
    ManageTaskQueue(task, target)
    
    NSString * description;
    if (system) {
        description = system.localizedDescription;
    } else if (http) {
        description = http.localizedDescription;
    }
    
    NSInteger httpCode = http ? http.code : ((NSHTTPURLResponse *)task.response).statusCode;
    if (failed) {
        failed(httpCode, description);
    }
    
    WriteErrorLog(task, system.code, httpCode, description);
}

#pragma mark Json / Data

- (void)JsonObject:(id _Nullable)responseObject
              Task:(NSURLSessionDataTask * _Nonnull)task
           Succeed:(RXSucceedBlock)succeed
            Failed:(RXFailedBlock)failed
            Target:(id)target {
    
    // http请求异常则立刻返回http失败原因
    NSInteger statusCode = ((NSHTTPURLResponse *)task.response).statusCode;
    if (statusCode < HttpSuccessCodeOK || statusCode > HttpSuccessCodePartialContent) {
        [self Failed_Task:task
              SystemError:nil
                HttpError:[RXNetHelper httpErrorWithCode:statusCode]
                   Failed:failed
                   Target:target];
        return;
    }
    
    // 非正常字典类型数据 直接过滤
    if (![responseObject isKindOfClass:[NSDictionary class]])  {
        NSError * error = [NSError errorWithDomain:@"" code:-1 userInfo:@{NSLocalizedDescriptionKey : @"[ResponseObject Is Not Validated JsonObject]"}];
        [self Failed_Task:task
              SystemError:nil
                HttpError:error
                   Failed:failed
                   Target:target];
        return;
    }
    if (succeed) {
        ManageTaskQueue(task, target);
        succeed(responseObject);
    }
}

- (void)DataObject:(id _Nullable)responseObject
              Task:(NSURLSessionDataTask * _Nonnull)task
           Succeed:(RXSucceedBlock)succeed
            Failed:(RXFailedBlock)failed
            Target:(id)target {
    
    NSError * error;
    NSDictionary * resultDic;
    if ([responseObject isKindOfClass:[NSDictionary class]]) {
        resultDic = responseObject;
    } else {
        resultDic = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:&error];
    }
    
    if (error) {
        [self Failed_Task:task
              SystemError:error
                HttpError:nil
                   Failed:failed
                   Target:target];
    } else {
        [self JsonObject:responseObject
                    Task:task
                 Succeed:succeed
                  Failed:failed
                  Target:target];
    }
}

#pragma mark - # upload & download #

- (void)upload_File:(NSData *)fileData
                Url:(NSString *)url
              Token:(id)token
           FileName:(NSString *)fileName
             Params:(NSDictionary *)params
     UploadProgress:(RXUploadProgress)progress
          Completed:(RXCompleteBlock)block {
    [self upload_File:fileData
                  Url:url
                Token:(id)token
               Header:nil
             FileName:fileName
               Params:params
       UploadProgress:progress
            Completed:block
               Target:nil];
}

- (void)upload_File:(NSData *)fileData
                Url:(NSString *)url
              Token:(id)token
             Header:(NSDictionary *)header
           FileName:(NSString *)fileName
             Params:(NSDictionary *)params
     UploadProgress:(RXUploadProgress)progress
          Completed:(RXCompleteBlock)block
             Target:(id)target {
    if (!fileName) fileName = @"1.jpg";
    
    AFHTTPRequestSerializer *requester = [AFHTTPRequestSerializer serializer];
    
    NSMutableDictionary * auths = [[NSMutableDictionary alloc] init];
    if (token) [auths setValue:[NSString stringWithFormat:@"Bearer %@", token] forKey:@"Authorization"];
    if (header) [auths addEntriesFromDictionary:header];
    [auths enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        [requester setValue:obj forHTTPHeaderField:key];
    }];
    
    NSMutableURLRequest *request = [requester multipartFormRequestWithMethod:@"PUT" URLString:SetUrl(url) parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        NSString * mimeType = [self contentTypeForData:fileData];
        [formData appendPartWithFileData:fileData name:@"file" fileName:fileName mimeType:mimeType];
    } error:nil];
    
    NSURLSessionUploadTask * uploadTask;
    uploadTask = [self.httpSessionManager uploadTaskWithRequest:request fromData:fileData progress:^(NSProgress * _Nonnull uploadProgress) {
        if (progress) progress(uploadProgress);
    } completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if (error) {
            [self Failed_Task:uploadTask SystemError:error HttpError:nil Failed:^(NSInteger statusCode, id object) {
                if (block) block(NO, [RXResponse failedWithStatusCode:statusCode
                                                               object:object]);
            } Target:target];
        } else {
            id object = responseObject;
            if (block) block(YES, [RXResponse succeedWithObject:object]);
        }
    }];
    [uploadTask resume];

    WriteTaskLog(uploadTask, params)
}

- (NSURLSessionDownloadTask *)download:(NSString *)url token:(NSString *)token path:(NSString *)savePath progress:(void (^)(NSProgress *))downloadProgressBlock block:(void (^)(id result,NSString *error))block {
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    [request setValue:[NSString stringWithFormat:@"Bearer %@", token] forHTTPHeaderField:@"Authorization"];
    
    NSURLSessionDownloadTask *task = [self.httpSessionManager downloadTaskWithRequest:request progress:downloadProgressBlock destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
        NSString * path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        path = [path stringByAppendingPathComponent:@"download"];
        if (savePath) path = savePath;
        BOOL isExist = [[NSFileManager defaultManager] fileExistsAtPath:path];
        if (!isExist) {
            [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
        }
        path = [path stringByAppendingFormat:@"/%@", response.suggestedFilename];
        return [NSURL fileURLWithPath:path];
    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        if (!error) {
            if(block)block(filePath,nil);
        } else {
            if(block)block(nil,error.description);
        }
    }];
    [task resume];
    
    return task;
}

@end



@implementation RXResponse

+ (id)succeedWithObject:(id)object {
    RXResponse * response = [[RXResponse alloc] init];
    response.object = object;
    return response;
}

+ (id)failedWithStatusCode:(NSInteger)status object:(id)object {
    RXResponse * response = [[RXResponse alloc] init];
    response.object = object;
    response.statusCode = status;
    return response;
}

@end
