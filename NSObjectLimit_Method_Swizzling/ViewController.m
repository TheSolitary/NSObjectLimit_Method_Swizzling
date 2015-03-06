//
//  ViewController.m
//  NSObjectLimit_Method_Swizzling
//
//  Created by zym on 15/3/6.
//  Copyright (c) 2015年 zym. All rights reserved.
//

#import "ViewController.h"
#import "TTIView.h"
#import "TTIView1.h"
#import "TTIView2.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    TTIView *view = [TTIView new];
    [self.view addSubview:view];
    
    TTIView1 *view1 = [TTIView1 new];
    [self.view addSubview:view1];
    
    TTIView2 *view2 = [TTIView2 new];
    [self.view addSubview:view2];
}



@end
