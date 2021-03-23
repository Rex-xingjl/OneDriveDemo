//
//  CrushHandler.m
//  COMEngine
//
//  Created by Rex on 2019/4/4.
//  Copyright © 2019 yunxiang. All rights reserved.
//

#import "CrushHandler.h"
#import <objc/runtime.h>

@implementation NSObject (CrushHandler)

- (void)swizzleMethod:(SEL)originalSelector swizzledSelector:(SEL)swizzledSelector {
    Class class = [self class];
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
    
    BOOL didAddMethod = class_addMethod(class,
                                        originalSelector,
                                        method_getImplementation(swizzledMethod),
                                        method_getTypeEncoding(swizzledMethod));
    if (didAddMethod) {
        class_replaceMethod(class,
                            swizzledSelector,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

+ (void)swizzlingMethod:(NSString *)systemMethodString systemClassString:(NSString *)systemClassString toSafeMethod:(NSString *)safeMethodString targetClassString:(NSString *)targetClassString {

    Method sysMethod = class_getInstanceMethod(NSClassFromString(systemClassString), NSSelectorFromString(systemMethodString));

    Method safeMethod = class_getInstanceMethod(NSClassFromString(targetClassString), NSSelectorFromString(safeMethodString));

    method_exchangeImplementations(safeMethod,sysMethod);
}

- (void)rx_handleWithCondition:(BOOL)condition handleBlock:(void (^)(void))block {
    if (condition) {
        @try {
            if (block) block();
        } @catch (NSException *exception) {
            NSLog(@"[CrushHandler] %@", exception.reason);
        } @finally {
        }
    } else {
        if (block) block();
    }
}

@end

@implementation NSArray (CrushHandler)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        @autoreleasepool {
            [objc_getClass("__NSArray0") swizzleMethod:@selector(objectAtIndex:) swizzledSelector:@selector(swizzling_0_ObjectIndex:)];
            [objc_getClass("__NSArrayI") swizzleMethod:@selector(objectAtIndex:) swizzledSelector:@selector(swizzling_I_ObjectIndex:)];
            [objc_getClass("__NSArrayM") swizzleMethod:@selector(objectAtIndex:) swizzledSelector:@selector(swizzling_M_ObjectIndex:)];
            [objc_getClass("__NSArrayI") swizzleMethod:@selector(objectAtIndexedSubscript:) swizzledSelector:@selector(swizzling_I_ObjectAtIndexedSubscript:)];
            [objc_getClass("__NSArrayM") swizzleMethod:@selector(objectAtIndexedSubscript:) swizzledSelector:@selector(swizzling_M_ObjectAtIndexedSubscript:)];
            [objc_getClass("__NSArrayM") swizzleMethod:@selector(insertObject:atIndex:) swizzledSelector:@selector(swizzling_InsertObject:atIndex:)];
            [objc_getClass("__NSArrayM") swizzleMethod:@selector(removeObjectsInRange:) swizzledSelector:@selector(swizzling_RemoveObjectsInRange:)];
            [objc_getClass("__NSPlaceholderArray") swizzleMethod:@selector(initWithObjects:count:) swizzledSelector:@selector(swizzling_InitWithObjects:count:)];
        }
    });
}

- (id)swizzling_I_ObjectAtIndexedSubscript:(NSUInteger)index {
    BOOL condition = index > self.count - 1 || !self.count;
    __block id object;
    [self rx_handleWithCondition:condition handleBlock:^{
         object = [self swizzling_I_ObjectAtIndexedSubscript:index];
    }];
    return object;
}

- (id)swizzling_M_ObjectAtIndexedSubscript:(NSUInteger)index {
    BOOL condition = index > self.count - 1 || !self.count;
    __block id object;
    [self rx_handleWithCondition:condition handleBlock:^{
         object = [self swizzling_M_ObjectAtIndexedSubscript:index];
    }];
    return object;
}

- (id)swizzling_0_ObjectIndex:(NSInteger)index {
    BOOL condition = index >= self.count || index < 0;
    __block id object;
    [self rx_handleWithCondition:condition handleBlock:^{
         object = [self swizzling_0_ObjectIndex:index];
    }];
    return object;
}

