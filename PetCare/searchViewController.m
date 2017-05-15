//
//  searchViewController.m
//  PetCare
//
//  Created by mao ke on 2017/3/7.
//  Copyright © 2017年 江苏科茂. All rights reserved.
//

#import "searchViewController.h"
#import "ActionSheetPicker.h"
#import "ActionSheetDatePicker.h"
#import "AFNetworking.h"
#import "DKProgressHUD.h"
#import "ZFChart.h"
#import "AppDelegate.h"

@interface searchViewController ()<ZFGenericChartDataSource, ZFBarChartDelegate>
@property (nonatomic, strong) ZFBarChart * barChart;
@property (nonatomic, assign) CGFloat height;
@property (weak, nonatomic) IBOutlet UIButton *searchDate;
@property (nonatomic, strong) AbstractActionSheetPicker *actionSheetPicker;
@property (nonatomic, strong) NSDate *selectedDate;
@property NSString *judge;
@property NSString *numberFood;
@property NSString *numberWater;
@property NSString *postWater;
@property NSString *watering;
@property NSString *fooding;
@property NSString *feedTitle;
@end

@implementation searchViewController

@synthesize selectedDate = _selectedDate;
@synthesize actionSheetPicker = _actionSheetPicker;

- (IBAction)searchDateClick:(id)sender {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *minimumDateComponents = [calendar components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:[NSDate date]];
    [minimumDateComponents setYear:2000];
    NSDate *minDate = [calendar dateFromComponents:minimumDateComponents];
    NSDate *maxDate = [NSDate date];
    
    
    _actionSheetPicker = [[ActionSheetDatePicker alloc] initWithTitle:@"" datePickerMode:UIDatePickerModeDate selectedDate:self.selectedDate
                                                          minimumDate:minDate
                                                          maximumDate:maxDate
                                                               target:self action:@selector(dateWasSelected:element:) origin:sender];
    
    [self.actionSheetPicker addCustomButtonWithTitle:@"Today" value:[NSDate date]];
    self.actionSheetPicker.hideCancel = YES;
    [self.actionSheetPicker showActionSheetPicker];
}
- (IBAction)searchDataClick:(id)sender {
    [DKProgressHUD showLoading];
    NSDateFormatter *dateformatter=[[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:@"yyyy-MM-dd 00:00"];
    NSString *date = [dateformatter stringFromDate:_selectedDate];
    NSDate *tstart = [dateformatter dateFromString:date];
//    NSTimeZone *zone =  [NSTimeZone systemTimeZone]; //获得系统时区
//    NSInteger timeOff = [zone secondsFromGMT]; //zone时区和格林尼治时间差
//    NSDate *timeOffDate = [tstart dateByAddingTimeInterval:timeOff];
    NSLog(@"%@", tstart);
    //起始时间戳
    NSTimeInterval interval = [tstart timeIntervalSince1970] * 1000;
    NSString *timeStart =[NSString stringWithFormat:@"%lf\n",interval];
    timeStart = [timeStart substringToIndex:10];
    NSLog(@"timeStart%@", timeStart);
    
    NSInteger endTime = [timeStart integerValue];
    endTime = endTime+86400;
    NSString *timeEnd = [NSString stringWithFormat:@"%ld", (long)endTime];
    NSTimeInterval interval1 = [[NSDate date] timeIntervalSince1970] * 1000;
    NSString *ch ;
    ch = [NSString stringWithFormat:@"%lf\n",interval1];
    ch = [ch substringToIndex:10];
    
    
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSString *postfood = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@",@"paraName={\"name\":method,\"value\":PhoneQuery},{\"name\":user,\"value\":",[userDefaults objectForKey:@"userName"],@"},{\"name\":mac,\"value\":",_whichMac,@"},{\"name\":type,\"value\":1},{\"name\":tstart,\"value\":",timeStart,@"},{\"name\":type,\"value\":",timeEnd];
    _postWater = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@",@"paraName={\"name\":method,\"value\":PhoneQuery},{\"name\":user,\"value\":",[userDefaults objectForKey:@"userName"],@"},{\"name\":mac,\"value\":",_whichMac,@"},{\"name\":type,\"value\":0},{\"name\":tstart,\"value\":",timeStart,@"},{\"name\":type,\"value\":",timeEnd];
    NSLog(@"%@", postfood);
    _judge = @"food";
    [self postToData:postfood];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(showData:) name:@"refreshData" object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if ([[[AppDelegate instance]currentLanguage]isEqualToString:@"en"]) {
        _watering = @"Watering";
        _fooding = @"Fooding";
        _feedTitle = @"Data of feeding";
    }else{
        _watering = @"喂水";
        _fooding = @"喂食";
        _feedTitle = @"喂食喂水数据";
    }
    self.selectedDate = [NSDate date];
    NSDateFormatter *dateformatter=[[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:@"yyyy-MM-dd"];
    NSString *date = [dateformatter stringFromDate:_selectedDate];
    [_searchDate setTitle:date forState:UIControlStateNormal];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/**
 请求数据库信息
 */
-(void)postToData:(NSString *)post{

     NSString *strURL =@"http://115.28.179.114:8885/wacw/WebServlet";
     NSURL *url = [NSURL URLWithString:strURL];
 
     //设置参数
//     NSString *post = [NSString stringWithFormat:@"%@%@%@%@%@%@",@"paraName={\"name\":method,\"value\":PhoneQuery},{\"name\":user,\"value\":",searchUser,@"},{\"name\":mac,\"value\":",_whichMac,@"},\"name\":type,\"value\":1},{\"name\":tstart,\"value\":",timeEnd];
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
             str = [str substringFromIndex:11];
             NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
             NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
             NSLog(@"str%@", str);
             dict = dict[@"ctl"];
             str = [NSString stringWithFormat:@"%@", dict];
             NSLog(@"str长度:%lu", (unsigned long)[str length]);
             if (![str  isEqual: @"null"]) {
                 str = [str stringByReplacingOccurrencesOfString:@"\n" withString:@""];
                 str = [str substringFromIndex:1];
                 str = [str substringWithRange:NSMakeRange(0, [str length] - 1)];
                 str = [str stringByReplacingOccurrencesOfString:@" " withString:@""];
                 str = [str stringByReplacingOccurrencesOfString:@"\"" withString:@""];
                 NSArray *arr = [str componentsSeparatedByString:@","];
                 NSLog(@"%lu", (unsigned long)arr.count);
                 if([_judge isEqualToString:@"food"]){
                     _numberFood = [NSString stringWithFormat:@"%lu",(unsigned long)arr.count ];
                     _judge = @"water";
                     [self postToData:_postWater];
                 }else{
                     _numberWater = [NSString stringWithFormat:@"%lu",(unsigned long)arr.count ];
                     [[NSNotificationCenter defaultCenter]postNotificationName:@"refreshData" object:self];
                 }
             }else{
                 if ([_judge isEqualToString: @"water"]) {
                     _numberWater = @"0";
                     [[NSNotificationCenter defaultCenter]postNotificationName:@"refreshData" object:self];
                 }else{
                     _numberFood = @"0";
                     _judge = @"water";
                     [self postToData:_postWater];
                 }
             }
         } else {
             NSLog(@"error : %@", error.localizedDescription);
         }
     }];
 
     [task resume];
 }
 
