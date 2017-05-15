//
//  SignInViewController.m
//  PetCare
//
//  Created by mao ke on 2017/3/23.
//  Copyright © 2017年 江苏科茂. All rights reserved.
//

#import "SignInViewController.h"
#import "AppDelegate.h"
#import "LoginViewController.h"
#import "DKProgressHUD.h"
#import "KeyboardToolBar.h"

@interface SignInViewController ()
@property (weak, nonatomic) IBOutlet UITextField *telName;
@property (weak, nonatomic) IBOutlet UITextField *pwdOnce;
@property (weak, nonatomic) IBOutlet UITextField *pwdAgain;
@property NSString * type;
@end

@implementation SignInViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _telName.delegate =self;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [KeyboardToolBar registerKeyboardToolBarWithTextField:self.telName];
    [KeyboardToolBar registerKeyboardToolBarWithTextField:self.pwdOnce];
    [KeyboardToolBar registerKeyboardToolBarWithTextField:self.pwdAgain];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)back:(id)sender {
    [self performSegueWithIdentifier:@"login" sender:self];
}

- (IBAction)signIn:(id)sender {
    if (![_telName.text isEqualToString:@""]&&![_pwdOnce.text isEqualToString:@""]&&![_pwdAgain.text isEqualToString:@""]) {
        if (![self checkPhoneNumInput:_telName.text]) {
            [self showAlert:@"账号应为手机号"];
        }else{
            if (![_pwdOnce.text isEqualToString: _pwdAgain.text]) {
                [self showAlert:@"两次密码不一致"];
            }else{
                [DKProgressHUD showLoading];
                NSString *post = [NSString stringWithFormat:@"%@%@%@",@"paraName={\"name\":method,\"value\":PhoneTestPhone},{\"name\":phone,\"value\":",self.telName.text,@"}"];
                [[AppDelegate instance]postToData:post postMac:nil];
                
                [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(judgePhone:) name:@"postToData" object:nil];
            }
        }
    }else{
        [self showAlert:@"账号密码不能为空！"];
    }
    
}

-(void)judgePhone:(NSNotification *)noti{
    NSLog(@"true or flase:%@", noti.userInfo);
     _type = [[NSString stringWithFormat:@"%@", noti.userInfo ]substringToIndex:9];
    NSLog(@"type:%@",_type);
    if ([_type isEqualToString:@"PhoneTest"]) {
        if ([noti.userInfo isEqual:@"PhoneTestPhone#true"]) {
            [self showAlert:@"号码已被注册!"];
            NSLog(@"号码已被注册!");
            [[NSNotificationCenter defaultCenter]removeObserver:self name:@"postToData" object:nil];
            dispatch_async(dispatch_get_main_queue(), ^{
                [DKProgressHUD dismiss ];
            });
        }else{
            NSString *post = [NSString stringWithFormat:@"%@%@%@%@%@",@"paraName={\"name\":method,\"value\":PhoneSign},{\"name\":user,\"value\":",self.telName.text,@"},{\"name\":psw,\"value\":",self.pwdAgain.text,@"}"];
//            [[NSNotificationCenter defaultCenter]removeObserver:self name:@"postToData" object:nil];
            [[AppDelegate instance]postToData:post postMac:nil];
            [[AppDelegate instance]registerWithName:self.telName.text andPassword:self.pwdAgain.text ];
        }
    }
    if ([_type isEqualToString:@"PhoneSign"]) {
        if ([noti.userInfo isEqual:@"PhoneSign#true"]||![[[AppDelegate instance]registerBool]isEqualToString:@"false"]) {
//            [self showAlert:@"注册成功"];
            dispatch_async(dispatch_get_main_queue(), ^{
                [DKProgressHUD dismiss ];
                [DKProgressHUD showSuccessWithStatus:@"注册成功"];
            });
            [self performSegueWithIdentifier:@"login" sender:self];
        }else{
            [self showAlert:@"注册失败，请重新注册!"];
            NSLog(@"注册失败，请重新注册!");
            dispatch_async(dispatch_get_main_queue(), ^{
                [DKProgressHUD dismiss ];
            });
            [[NSNotificationCenter defaultCenter]removeObserver:self name:@"postToData" object:nil];
        }
    }
}

-(void)showAlert:(NSString *)msg{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:msg preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:ok];
    [self presentViewController:alert animated:YES completion:nil];
    
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
