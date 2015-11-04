//
//  HomeViewController.m
//  QRCodeProduct
//
//  Created by 一卡易 on 15/11/4.
//  Copyright © 2015年 1card1. All rights reserved.
//

#import "HomeViewController.h"
#import "ScanQRCodeViewController.h"
#import "CreateQrCodeViewController.h"

@interface HomeViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    CGFloat view_width;
    CGFloat view_height;
}
@end

@implementation HomeViewController

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"主页";
    self.view.backgroundColor = [UIColor whiteColor];
    
    //数据初始化
    view_width  = CGRectGetWidth(self.view.frame);
    view_height = CGRectGetHeight(self.view.frame);
    
    //界面布局
    UITableView *tableView_list = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, view_width, view_height)];
    tableView_list.dataSource = self;
    tableView_list.delegate = self;
    tableView_list.backgroundColor = [UIColor whiteColor];
    //tableView_list.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:tableView_list];
}

#pragma mark - UITableView datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identify = @"CellIdentify";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
        
        UIImageView *lineImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 49.5, view_width, 0.5)];
        lineImgView.backgroundColor = [UIColor lightGrayColor];
        //[cell addSubview:lineImgView];
    }
    
    if (indexPath.row == 0) {
        cell.textLabel.text = @"扫码";
    }
    else if (indexPath.row == 1) {
        cell.textLabel.text = @"生成二维码";
    }
    
    return cell;
}

#pragma mark - UITableView Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 0) {
        ScanQRCodeViewController *scanQrCodeVC = [[ScanQRCodeViewController alloc] init];
        [self.navigationController pushViewController:scanQrCodeVC animated:YES];
    }
    else if (indexPath.row == 1) {
        CreateQrCodeViewController *createQRCodeVC = [[CreateQrCodeViewController alloc] init];
        [self.navigationController pushViewController:createQRCodeVC animated:YES];
    }
}

@end
