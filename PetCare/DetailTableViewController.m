//
//  DetailTableViewController.m
//  PetCare
//
//  Created by mao ke on 2017/3/2.
//  Copyright © 2017年 江苏科茂. All rights reserved.
//

#import "DetailTableViewController.h"
#import "DingshiTableViewController.h"
#import "searchViewController.h"
#import "ActionSheetPicker.h"
#import <XMPPFramework/XMPPFramework.h>
#import "DKProgressHUD.h"
#import "AppDelegate.h"

@interface DetailTableViewController ()<XMPPStreamDelegate>
@property (weak, nonatomic) IBOutlet UILabel *DSLable;
@property (weak, nonatomic) IBOutlet UIView *DSView;
@property (weak, nonatomic) IBOutlet UIView *feedDataView;
@property UIRefreshControl *control;
@property (weak, nonatomic) IBOutlet UIImageView *DTVImage;
@property (weak, nonatomic) IBOutlet UITableViewCell *functionCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *dingshiCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *dataCell;
@property CGFloat height;
@property NSMutableArray *timeMuArray;
@property NSString *count;
@property NSString *judge;
@property NSString *loading;
@property NSString *foodsuccess;
@property NSString *watersucccess;
@end

@implementation DetailTableViewController
- (IBAction)food:(id)sender {
    NSArray *colors = [NSArray arrayWithObjects:@"40g", @"80g", @"120g",nil];
    [ActionSheetStringPicker showPickerWithTitle:@""
                                            rows:colors
                                initialSelection:0
                                       doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
                                           NSString *pour = @"";
                                           switch (selectedIndex) {
                                               case 0:
                                                   pour = @"action#1,3";
                                                   break;
                                                   
                                               case 1:
                                                   pour = @"action#1,6";
                                                   break;
                                                   
                                               default:
                                                   pour = @"action#1,9";
                                                   break;
                                           }
                                           [[AppDelegate instance]sendMessage:pour Mac:_whichMac];
                                           [DKProgressHUD showLoadingWithStatus:_loading toView:self.view];
                                            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(disDK:) name:@"successNotice" object:nil];
                                       }
                                     cancelBlock:^(ActionSheetStringPicker *picker) {
                                         NSLog(@"Block Picker Canceled");
                                     }
                                          origin:sender];

}
- (IBAction)water:(id)sender {
    _judge = @"water";
    NSArray *colors = [NSArray arrayWithObjects:@"小份", @"中份", @"大份",nil];
    [ActionSheetStringPicker showPickerWithTitle:@""
                                            rows:colors
                                initialSelection:0
                                       doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
                                            NSString *pour = @"";
                                            switch (selectedIndex) {
                                               case 0:
                                                   pour = @"action#0,3";
                                                   break;
                                                   
                                               case 1:
                                                   pour = @"action#0,6";
                                                   break;
                                                   
                                               default:
                                                   pour = @"action#0,9";
                                                   break;
                                           }
                                           [[AppDelegate instance]sendMessage:pour Mac:_whichMac];
                                           [DKProgressHUD showLoadingWithStatus:_loading toView:self.view];
                                           [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(disDK:) name:@"successNotice" object:nil];
                                       }
                                     cancelBlock:^(ActionSheetStringPicker *picker) {
                                         NSLog(@"Block Picker Canceled");
                                     }
                                          origin:sender];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
//    [self setupRefresh];
    
    if([[[AppDelegate instance]currentLanguage]isEqualToString:@"en"]){
        _loading = @"loading...";
        _foodsuccess = @"Success!";
        _watersucccess = @"Success!";
    }else{
        _loading = @"加载中...";
        _foodsuccess = @"喂食成功";
        _watersucccess = @"喂水成功！";
    }
    
    NSLog(@"_whichMac:%@", _whichMac);
    NSLog(@"_Name:%@", _Name);
    self.navigationItem.title = _Name;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    //获取屏幕的尺寸
    CGRect rect = [[UIScreen mainScreen] bounds];
    CGSize size = rect.size;
    CGFloat width = size.width;
    _height = size.height;
    _DTVImage.bounds = CGRectMake(0, 0, width, _height/3);
    _DTVImage.image = [UIImage imageNamed:@"petpic"];
    
    //隐藏多余cell
    self.tableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    
    //设置UIView的点击事件
    UITapGestureRecognizer *dingshiView = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dingshiViewClicked:)];
    [self.DSView addGestureRecognizer:dingshiView];
    UITapGestureRecognizer *feedDataView = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dingshiViewClicked:)];
    [self.feedDataView addGestureRecognizer:feedDataView];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [DKProgressHUD dismiss];
    [self setupRefresh];
}

