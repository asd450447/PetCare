//
//  DingshiTableViewController.m
//  pet
//
//  Created by 蒋 磊 on 2016/11/11.
//  Copyright © 2016年 江苏科茂. All rights reserved.
//

#import "DingshiTableViewController.h"
#import "DSDetialTableViewController.h"
#import "DKProgressHUD.h"
#import "AppDelegate.h"

@interface DingshiTableViewController ()

@property (weak, nonatomic) IBOutlet UILabel *food1time;
@property NSString * onLine;
@property NSString *iscoming;
@property NSString *judgeDK;
@property NSString *mac;
@property NSMutableArray *timeMuArray;
@property (weak, nonatomic) IBOutlet UIView *food1;
@property (weak, nonatomic) IBOutlet UIView *food2;
@property (weak, nonatomic) IBOutlet UIView *food3;
@property (weak, nonatomic) IBOutlet UIView *food4;
@property (weak, nonatomic) IBOutlet UIView *water1;
@property (weak, nonatomic) IBOutlet UIView *water2;
@property (weak, nonatomic) IBOutlet UILabel *time1;
@property (weak, nonatomic) IBOutlet UILabel *count1;
@property (weak, nonatomic) IBOutlet UILabel *day1;
@property (weak, nonatomic) IBOutlet UILabel *time2;
@property (weak, nonatomic) IBOutlet UILabel *count2;
@property (weak, nonatomic) IBOutlet UILabel *day2;
@property (weak, nonatomic) IBOutlet UILabel *time3;
@property (weak, nonatomic) IBOutlet UILabel *count3;
@property (weak, nonatomic) IBOutlet UILabel *day3;
@property (weak, nonatomic) IBOutlet UILabel *time4;
@property (weak, nonatomic) IBOutlet UILabel *count4;
@property (weak, nonatomic) IBOutlet UILabel *day4;
@property (weak, nonatomic) IBOutlet UILabel *time5;
@property (weak, nonatomic) IBOutlet UILabel *count5;
@property (weak, nonatomic) IBOutlet UILabel *day5;
@property (weak, nonatomic) IBOutlet UILabel *time6;
@property (weak, nonatomic) IBOutlet UILabel *count6;
@property (weak, nonatomic) IBOutlet UILabel *day6;
@property (weak, nonatomic) IBOutlet UISwitch *switch_food1;
@property (weak, nonatomic) IBOutlet UISwitch *switch_food2;
@property (weak, nonatomic) IBOutlet UISwitch *switch_food3;
@property (weak, nonatomic) IBOutlet UISwitch *switch_food4;
@property (weak, nonatomic) IBOutlet UISwitch *switch_water1;
@property (weak, nonatomic) IBOutlet UISwitch *switch_water2;
@property NSString *loading;
@property NSString *everyday;
@property NSString *today;
@property NSString *setting;
@property NSString *setted;
@property NSString *cancel;
@end

@implementation DingshiTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"mac:%@", _whichMac);
    if ([[[AppDelegate instance]currentLanguage]isEqualToString:@"en"]) {
        _loading = @"Loading...";
        _everyday = @"Every Day";
        _today = @"Today";
        _setting = @"Setting...";
        _setted = @"Success";
        _cancel = @"Success";
    }else{
        _loading = @"加载中...";
        _everyday = @"每天";
        _today = @"当天";
        _setting = @"正在设置";
        _setted = @"设置成功";
        _cancel = @"取消成功";
    }
    //设置UIView的点击事件
    UITapGestureRecognizer *portraitTap1 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(feedingViewClicked:)];
    [self.food1 addGestureRecognizer:portraitTap1];
    UITapGestureRecognizer *portraitTap2 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(feedingViewClicked:)];
    [self.food2 addGestureRecognizer:portraitTap2];
    UITapGestureRecognizer *portraitTap3 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(feedingViewClicked:)];
    [self.food3 addGestureRecognizer:portraitTap3];
    UITapGestureRecognizer *portraitTap4 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(feedingViewClicked:)];
    [self.food4 addGestureRecognizer:portraitTap4];
    UITapGestureRecognizer *portraitTap5 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(feedingViewClicked:)];
    [self.water1 addGestureRecognizer:portraitTap5];
    UITapGestureRecognizer *portraitTap6 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(feedingViewClicked:)];
    [self.water2 addGestureRecognizer:portraitTap6];
    //隐藏多余cell
    self.tableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
}


