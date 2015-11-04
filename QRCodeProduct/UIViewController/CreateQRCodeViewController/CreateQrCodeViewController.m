//
//  CreateQrCodeViewController.m
//  QRCodeProduct
//
//  Created by 一卡易 on 15/11/4.
//  Copyright © 2015年 1card1. All rights reserved.
//

#import "CreateQrCodeViewController.h"
#import "NSObject+QRCreate.h"

@interface CreateQrCodeViewController ()<UITextViewDelegate,UIActionSheetDelegate>
{
    UITextView *myTextView;
    UIImageView *showQrImgView;
    
    NSString *selectColor;
}

@end

@implementation CreateQrCodeViewController

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"生成二维码";
    self.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO; //去掉scroll上面的空白
    
    selectColor = @"yellow";
    [self initCurrentView];
}

#pragma mark - 界面布局
- (void)initCurrentView {
    CGFloat tempWidth = CGRectGetWidth(self.view.frame);
    
    myTextView = [[UITextView alloc] initWithFrame:CGRectMake((tempWidth - 240) / 2, 80, 240, 60)];
    myTextView.backgroundColor = [UIColor lightGrayColor];
    myTextView.textColor = [UIColor darkGrayColor];
    myTextView.font = [UIFont systemFontOfSize:16.0];
    myTextView.layer.cornerRadius = 3.0;
    myTextView.layer.masksToBounds = YES;
    myTextView.contentInset = UIEdgeInsetsMake(-3, 0, 0, 0); //设置文字与边框的间距
    myTextView.keyboardType = UIKeyboardTypeURL;
    myTextView.text = @"请输入二维码内容";
    myTextView.delegate = self;
    [self.view addSubview:myTextView];
    
    //
    UISegmentedControl *mySegmentControl = [[UISegmentedControl alloc] initWithItems:@[@"黄",@"绿",@"蓝",@"紫"]];
    mySegmentControl.frame = CGRectMake((tempWidth - 240)/2, 160, 240, 30);
    mySegmentControl.selectedSegmentIndex = 0; //默认选择
    [self.view addSubview:mySegmentControl];
    [mySegmentControl addTarget:self action:@selector(segmentControllerAction:) forControlEvents:UIControlEventValueChanged];
    
    //
    UIButton *createButton = [UIButton buttonWithType:UIButtonTypeCustom];
    createButton.frame = CGRectMake((tempWidth - 100)/2, 220, 100, 30);
    createButton.backgroundColor = [UIColor lightGrayColor];
    [createButton setTitle:@"生成二维码" forState:UIControlStateNormal];
    [createButton setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    createButton.titleLabel.font = [UIFont systemFontOfSize:16.0];
    createButton.layer.cornerRadius = 5.0;
    createButton.layer.masksToBounds = YES;
    [self.view addSubview:createButton];
    [createButton addTarget:self action:@selector(createQRMethod) forControlEvents:UIControlEventTouchUpInside];
    
    //
    showQrImgView = [[UIImageView alloc] initWithFrame:CGRectMake((tempWidth - 240)/2, 300, 240, 240)];
    showQrImgView.backgroundColor = [UIColor clearColor];
    showQrImgView.userInteractionEnabled = YES;
    showQrImgView.tag = 100;
    [self.view addSubview:showQrImgView];
    
    //阴影设置
    showQrImgView.layer.shadowOffset = CGSizeMake(0, 2);
    showQrImgView.layer.shadowRadius = 2;
    showQrImgView.layer.shadowColor = [UIColor blackColor].CGColor;
    showQrImgView.layer.shadowOpacity = 0.5;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnImgViewAction:)];
    [showQrImgView addGestureRecognizer:tap];
}

- (void)segmentControllerAction:(UISegmentedControl *)sender {
    if (sender.selectedSegmentIndex == 0) {
        selectColor = @"yellow";
    }
    else if (sender.selectedSegmentIndex == 1) {
        selectColor = @"green";
    }
    else if (sender.selectedSegmentIndex == 2) {
        selectColor = @"blue";
    }
    else {
        selectColor = @"purple";
    }
}

#pragma mark - 创建二维码
- (void)createQRMethod {
    [myTextView resignFirstResponder];
    NSString *tempUrl = [myTextView.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    if (myTextView.text.length == 0) {
        return;
    }
    
    UIImage *tempQrImg = [self createNonInterpolatedUIImageFormCIImage:[self createQRForString:tempUrl] withSize:240];
    if ([selectColor isEqualToString:@"yellow"]) {
        tempQrImg = [self imageBlackToTransparent:tempQrImg withRed:255 andGreen:255 andBlue:0];
    }
    else if ([selectColor isEqualToString:@"green"]) {
        tempQrImg = [self imageBlackToTransparent:tempQrImg withRed:0 andGreen:128 andBlue:0];
    }
    else if ([selectColor isEqualToString:@"blue"]) {
        tempQrImg = [self imageBlackToTransparent:tempQrImg withRed:0 andGreen:0 andBlue:255];
    }
    else if ([selectColor isEqualToString:@"purple"]) {
        tempQrImg = [self imageBlackToTransparent:tempQrImg withRed:128 andGreen:0 andBlue:128];
    }
    showQrImgView.image = tempQrImg;
}

- (void)tapOnImgViewAction:(UIGestureRecognizer *)temptap {
    NSLog(@"%ld",(long)temptap.view.tag);
    [myTextView resignFirstResponder];
    
    if (showQrImgView.image) {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                                 delegate:self
                                                        cancelButtonTitle:@"取消"
                                                   destructiveButtonTitle:nil
                                                        otherButtonTitles:@"保存到相册", nil];
        [actionSheet showInView:self.view];
    }
}

#pragma mark - UITextView delegate
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    textView.text = @"";
    
    return YES;
}


#pragma mark - UIActionSheet delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSLog(@"%ld",(long)buttonIndex);
    if (buttonIndex == 0) {
        /*
         *  将图片保存到iPhone本地相册
         *  UIImage *image            图片对象
         *  id completionTarget       响应方法对象
         *  SEL completionSelector    方法
         *  void *contextInfo
         */
        UIImageWriteToSavedPhotosAlbum(showQrImgView.image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    }
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if (error == nil) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"已存入手机相册" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        [alert show];
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"保存失败" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        [alert show];
    }
}

@end