-(void)showData:(NSNotification *)noti{
    NSLog(@"喂食%@，喂水%@",_numberFood,_numberWater);
    dispatch_async(dispatch_get_main_queue(), ^{
        [DKProgressHUD dismiss];
        [self setUp];
        //图表设置
        self.barChart = [[ZFBarChart alloc] initWithFrame:CGRectMake(0, 170, SCREEN_WIDTH, _height)];
        self.barChart.dataSource = self;
        self.barChart.delegate = self;
        self.barChart.topicLabel.text = _feedTitle;
//        self.barChart.unit = @"次";
        self.barChart.isResetAxisLineMaxValue = YES;
        [self.view addSubview:self.barChart];
        [self.barChart strokePath];

    });
}

- (void)dateWasSelected:(NSDate *)selectedDate element:(id)element {
    self.selectedDate = selectedDate;
    NSDateFormatter *dateformate = [[NSDateFormatter alloc]init];
    [dateformate setDateFormat:@"yyyy-MM-dd"];
    //may have originated from textField or barButtonItem, use an IBOutlet instead of element
    [self.searchDate setTitle:[dateformate stringFromDate:_selectedDate] forState:UIControlStateNormal];
}

/**
 图表show
 */
- (void)setUp{
    
    if ([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationLandscapeLeft || [[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationLandscapeRight){
        //首次进入控制器为横屏时
        _height = SCREEN_HEIGHT - NAVIGATIONBAR_HEIGHT * 0.4;
    }else{
        //首次进入控制器为竖屏时
        _height = (SCREEN_HEIGHT - NAVIGATIONBAR_HEIGHT)*0.8;
    }
}

#pragma mark - ZFGenericChartDataSource

- (NSArray *)valueArrayInGenericChart:(ZFGenericChart *)chart{
    return @[_numberFood, _numberWater];
}

- (NSArray *)nameArrayInGenericChart:(ZFGenericChart *)chart{
    return @[_fooding, _watering];
}

- (NSArray *)colorArrayInGenericChart:(ZFGenericChart *)chart{
    return @[ZFBlue];
}

- (CGFloat)axisLineMaxValueInGenericChart:(ZFGenericChart *)chart{
    float numFood = [_numberFood floatValue];
    float numWater = [_numberWater floatValue];
    return numFood > numWater ? numFood+2 : numWater+2;
}

- (NSUInteger)axisLineSectionCountInGenericChart:(ZFGenericChart *)chart{
    float numFood = [_numberFood floatValue];
    float numWater = [_numberWater floatValue];
    float high = 2;
    if ((numFood > numWater ? numFood : numWater) >10) {
        high = 10;
    }else if((numFood > numWater ? numFood : numWater) >0){
        high =numFood > numWater ? numFood : numWater;
    }
    return high;
}

#pragma mark - ZFBarChartDelegate

- (CGFloat)barWidthInBarChart:(ZFBarChart *)barChart{
    return SCREEN_WIDTH/7;
}

- (CGFloat)paddingForGroupsInBarChart:(ZFBarChart *)barChart{
    return SCREEN_WIDTH/6;
}

- (id)valueTextColorArrayInBarChart:(ZFGenericChart *)barChart{
    return ZFBlue;
}

- (NSArray *)gradientColorArrayInBarChart:(ZFBarChart *)barChart{
    ZFGradientAttribute * gradientAttribute = [[ZFGradientAttribute alloc] init];
    gradientAttribute.colors = @[(id)ZFSkyBlue.CGColor, (id)ZFWhite.CGColor];
    gradientAttribute.locations = @[@(0.5), @(0.99)];
    
    return [NSArray arrayWithObjects:gradientAttribute, nil];
}

- (void)barChart:(ZFBarChart *)barChart didSelectBarAtGroupIndex:(NSInteger)groupIndex barIndex:(NSInteger)barIndex bar:(ZFBar *)bar popoverLabel:(ZFPopoverLabel *)popoverLabel{
    NSLog(@"第%ld组========第%ld个",(long)groupIndex,(long)barIndex);
    
    //可在此处进行bar被点击后的自身部分属性设置,可修改的属性查看ZFBar.h
    bar.barColor = ZFGold;
    bar.isAnimated = YES;
    //    bar.opacity = 0.5;
    [bar strokePath];
    
    //可将isShowAxisLineValue设置为NO，然后执行下句代码进行点击才显示数值
    //    popoverLabel.hidden = NO;
}

- (void)barChart:(ZFBarChart *)barChart didSelectPopoverLabelAtGroupIndex:(NSInteger)groupIndex labelIndex:(NSInteger)labelIndex popoverLabel:(ZFPopoverLabel *)popoverLabel{
    NSLog(@"第%ld组========第%ld个",(long)groupIndex,(long)labelIndex);
    
    //可在此处进行popoverLabel被点击后的自身部分属性设置
    //    popoverLabel.textColor = ZFSkyBlue;
    //    [popoverLabel strokePath];
}

#pragma mark - 横竖屏适配(若需要同时横屏,竖屏适配，则添加以下代码，反之不需添加)

/**
 *  PS：size为控制器self.view的size，若图表不是直接添加self.view上，则修改以下的frame值
 */
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id <UIViewControllerTransitionCoordinator>)coordinator{
    
    if ([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationLandscapeLeft || [[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationLandscapeRight){
        self.barChart.frame = CGRectMake(0, 0, size.width, size.height - NAVIGATIONBAR_HEIGHT * 0.5);
    }else{
        self.barChart.frame = CGRectMake(0, 0, size.width, size.height + NAVIGATIONBAR_HEIGHT * 0.5);
    }
    
    [self.barChart strokePath];
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
