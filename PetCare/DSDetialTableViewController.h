//
//  DSDetialTableViewController.h
//  pet
//
//  Created by 蒋 磊 on 2016/11/11.
//  Copyright © 2016年 江苏科茂. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DSDetialTableViewController;

@protocol PassingValueDelegatte <NSObject>

@optional

-(void)viewController:(DSDetialTableViewController *)viewcontroller didPassingValueWithInfo:(id)info;

@end
@interface DSDetialTableViewController : UITableViewController<NSCoding>{
     NSString *name;
}

@property (nonatomic, assign) id<PassingValueDelegatte>delegate;

@property (nonatomic, copy) NSString *strDay;
@property (nonatomic, copy) NSString *strNum;
@property (nonatomic, copy) NSString *strTime;
@property (nonatomic, copy) NSString *id;
@property (nonatomic, copy) NSString *whichMac;

@end