-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [DKProgressHUD showLoadingWithStatus:_loading];
    //1.获得NSUserDefaults文件
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:@"0" forKey:@"switch1"];
    [userDefaults setObject:@"0" forKey:@"switch2"];
    [userDefaults setObject:@"0" forKey:@"switch3"];
    [userDefaults setObject:@"0" forKey:@"switch4"];
    [userDefaults setObject:@"0" forKey:@"switch5"];
    [userDefaults setObject:@"0" forKey:@"switch6"];
    [userDefaults synchronize];
    
    [[AppDelegate instance]sendMessage:@"flashMemory#1" Mac:_whichMac];
    
    
    
    //广播接收
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(timeNotice:) name:@"receiveMessage" object:nil];
    
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//跳转页面
-(void)feedingViewClicked:(UITapGestureRecognizer *)recognizer{
    NSLog(@"tag是%d",recognizer.view.tag);
    NSString *tag = [[NSString alloc]initWithFormat:@"%d",recognizer.view.tag];
    DSDetialTableViewController *detial = [self.storyboard instantiateViewControllerWithIdentifier:@"DSDetialVC"];
    switch (recognizer.view.tag) {
        case 1:
            detial.strDay = _day1.text;
            detial.strNum = _count1.text;
            detial.strTime = _time1.text;
            break;
        case 2:
            detial.strDay = _day2.text;
            detial.strNum = _count2.text;
            detial.strTime = _time2.text;
            break;
        case 3:
            detial.strDay = _strDay3;
            detial.strNum = _strCount3;
            detial.strTime = _strTime3;
            break;
        case 4:
            detial.strDay = _strDay4;
            detial.strNum = _strCount4;
            detial.strTime = _strTime4;
            break;
        case 5:
            detial.strDay = _strDay5;
            detial.strNum = _strCount5;
            detial.strTime = _strTime5;
            break;
        case 6:
            detial.strDay = _strDay6;
            detial.strNum = _strCount6;
            detial.strTime = _strTime6;
            break;
            
        default:
            break;
    }
    NSLog(@"time%@,count%@,day%@",detial.strTime,detial.strNum,detial.strDay);
    detial.id = tag;
    detial.whichMac = _whichMac;
    [self.navigationController pushViewController:detial animated:YES ];
//    [detial release];

}
- (IBAction)switch_food1:(id)sender {
    if(_switch_food1.on == YES){
        NSString *day = @"";
        NSString *count = @"";
        if([_day1.text  isEqual: _everyday]){
            day = @",2,";
        }else{
            day = @",1,";
        }
        count = [_count1.text substringToIndex:1];
        NSString *pour = [NSString stringWithFormat:@"%@%@%@%@",@"set#1,",_time2.text,day,count];
        NSLog(@"%@",pour);
        [[AppDelegate instance]sendMessage:pour Mac:_whichMac];
        [DKProgressHUD showLoadingWithStatus:_setting];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(judgeDk:) name:@"judgeNotice" object:nil];
        if ([_judgeDK  isEqual: @"1"]) {
            [DKProgressHUD dismiss];
            [DKProgressHUD showSuccessWithStatus:_setted];
            _judgeDK = @"";
        }
    }else{
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:@"0" forKey:@"switch1"];
        [userDefaults synchronize];
        NSString *pour = @"cancel#1";
        [[AppDelegate instance]sendMessage:pour Mac:_whichMac];
        [DKProgressHUD showLoadingWithStatus:_setting];
        _judgeDK = @"2";
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(judgeDk:) name:@"judgeNotice" object:nil];
        if ([_judgeDK  isEqual: @"2"]) {
            [DKProgressHUD dismiss];
            [DKProgressHUD showSuccessWithStatus:_cancel];
            _judgeDK =@"";
        }
    }
}
- (IBAction)switch_food2:(id)sender {
    if(_switch_food2.on == YES){
        NSString *day = @"";
        NSString *count = @"";
        if([_day2.text  isEqual: _everyday]){
            day = @",2,";
        }else{
            day = @",1,";
        }
        count = [_count2.text substringToIndex:1];
        NSString *pour = [NSString stringWithFormat:@"%@%@%@%@",@"set#2,",_time2.text,day,count];
            NSLog(@"%@",pour);
            [[AppDelegate instance]sendMessage:pour Mac:_whichMac];
            [DKProgressHUD showLoadingWithStatus:_setting];
            _judgeDK = @"1";
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(judgeDk:) name:@"judgeNotice" object:nil];
            if ([_judgeDK  isEqual: @"1"]) {
                [DKProgressHUD dismiss];
                [DKProgressHUD showSuccessWithStatus:_setted];
                _judgeDK = @"";
            }
        }else{
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            [userDefaults setObject:@"0" forKey:@"switch2"];
            [userDefaults synchronize];
            NSString *pour = @"cancel#2";
            [[AppDelegate instance]sendMessage:pour Mac:_whichMac];
            [DKProgressHUD showLoadingWithStatus:_setting];
            _judgeDK = @"2";
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(judgeDk:) name:@"judgeNotice" object:nil];
            if ([_judgeDK  isEqual: @"2"]) {
                [DKProgressHUD dismiss];
                [DKProgressHUD showSuccessWithStatus:_cancel];
                _judgeDK =@"";
            }
        }
}
- (IBAction)switch_food3:(id)sender {
    if(_switch_food3.on == YES){
        NSString *day = @"";
        NSString *count = @"";
        if([_day3.text  isEqual: _everyday]){
            day = @",2,";
        }else{
            day = @",1,";
        }
        count = [_count3.text substringToIndex:1];
        NSString *pour = [NSString stringWithFormat:@"%@%@%@%@",@"set#3,",_time3.text,day,count];
        NSLog(@"%@",pour);
        [[AppDelegate instance]sendMessage:pour Mac:_whichMac];
        [DKProgressHUD showLoadingWithStatus:_setting];
        _judgeDK = @"1";
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(judgeDk:) name:@"judgeNotice" object:nil];
        if ([_judgeDK  isEqual: @"1"]) {
            [DKProgressHUD dismiss];
            [DKProgressHUD showSuccessWithStatus:_setted];
            _judgeDK = @"";
        }
    }else{
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:@"0" forKey:@"switch3"];
        [userDefaults synchronize];
        NSString *pour = @"cancel#3";
        [[AppDelegate instance]sendMessage:pour Mac:_whichMac];
        [DKProgressHUD showLoadingWithStatus:_setting];
        _judgeDK = @"2";
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(judgeDk:) name:@"judgeNotice" object:nil];
        if ([_judgeDK  isEqual: @"2"]) {
            [DKProgressHUD dismiss];
            [DKProgressHUD showSuccessWithStatus:_cancel];
            _judgeDK =@"";
        }
    }
}
- (IBAction)switch_food4:(id)sender {
    if(_switch_food4.on == YES){
        NSString *day = @"";
        NSString *count = @"";
        if([_day4.text  isEqual: _everyday]){
            day = @",2,";
        }else{
            day = @",1,";
        }
        count = [_count4.text substringToIndex:1];
        NSString *pour = [NSString stringWithFormat:@"%@%@%@%@",@"set#4,",_time4.text,day,count];
        NSLog(@"%@",pour);
        [[AppDelegate instance]sendMessage:pour Mac:_whichMac];
        [DKProgressHUD showLoadingWithStatus:_setting];
        _judgeDK = @"1";
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(judgeDk:) name:@"judgeNotice" object:nil];
        if ([_judgeDK  isEqual: @"1"]) {
            [DKProgressHUD dismiss];
            [DKProgressHUD showSuccessWithStatus:_setted];
            _judgeDK = @"";
        }
    }else{
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:@"0" forKey:@"switch4"];
        [userDefaults synchronize];
        NSString *pour = @"cancel#4";
        [[AppDelegate instance]sendMessage:pour Mac:_whichMac];
        [DKProgressHUD showLoadingWithStatus:_setting];
        _judgeDK = @"2";
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(judgeDk:) name:@"judgeNotice" object:nil];
        if ([_judgeDK  isEqual: @"2"]) {
            [DKProgressHUD dismiss];
            [DKProgressHUD showSuccessWithStatus:_cancel];
            _judgeDK =@"";
        }
    }
}
- (IBAction)switch_water1:(id)sender {
    if(_switch_water1.on == YES){
        NSString *day = @"";
        NSString *count = @"";
        if([_day5.text  isEqual: _everyday]){
            day = @",2,";
        }else{
            day = @",1,";
        }
        count = [_count5.text substringToIndex:1];
        NSString *pour = [NSString stringWithFormat:@"%@%@%@%@",@"set#5,",_time5.text,day,count];
        NSLog(@"%@",pour);
        [[AppDelegate instance]sendMessage:pour Mac:_whichMac];
        [DKProgressHUD showLoadingWithStatus:_setting];
        _judgeDK = @"1";
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(judgeDk:) name:@"judgeNotice" object:nil];
        if ([_judgeDK  isEqual: @"1"]) {
            [DKProgressHUD dismiss];
            [DKProgressHUD showSuccessWithStatus:_setted];
            _judgeDK = @"";
        }
    }else{
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:@"0" forKey:@"switch5"];
        [userDefaults synchronize];
        NSString *pour = @"cancel#5";
        [[AppDelegate instance]sendMessage:pour Mac:_whichMac];
        [DKProgressHUD showLoadingWithStatus:_setting];
        _judgeDK = @"2";
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(
         judgeDk:) name:@"judgeNotice" object:nil];
        if ([_judgeDK  isEqual: @"2"]) {
            [DKProgressHUD dismiss];
            [DKProgressHUD showSuccessWithStatus:_cancel];
            _judgeDK =@"";
        }
    }
}
- (IBAction)switch_water2:(id)sender {
    if(_switch_water2.on == YES){
        NSString *day = @"";
        NSString *count = @"";
        if([_day6.text  isEqual: _everyday]){
            day = @",2,";
        }else{
            day = @",1,";
        }
        count = [_count6.text substringToIndex:1];
        NSString *pour = [NSString stringWithFormat:@"%@%@%@%@",@"set#6,",_time6.text,day,count];
        NSLog(@"%@",pour);
        [[AppDelegate instance]sendMessage:pour Mac:_whichMac];
        [DKProgressHUD showLoadingWithStatus:_setting];
        _judgeDK = @"1";
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(judgeDk:) name:@"judgeNotice" object:nil];
        if ([_judgeDK  isEqual: @"1"]) {
            [DKProgressHUD dismiss];
            [DKProgressHUD showSuccessWithStatus:_setted];
            _judgeDK = @"";
        }
    }else{
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:@"0" forKey:@"switch6"];
        [userDefaults synchronize];
        NSString *pour = @"cancel#6";
        [[AppDelegate instance]sendMessage:pour Mac:_whichMac];
        [DKProgressHUD showLoadingWithStatus:_setting];
        _judgeDK = @"2";
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(judgeDk:) name:@"judgeNotice" object:nil];
        if ([_judgeDK  isEqual: @"2"]) {
            [DKProgressHUD dismiss];
            [DKProgressHUD showSuccessWithStatus:_cancel];
            _judgeDK =@"";
        }
    }
}

