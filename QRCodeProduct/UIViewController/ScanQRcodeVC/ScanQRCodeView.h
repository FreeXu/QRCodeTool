//
//  ScanQRCodeView.h
//  ParkPlus
//
//  Created by xuls on 16/4/19.
//  Copyright © 2016年 Genvict. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ScanQRCodeView : UIView

@property (nonatomic, strong) UIImageView *scanBgImgView;
@property (nonatomic, strong) UIButton *backBtn;
@property (nonatomic, strong) UIButton *recordBtn;
@property (nonatomic, strong) UIButton *helpBtn;
@property (nonatomic, assign) BOOL isShowActivity;
@property (nonatomic, assign) BOOL isShowScanLine;

@end
