//
//  ScanQRCodeView.m
//  ParkPlus
//
//  Created by xuls on 16/4/19.
//  Copyright © 2016年 Genvict. All rights reserved.
//

#import "ScanQRCodeView.h"

#define ScanCodeBgColor [UIColor colorWithRed:.0 green:.0 blue:.0 alpha:0.3] //背景透明度
static const CGFloat buttonWidth = 30.0;
static const CGFloat scanLineY = 7.0;//扫码线的Y坐标

@interface ScanQRCodeView ()
{
    UIView *topView;
    UIImageView *scanBgImgView;
    UIView *bottomView;
    UIActivityIndicatorView *activity_scan;
    
    CGFloat view_height;
    CGFloat view_width;
    //扫码线动画参数
    NSInteger time_num;//时间
    BOOL upOrdown;
    NSTimer *timer_animation; //动画
}
@property (nonatomic, strong) UIView *activityView;
@property (nonatomic, strong) UIImageView *scanLine;

@end

@implementation ScanQRCodeView
@synthesize scanBgImgView;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor blackColor];
        view_width = CGRectGetWidth(frame);
        view_height = CGRectGetHeight(frame);
        
        //顶部设置
        topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, view_width, 140)];
        topView.backgroundColor = ScanCodeBgColor;
        [self addSubview:topView];
        
        CGFloat tempY = 100.0;
        CGFloat distance = 40.0;
        UIImageView *barCode = [[UIImageView alloc] initWithFrame:CGRectMake(distance, tempY, 20, 20)];
        barCode.image = [UIImage imageNamed:@"scanQR_barCode"];
        [topView addSubview:barCode];
        
        UILabel *mark = [[UILabel alloc] initWithFrame:CGRectMake(distance, tempY, view_width - 2 * distance, 20)];
        mark.textColor = [UIColor whiteColor];
        mark.font = [UIFont systemFontOfSize:16.0];
        mark.textAlignment = NSTextAlignmentCenter;
        [topView addSubview:mark];
        mark.text = @"将条形码/二维码放入框内";
        
        UIImageView *qrCode = [[UIImageView alloc] initWithFrame:CGRectMake(view_width - distance - 20, tempY, 20, 20)];
        qrCode.image = [UIImage imageNamed:@"scanQR_code"];
        [topView addSubview:qrCode];
        
        //扫码框
        [self initScanCodeViewWithY:CGRectGetMaxY(topView.frame) withX:distance];
        
        //底部
        bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(scanBgImgView.frame), view_width, view_height - CGRectGetMaxY(scanBgImgView.frame))];
        bottomView.backgroundColor = ScanCodeBgColor;
        [self addSubview:bottomView];
        
        UIImageView *circleImgView = [[UIImageView alloc] initWithFrame:CGRectMake((view_width - 10) / 2, 10, 10, 10)];
        circleImgView.backgroundColor = [UIColor blueColor];
        [bottomView addSubview:circleImgView];
        circleImgView.layer.cornerRadius = CGRectGetHeight(circleImgView.frame) / 2;
        circleImgView.layer.masksToBounds = YES;
        
        UILabel *scanLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(circleImgView.frame) + 5, view_width, 20)];
        scanLabel.textColor = [UIColor blueColor];
        scanLabel.textAlignment = NSTextAlignmentCenter;
        scanLabel.font = [UIFont systemFontOfSize:18.0];
        [bottomView addSubview:scanLabel];
        scanLabel.text = @"扫码付";
    }
    
    return self;
}

#pragma mark init
//初始化扫码框
- (void)initScanCodeViewWithY:(CGFloat)tempY withX:(CGFloat)tempX {
    CGFloat tempWidth = view_width - 2 * tempX;
    scanBgImgView = [[UIImageView alloc] initWithFrame:CGRectMake(tempX, tempY, tempWidth, tempWidth)];
    [scanBgImgView setImage:[UIImage imageNamed:@"scanQR_border"]];
    [self addSubview:scanBgImgView];
    
    UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, tempY, tempX, tempWidth)];
    leftView.backgroundColor = ScanCodeBgColor;
    [self addSubview:leftView];
    
    UIView *rightView = [[UIView alloc] initWithFrame:CGRectMake(tempX + tempWidth, tempY, tempX, tempWidth)];
    rightView.backgroundColor = ScanCodeBgColor;
    [self addSubview:rightView];
}

