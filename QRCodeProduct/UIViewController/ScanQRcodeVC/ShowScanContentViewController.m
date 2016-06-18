//
//  ShowScanContentViewController.m
//  QRCodeProduct
//
//  Created by 一卡易 on 15/11/4.
//  Copyright © 2015年 1card1. All rights reserved.
//

#import "ShowScanContentViewController.h"

@interface ShowScanContentViewController ()

@end

@implementation ShowScanContentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"扫描内容";
    self.view.backgroundColor = [UIColor whiteColor];
    
    UITextView *showTextView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 100)];
    showTextView.textColor = [UIColor blackColor];
    showTextView.font = [UIFont systemFontOfSize:16.0];
    showTextView.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:showTextView];
    showTextView.editable = NO;
    showTextView.text = _contentString;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