//接收消息时的操作
-(void)timeNotice:(NSNotification *)noti{
    _timeMuArray = [[NSMutableArray alloc]init];
    if ([[[AppDelegate instance]reciveMessage] isEqual:@"CtlSuccess"]) {
        //发通知
        [[NSNotificationCenter defaultCenter] postNotificationName:@"judgeNotice" object:self ];
    }else{
        NSArray *mes = [[[AppDelegate instance]reciveMessage] componentsSeparatedByString:@"|"];
        NSLog(@"数组个数：%lu",(unsigned long)mes.count);
        NSLog(@"%lu", (unsigned long)[[mes[0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]length]);
        for (int i=0; i<mes.count; i++) {
            if((unsigned long)[[mes[i] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]length]==0){
                NSLog(@"第%d个数组:%@",i+1,mes[i]);
                dispatch_async(dispatch_get_main_queue(), ^{
                    [DKProgressHUD dismiss];
                });
                break;
            }else{
                NSLog(@"else第%d个数组:%@",i+1,mes[i]);
                NSArray *timeArray = [mes[i] componentsSeparatedByString:@","];
                NSLog(@"1:%@,2:%@,3:%@,4:%@",timeArray[0],timeArray[1],timeArray[2],timeArray[3]);
                [_timeMuArray addObject: timeArray];
            }
        }
    }
    
    NSString *time = @"";
    NSString *day = @"";
    NSString *count = @"";
    NSLog(@"接收广播中的消息:%@",[[AppDelegate instance]reciveMessage]);
    NSLog(@"数组长度:%lu", (unsigned long)_timeMuArray.count);
    if(_timeMuArray.count != 0){
    for (int i=0; i<_timeMuArray.count; i++) {
        NSInteger int_id = [_timeMuArray[i][0] integerValue];
        time = _timeMuArray[i][1];
        count = [NSString stringWithFormat:@"%@%@",_timeMuArray[i][3],@"份"];
        if([_timeMuArray[i][2] isEqual:@"1"]){
            day = _today;
        }else{
            day = _everyday;
        }
        
        //1.获得NSUserDefaults文件
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        switch (int_id) {
            case 1:
                //2.向文件中写入内容
                [userDefaults setObject:time forKey:@"time1"];
                [userDefaults setObject:day forKey:@"day1"];
                [userDefaults setObject:count forKey:@"count1"];
                [userDefaults setObject:@"1" forKey:@"switch1"];
                break;
            case 2:
                //2.向文件中写入内容
                [userDefaults setObject:time forKey:@"time2"];
                [userDefaults setObject:day forKey:@"day2"];
                [userDefaults setObject:count forKey:@"count2"];
                [userDefaults setObject:@"1" forKey:@"switch2"];
                break;
            case 3:
                //2.向文件中写入内容
                [userDefaults setObject:time forKey:@"time3"];
                [userDefaults setObject:day forKey:@"day3"];
                [userDefaults setObject:count forKey:@"count3"];
                [userDefaults setObject:@"1" forKey:@"switch3"];
                break;
            case 4:
                //2.向文件中写入内容
                [userDefaults setObject:time forKey:@"time4"];
                [userDefaults setObject:day forKey:@"day4"];
                [userDefaults setObject:count forKey:@"count4"];
                [userDefaults setObject:@"1" forKey:@"switch4"];
                break;
            case 5:
                //2.向文件中写入内容
                [userDefaults setObject:time forKey:@"time5"];
                [userDefaults setObject:day forKey:@"day5"];
                [userDefaults setObject:count forKey:@"count5"];
                [userDefaults setObject:@"1" forKey:@"switch5"];
                break;
            case 6:
                //2.向文件中写入内容
                [userDefaults setObject:time forKey:@"time6"];
                [userDefaults setObject:day forKey:@"day6"];
                [userDefaults setObject:count forKey:@"count6"];
                [userDefaults setObject:@"1" forKey:@"switch6"];
                break;
            default:
                break;
        }
    }
        [self refreshData];
    }
    
    
//    [self.tableView reloadData];
}

//接收消息的操作
-(void)judgeDk:(NSNotification *)noti{
    
}

//移除观察者
-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)refreshData{
    dispatch_async(dispatch_get_main_queue(), ^{
        //1.获得NSUserDefaults文件
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        //3.读取文件
        NSString *time1 = [userDefaults objectForKey:@"time1"];
        if(time1 !=nil){_time1.text = time1;_strTime1 = time1;}
        NSString *day1 = [userDefaults objectForKey:@"day1"];
        if(day1 != nil){_day1.text = day1;_strDay1 = day1;}
        NSString *count1 = [userDefaults objectForKey:@"count1"];
        if(count1 != nil){_count1.text = count1;_strCount1 = count1;}
        NSString *switch1 = [userDefaults objectForKey:@"switch1"];
        if ([switch1  isEqual: @"1"]) {_switch_food1.on = YES;}
        NSString *time2 = [userDefaults objectForKey:@"time2"];
        if(time2 != nil){_time2.text = time2;_strTime2 = time2;}
        NSString *day2 = [userDefaults objectForKey:@"day2"];
        if(day2 != nil){_day2.text = day2;_strDay2 = day2;}
        NSString *count2 = [userDefaults objectForKey:@"count2"];
        if(count2 != nil){_count2.text = count2;_strCount2 = count2;}
        NSString *switch2 = [userDefaults objectForKey:@"switch2"];
        if ([switch2  isEqual: @"1"]) {_switch_food2.on = YES;}
        NSString *time3 = [userDefaults objectForKey:@"time3"];
        if(time3 != nil){_time3.text = time3;_strTime3 = time3;}
        NSString *day3 = [userDefaults objectForKey:@"day3"];
        if(day3 != nil){_day3.text = day3;_strDay3 = day3;}
        NSString *count3 = [userDefaults objectForKey:@"count3"];
        if(count3 != nil){_count3.text = count3;_strCount3 = count3;}
        NSString *switch3 = [userDefaults objectForKey:@"switch3"];
        if ([switch3  isEqual: @"1"]) {_switch_food3.on = YES;}
        NSString *time4 = [userDefaults objectForKey:@"time4"];
        if(time4 != nil){_time4.text = time4;_strTime4 = time4;}
        NSString *day4 = [userDefaults objectForKey:@"day4"];
        if(day4 != nil){_day4.text = day4;_strDay4 = day4;}
        NSString *count4 = [userDefaults objectForKey:@"count4"];
        if(count4 != nil){_count4.text = count4;_strCount4 = count4;}
        NSString *switch4 = [userDefaults objectForKey:@"switch4"];
        if ([switch4  isEqual: @"1"]) {_switch_food4.on = YES;}
        NSString *time5 = [userDefaults objectForKey:@"time5"];
        if(time5 != nil){_time5.text = time5;_strTime5 = time5;}
        NSString *day5 = [userDefaults objectForKey:@"day5"];
        if(day5 != nil){_day5.text = day5;_strDay5 = day5;}
        NSString *count5 = [userDefaults objectForKey:@"count5"];
        if(count5 != nil){_count5.text = count5;_strCount5 = count5;}
        NSString *switch5 = [userDefaults objectForKey:@"switch5"];
        if ([switch5  isEqual: @"1"]) {_switch_water1.on = YES;}
        NSString *time6 = [userDefaults objectForKey:@"time6"];
        if(time6 != nil){_time6.text = time6;_strTime6 = time6;}
        NSString *day6 = [userDefaults objectForKey:@"day6"];
        if(day6 != nil){_day6.text = day6;_strDay6 = day6;}
        NSString *count6 = [userDefaults objectForKey:@"count6"];
        if(count6 != nil){_count6.text = count6;_strCount6 = count6;}
        NSString *switch6 = [userDefaults objectForKey:@"switch6"];
        if ([switch6  isEqual: @"1"]) {_switch_water2.on = YES;}
    
        [DKProgressHUD dismiss];
    });
}


//不允许上拉或下拉
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    self.tableView.bounces = NO;
}

#pragma mark - Table view data source
//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
//{
//    return 10.; // you can have your own choice, of course
//}
//
//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    UIView *headerView = [[UIView alloc] init];
//    headerView.backgroundColor = [UIColor clearColor];
//    return headerView;
//}



//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//
//    return 1;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//#warning Incomplete implementation, return the number of rows
//    return 4;
//}


//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reuseIdentifier" forIndexPath:indexPath];
//    
//    // Configure the cell...
//    
//    return cell;
//}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//
//}

//-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
//    
//    if(indexPath.section == 0 && indexPath.row == 0){
//        NSLog(@"11");
//        [self performSegueWithIdentifier:@"food1" sender:nil];
//    }
//    if(indexPath.section == 0 && indexPath.row == 1){
//        NSLog(@"12");
//    }
//}
//

@end

