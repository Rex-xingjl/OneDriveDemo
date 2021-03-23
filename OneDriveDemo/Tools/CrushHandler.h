//
//  CrushHandler.h
//  COMEngine
//
//  Created by Rex on 2019/4/4.
//  Copyright © 2019 yunxiang. All rights reserved.
//
//  拦截应用中常见的崩溃问题

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (CrushHandler)

- (void)swizzleMethod:(SEL)originalSelector swizzledSelector:(SEL)swizzledSelector;

+ (void)swizzlingMethod:(NSString *)systemMethodString systemClassString:(NSString *)systemClassString toSafeMethod:(NSString *)safeMethodString targetClassString:(NSString *)targetClassString;

@end

@interface NSArray (CrushHandler)

@end

@interface NSDictionary (CrushHandler)

@end

@interface NSMutableString (CrushHandler)

@end

@interface UITableView(CrushHandler)

@end

NS_ASSUME_NONNULL_END
