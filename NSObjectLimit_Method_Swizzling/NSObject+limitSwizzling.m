//
//  NSObject+limitSwizzling.m
//  NSObjectLimit_Method_Swizzling
//
//  Created by zym on 15/3/6.
//  Copyright (c) 2015年 zym. All rights reserved.
//

#import "NSObject+limitSwizzling.h"
#import <objc/runtime.h>

static NSString *authorizeIdentifier = @"com.threeti.NSObjectLimit-Method-Swizzling";

@implementation NSObject (limitSwizzling)

+(void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        
        SEL originalSelector = @selector(init);
        SEL swizzledSelector = @selector(limit_init);
        
        Method originalMethod = class_getInstanceMethod(class, originalSelector);
        Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
        
        BOOL didAddMehod = class_addMethod(class,
                                           originalSelector,
                                           method_getImplementation(swizzledMethod),
                                           method_getTypeEncoding(swizzledMethod));
        
        if (didAddMehod) {
            class_replaceMethod(class,
                                swizzledSelector,
                                method_getImplementation(originalMethod),
                                method_getTypeEncoding(originalMethod));
        }else{
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }
        
    });
}
-(instancetype)limit_init
{
    //获取到当前执行的类
    NSString *currentClassName = NSStringFromClass([self class]);
    const char *currentClassName_char = [currentClassName UTF8String];
    __weak id currentClass = objc_getClass(currentClassName_char);
    
    [[self limitClassArray] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        const char *limitClassName_char = [(NSString *)obj UTF8String];
        id limitClass = objc_getClass(limitClassName_char);
        
        if (limitClass == currentClass) {
            
            NSString *appIdentifier = [[NSBundle mainBundle] bundleIdentifier];
            //NSAssert([appIdentifier isEqualToString:authorizeIdentifier], @"当前bundleIdentifier不匹配，请联系管理员进行授权");
            
            if (![appIdentifier isEqualToString:authorizeIdentifier]){
                
                NSLog(@"当前bundleIdentifier不匹配，请联系管理员进行授权");
                exit(0);
            }
        }
        
    }];;
    
    return [self limit_init];
    
}

-(NSArray *)limitClassArray
{
    
    return @[@"TTIView",
             @"TTIView1",];
}



@end
