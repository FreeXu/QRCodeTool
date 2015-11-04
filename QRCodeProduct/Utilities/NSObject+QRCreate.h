//
//  NSObject+QRCreate.h
//  QRProduct
//
//  Created by xulisheng-Mac on 15/6/11.
//  Copyright (c) 2015年 xulisheng-Mac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSObject (QRCreate)

#pragma mark - InterpolatedUIImage  二维码图片
- (UIImage *)createNonInterpolatedUIImageFormCIImage:(CIImage *)image withSize:(CGFloat)size;

#pragma mark - QRCodeGenerator  二维码原型
- (CIImage *)createQRForString:(NSString *)qrString;

#pragma mark - imageToTransparent  二维码图片处理  改变二维码颜色
- (UIImage*)imageBlackToTransparent:(UIImage*)image withRed:(CGFloat)red andGreen:(CGFloat)green andBlue:(CGFloat)blue;

@end
