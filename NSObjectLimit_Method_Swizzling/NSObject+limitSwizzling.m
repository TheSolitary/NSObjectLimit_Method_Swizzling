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

/**
 *  我们可以利用method_exchangeImplementations 来交换2个方法中的IMP，
 *  我们可以利用 class_replaceMethod 来修改类，
 *  我们可以利用 method_setImplementation 来直接设置某个方法的IMP，
 *  归根结底，都是偷换了selector的IMP
 */

+(void)load
{
    
    /**
     *  Swizzling 的处理，在类的 +load 方法中完成。
     *  因为 +load 方法会在类被添加到 OC 运行时执行，保证了 Swizzling 方法的及时处理。
     */
    
    /**
     *  Swizzling 的处理，dispatch_once 中完成。保证只执行一次。
     */
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        
        SEL originalSelector = @selector(init);
        SEL swizzledSelector = @selector(limit_init);
        
        Method originalMethod = class_getInstanceMethod(class, originalSelector);
        Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
        
        //IMP实际上是一个函数指针，指向方法实现的首地址
        
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
    
    //遍历当前我们需要授权的类的名字的数组
    [[self limitClassArray] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        //获取到“受保护”类的对象
        const char *limitClassName_char = [(NSString *)obj UTF8String];
        id limitClass = objc_getClass(limitClassName_char);
        
        if (limitClass == currentClass) {
            //获取当前identifier
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
