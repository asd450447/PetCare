//
//  DSDetialTableViewController.m
//  pet
//
//  Created by 蒋 磊 on 2016/11/11.
//  Copyright © 2016年 江苏科茂. All rights reserved.
//

#import "DSDetialTableViewController.h"
#import "ActionSheetPicker.h"
#import "DingshiTableViewController.h"
#import "AppDelegate.h"
@interface DSDetialTableViewController ()
@property (weak, nonatomic) IBOutlet UIButton *day;
@property (weak, nonatomic) IBOutlet UIButton *number;
@property (weak, nonatomic) IBOutlet UIButton *dtime;
@property (nonatomic, strong) NSDate *selectedTime;
@property (weak, nonatomic) IBOutlet UIButton *timeSelect;

@property (weak, nonatomic) IBOutlet UILabel *leixing;
@property NSString *today;
@property NSString *everyday;
@property NSString *chooseType;
@property NSString *choseCount;
@property NSString *watering;
@end

@implementation DSDetialTableViewController
- (IBAction)day:(id)sender {
    NSArray *colors = [NSArray arrayWithObjects:_today, _everyday, nil];
    [ActionSheetStringPicker showPickerWithTitle:_chooseType
                                            rows:colors
                                initialSelection:0
                                       doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
                                           [_day setTitle:selectedValue forState:UIControlStateNormal];
                                           _strDay = selectedValue;
                                       }
                                     cancelBlock:^(ActionSheetStringPicker *picker) {
                                         NSLog(@"Block Picker Canceled");
                                     }
                                          origin:sender];
}
- (IBAction)number:(id)sender {
    NSArray *colors = [NSArray arrayWithObjects:@"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"10", nil];
    [ActionSheetStringPicker showPickerWithTitle:_choseCount
                                            rows:colors
                                initialSelection:0
                                       doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
                                           [_number setTitle:selectedValue forState:UIControlStateNormal];
                                           _strNum = selectedValue;
                                       }
                                     cancelBlock:^(ActionSheetStringPicker *picker) {
                                         NSLog(@"Block Picker Canceled");
                                     }
                                          origin:sender];
}
- (IBAction)timeSelect:(id)sender {
    NSInteger minuteInterval = 5;
    //clamp date
    NSInteger referenceTimeInterval = (NSInteger)[self.selectedTime timeIntervalSinceReferenceDate];
    NSInteger remainingSeconds = referenceTimeInterval % (minuteInterval *60);
    NSInteger timeRoundedTo5Minutes = referenceTimeInterval - remainingSeconds;
    if(remainingSeconds>((minuteInterval*60)/2)) {/// round up
        timeRoundedTo5Minutes = referenceTimeInterval +((minuteInterval*60)-remainingSeconds);
    }
    
    self.selectedTime = [NSDate dateWithTimeIntervalSinceReferenceDate:(NSTimeInterval)timeRoundedTo5Minutes];
    
    ActionSheetDatePicker *datePicker = [[ActionSheetDatePicker alloc] initWithTitle:nil datePickerMode:UIDatePickerModeTime selectedDate:self.selectedTime target:self action:@selector(timeWasSelected:element:) origin:sender];
    datePicker.minuteInterval = minuteInterval;
    [datePicker showActionSheetPicker];


}
- (IBAction)saveButton:(id)sender {
//    DingshiTableViewController *DsDate = [[DingshiTableViewController alloc]init];
//    DingshiTableViewController *ding = [[DingshiTableViewController alloc]init];
    
    struct dingshidate dingshi = {_strDay,_strNum,_strTime,_id};
    NSLog(@"day:%@", _strDay);
    NSLog(@"num:%@", _strNum);
    NSLog(@"time%@", _strTime);
    
    NSLog(@"%@", dingshi.day);
    NSLog(@"%@", dingshi.count);
    NSLog(@"%@", dingshi.time);
    NSLog(@"%@", dingshi.id);
//    [self performSegueWithIdentifier:@"unwindToList" sender:self];
    NSInteger int_id = [_id integerValue];
    //1.获得NSUserDefaults文件
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    switch (int_id) {
        case 1:
            //2.向文件中写入内容
            [userDefaults setObject:_strTime forKey:@"time1"];
            [userDefaults setObject:_strDay forKey:@"day1"];
            [userDefaults setObject:_strNum forKey:@"count1"];
            [userDefaults setObject:_id forKey:@"id"];
            [userDefaults setObject:@"1" forKey:@"switch1"];
            break;
        case 2:
            //2.向文件中写入内容
            [userDefaults setObject:_strTime forKey:@"time2"];
            [userDefaults setObject:_strDay forKey:@"day2"];
            [userDefaults setObject:_strNum forKey:@"count2"];
            [userDefaults setObject:_id forKey:@"id"];
            [userDefaults setObject:@"1" forKey:@"switch2"];
            break;
        case 3:
            //2.向文件中写入内容
            [userDefaults setObject:_strTime forKey:@"time3"];
            [userDefaults setObject:_strDay forKey:@"day3"];
            [userDefaults setObject:_strNum forKey:@"count3"];
            [userDefaults setObject:_id forKey:@"id"];
            [userDefaults setObject:@"1" forKey:@"switch3"];
            break;
        case 4:
            //2.向文件中写入内容
            [userDefaults setObject:_strTime forKey:@"time4"];
            [userDefaults setObject:_strDay forKey:@"day4"];
            [userDefaults setObject:_strNum forKey:@"count4"];
            [userDefaults setObject:_id forKey:@"id"];
            [userDefaults setObject:@"1" forKey:@"switch4"];
            break;
        case 5:
            //2.向文件中写入内容
            [userDefaults setObject:_strTime forKey:@"time5"];
            [userDefaults setObject:_strDay forKey:@"day5"];
            [userDefaults setObject:_strNum forKey:@"count5"];
            [userDefaults setObject:_id forKey:@"id"];
            [userDefaults setObject:@"1" forKey:@"switch5"];
            break;
        case 6:
            //2.向文件中写入内容
            [userDefaults setObject:_strTime forKey:@"time6"];
            [userDefaults setObject:_strDay forKey:@"day6"];
            [userDefaults setObject:_strNum forKey:@"count6"];
            [userDefaults setObject:_id forKey:@"id"];
            [userDefaults setObject:@"1" forKey:@"switch6"];
            break;
        default:
            break;
    }
    
//    [userDefaults setBool:YES forKey:@"sex"];
//    [userDefaults setInteger:21 forKey:@"age"];
    //2.1立即同步
    [userDefaults synchronize];
    if([_strDay isEqual: _everyday]){
        _strDay = @",2,";
    }else{
        _strDay = @",1,";
    }
    _strNum = [_strNum substringToIndex:1];
    NSString *pour = [NSString stringWithFormat:@"%@%@%@%@%@%@",@"set#",_id,@",",_strTime,_strDay,_strNum];
    NSLog(@"%@",pour);
    [[AppDelegate instance]sendMessage:pour Mac:_whichMac];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    if ([[[AppDelegate instance]currentLanguage]isEqualToString:@"en"]) {
        _today = @"Today";
        _everyday = @"Every Day";
        _chooseType = @"Select";
        _choseCount = @"Select";
        _watering = @"Watering";
    }else{
        _today = @"当天";
        _everyday = @"每天";
        _chooseType = @"选择重复类型";
        _choseCount = @"选择份数";
        _watering = @"喂水";
    }
//    _strDay = @"每天";
//    _strNum = @"1份";
//    _strTime = @"00:00";
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if(self.delegate && [self.delegate respondsToSelector:@selector(viewController:didPassingValueWithInfo:)]){
        [self.delegate viewController:self didPassingValueWithInfo:_strTime];
    }
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    NSLog(@"%@", self.id);
    NSInteger int_id = [self.id integerValue];
    switch (int_id) {
        case 5:
            _leixing.text = _watering;
            break;
        case 6:
            _leixing.text = _watering;
            break;
        default:
            break;
    }
    NSLog(@"time:%@，count:%@，day:%@",_strTime,_strNum,_strDay);
    if(_strTime != nil) {
        [_day setTitle:_strDay forState:UIControlStateNormal];
    }
    if (_strNum != nil) {
        [_number setTitle:_strNum forState:UIControlStateNormal];
    }
    if(_strDay != nil) {
        [_dtime setTitle:_strTime forState:UIControlStateNormal];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//#warning Incomplete implementation, return the number of sections
//    return 4;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//#warning Incomplete implementation, return the number of rows
//    return 1;
//}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
-(void)timeWasSelected:(NSDate *)selectedTime element:(id)element {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm"];
    NSLog(@"%@", [dateFormatter stringFromDate:selectedTime]);
    _strTime=[dateFormatter stringFromDate:selectedTime];
    [element setTitle:[dateFormatter stringFromDate:selectedTime] forState:UIControlStateNormal];
}




@end
