//
//  LoginViewController.m
//  PetCare
//
//  Created by mao ke on 2017/3/21.
//  Copyright © 2017年 江苏科茂. All rights reserved.
//

#import "LoginViewController.h"
#import "AppDelegate.h"
#import "DevTableViewController.h"
#import "KeyboardToolBar.h"
#import "DKProgressHUD.h"

@interface LoginViewController ()
@property NSString *logining;
@property NSString *showMsg;
@property NSString *pwdError;
@property NSString *dataError;
@end

@implementation LoginViewController
- (IBAction)LoginClick:(id)sender {
    [DKProgressHUD showLoadingWithStatus:_logining];
    NSLog(@"BtnUser:%@,BtnPwd:%@", _BtnUser.text,_BtnPwd.text);
    if (_BtnPwd.text.length ==0 && _BtnUser.text.length ==0) {
        [self showAlert:_showMsg];
    }else{
        NSString *post = [NSString stringWithFormat:@"%@%@%@%@%@",@"paraName={\"name\":method,\"value\":PhoneLogIn},{\"name\":user,\"value\":",_BtnUser.text,@"},{\"name\":psw,\"value\":",_BtnPwd.text,@"}"];
        [[AppDelegate instance]postToData:post postMac:nil ];
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(LoginJudge:) name:@"postToData" object:nil];
            [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(LoginDataError) name:@"postToDataError" object:nil];
        });
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if ([[[AppDelegate instance]currentLanguage]isEqualToString:@"en"]) {
        _logining = @"Logining...";
        _showMsg = @"The username password can not be empty";
        _pwdError = @"Account or password error";
        _dataError = @"The server is busy. Please try again later";
    }else{
        _logining = @"正在登录";
        _showMsg = @"用户名密码不能为空";
        _pwdError = @"用户名密码错误";
        _dataError = @"服务器繁忙，请稍后再试";
    }
    // Do any additional setup after loading the view.
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    _BtnUser.text = [defaults objectForKey:@"userName"];
    _BtnPwd.text = [defaults objectForKey:@"passWord"];
    // 去掉返回按钮
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"" style:(UIBarButtonItemStyleDone) target:self action:nil];
    // 去掉返回手势
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
    /// 为UITextField注册使用KeyboardToolBar.
    [KeyboardToolBar registerKeyboardToolBarWithTextField:self.BtnPwd];
    [KeyboardToolBar registerKeyboardToolBarWithTextField:self.BtnUser];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [DKProgressHUD dismiss];
}

/**
 警告框提醒

 @param msg 提醒内容
 */
-(void)showAlert:(NSString *)msg{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:msg preferredStyle:UIAlertControllerStyleAlert ];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"ok" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:ok];
    [self presentViewController:alert animated:YES completion:nil];
}

//数据库登录返回判断结果
-(void)LoginJudge:(NSNotification *)noti{
    NSLog(@"notice:%@", noti.userInfo);
    if ([noti.userInfo isEqual :@"PhoneLogIn#true"]) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:_BtnUser.text forKey:@"userName"];
        [defaults setObject:_BtnPwd.text forKey:@"passWord"];
        //保存
        [defaults synchronize];
        
        [[AppDelegate instance]connectToHost];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(openfileOnline) name:@"openfileOnline" object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(openfileField) name:@"openfileFiled" object:nil];

    }else{
        dispatch_async(dispatch_get_main_queue(), ^{
            [DKProgressHUD dismiss];
            [DKProgressHUD showErrorWithStatus:_pwdError toView:self.view];
        });
    }
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"postToData" object:nil ];
}

-(void)LoginDataError{
    dispatch_async(dispatch_get_main_queue(), ^{
        [DKProgressHUD dismiss];
        [DKProgressHUD showErrorWithStatus:_dataError toView:self.view];
    });
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"postToDataError" object:nil ];
}

//openfile登陆成功
-(void)openfileOnline{
    dispatch_async(dispatch_get_main_queue(), ^{
//        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//        [defaults setObject:_BtnUser.text forKey:@"userName"];
//        [defaults setObject:_BtnPwd.text forKey:@"passWord"];
//        //保存
//        [defaults synchronize];
        [self performSegueWithIdentifier:@"tarbarController" sender:self];
    });
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"openfileOnline" object:nil ];
    dispatch_async(dispatch_get_main_queue(), ^{
        [DKProgressHUD dismiss];
    });
}

//openfile登录失败
-(void)openfileField{
    dispatch_async(dispatch_get_main_queue(), ^{
        [DKProgressHUD showErrorWithStatus:_pwdError toView:self.view];
    });
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"openfileField" object:nil ];
}

/**
 移除观察者
 */
-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