-(void) viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dingshiViewClicked:(UITapGestureRecognizer *)recognizer{
    
    if (recognizer.view.tag == 1) {
        //定时页面
        DingshiTableViewController *dingshiVC = [self.storyboard instantiateViewControllerWithIdentifier:@"DSTableVC"];
        dingshiVC.whichMac = self.whichMac;
        [self.navigationController pushViewController:dingshiVC animated:YES ];
    }else{
        //查询数据页面
        searchViewController *searchVC = [self.storyboard instantiateViewControllerWithIdentifier:@"searchViewController"];
        searchVC.whichMac = self.whichMac;
         [self.navigationController pushViewController:searchVC animated:YES];
    }
}

/**
 *  集成下拉刷新
 */
-(void)setupRefresh
{
    //1.添加刷新控件
    _control=[[UIRefreshControl alloc]init];
    [_control addTarget:self action:@selector(refreshStateChange:) forControlEvents:UIControlEventValueChanged];
    _control.attributedTitle = [[NSAttributedString alloc]initWithString:_loading];
    [self.tableView addSubview:_control];
    
    //2.马上进入刷新状态，并不会触发UIControlEventValueChanged事件
    [_control beginRefreshing];
    
    // 3.加载数据
    [self refreshStateChange:_control];
}

-(void)refreshStateChange:(UIRefreshControl *)control
{
    [[AppDelegate instance]sendMessage:@"flashMemory#1" Mac:_whichMac];
    //广播接收
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(countNotice:) name:@"receiveMessage" object:nil];
}


/**
 接收消息时的操作
 */
-(void)countNotice:(NSNotification *)noti{
    if ([[[AppDelegate instance]reciveMessage] isEqual:@"CtlSuccess"]) {
        //发通知
        [[NSNotificationCenter defaultCenter] postNotificationName:@"successNotice" object:self];
    }else{
        NSArray *mes = [[[AppDelegate instance]reciveMessage]componentsSeparatedByString:@"|"];
        NSLog(@"数组个数：%lu",(unsigned long)mes.count);
        switch (mes.count) {
                case 0:
                _count = @"There is 0 timing information today";
                break;
                
                case 1:
                _count = @"There is 0 timing information today";
                break;

                case 2:
                _count = @"There is 1 timing information today";
                break;
                
                case 3:
                _count = @"There are 2 timing information today";
                break;
                
                case 4:
                _count = @"There are 3 timing information today";
                break;
                
                case 5:
                _count = @"There are 4 timing information today";
                break;
                
                case 6:
                _count = @"There are 5 timing information today";
                break;
                
                case 7:
                _count = @"There are 6 timing information today";
                break;
            default:
                break;
        }
        
//        _count = [NSString stringWithFormat:@"%lu",(unsigned long)mes.count-1];
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([[[AppDelegate instance]currentLanguage]isEqualToString:@"en"]) {
                _DSLable.text = _count;
            }else{
                _DSLable.text = [NSString stringWithFormat:@"%@%lu%@",@"今天共有",mes.count-1,@"条定时信息"];
            }
            [_control endRefreshing];
        });
    }
}

-(void)disDK:(NSNotification *)noti{
    dispatch_async(dispatch_get_main_queue(), ^{
        [DKProgressHUD dismiss];
        if ([_judge isEqualToString:@"food"]) {
            [DKProgressHUD showSuccessWithStatus:_foodsuccess toView:self.view];
        }else{
            [DKProgressHUD showSuccessWithStatus:_watersucccess toView:self.view];
        }
    });
}

/**
 移除观察者
 */
-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
#pragma mark - Table view data source

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        
        return _height/7;
    }else {
        
        return _height/8;
    }
    
}
/**
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
 #warning Incomplete implementation, return the number of sections
 return 0;
 }
 
 - (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
 #warning Incomplete implementation, return the number of rows
 return 0;
 }

 */

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

@end
