//
//  ScanQRCodeViewController.m
//  QRCodeProduct
//
//  Created by 一卡易 on 15/11/4.
//  Copyright © 2015年 1card1. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "ScanQRCodeViewController.h"
#import "ShowScanContentViewController.h"

@interface ScanQRCodeViewController ()<AVCaptureMetadataOutputObjectsDelegate>
{
    //活动指示器
    UIView *view_activityBg;
    UIActivityIndicatorView *activity_scan;
    
    UIImageView *imgView_scanBg;//扫码框
    UIImageView *imgView_line;//扫码线
    
    //扫码线动画参数
    NSInteger time_num; //时间
    BOOL upOrdown;
    NSTimer *timer_animation;//动画
    
    CGFloat view_width;
    CGFloat view_height;
    BOOL lightState;//闪关灯状态
}
@property (strong, nonatomic) AVCaptureSession *captureSession;
@property (strong, nonatomic) AVCaptureVideoPreviewLayer *videoPreviewLayer;
@property (strong, nonatomic) AVCaptureMetadataOutput *captureMetadataOutput;

@end

@implementation ScanQRCodeViewController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"LoadedCamera" object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    //关闭扫码
    [self.captureSession stopRunning];
    [timer_animation invalidate];
    timer_animation = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.captureSession) {//直接开启扫码
        [self.captureSession startRunning];
        
        //扫码线动画
        upOrdown = NO;
        time_num = 0;
        timer_animation = [NSTimer scheduledTimerWithTimeInterval:.02 target:self selector:@selector(lineAnimationAction) userInfo:nil repeats:YES];
    }
    else {//首次启动该界面时
        [self performSelectorOnMainThread:@selector(initScanCodeView) withObject:self waitUntilDone:NO];
//        [self initScanCodeView];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hiddenActivityAction:) name:@"LoadedCamera" object:nil];
    self.title = @"扫码";
    self.view.backgroundColor = [UIColor whiteColor];
    
    //闪光灯
    UIButton *flashLamp = [UIButton buttonWithType:UIButtonTypeCustom];
    flashLamp.frame = CGRectMake(0, 0, 60, 30);
    [flashLamp setTitle:@"闪光灯" forState:UIControlStateNormal];
    [flashLamp setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    flashLamp.titleLabel.font = [UIFont systemFontOfSize:15.0];
    [flashLamp addTarget:self action:@selector(onFlashLampAction) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightBarItem = [[UIBarButtonItem alloc] initWithCustomView:flashLamp];
    self.navigationItem.rightBarButtonItem = rightBarItem;
    
    //初始化
    view_height = CGRectGetHeight(self.view.frame);
    view_width  = CGRectGetWidth(self.view.frame);
    
    //界面布局
    [self initActivityView];
    [self initScanBackgroundAction];
}

#pragma mark 通知事件 相机加载完成时，处理一些事件
- (void)hiddenActivityAction:(id)sender {
    [UIView animateWithDuration:0.8
                          delay:0.5
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         view_activityBg.frame = CGRectMake(0, 64, view_width, view_height);
                         
                     } completion:^(BOOL finished) {
                         //关闭指示器
                         [activity_scan stopAnimating];
                         view_activityBg.hidden = YES;
                         [view_activityBg.layer removeFromSuperlayer];
                         imgView_scanBg.hidden = NO; //显示框
                         
                         //扫码线动画
                         upOrdown = NO;
                         time_num = 0;
                         timer_animation = [NSTimer scheduledTimerWithTimeInterval:.02 target:self selector:@selector(lineAnimationAction) userInfo:nil repeats:YES];
                     }];
}

#pragma mark 闪光灯
- (void)onFlashLampAction {
    if (!self.captureSession) {
        return;
    }
    
    Class captureDeviceClass = NSClassFromString(@"AVCaptureDevice");
    if (captureDeviceClass != nil) {
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        if ([device hasTorch] && [device hasFlash]){
            [device lockForConfiguration:nil];
            if (!lightState) {
                [device setTorchMode:AVCaptureTorchModeOn];
                [device setFlashMode:AVCaptureFlashModeOn];
                lightState = YES;
            }
            else {
                [device setTorchMode:AVCaptureTorchModeOff];
                [device setFlashMode:AVCaptureFlashModeOff];
                lightState = NO;
            }
            [device unlockForConfiguration];
        }
    }
}

#pragma mark - 初始化活动指示器
- (void)initActivityView {
    view_activityBg = [[UIView alloc] initWithFrame:CGRectMake(0, 64, view_width, view_height)];
    view_activityBg.backgroundColor = [UIColor darkGrayColor];
    [self.view.layer addSublayer:view_activityBg.layer];
    
    activity_scan = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake((view_width - 50) / 2, (view_height - 50) / 2 - 90, 50, 50)];
    activity_scan.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
    [view_activityBg.layer addSublayer:activity_scan.layer];
    [activity_scan startAnimating];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(activity_scan.frame) + 5, view_width, 20)];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont systemFontOfSize:14.0];
    label.textAlignment = NSTextAlignmentCenter;
    [view_activityBg addSubview:label];
    label.text = @"正在加载...";
}

