//
//  RXNetHelper.m
//  COMEngine
//
//  Created by Rex on 2019/6/25.
//  Copyright © 2019 yunxiang. All rights reserved.
//

#import "RXNetHelper.h"

@implementation RXNetHelper

+ (NSError *)httpErrorWithCode:(RXHttpCode)code {
    NSString * description = @"";
    switch (code) {
        case HttpSuccessCodeOK: description = @"请求成功"; break;
        case HttpSuccessCodeCreated: description = @"请求成功并创建了新的资源"; break;
        case HttpSuccessCodeAccepted: description = @"已经接受请求，但未处理完成"; break;
        case HttpSuccessCodeNonAuthForDNS: description = @"请求成功，但返回的信息可能来自另一来源"; break;
        case HttpSuccessCodeNoContent:
        case HttpSuccessCodeResetContent: description = @"请求成功，但没有返回任何内容"; break;
        case HttpSuccessCodePartialContent: description = @"服务器成功处理了部分GET请求。"; break;

        case HttpRedirectCodeMultipleChoices: description = @"针对请求，服务器可执行多种操作。服务器可根据请求者 (user agent) 选择一项操作，或提供操作列表供请求者选择"; break;
        case HttpRedirectCodeMovedPermanently: description = @"请求地址已永久移动到新位置"; break;
        case HttpRedirectCodeMovedTemporarily: description = @"请求地址目前暂时移动到新位置"; break;
        case HttpRedirectCodeSeeOther: description = @"查看其它地址"; break;
        case HttpRedirectCodeNotModified: description = @"请求地址未修改过"; break;
        case HttpRedirectCodeUseProxy: description = @"只能使用代理访问请求地址"; break;
        case HttpRedirectCodeRedirectKeepVerb: description = @"请求地址临时重定向"; break;
            
        case HttpFailureCodeBadRequest: description = @"请求的语法错误，服务器无法理解"; break;
        case HttpFailureCodeUnauthorized: description = @"请求需要身份认证"; break;
        case HttpFailureCodeForbidden: description = @"请求被服务器拒绝"; break;
        case HttpFailureCodeNotFound: description = @"请求地址无法找到"; break;
        case HttpFailureCodeMethodNotAllowed: description = @"客户端请求中的方法被禁止"; break;
        case HttpFailureCodeNotAcceptable: description = @"无法根据请求的内容特性完成请求"; break;
        case HttpFailureCodeProxyAuthRequired: description = @"请求要求代理的身份认证"; break;
        case HttpFailureCodeRequestTimedOut: description = @"请求超时"; break;
        case HttpFailureCodeConflict: description = @"请求处理过程中发生了冲突"; break;
        case HttpFailureCodeGone: description = @"请求地址目前已经不存在"; break;
        case HttpFailureCodeLengthRequired: description = @"请求缺失了ContentLength信息"; break;
        case HttpFailureCodePreconditionFailed: description = @"请求信息先决条件错误"; break;
        case HttpFailureCodeRequestEntityTooLarge: description = @"请求实体过大，服务器无法处理，因此拒绝请求"; break;
        case HttpFailureCodeRequestURITooLarge: description = @"请求的URI过长，无法处理"; break;
        case HttpFailureCodeUnsupportedMediaType: description = @"无法处理请求附带的媒体格式"; break;
        case HttpFailureCodeRangeNotSatisfiable: description = @"请求的范围无效"; break;
        case HttpFailureCodeExpectationFailed: description = @"无法满足Expect的请求头信息"; break;
            
        case HttpServerCodeInternalServerError: description = @"服务器内部错误，无法完成请求"; break;
        case HttpServerCodeNotImplemented: description = @"服务器不支持请求的功能，无法完成请求"; break;
        case HttpServerCodeBadGateway: description = @"尝试执行请求时，从远程服务器接收到了一个无效的响应"; break;
        case HttpServerCodeServiceUnavailable: description = @"由于超载或系统维护，暂时无法处理请求"; break;
        case HttpServerCodeGatewayTimeout: description = @"网关或代理的服务器，未及时从远端服务器获取请求"; break;
        case HttpServerCodeVersionNotSupported: description = @"服务器不支持请求的HTTP协议的版本"; break;

        default: description = @"未知网络错误";
            break;
    }
    NSString * localizedDescription = [NSString stringWithFormat:@"[http-%ld] %@", code, description];
    return [NSError errorWithDomain:description code:code userInfo:@{NSLocalizedDescriptionKey : localizedDescription}];
}

@end