- (id)swizzling_I_ObjectIndex:(NSInteger)index {
    BOOL condition = index >= self.count || index < 0;
    __block id object;
    [self rx_handleWithCondition:condition handleBlock:^{
         object = [self swizzling_I_ObjectIndex:index];
    }];
    return object;
}

- (id)swizzling_M_ObjectIndex:(NSInteger)index {
    BOOL condition = index >= self.count || index < 0;
    __block id object;
    [self rx_handleWithCondition:condition handleBlock:^{
         object = [self swizzling_M_ObjectIndex:index];
    }];
    return object;
}

- (void)swizzling_InsertObject:(id)object atIndex:(NSUInteger)index {
    BOOL condition = object == nil;
    [self rx_handleWithCondition:condition handleBlock:^{
         [self swizzling_InsertObject:object atIndex:index];
    }];
}

- (void)swizzling_RemoveObjectsInRange:(NSRange)range {
    BOOL condition = range.location > self.count || range.length > self.count || range.location + range.length > self.count;
    [self rx_handleWithCondition:condition handleBlock:^{
        [self swizzling_RemoveObjectsInRange:range];
    }];
}

- (id)swizzling_InitWithObjects:(const id [])objects count:(NSUInteger)count {
    BOOL condition1 = objects == NULL;
    BOOL condition2;
    
    id objects_new[count];
    int count_new = 0;
    for (int i = 0; i < count; i ++) {
        if (objects[i] != nil) {
            objects_new[count_new] = objects[i];
            count_new ++;
        } else {
            condition2 = YES;
        }
    }
    return [self swizzling_InitWithObjects:objects_new count:count_new];
}

@end

@implementation NSDictionary (CrushHandler)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        @autoreleasepool {
            [self swizzlingMethod:@"initWithObjects:forKeys:count:" systemClassString:@"__NSPlaceholderDictionary"
                     toSafeMethod:@"swizzling_InitWithObjects:forKeys:count:"
                targetClassString:@"NSDictionary"];
            [objc_getClass("__NSDictionaryI") swizzleMethod:@selector(dictionaryWithObjects:forKeys:count:) swizzledSelector:@selector(swizzling_DictionaryWithObjects:forKeys:count:)];
            [objc_getClass("__NSDictionary0") swizzleMethod:@selector(objectForKey:) swizzledSelector:@selector(swizzling_0_objectForKey:)];
            [objc_getClass("__NSDictionaryI") swizzleMethod:@selector(setValue:forKey:) swizzledSelector:@selector(swizzling_I_setValue:forKey:)];
            [objc_getClass("__NSDictionaryM") swizzleMethod:@selector(setObject:forKey:) swizzledSelector:@selector(swizzling_M_setObject:forKey:)];
            [objc_getClass("__NSDictionaryM") swizzleMethod:@selector(removeObjectForKey:) swizzledSelector:@selector(swizzling_M_removeObjectForKey:)];
        }
    });
}

- (id)swizzling_0_objectForKey:(NSString *)key {
    BOOL condition = !key;
    __block id object;
    [self rx_handleWithCondition:condition handleBlock:^{
         object = [self swizzling_0_objectForKey:key];
    }];
    return object;
}

- (void)swizzling_M_removeObjectForKey:(id<NSCopying>)key {
    BOOL condition = !key;
    [self rx_handleWithCondition:condition handleBlock:^{
         [self swizzling_M_removeObjectForKey:key];
    }];
}

- (void)swizzling_I_setValue:(id)value forKey:(NSString* )key {
    if (!key) {
        NSLog(@"[CrushHandler] 字典key为空 %s", __FUNCTION__);
        return;
    }
    if (!value) {
        value = [NSNull null];
        NSLog(@"[CrushHandler] 字典Value为空 %s", __FUNCTION__);
        return;
    }
    [self swizzling_I_setValue:value forKey:key];
}

- (void)swizzling_M_setObject:(id)object forKey:(NSString* )key {
    if (!key) {
        NSLog(@"[CrushHandler] 字典key为空 %s", __FUNCTION__);
        return;
    }
    if (!object) {
        object = [NSNull null];
        NSLog(@"[CrushHandler] 字典Value为空 %s", __FUNCTION__);
        return;
    }
    [self swizzling_M_setObject:object forKey:key];
}