#pragma mark get method
- (UIButton *)backBtn {
    if (!_backBtn) {
        _backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _backBtn.frame = CGRectMake(20, 25, buttonWidth, buttonWidth);
        [_backBtn setImage:[UIImage imageNamed:@"scanQR_back"] forState:UIControlStateNormal];
        [topView addSubview:_backBtn];
    }
    return _backBtn;
}

- (UIButton *)recordBtn {
    if (!_recordBtn) {
        _recordBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _recordBtn.frame = CGRectMake(view_width - 20 - buttonWidth - 15 - buttonWidth, 25, buttonWidth, buttonWidth);
        [_recordBtn setImage:[UIImage imageNamed:@"scanQR_record"] forState:UIControlStateNormal];
        [topView addSubview:_recordBtn];
    }
    return _recordBtn;
}

- (UIButton *)helpBtn {
    if (!_helpBtn) {
        _helpBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _helpBtn.frame = CGRectMake(view_width - 20 - buttonWidth, 25, buttonWidth, buttonWidth);
        [_helpBtn setImage:[UIImage imageNamed:@"scanQR_help"] forState:UIControlStateNormal];
        [topView addSubview:_helpBtn];
    }
    return _helpBtn;
}

- (UIView *)activityView {
    if (!_activityView) {
        _activityView = [[UIView alloc] initWithFrame:scanBgImgView.frame];
        _activityView.backgroundColor = ScanCodeBgColor;
        [self addSubview:_activityView];
        
        activity_scan = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(((CGRectGetWidth(_activityView.frame)) - 50) / 2, (CGRectGetHeight(_activityView.frame) - 50) / 2, 50, 50)];
        activity_scan.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
        [_activityView addSubview:activity_scan];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(activity_scan.frame) + 5, CGRectGetWidth(_activityView.frame), 20)];
        label.textColor = [UIColor whiteColor];
        label.font = [UIFont systemFontOfSize:16.0];
        label.textAlignment = NSTextAlignmentCenter;
        [_activityView addSubview:label];
        label.text = @"正在加载...";
    }
    return _activityView;
}

- (UIImageView *)scanLine {
    if (!_scanLine) {
        _scanLine = [[UIImageView alloc] initWithFrame:CGRectMake(scanLineY, scanLineY, CGRectGetWidth(scanBgImgView.frame) - 2 * scanLineY, 2)];
        _scanLine.backgroundColor = [UIColor blueColor];
        [scanBgImgView addSubview:_scanLine];
    }
    return _scanLine;
}

#pragma mark set method
- (void)setIsShowActivity:(BOOL)isShowActivity {
    if (isShowActivity) {
        self.activityView.hidden = NO;
        [activity_scan startAnimating];
    }
    else {
        [activity_scan stopAnimating];
        self.activityView.hidden = YES;
        [self.activityView removeFromSuperview];
        self.activityView = nil;
        self.backgroundColor = [UIColor clearColor];
        
        //扫码线动画
        self.isShowScanLine = YES;
    }
}

- (void)setIsShowScanLine:(BOOL)isShowScanLine {
    if (isShowScanLine) {
        self.scanLine.hidden = NO;
        upOrdown = NO;
        time_num = 0;
        timer_animation = [NSTimer scheduledTimerWithTimeInterval:.01 target:self selector:@selector(lineAnimationAction) userInfo:nil repeats:YES];
    }
    else {
        self.scanLine.hidden = YES;
        [timer_animation invalidate];
        timer_animation = nil;
        time_num = 0;
    }
}

//扫码线动画
- (void)lineAnimationAction {
    if (upOrdown == NO) {
        time_num++;
        self.scanLine.frame = CGRectMake(CGRectGetMinX(self.scanLine.frame), scanLineY + time_num, CGRectGetWidth(self.scanLine.frame), CGRectGetHeight(self.scanLine.frame));
        CGFloat tempHeight = CGRectGetHeight(scanBgImgView.frame) - 2 * scanLineY;
        if (time_num == (NSInteger)tempHeight) {
            upOrdown = YES;
        }
    }
    else {
        time_num--;
        self.scanLine.frame = CGRectMake(CGRectGetMinX(self.scanLine.frame), scanLineY + time_num, CGRectGetWidth(self.scanLine.frame), CGRectGetHeight(self.scanLine.frame));
        if (time_num == 0) {
            upOrdown = NO;
        }
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
