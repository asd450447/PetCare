//
//  AppDelegate.m
//  PetCare
//
//  Created by 蒋 磊 on 2017/2/16.
//  Copyright © 2017年 江苏科茂. All rights reserved.
//

#import "AppDelegate.h"
#import "XMPPRegistration.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

+ (AppDelegate *)instance {
    
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [self setupStream];
    [SMSSDK registerApp:@"1c8c9316e37d2" withSecret:@"7e66dc9830036e29a98c00b53fd10c63"];
    _password = @"null";
    
    NSArray *languages = [NSLocale preferredLanguages];
    _currentLanguage = [languages objectAtIndex:0];
    _currentLanguage = [_currentLanguage substringToIndex:2];
    NSLog ( @"%@" , _currentLanguage);
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

/**
 初始化
 */
- (void)setupStream{
    NSLog(@"开始初始化");
    _onLineMac = [[NSMutableArray alloc]init];
    _xmppStream = [[XMPPStream alloc] init];
    [_xmppStream addDelegate:self delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
    _xmppReconnect = [[XMPPReconnect alloc]init];
    [_xmppReconnect activate:_xmppStream];
    [_xmppReconnect addDelegate:self delegateQueue:dispatch_get_main_queue()];
    _xmppRosterDataStorage = [[XMPPRosterCoreDataStorage alloc] init];
    _xmppRoster = [[XMPPRoster alloc] initWithRosterStorage:_xmppRosterDataStorage];
}

/**
 连接服务器
 */
- (void)connectToHost{
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    NSDate *datenow =[NSDate date];
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSInteger interval = [zone secondsFromGMTForDate:datenow];
    NSDate *localeDate = [datenow  dateByAddingTimeInterval: interval];
    NSString *timeSp = [NSString stringWithFormat:@"%ld", (long)[localeDate timeIntervalSince1970]];
    
    if ([_xmppStream isConnected]) {
        [_xmppStream disconnect];
    }
    XMPPJID *myJid = [XMPPJID jidWithUser:[defaults objectForKey:@"userName"] domain:@"ipet.local" resource:timeSp ];
    _xmppStream.myJID = myJid;
    _xmppStream.hostName = @"115.28.179.114";
    NSError *error = nil;
    [_xmppStream connectWithTimeout:XMPPStreamTimeoutNone error:&error];
    if(!error){
        printf("连接成功\n");
    }else{
        printf("连接失败\n");
    }
    
}


/**
 验证密码
 */
- (void)xmppStreamDidConnect:(XMPPStream *)sender{
    if ([self.password isEqualToString:@"null"]) {
        NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
        [_xmppStream authenticateWithPassword:[defaults objectForKey:@"passWord"] error:nil];
        
    }else{
        [sender registerWithPassword:self.password error:nil];
    }
}

//验证登录
- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender{
    NSLog(@"xmppstreamdidauthenticate\n");
    [self sendOnline];
}

//验证失败的方法
-(void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(DDXMLElement *)error
{
    NSLog(@"验证失败的方法,请检查你的用户名或密码是否正确,%@",error);
    [[NSNotificationCenter defaultCenter]postNotificationName:@"openfileFiled" object:self ];
}

/**
 发送上线消息
 */
-(void)sendOnline{
    XMPPPresence *presence = [XMPPPresence presence];
    NSLog(@"登录成功\n");
    [_xmppRoster activate:_xmppStream];
    [_xmppRoster addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [_xmppStream sendElement:presence];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"openfileOnline" object:self ];
}

/**
 断开连接
 */
-(void)disconnect{
    if([_xmppStream isConnected]){
        [_xmppStream disconnect];
        NSLog(@"断开连接");
    }
    _xmppStream=nil;
}


/**
 接收消息
 
 @param mes 指令
 */
-(void)sendMessage:(NSString*) mes Mac:(NSString *)whichMac{
    XMPPJID *tojid = [XMPPJID jidWithUser:whichMac domain:@"ipet.local" resource:nil];
    XMPPMessage *message = [XMPPMessage messageWithType:@"chat" to:tojid];
    [message addBody:mes];
    [_xmppStream sendElement:message];
}

//接收返回消息
-(void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message{
    NSLog(@"ReceiveMessage:%@",[message body]);
    _reciveMessage = [message body];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"receiveMessage" object:self];
}

/**
 获取在线设备mac
 presenceType 取得设备状态
 useId 当前用户
 presenceFromUser 在线用户
 */
-(void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence{
    //    NSString *presenceType = [presence type];
    NSString *useId = [[sender myJID]user];
    NSString *presenceFromUser = [[presence from]user];
    //    NSLog(@"%@", presenceType);
    NSLog(@"%@", useId);
    NSLog(@"在线用户：%@", presenceFromUser);
    [_onLineMac addObject:presenceFromUser];
    if (presenceFromUser != useId) {
        [[NSNotificationCenter defaultCenter]postNotificationName:@"onLineMac" object:self];
    }
}

//注册
-(void)registerWithName:(NSString *)userName andPassword:(NSString *)password{
    self.password = password;
    // 创建一个jid
    XMPPJID *jid = [XMPPJID jidWithUser:userName domain:@"ipet.local" resource:nil];
    //2.将jid绑定到xmppStream
    _xmppStream.myJID = jid;
    _xmppStream.hostName = @"115.28.179.114";
    //3.连接到服务器
    NSError *error = nil;
    [_xmppStream connectWithTimeout:XMPPStreamTimeoutNone error:&error];
    
}

#pragma mark 注册成功的方法
-(void)xmppStreamDidRegister:(XMPPStream *)sender{
    NSLog(@"注册成功的方法");
}

#pragma mark 注册失败的方法
-(void)xmppStream:(XMPPStream *)sender didNotRegister:(DDXMLElement *)error
{
    NSLog(@"注册失败执行的方法");
    self.registerBool = @"false";
}

//修改密码
- (void)changePassworduseWord:(NSString *)checkPassword userName:(NSString *)userName
{
    NSLog(@"修改open file密码");
    NSString *toStr = _xmppStream.myJID.domain;
    NSXMLElement *query = [NSXMLElement elementWithName:@"query" xmlns:@"jabber:iq:register"];
    
    NSXMLElement *username = [NSXMLElement elementWithName:@"username"
                                               stringValue:_xmppStream.myJID.user];
    NSXMLElement *password = [NSXMLElement elementWithName:@"password"
                                               stringValue:checkPassword];
    [query addChild:username];
    [query addChild:password];
    
    XMPPIQ *iq = [XMPPIQ iqWithType:@"set"
                                 to:[XMPPJID jidWithString:toStr]
                          elementID:[_xmppStream generateUUID]
                              child:query];
    
    [_xmppIDTracker addID:@"change1"
                  target:self
                selector:nil
                 timeout:60];
    _addid = @"change1";
    [_xmppStream sendElement:iq];
}


//修改密码返回信息
- (BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq{
    NSLog(@"__%@",iq.description);
    
    /*
     
     <iq xmlns="jabber:client" type="result" id="change1" from="ubuntu-dev" to="13333333333@ubuntu-dev/870efdcd"></iq>
     
     */
    NSString *iqTypePWD = [[iq attributeForName:@"type"]stringValue];
    NSString *iqIDPWD = [[iq attributeForName:@"id"]stringValue];    
    NSLog(@"iqTypePWD:%@___iqIDPWD:%@",iqTypePWD,iqIDPWD);
    if ([iqTypePWD isEqualToString:@"result"]&&[_addid isEqualToString:@"change1"]) {   //进行判断只有type="result" id="change1"时,密码修改成功
        [[NSNotificationCenter defaultCenter]postNotificationName:@"changePwd" object:self ];
        NSLog(@"OpenFire密码修改成功!!!");
        _addid = @"";
    }
    return YES;
}


/**
 添加好友

 @param friendMac 板子mac
 */
-(void)addFriend:(NSString *)friendMac{
    XMPPJID *Jid = [XMPPJID jidWithUser:friendMac domain:@"ipet.local" resource:nil ];
    
    [_xmppRoster addUser:Jid withNickname:friendMac];
    [_xmppRoster subscribePresenceToUser:Jid];
}

/**
 请求数据库信息
 */
-(void)postToData:(NSString *)post postMac:(NSString *)mac{
    NSString *strURL =@"http://115.28.179.114:8885/wacw/WebServlet";
    NSURL *url = [NSURL URLWithString:strURL];
    
    //设置参数
    //    NSString *post = [NSString stringWithFormat:@"%@"@"%@",@"paraName={\"name\":method,\"value\":PhoneGetDevInfo},{\"name\":user,\"value\":",user];
    NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:postData];
    
    NSURLSessionConfiguration *defaultConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:defaultConfig];
    
    NSURLSessionDataTask *task = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        NSLog(@"请求完成...");
        NSLog(@"appdeleget:%@", responseObject[@"flag"]);
        if (!error) {
            [[NSNotificationCenter defaultCenter]postNotificationName:@"postToData" object:self userInfo:responseObject[@"flag"] ];
        } else {
            NSLog(@"error : %@", error.localizedDescription);
            _postDataError = error.localizedDescription;
            [[NSNotificationCenter defaultCenter]postNotificationName:@"postToDataError" object:self ];
        }
    }];
    
    [task resume];
}


@end