+ (instancetype)swizzling_DictionaryWithObjects:(const id [])objects forKeys:(const id<NSCopying> [])keys count:(NSUInteger)cnt {
    id safeObjects[cnt];
    id safeKeys[cnt];
    NSUInteger j = 0;
    for (NSUInteger i = 0; i < cnt; i++) {
        id key = keys[i];
        id obj = objects[i];
        if (!key || !obj) continue;
        
        safeKeys[j] = key;
        safeObjects[j] = obj;
        j++;
    }
    return [self swizzling_DictionaryWithObjects:safeObjects forKeys:safeKeys count:j];
}

- (instancetype)swizzling_InitWithObjects:(const id [])objects forKeys:(const id<NSCopying> [])keys count:(NSUInteger)cnt {
    id safeObjects[cnt];
    id safeKeys[cnt];
    NSUInteger j = 0;
    for (NSUInteger i = 0; i < cnt; i++) {
        id key = keys[i];
        id obj = objects[i];
        if (!key || !obj) continue;
        if (!obj) obj = [NSNull null];
        
        safeKeys[j] = key;
        safeObjects[j] = obj;
        j++;
    }
    return [self swizzling_InitWithObjects:safeObjects forKeys:safeKeys count:j];
}

@end

@implementation NSMutableString (CrushHandler)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = objc_getClass("__NSCFString");
        [class swizzleMethod:@selector(substringFromIndex:) swizzledSelector:@selector(swizzling_SubstringFromIndex:)];
        [class swizzleMethod:@selector(substringToIndex:) swizzledSelector:@selector(swizzling_SubstringToIndex:)];
        [class swizzleMethod:@selector(substringWithRange:) swizzledSelector:@selector(swizzling_SubstringWithRange:)];
        [class swizzleMethod:@selector(rangeOfString:options:range:locale:) swizzledSelector:@selector(swizzling_RangeOfString:options:range:locale:)];
        [class swizzleMethod:@selector(appendString:) swizzledSelector:@selector(swizzling_AppendString:)];
    });
}

- (NSString *)swizzling_SubstringFromIndex:(NSUInteger)index {
    BOOL condition = index >= self.length;
    __block id object;
    [self rx_handleWithCondition:condition handleBlock:^{
         object = [self swizzling_SubstringFromIndex:index];
    }];
    return object;
}

- (NSString *)swizzling_SubstringToIndex:(NSUInteger)index {
    BOOL condition = index >= self.length;
    __block id object;
    [self rx_handleWithCondition:condition handleBlock:^{
         object = [self swizzling_SubstringToIndex:index];
    }];
    return object;
}

- (NSRange)swizzling_RangeOfString:(NSString *)searchString options:(NSStringCompareOptions)mask range:(NSRange)rangeOfReceiverToSearch locale:(nullable NSLocale *)locale {
    if (!searchString) {
        searchString = self;
    }
    if (rangeOfReceiverToSearch.location > self.length) {
        rangeOfReceiverToSearch = NSMakeRange(0, self.length);
    }
    if (rangeOfReceiverToSearch.length > self.length) {
        rangeOfReceiverToSearch = NSMakeRange(0, self.length);
    }
    if ((rangeOfReceiverToSearch.location + rangeOfReceiverToSearch.length) > self.length) {
        rangeOfReceiverToSearch = NSMakeRange(0, self.length);
    }
    return [self swizzling_RangeOfString:searchString options:mask range:rangeOfReceiverToSearch locale:locale];
}

- (NSString *)swizzling_SubstringWithRange:(NSRange)range {
    BOOL condition = range.location > self.length || range.length > self.length || (range.location + range.length) > self.length;
    __block id object;
    [self rx_handleWithCondition:condition handleBlock:^{
         object = [self swizzling_SubstringWithRange:range];
    }];
    return object;
}

- (void)swizzling_AppendString:(NSString *)string {
    if (!string) {
        return;
    }
    [self swizzling_AppendString:string];
}

@end

