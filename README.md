# QRCodeTool二维码处理

1.扫码 

 从iOS7开始，苹果增加的扫码API，可以利用苹果自带的方法，完成扫码功能；初始化扫码代码如下：
 
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
      }
        
将上面的初始化封装，在- (void)viewWillAppear:(BOOL)animated中调用


2.生成二维码

 利用系统的方法，画出对应的二维码，颜色可以自定义
