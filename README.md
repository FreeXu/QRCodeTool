# QRCodeTool二维码处理

1.扫码 

 从iOS7开始，苹果增加的扫码API，可以利用苹果自带的方法，完成扫码功能；初始化扫码代码如下：
 
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
        
将上面的初始化封装，在- (void)viewWillAppear:(BOOL)animated中调用


2.生成二维码

 利用系统的方法，画出对应的二维码，颜色可以自定义
