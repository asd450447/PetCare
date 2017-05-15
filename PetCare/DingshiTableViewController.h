//
//  DingshiTableViewController.h
//  pet
//
//  Created by 蒋 磊 on 2016/11/11.
//  Copyright © 2016年 江苏科茂. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XMPPFramework/XMPPFramework.h>
#import "XMPPReconnect.h"
struct dingshidate{
    __unsafe_unretained NSString *day;
    __unsafe_unretained NSString *count;
    __unsafe_unretained NSString *time;
    __unsafe_unretained NSString *id;
};

@interface DingshiTableViewController : UITableViewController<UIGestureRecognizerDelegate,NSCoding,XMPPStreamDelegate>
@property (nonatomic, retain) NSString *strCount1;
@property (nonatomic, retain) NSString *strDay1;
@property (nonatomic, retain) NSString *strTime1;
@property (nonatomic, retain) NSString *strCount2;
@property (nonatomic, retain) NSString *strDay2;
@property (nonatomic, retain) NSString *strTime2;
@property (nonatomic, retain) NSString *strCount3;
@property (nonatomic, retain) NSString *strDay3;
@property (nonatomic, retain) NSString *strTime3;
@property (nonatomic, retain) NSString *strCount4;
@property (nonatomic, retain) NSString *strDay4;
@property (nonatomic, retain) NSString *strTime4;
@property (nonatomic, retain) NSString *strCount5;
@property (nonatomic, retain) NSString *strDay5;
@property (nonatomic, retain) NSString *strTime5;
@property (nonatomic, retain) NSString *strCount6;
@property (nonatomic, retain) NSString *strDay6;
@property (nonatomic, retain) NSString *strTime6;
@property (strong, nonatomic) NSString *tag;
@property NSString *whichDevice;
@property NSString *whichMac;
@end




