//
//  AppDelegate.h
//  PetCare
//
//  Created by 蒋 磊 on 2017/2/16.
//  Copyright © 2017年 江苏科茂. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XMPPFramework/XMPPFramework.h>
#import "AFNetworking.h"
#import <SMS_SDK/SMSSDK.h>

@interface AppDelegate : UIResponder <XMPPRosterDelegate,UIApplicationDelegate,XMPPRegistrationDelegate,XMPPStreamDelegate>

@property (strong, nonatomic) UIWindow *window;
@property NSMutableArray *onLineMac;
@property NSString *reciveMessage;
@property NSString *password;
@property NSString *registerBool;
@property NSString *postDataError;
@property NSString *addid;
@property NSString *currentLanguage;

@property (strong, nonatomic) XMPPStream *xmppStream;
@property (strong, nonatomic) XMPPReconnect *xmppReconnect;
@property (strong, nonatomic) XMPPRoster *xmppRoster;
@property (strong, nonatomic) XMPPRegistration *xmppRegistration;
@property (strong, nonatomic) XMPPIDTracker *xmppIDTracker;
@property (nonatomic , strong) XMPPRosterCoreDataStorage *xmppRosterDataStorage;
+ (AppDelegate *)instance;
-(void)connectToHost;
-(void)disconnect;
-(void)sendMessage:(NSString*) mes Mac:(NSString *)whichMac;
-(void)postToData:(NSString *)post postMac:(NSString *)mac;
-(void)addFriend:(NSString *)friendMac;
-(void)registerWithName:(NSString *)userName andPassword:(NSString *)password;
- (void)changePassworduseWord:(NSString *)checkPassword userName:(NSString *)userName;
@end

