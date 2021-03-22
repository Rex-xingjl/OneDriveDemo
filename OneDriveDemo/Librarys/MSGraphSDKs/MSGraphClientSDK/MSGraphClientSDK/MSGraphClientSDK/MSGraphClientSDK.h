//
// Copyright (c) Microsoft Corporation. All Rights Reserved. Licensed under the MIT License. See License in the project root for license information.
//

#import <Foundation/Foundation.h>

//! Project version number for MSGraphClientSDK.
FOUNDATION_EXPORT double MSGraphClientSDKVersionNumber;

//! Project version string for MSGraphClientSDK.
FOUNDATION_EXPORT const unsigned char MSGraphClientSDKVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <PublicHeader.h>



#ifndef MSSDK_h
#define MSSDK_h

#import "MSAuthenticationProvider.h"
#import "MSAuthenticationProviderOptions.h"
#import "MSHttpProvider.h"
#import "MSGraphMiddleware.h"
#import "MSMiddlewareOptions.h"

#import "MSURLSessionManager.h"
#import "MSClientFactory.h"
#import "MSMiddlewareFactory.h"
#import "MSConstants.h"
#import "MSURLSessionTaskDelegate.h"
#import "MSAuthenticationHandler.h"
#import "MSRedirectHandler.h"
#import "MSRetryHandler.h"

#import "MSURLSessionTask.h"
#import "MSURLSessionDataTask.h"
#import "MSURLSessionDownloadTask.h"
#import "MSURLSessionUploadTask.h"

#import "MSErrorCodes.h"
#import "MSBatchRequestStep.h"
#import "MSBatchRequestContent.h"
#import "MSBatchResponseContent.h"

#import "MSRetryHandlerOptions.h"
#import "MSRedirectHandlerOptions.h"
#import "MSAuthenticationHandlerOptions.h"

#import "MSPageIterator.h"
#import "MSLargeFileUploadTask.h"
#import "MSGraphOneDriveLargeFileUploadTask.h"

#endif