@implementation UITableView (CrushHandler)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = objc_getClass("UITableView");
        
        [class swizzleMethod:@selector(reloadRowsAtIndexPaths:withRowAnimation:) swizzledSelector:@selector(swizzling_reloadRowsAtIndexPaths:withRowAnimation:)];
        [class swizzleMethod:@selector(insertRowsAtIndexPaths:withRowAnimation:) swizzledSelector:@selector(swizzling_insertRowsAtIndexPaths:withRowAnimation:)];
        [class swizzleMethod:@selector(deleteRowsAtIndexPaths:withRowAnimation:) swizzledSelector:@selector(swizzling_deleteRowsAtIndexPaths:withRowAnimation:)];
        [class swizzleMethod:@selector(moveRowAtIndexPath:toIndexPath:) swizzledSelector:@selector(swizzling_moveRowAtIndexPath:toIndexPath:)];
        
        [class swizzleMethod:@selector(scrollToRowAtIndexPath:atScrollPosition:animated:) swizzledSelector:@selector(swizzling_scrollToRowAtIndexPath:atScrollPosition:animated:)];
    });
}

- (void)swizzling_reloadRowsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation {
    [self rx_handleRowsAtIndexPaths:indexPaths handleBlock:^{
        [self swizzling_reloadRowsAtIndexPaths:indexPaths withRowAnimation:animation];
    }];
}

- (void)swizzling_insertRowsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation {
    [self rx_handleRowsAtIndexPaths:indexPaths handleBlock:^{
        [self swizzling_insertRowsAtIndexPaths:indexPaths withRowAnimation:animation];
    }];
}

- (void)swizzling_deleteRowsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation {
    [self rx_handleRowsAtIndexPaths:indexPaths handleBlock:^{
        [self swizzling_deleteRowsAtIndexPaths:indexPaths withRowAnimation:animation];
    }];
}

- (void)swizzling_moveRowsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation {
    [self rx_handleRowsAtIndexPaths:indexPaths handleBlock:^{
        [self swizzling_moveRowsAtIndexPaths:indexPaths withRowAnimation:animation];
    }];
}


- (void)swizzling_scrollToRowAtIndexPath:(NSIndexPath *)indexPath atScrollPosition:(UITableViewScrollPosition)scrollPosition animated:(BOOL)animated {
    BOOL beyound = [self rx_indexPathBeyoundTableView:@[indexPath]];
    [self rx_handleWithCondition:beyound handleBlock:^{
        [self swizzling_scrollToRowAtIndexPath:indexPath atScrollPosition:scrollPosition animated:animated];
    }];
}

#pragma mark #

- (void)rx_handleRowsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths handleBlock:(void (^)(void))block {
    BOOL beyound = [self rx_indexPathBeyoundTableView:indexPaths];
    [self rx_handleWithCondition:beyound handleBlock:^{
        if (@available(iOS 11.0, *)) {
            [self performBatchUpdates:^{
                if (block) block();
            } completion:nil];
        } else {
            [self beginUpdates];
            if (block) block();
            [self endUpdates];
        }
    }];
}

- (void)rx_handleSectionAtIndexSets:(NSIndexSet *)sections handleBlock:(void (^)(void))block {
    BOOL beyound = [self rx_sectionsBeyoundTableView:sections];
    [self rx_handleWithCondition:beyound handleBlock:^{
        if (@available(iOS 11.0, *)) {
            [self performBatchUpdates:^{
                if (block) block();
            } completion:nil];
        } else {
            [self beginUpdates];
            if (block) block();
            [self endUpdates];
        }
    }];
}

- (BOOL)rx_sectionsBeyoundTableView:(NSIndexSet *)sections {
    __block BOOL beyound = NO;
    NSInteger section_count = [self numberOfSections];
    [sections enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
        if (idx >= section_count) {
            beyound = YES;
            *stop = YES;
        }
    }];
    return beyound;
}


- (BOOL)rx_indexPathBeyoundTableView:(NSArray <NSIndexPath *>*)indexPaths {
    BOOL beyound = NO;
    NSInteger section_count = [self numberOfSections];
    for (NSIndexPath * indexPath in indexPaths) {
        if (indexPath.section < section_count) {
            NSInteger row_count = [self numberOfRowsInSection:indexPath.section];
            if (indexPath.row < row_count) {
                continue;
            } else {
                beyound = YES; break;
            }
        } else {
            beyound = YES; break;
        }
    }
    return beyound;
}

@end
