//
//  RXNetHelper.h
//  COMEngine
//
//  Created by Rex on 2019/6/25.
//  Copyright © 2019 yunxiang. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, RXHttpCode) {
    HttpSuccessCodeOK                    = 200,
    HttpSuccessCodeCreated               = 201,
    HttpSuccessCodeAccepted              = 202,
    HttpSuccessCodeNonAuthForDNS         = 203,
    HttpSuccessCodeNoContent             = 204,
    HttpSuccessCodeResetContent          = 205,
    HttpSuccessCodePartialContent        = 206,
    
    HttpRedirectCodeMultipleChoices      = 300,
    HttpRedirectCodeMovedPermanently     = 301,
    HttpRedirectCodeMovedTemporarily     = 302,
    HttpRedirectCodeSeeOther             = 303,
    HttpRedirectCodeNotModified          = 304,
    HttpRedirectCodeUseProxy             = 305,
    HttpRedirectCodeRedirectKeepVerb     = 307,
    
    HttpFailureCodeBadRequest            = 400,
    HttpFailureCodeUnauthorized          = 401,
    HttpFailureCodeForbidden             = 403,
    HttpFailureCodeNotFound              = 404,
    HttpFailureCodeMethodNotAllowed      = 405,
    HttpFailureCodeNotAcceptable         = 406,
    HttpFailureCodeProxyAuthRequired     = 407,
    HttpFailureCodeRequestTimedOut       = 408,
    HttpFailureCodeConflict              = 409,
    HttpFailureCodeGone                  = 410,
    HttpFailureCodeLengthRequired        = 411,
    HttpFailureCodePreconditionFailed    = 412,
    HttpFailureCodeRequestEntityTooLarge = 413,
    HttpFailureCodeRequestURITooLarge    = 414,
    HttpFailureCodeUnsupportedMediaType  = 415,
    HttpFailureCodeRangeNotSatisfiable   = 416,
    HttpFailureCodeExpectationFailed     = 417,
    
    HttpServerCodeInternalServerError    = 500,
    HttpServerCodeNotImplemented         = 501,
    HttpServerCodeBadGateway             = 502,
    HttpServerCodeServiceUnavailable     = 503,
    HttpServerCodeGatewayTimeout         = 504,
    HttpServerCodeVersionNotSupported    = 505,
};

NS_ASSUME_NONNULL_BEGIN

@interface RXNetHelper : NSObject

+ (NSError *)httpErrorWithCode:(RXHttpCode)code;

@end

NS_ASSUME_NONNULL_END
