//
//  ForgetPwdViewController.m
//  PetCare
//
//  Created by mao ke on 2017/3/23.
//  Copyright © 2017年 江苏科茂. All rights reserved.
//

#import "ForgetPwdViewController.h"
#import <SMS_SDK/SMSSDK.h>
#import "AppDelegate.h"
#import "KeyboardToolBar.h"
#import "DKProgressHUD.h"

int i = 60;
@interface ForgetPwdViewController ()
@property (weak, nonatomic) IBOutlet UITextField *telName;
@property (weak, nonatomic) IBOutlet UITextField *checkout;
@property (weak, nonatomic) IBOutlet UITextField *rePwd;
@property (weak, nonatomic) IBOutlet UIButton *checkNumber;

@end

@implementation ForgetPwdViewController
@synthesize timerView = _timerView;

- (IBAction)back:(id)sender {
    [self performSegueWithIdentifier:@"backtologin" sender:self];
}

- (IBAction)checkOutPwd:(id)sender {
    if ([_telName.text isEqualToString:@""]) {
        [self judgeNull:@"账号不能为空"];
        if (![self checkPhoneNumInput:self.telName.text]) {
            [self judgeNull:@"账号应为手机号"];
        }
    }else{
        //获取验证码
        [SMSSDK getVerificationCodeByMethod:SMSGetCodeMethodSMS phoneNumber:self.telName.text
                                       zone:@"86"
                           customIdentifier:nil
                                     result:^(NSError *error){
                                         if (!error) {
                                             NSLog(@"获取验证码成功");
                                         } else {
                                             NSLog(@"错误信息：%@",error);
                                             [self judgeNull:@"获取验证码失败"];
                                         }}];
        //获取密码
        NSString *post = [NSString stringWithFormat:@"%@%@%@",@"paraName={\"name\":method,\"value\":PhoneGetPswOfUser},{\"name\":user,\"value\":",self.telName.text,@"}"];
        [[AppDelegate instance]postToData:post postMac:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(getPwd:) name:@"postToData" object:nil];
        //定时器
        _timerView = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(changeTimeAtTimedisplay) userInfo:nil repeats:YES];

    }

}

- (IBAction)reName:(id)sender {
    [DKProgressHUD showLoading];
    [SMSSDK commitVerificationCode:self.checkout.text phoneNumber:self.telName.text zone:@"86" result:^(SMSSDKUserInfo *userInfo, NSError *error) {
        
        {
            if (!error)
            {
                NSString *post = [NSString stringWithFormat:@"%@%@%@%@%@",@"paraName={\"name\":method,\"value\":PhoneResetPsw},{\"name\":user,\"value\":",self.telName.text,@"},{\"name\":newpsw,\"value\":",self.rePwd.text,@"}"];
                //数据库修改密码
                [[AppDelegate instance]postToData:post postMac:nil ];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(repwd:) name:@"postToData" object:nil];
                });
    
                
            }
            else
            {
                [self judgeNull:@"验证失败"];
                NSLog(@"错误信息:%@",error);
            }
        }
    }];

    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _telName.delegate = self;
    
    [KeyboardToolBar registerKeyboardToolBarWithTextField:self.rePwd];
    [KeyboardToolBar registerKeyboardToolBarWithTextField:self.telName];
    [KeyboardToolBar registerKeyboardToolBarWithTextField:self.checkout];
    
}

-(void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [DKProgressHUD dismiss];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//alert show
-(void)judgeNull:(NSString *)msg{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:msg preferredStyle: UIAlertControllerStyleAlert ];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"ok" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:ok];
    [self presentViewController:alert animated:YES completion:nil];
}

//open修改密码
-(void)repwd:(NSNotification *)noti{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"open修改密码:%@", noti.userInfo);
        if ([noti.userInfo isEqual:@"PhoneResetPsw#true"]) {
            [[AppDelegate instance]changePassworduseWord:_rePwd.text userName:nil];
            //openfile修改密码
            [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(changePwdOpen) name:@"changePwd" object:nil ];
        }else{
            [self judgeNull:@"重置失败"];
        }
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"postToData" object:nil ];
    });
}

//open file修改密码
-(void)changePwdOpen{
    dispatch_async(dispatch_get_main_queue(), ^{
        [DKProgressHUD dismiss];
        [self judgeNull:@"重置成功"];
    });
}

//数据库获取密码
-(void)getPwd:(NSNotification *)noti{
    NSLog(@"%@",noti.userInfo);
    NSLog(@"数据库获取密码");
    NSString *pwd = [NSString stringWithFormat:@"%@",noti.userInfo];
    pwd = [pwd substringFromIndex:18];
    NSLog(@"%@", pwd);
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    [def setObject:_telName.text forKey:@"userName"];
    [def setObject:pwd forKey:@"passWord"];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"postToData" object:nil ];
    [[AppDelegate instance]connectToHost];
}

//定时器
-(void)changeTimeAtTimedisplay{
    i--;
    NSString *info = [NSString stringWithFormat:@"%d",i];
    dispatch_async(dispatch_get_main_queue(), ^{
        [_checkNumber setTitle:info forState:UIControlStateNormal];
        _checkNumber.enabled = NO;
    });
    if (i<=0) {
        [_timerView invalidate];
        dispatch_async(dispatch_get_main_queue(), ^{
            [_checkNumber setTitle:@"获取校验码" forState:UIControlStateNormal];
            _checkNumber.enabled = YES;
            i = 60;
        });
    }

}

//只允许输入数字，且只有11位数
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (textField.text.length == 11) {
        if ([string isEqualToString:@""]) {
            return YES;
        }
        else {
            return NO;
        }
    }
    return [self validateNumber:string];
}

//只允许输入数字
- (BOOL)validateNumber:(NSString*)number {
    BOOL res = YES;
    NSCharacterSet* tmpSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
    int i = 0;
    while (i < number.length) {
        NSString * string = [number substringWithRange:NSMakeRange(i, 1)];
        NSRange range = [string rangeOfCharacterFromSet:tmpSet];
        if (range.length == 0) {
            res = NO;
            break;
        }
        i++;
    }
    return res;
}

//检查是否为手机号的方法
-(BOOL)checkPhoneNumInput:(NSString *)phoneStr
{
    NSString *photoRange = @"^1(3[0-9]|4[0-9]|5[0-9]|7[0-9]|8[0-9])\\d{8}$";//正则表达式
    NSPredicate *regexMobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",photoRange];
    BOOL result = [regexMobile evaluateWithObject:phoneStr];
    if (result) {
        return YES;
    } else {
        return NO;
    }
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