#pragma mark - 扫码框架，提示初始化
- (void)initScanBackgroundAction {
    //扫码框背景图片
    imgView_scanBg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 64, view_width, view_height)];
    imgView_scanBg.image = [UIImage imageNamed:@"qr_bg_img"];
    [self.view addSubview:imgView_scanBg];
    imgView_scanBg.hidden = YES;
    
    //提示语
    UILabel *markLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, view_height - 150 - 60, view_width - 60, 60)];
    markLabel.backgroundColor = [UIColor clearColor];
    markLabel.textColor = [UIColor lightGrayColor];
    markLabel.textAlignment = NSTextAlignmentCenter;
    markLabel.font = [UIFont systemFontOfSize:15.0];
    markLabel.numberOfLines = 0;
    [imgView_scanBg addSubview:markLabel];
    markLabel.text = @"将二维码/条形码放在取景框内，进行扫描!";
    
    //扫码线
    imgView_line = [[UIImageView alloc] initWithFrame:CGRectMake((view_width - 260) / 2, CGRectGetHeight(imgView_scanBg.frame) * 27 / 542 + 15, 260, 1)];
    imgView_line.backgroundColor = [UIColor colorWithRed:174/255.0 green:143/255.0 blue:101/255.0 alpha:1];
    [imgView_scanBg addSubview:imgView_line];
}

//扫码线动画
- (void)lineAnimationAction {
    if (upOrdown == NO) {
        time_num++;
        imgView_line.frame = CGRectMake(CGRectGetMinX(imgView_line.frame), CGRectGetHeight(imgView_scanBg.frame) * 27 / 542 + 15 + time_num, CGRectGetWidth(imgView_line.frame), 1);
        CGFloat tempHeight = CGRectGetHeight(imgView_scanBg.frame) * 321 / 542;
        NSInteger height = (NSInteger)tempHeight - 30;
        if (time_num == height) {
            upOrdown = YES;
        }
    }
    else {
        time_num--;
        imgView_line.frame = CGRectMake(CGRectGetMinX(imgView_line.frame), CGRectGetHeight(imgView_scanBg.frame) * 27 / 542 + 15 + time_num, CGRectGetWidth(imgView_line.frame), 1);
        if (time_num == 0) {
            upOrdown = NO;
        }
    }
}

#pragma mark - 扫码初始化，只初始化一次
- (void)initScanCodeView {
    //初始化
    NSError *error;
    AVCaptureDevice *currentDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:currentDevice error:&error];
    
    if (!deviceInput) { //判断是否可以调用相机
        NSLog(@"%@", [error localizedDescription]);
    }
    else {
        //设置会话的输入设备
        _captureSession = [[AVCaptureSession alloc] init];
        [_captureSession addInput:deviceInput];
        
        //对应输出
        _captureMetadataOutput = [[AVCaptureMetadataOutput alloc] init];
        [_captureSession addOutput:_captureMetadataOutput];
        
        //设置处理代理
        [_captureMetadataOutput setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
        
        //设置条码类型
        [_captureMetadataOutput setMetadataObjectTypes:@[AVMetadataObjectTypeQRCode,AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode128Code]];
        
        //将捕获的数据流展现出来
        _videoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_captureSession];
        [_videoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
        [_videoPreviewLayer setFrame:self.view.layer.bounds];
        [self.view.layer insertSublayer:_videoPreviewLayer atIndex:0];
        
        //开始捕获
        [_captureSession startRunning];
        
        //通知相机加载完成
        [[NSNotificationCenter defaultCenter] postNotificationName:@"LoadedCamera" object:nil];
    }
}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate  扫码结果代理
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    //判断是否有数据
    if (metadataObjects != nil && [metadataObjects count] > 0) {
        AVMetadataMachineReadableCodeObject *metadataObj = [metadataObjects objectAtIndex:0];
        if ([[metadataObj type] isEqualToString:AVMetadataObjectTypeQRCode]) {
            NSLog(@"二维码");
        }
        else if ([[metadataObj type] isEqualToString:AVMetadataObjectTypeEAN13Code]) {
            NSLog(@"条形码");
        }
        else if ([[metadataObj type] isEqualToString:AVMetadataObjectTypeEAN8Code]) {
            NSLog(@"3");
        }
        NSLog(@"%@",metadataObj.stringValue);//扫描内容
        //扫描结束后
        [self dealScanResultAction:metadataObj.stringValue];
    }
}

#pragma mark 处理扫码结果
- (void)dealScanResultAction:(id)sender {
    NSLog(@"扫描的内容：%@",sender);
    //关闭扫码
    [self.captureSession stopRunning];
    [timer_animation invalidate];
    timer_animation = nil;
    
    ShowScanContentViewController *showScanContentVC = [[ShowScanContentViewController alloc] init];
    showScanContentVC.contentString = sender;
    [self.navigationController pushViewController:showScanContentVC animated:YES];
}

@end
