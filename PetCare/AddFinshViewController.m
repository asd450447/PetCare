//
//  AddFinshViewController.m
//  PetCare
//
//  Created by mao ke on 2017/3/13.
//  Copyright © 2017年 江苏科茂. All rights reserved.
//

#import "AddFinshViewController.h"
#import "HFSmartLink.h"
#import "HFSmartLinkDeviceInfo.h"
#import "DKProgressHUD.h"
#import "AFNetworking.h"
#import <XMPPFramework/XMPPFramework.h>
#import "XMPPRoster.h"
#import "XMPPRosterCoreDataStorage.h"
#import "XMPPMessageArchiving.h"
#import "XMPPMessageArchivingCoreDataStorage.h"
#import "AppDelegate.h"
#import "TabBarViewController.h"

@interface AddFinshViewController ()<XMPPStreamDelegate,XMPPRosterDelegate>{
    HFSmartLink * smtlk;
    BOOL isconnecting;
}

@property (weak, nonatomic) IBOutlet UIButton *btnSearch;
@property (weak, nonatomic) IBOutlet UILabel *needChangeLable;
@property (weak, nonatomic) IBOutlet UILabel *needHideLable;
@property NSString *searching;
@property NSString *reSetWifi;
@property NSString *cancel;
@property NSString *added;
@property NSString *setted;
@property NSString *finish;
@end

@implementation AddFinshViewController
- (IBAction)searchClick:(id)sender {
    
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([[[AppDelegate instance]currentLanguage]isEqualToString:@"en"]) {
        _searching = @"Searching";
        _reSetWifi = @"Press the network,Re-allocation network";
        _cancel = @"Cancel";
        _added = @"The device has added";
        _setted = @"The configuration is complete";
        _finish = @"Finish";
    }else{
        _searching = @"搜索中";
        _reSetWifi = @"重按配网，重新配置";
        _cancel = @"取消";
        _added = @"设备已添加";
        _setted = @"配置完成";
        _finish = @"完成";
    }
    
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    _ssidStr = [def objectForKey:@"ssidStr"];
    _pswdStr = [def objectForKey:@"pswdStr"];
    smtlk = [HFSmartLink shareInstence];
    smtlk.isConfigOneDevice = true;
    smtlk.waitTimers = 30;
    isconnecting=false;
    
    [self configWifi];
    // Do any additional setup after loading the view.
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//配置wifi
-(void)configWifi{
    
    if(!isconnecting){
        isconnecting = true;
        [smtlk startWithSSID:_ssidStr Key:_pswdStr withV3x:true
                processblock: ^(NSInteger pro) {
                   
                } successBlock:^(HFSmartLinkDeviceInfo *dev) {
                  
//                    [self  showAlertWithMsg:[NSString stringWithFormat:@"%@:%@",dev.mac,dev.ip] title:@"OK"];
                    NSLog(@"%@", dev.mac);
                    _whichMac = [dev.mac lowercaseString];
                    NSString *post = [NSString stringWithFormat:@"%@%@%@",@"paraName={\"name\":method,\"value\":PhoneIsDevExsitByMacWhenBind},{\"name\":mac,\"value\":",[dev.mac lowercaseString],@"}"];
                    [self postToData:dev.mac typeData:@"search" senfPost:post];
                } failBlock:^(NSString *failmsg) {
                    [self  showAlertWithMsg:failmsg title:@"error"];
                } endBlock:^(NSDictionary *deviceDic) {
                    isconnecting  = false;
//                    [self.btnSearch setTitle:@"搜索中3" forState:UIControlStateNormal];
//                    _btnSearch.enabled = false;
                }];
        [self.btnSearch setTitle:_searching forState:UIControlStateNormal];
    }else{
        [smtlk stopWithBlock:^(NSString *stopMsg, BOOL isOk) {
            if(isOk){
                isconnecting  = false;
                [self.btnSearch setTitle:_searching forState:UIControlStateNormal];
                [self showAlertWithMsg:stopMsg title:@"OK"];
            }else{
                [self showAlertWithMsg:stopMsg title:@"error"];
            }
        }];
    }
}


-(void)showAlertWithMsg:(NSString *)msg
                  title:(NSString*)title{
//    _message = [msg substringToIndex:12];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:_reSetWifi style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self configWifi];
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:_cancel style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:ok];
    [alert addAction:cancel];
    [self presentViewController:alert animated:YES completion:nil];
}

/**
 请求数据库信息
 */
-(void)postToData:(NSString *)msg typeData:(NSString *)type senfPost:(NSString *)post{
    NSString *strURL =@"http://115.28.179.114:8885/wacw/WebServlet";
    NSURL *url = [NSURL URLWithString:strURL];
    msg = [msg lowercaseString];
    NSLog(@"msg:%@", msg);
    //设置参数
    
    NSLog(@"post:%@", post);
    NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:postData];
    
    NSURLSessionConfiguration *defaultConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:defaultConfig];
    
    NSURLSessionDataTask *task = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        NSLog(@"请求完成...");
        if (!error) {
            NSString *str = responseObject[@"flag"];
            str = [str stringByReplacingOccurrencesOfString:@"'" withString:@"\""];
            NSLog(@"%@", str);
            if ([type isEqualToString:@"search"]) {
                str = [str substringFromIndex:29];
                if ([str isEqualToString:@"true"]) {
                    [self showAlertWithMsg:_added title:@"ERROR"];
                }else{
                    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
                    NSString *sendPost = [NSString stringWithFormat:@"%@%@%@%@%@",@"paraName={\"name\":method,\"value\":PhoneCreateMacWhenBind},{\"name\":mac,\"value\":",msg,@"},{\"name\":user,\"value\":",[def objectForKey:@"userName"],@"}"];
                    NSLog(@"sendpost:%@", sendPost);
                    [self postToData:msg typeData:@"Add" senfPost:sendPost];
                    
                }
            }else{
                str = [str substringFromIndex:23];
                if ([str isEqualToString:@"true"]) {
                    [[AppDelegate instance]addFriend:msg];
//                  XMPPJID *jid = [XMPPJID jidWithString:msg];
//                  [xmppRoster subscribePresenceToUser:jid];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        _needHideLable.hidden = true;
                        _needChangeLable .text = _setted;
                        [_btnSearch setTitle:_finish forState:UIControlStateNormal];
                        _btnSearch.enabled = YES;
                        _btnSearch.backgroundColor = [UIColor redColor];
                    });
                }else{
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:_reSetWifi preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *ok = [UIAlertAction actionWithTitle:_reSetWifi style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        [self configWifi];
                    }];
                    UIAlertAction *cancel = [UIAlertAction actionWithTitle:_cancel style:UIAlertActionStyleCancel handler:nil];
                    [alert addAction:ok];
                    [alert addAction:cancel];
                    [self presentViewController:alert animated:YES completion:nil];
                }
            }
        }
        }];
    
    [task resume];
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
