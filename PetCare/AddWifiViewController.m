//
//  AddWifiViewController.m
//  PetCare
//
//  Created by mao ke on 2017/3/13.
//  Copyright © 2017年 江苏科茂. All rights reserved.
//

#import "AddWifiViewController.h"
#import "AddFinshViewController.h"
#import <SystemConfiguration/CaptiveNetwork.h>

@interface AddWifiViewController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *wifiName;
@property (weak, nonatomic) IBOutlet UITextField *wifiPwd;

@end

@implementation AddWifiViewController
- (IBAction)buttonNetx:(id)sender {
    [self savePswd];
    
    [self performSegueWithIdentifier:@"addToFinish" sender:self];
//    AddFinshViewController *addFinshVC = [self.storyboard instantiateViewControllerWithIdentifier:@"addFinshVC"];
//    addFinshVC.ssidStr = self.wifiName.text;
//    addFinshVC.pswdStr = self.wifiPwd.text;
//    [self.navigationController pushViewController:addFinshVC animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    [self showWifiSsid];
    self.wifiPwd.text = [self getspwdByssid:self.wifiName.text];
    _wifiName.delegate=self;
    _wifiPwd.delegate=self;

    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showWifiSsid
{
    BOOL wifiOK= FALSE;
    NSDictionary *ifs;
    NSString *ssid;
    if (!wifiOK)
    {
        ifs = [self fetchSSIDInfo];
        ssid = [ifs objectForKey:@"SSID"];
        if (ssid!= nil)
        {
            wifiOK= TRUE;
            self.wifiName.text = ssid;
        }
        else
        {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:@"请连接Wi-Fi" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"关闭" style:UIAlertActionStyleCancel handler:nil];
            [alert addAction:cancel];
            [self presentViewController:alert animated:YES completion:nil];
        }
    }
}

- (id)fetchSSIDInfo {
    NSArray *ifs = (__bridge_transfer id)CNCopySupportedInterfaces();
    NSLog(@"Supported interfaces: %@", ifs);
    id info = nil;
    for (NSString *ifnam in ifs) {
        info = (__bridge_transfer id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam);
        NSLog(@"%@ => %@", ifnam, info);
        if (info && [info count]) { break; }
    }
    return info;
}

-(NSString *)getspwdByssid:(NSString * )mssid{
    NSUserDefaults * def = [NSUserDefaults standardUserDefaults];
    return [def objectForKey:mssid];
}

-(void)savePswd{
    NSUserDefaults * def = [NSUserDefaults standardUserDefaults];
    [def setObject:self.wifiPwd.text forKey:self.wifiName.text];
    [def setObject:self.wifiName.text forKey:@"ssidStr"];
    [def setObject:self.wifiPwd.text forKey:@"pswdStr"];
    [def synchronize];
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
