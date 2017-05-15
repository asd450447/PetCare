//
//  ViewController.m
//  PetCare
//
//  Created by 蒋 磊 on 2017/2/16.
//  Copyright © 2017年 江苏科茂. All rights reserved.
//

#import "ViewController.h"
#import "AFNetworking.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self connect];
}

- (void)connect{
    NSString *strURL =@"http://115.28.179.114:8885/wacw/WebServlet";
    NSURL *url = [NSURL URLWithString:strURL];
    
    //设置参数
    NSString *post = [NSString stringWithFormat:@"paraName={\"name\":method,\"value\":PhoneGetDevInfo},{\"name\":user,\"value\":18852866235"];
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
            str = [str substringFromIndex:16];
            NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
            dict = dict[@"dev"];
            NSLog(@"%@", dict);
            NSArray *name =[dict valueForKeyPath:@"Name"];
            NSLog(@"%lu",(unsigned long)[name count]);
            
        } else {
            NSLog(@"error : %@", error.localizedDescription);
        }
    }];
    
    [task resume];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
