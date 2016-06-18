//
//  ScanQRCodeViewController.m
//  QRCodeProduct
//

#import <AVFoundation/AVFoundation.h>
#import "ScanQRCodeViewController.h"
#import "ScanQRCodeView.h"
#import "ShowScanContentViewController.h"

@interface ScanQRCodeViewController ()<AVCaptureMetadataOutputObjectsDelegate>
{
    ScanQRCodeView *scanQRView;
    
    CGFloat view_width;
    CGFloat view_height;
    BOOL isWait;
    BOOL lightState;//闪关灯状态
}
@property (strong, nonatomic) AVCaptureSession *captureSession;
@property (strong, nonatomic) AVCaptureVideoPreviewLayer *videoPreviewLayer;
@property (strong, nonatomic) AVCaptureMetadataOutput *captureMetadataOutput;

@end

@implementation ScanQRCodeViewController

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"LoadedCamera" object:nil];
    self.captureSession = nil;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    //关闭扫码
    [self.captureSession stopRunning];
    scanQRView.isShowScanLine = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    
    if (self.captureSession) { //直接开启扫码
        [self.captureSession startRunning];
        scanQRView.isShowScanLine = YES;
    }
    else { //首次启动该界面时
        [self performSelectorOnMainThread:@selector(initScanCodeFunction) withObject:nil waitUntilDone:NO];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(hiddenActivityAction:)
                                                 name:@"LoadedCamera"
                                               object:nil];
    
    //数据初始化
    view_height = CGRectGetHeight(self.view.frame);
    view_width  = CGRectGetWidth(self.view.frame);
    
    //界面初始化
    scanQRView = [[ScanQRCodeView alloc] initWithFrame:CGRectMake(0, 0, view_width, view_height)];
    scanQRView.isShowActivity = YES;
    [self.view addSubview:scanQRView];
    scanQRView.backBtn.tag = 100;
    [scanQRView.backBtn addTarget:self action:@selector(btnAction_clickBtn:) forControlEvents:UIControlEventTouchUpInside];
    scanQRView.recordBtn.tag = 101;
    [scanQRView.recordBtn addTarget:self action:@selector(btnAction_clickBtn:) forControlEvents:UIControlEventTouchUpInside];
    scanQRView.helpBtn.tag = 102;
    [scanQRView.helpBtn addTarget:self action:@selector(btnAction_clickBtn:) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark btn action
- (void)btnAction_clickBtn:(UIButton *)btn {
    switch (btn.tag) {
        case 100:
            [self.navigationController popViewControllerAnimated:YES];
            break;
        case 101: {
        }
            break;
        case 102:
            
            break;
            
        default:
            break;
    }
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

#pragma mark 通知事件 相机加载完成时，处理一些事件
- (void)hiddenActivityAction:(id)sender {
    scanQRView.isShowActivity = NO;
}

#pragma mark 初始化扫码功能
- (void)initScanCodeFunction {
    NSError *error;
    AVCaptureDevice *currentDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:currentDevice error:&error];
    if (!deviceInput) { //判断是否可以调用相机
        NSLog(@"%@", [error localizedDescription]);
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示"
                                                            message:@"没有权限访问您的相机，请在“设置－隐私－相机”中允许使用"
                                                           delegate:nil
                                                  cancelButtonTitle:@"确定"
                                                  otherButtonTitles: nil];
        [alertView show];
    }
    else {
        //设置会话的输入设备
        self.captureSession = [[AVCaptureSession alloc] init];
        [self.captureSession addInput:deviceInput];
        
        //对应输出
        self.captureMetadataOutput = [[AVCaptureMetadataOutput alloc] init];
        [self.captureSession addOutput:_captureMetadataOutput];
        
        //设置处理代理
        [self.captureMetadataOutput setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
        //设置扫码类型
        [self.captureMetadataOutput setMetadataObjectTypes:@[AVMetadataObjectTypeQRCode,
                                                             AVMetadataObjectTypeEAN13Code,
                                                             AVMetadataObjectTypeEAN8Code,
                                                             AVMetadataObjectTypeCode128Code]];
        
        //调整扫描区域
        CGRect viewRect = self.view.frame;
        CGRect containerRect = scanQRView.scanBgImgView.frame;
        CGFloat x = containerRect.origin.y / viewRect.size.height;
        CGFloat y = containerRect.origin.x / viewRect.size.width;
        CGFloat width = containerRect.size.height / viewRect.size.height;
        CGFloat height = containerRect.size.width / viewRect.size.width;
        self.captureMetadataOutput.rectOfInterest = CGRectMake(x, y, width, height);
        
        //将捕获的数据流展现出来
        self.videoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.captureSession];
        [self.videoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
        [self.videoPreviewLayer setFrame:self.view.layer.bounds];
        [self.view.layer insertSublayer:self.videoPreviewLayer atIndex:0];
        
        //开始捕获
        [self.captureSession startRunning];
        
        //通知相机加载完成
        [[NSNotificationCenter defaultCenter] postNotificationName:@"LoadedCamera" object:nil];
    }
}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate  扫码结果代理
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    if (metadataObjects != nil && [metadataObjects count] > 0 && !isWait) { //判断是否有数据
        isWait = YES;
        [self performSelector:@selector(openOrCloseScanStatus) withObject:nil afterDelay:5.0]; //设置扫码间隔
        
        AVMetadataMachineReadableCodeObject *metadataObj = [metadataObjects objectAtIndex:0];
        NSLog(@"%@",metadataObj.stringValue);//扫描内容
        if ([[metadataObj type] isEqualToString:AVMetadataObjectTypeQRCode]) {
            NSLog(@"二维码");
        }
        else if ([[metadataObj type] isEqualToString:AVMetadataObjectTypeEAN13Code]) {
            NSLog(@"条形码");
        }
        else if ([[metadataObj type] isEqualToString:AVMetadataObjectTypeEAN8Code]) {
            NSLog(@"3");
        }
        [self dealScanResultAction:metadataObj.stringValue]; //扫描结束后
    }
}

- (void)openOrCloseScanStatus {
    isWait = NO;
}

#pragma mark 处理扫码结果
- (void)dealScanResultAction:(NSString *)url {
    NSLog(@"扫描的内容：%@",url);
    //关闭扫码
    [self.captureSession stopRunning];
    scanQRView.isShowScanLine = YES;
    
    ShowScanContentViewController *showScanContentVC = [[ShowScanContentViewController alloc] init];
    showScanContentVC.contentString = url;
    [self.navigationController pushViewController:showScanContentVC animated:YES];
}

@end
