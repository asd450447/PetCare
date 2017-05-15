//
//  DevTableViewController.m
//  PetCare
//
//  Created by mao ke on 2017/3/1.
//  Copyright © 2017年 江苏科茂. All rights reserved.
//

#import "DevTableViewController.h"
#import "DevTableViewCell.h"
#import "AFNetworking.h"
#import "DetailTableViewController.h"
#import <XMPPFramework/XMPPFramework.h>
#import "DKProgressHUD.h"
#import "AppDelegate.h"


XMPPStream *xs;
XMPPReconnect *xr;

@interface DevTableViewController ()<XMPPStreamDelegate,NSFetchedResultsControllerDelegate>{
    NSFetchedResultsController *fetchedResultsController;
}
@property NSMutableArray *name;
@property NSMutableArray *mac;
@property NSMutableArray *onlineMac;
@property UIRefreshControl *control;
@property NSString *tname;
@property NSString *online;
@property NSString *unonline;

@end

@implementation DevTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 集成刷新控件
    [self setupRefresh];
    
    //隐藏多余cell
    self.tableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor whiteColor];
    
    // 去掉返回按钮
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"" style:(UIBarButtonItemStyleDone) target:self action:nil];
    // 去掉返回手势
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
    
    [[AppDelegate instance]connectToHost];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(showOnlineMac:) name:@"onLineMac" object:nil];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self DTrefreshStateChange];
    
    // 集成刷新控件
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [self setupRefresh];
//    });
    
    
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_name count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"DevIdentifier";
    DevTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    cell.DevName.text = self.name[indexPath.row];
//    cell.DevImage.image = [UIImage imageNamed:@"paw"];
    
//    XMPPUserCoreDataStorageObject *user = [self->fetchedResultsController objectAtIndexPath:indexPath];
//    NSLog(@"%ld", (long)user.section) ;
//    NSLog(@"%@", user.nickname);
    if ([[[AppDelegate instance]currentLanguage]isEqualToString:@"en"]) {
        _online = @"Online";
        _unonline = @"UnOnline";
    }else{
        _online = @"在线";
        _unonline = @"离线";
    }
    for (int i = 0; i<_onlineMac.count; i++) {
        if ([self.mac[indexPath.row] isEqualToString:self.onlineMac[i]]) {
            cell.DevOnline.text = _online;
            break;
        }else{
            cell.DevOnline.text = _unonline;
        }
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSLog(@"onlineMac:%@", _onlineMac);
    if (_onlineMac.count>1) {
        for (int i=0; i<_onlineMac.count; i++) {
            for (int j=i+1; j<_onlineMac.count; j++) {
                if ([_onlineMac[i] isEqualToString: _onlineMac[j]]) {
                    [_onlineMac removeObjectAtIndex:j];
                }
            }
        }
    }
    NSLog(@"onlineMac0:%@", _onlineMac);
    
    for (int i = 0 ; i<_onlineMac.count; i++) {
        NSLog(@"%@", self.mac[indexPath.row]);
        NSLog(@"%@", _onlineMac[i]);
        if ([self.mac[indexPath.row] isEqualToString: _onlineMac[i]]) {
            NSLog(@"%@", self.mac[indexPath.row]);
            NSLog(@"%@", _onlineMac[i]);
            DetailTableViewController *detialVC = [self.storyboard instantiateViewControllerWithIdentifier:@"detialtableview"];
            detialVC.whichMac = self.mac[indexPath.row];
            detialVC.Name = self.name[indexPath.row];
            [self.navigationController pushViewController:detialVC animated:YES ];
        }
    }
    if ([[[AppDelegate instance]currentLanguage ]isEqualToString:@"en"]) {
        [DKProgressHUD showErrorWithStatus:@"Device Unonline" toView:self.view];
    }else{
        [DKProgressHUD showErrorWithStatus:@"设备不在线" toView:self.view];
    }
    
}


/**
 *  集成下拉刷新
 */
-(void)setupRefresh
{
    //1.添加刷新控件
    _control=[[UIRefreshControl alloc]init];
    [_control addTarget:self action:@selector(DTrefreshStateChange) forControlEvents:UIControlEventValueChanged];
    
    if ([[[AppDelegate instance]currentLanguage ]isEqualToString:@"en"]) {
        _control.attributedTitle = [[NSAttributedString alloc]initWithString:@"Loading..."];
    }else{
        _control.attributedTitle = [[NSAttributedString alloc]initWithString:@"加载中..."];
    }

    [self.tableView addSubview:_control];
    
    //2.马上进入刷新状态，并不会触发UIControlEventValueChanged事件
    [_control beginRefreshing];
    
    // 3.加载数据
    [self DTrefreshStateChange];
    
}

/**
 *  UIRefreshControl进入刷新状态：加载最新的数据
 */
-(void)DTrefreshStateChange
{
    
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    
    //设置参数
    NSString *post = [NSString stringWithFormat:@"%@%@%@",@"paraName={\"name\":method,\"value\":PhoneGetDevInfo},{\"name\":user,\"value\":",[defaults objectForKey:@"userName"],@"}"];
    [[AppDelegate instance]postToData:post postMac:nil ];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(devShowData:) name:@"postToData" object:nil];
    
}

/**
 请求数据库信息
 */
-(void)postToData:(NSString *)post postType:(NSString *)type{
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
        if (!error) {
            NSString *str = responseObject[@"flag"];
            str = [str stringByReplacingOccurrencesOfString:@"'" withString:@"\""];
            NSLog(@"%@", str);
            if ([type isEqualToString:@"updatename"]) {
                str = [str substringFromIndex:19];
                if ([str isEqualToString:@"true"]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if ([[[AppDelegate instance]currentLanguage ]isEqualToString:@"en"]) {
                            [DKProgressHUD showSuccessWithStatus:@"update successfully" toView:self.view];
                        }else{
                            [DKProgressHUD showSuccessWithStatus:@"修改成功" toView:self.view];
                        }
                        [self DTrefreshStateChange];
                    });
                    
                }else{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if ([[[AppDelegate instance]currentLanguage ]isEqualToString:@"en"]) {
                            [DKProgressHUD showSuccessWithStatus:@"update failed" toView:self.view];
                        }else{
                            [DKProgressHUD showSuccessWithStatus:@"修改失败" toView:self.view];
                        }
                    });
                }
            }else{
                str = [str substringFromIndex:15];
                if ([str isEqualToString:@"true"]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
//                        [DKProgressHUD showSuccessWithStatus:@"修改成功" toView:self.view];
                        [self DTrefreshStateChange];
                    });
                    
                }else{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if ([[[AppDelegate instance]currentLanguage ]isEqualToString:@"en"]) {
                            [DKProgressHUD showSuccessWithStatus:@"update failed" toView:self.view];
                        }else{
                            [DKProgressHUD showSuccessWithStatus:@"修改失败" toView:self.view];
                        }
                    });
                }

            }
        } else {
            NSLog(@"error : %@", error.localizedDescription);
        }
    }];
    
    [task resume];
}
 


/**
 修改设备信息格式，并存入数组

 @param str 获取的设备名
 @param sw 判断Mac还是name
 */
-(void) strChange:(NSString*)str switch:(NSString*)sw{
    str = [str stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    str = [str substringFromIndex:1];
    str = [str substringWithRange:NSMakeRange(0, [str length] - 1)];
    str = [str stringByReplacingOccurrencesOfString:@" " withString:@""];
    str = [str stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    NSLog(@"str:%@", str);
    str = [self replaceUnicode:str];
    NSLog(@"str:%@", str);
    NSArray *arr = [str componentsSeparatedByString:@","];
    for (int i=0; i<arr.count; i++) {
        if ([sw isEqualToString:@"name"]) {
            [_name addObject:arr[i]];
        }else{
            NSString *lowercase = [arr[i] lowercaseString];
            [_mac addObject:lowercase];
        }
    }
}

-(void)devShowData:(NSNotification *)noti{
    //初始化数组
    _name = [[NSMutableArray alloc]init];
    _mac = [[NSMutableArray alloc]init];
   
    NSString *str = [NSString stringWithFormat:@"%@",noti.userInfo];
    str = [str stringByReplacingOccurrencesOfString:@"'" withString:@"\""];
    str = [str substringFromIndex:16];
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    dict = dict[@"dev"];
    NSLog(@"dict:%@", dict);
    if (![dict isEqual:@"null"]) {
        str =[NSString stringWithFormat:@"%@",[dict valueForKeyPath:@"Name"]];
        [self strChange:str switch:@"name"];
        str =[NSString stringWithFormat:@"%@",[dict valueForKeyPath:@"Mac"]];
        [self strChange:str switch:@"Mac"];
    }else{
        NSString *title = @"请点击下方添加按钮，添加新设备";
        if ([[[AppDelegate instance]currentLanguage ]isEqualToString:@"en"]) {
            title = @"Please click the Add button below to add a new device";
            
        }

        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:title preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:ok];
        [self presentViewController:alert animated:YES completion:nil];
    }
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"postToData" object:nil ];
    dispatch_async(dispatch_get_main_queue(), ^{
        //刷新表格
        [self.tableView reloadData];
        //  结束刷新
        [_control endRefreshing];
    });
}

-(void)showOnlineMac:(NSNotification *)noti{
    dispatch_async(dispatch_get_main_queue(), ^{
        _onlineMac = [[NSMutableArray alloc]init];
        _onlineMac = [[AppDelegate instance]onLineMac];
        NSLog(@"onlineMac:%@", _onlineMac);
        if (_onlineMac.count>1) {
            for (int i=0; i<_onlineMac.count; i++) {
                for (int j=i+1; j<_onlineMac.count; j++) {
                    if ([_onlineMac[i] isEqualToString: _onlineMac[j]]) {
                        [_onlineMac removeObjectAtIndex:j];
                    }
                }
            }
        }
        NSLog(@"onlineMac0:%@", _onlineMac);
        
        //刷新表格
        [self.tableView reloadData];
        
    });
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"onLineMac" object:nil];
}


/**
 移除观察者
 
-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
*/
/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
//    if (editingStyle == UITableViewCellEditingStyleDelete) {
//        // Delete the row from the data source
////        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
//        NSLog(@"shanchu");
//    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
//        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
//    }   
}

/**
 *  左滑cell时出现什么按钮
 */
- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *title = @"修改设备名称";
    NSString *cancel = @"取消";
    NSString *changename = @"改名";
    NSString *delete = @"删除";
    if ([[[AppDelegate instance]currentLanguage ]isEqualToString:@"en"]) {
        title = @"Update name of device";
        cancel = @"Cancel";
        changename = @"Update Name";
        delete = @"Delete";
    }

    UITableViewRowAction *action0 = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:changename handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        NSLog(@"点击了改名");
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleAlert];
        [alert addTextFieldWithConfigurationHandler:^(UITextField * textField) {
            _tname = textField.text;
             [[NSNotificationCenter defaultCenter] addObserver: self selector:@selector(handlerTextFieldTextDidChangeNotification:) name:UITextFieldTextDidChangeNotification object:textField];
        }];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancel style:UIAlertActionStyleCancel handler:nil];
        UIAlertAction *OkAction=[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *actoin){
            NSLog(@"tname：%@mac：%@",  _tname,self.mac[indexPath.row]);
            NSString *post = [NSString stringWithFormat:@"%@%@%@%@%@",@"paraName={\"name\":method,\"value\":PhoneUpdateDevName},{\"name\":mac,\"value\":",self.mac[indexPath.row],@"},{\"name\":name,\"value\":", _tname,@"}"];
            NSLog(@"%@", post);
            [self postToData:post postType:@"updatename"];
            NSLog(@"点击ok");
             [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:alert.textFields.firstObject];
        }];//在代码块中可以填写具体这个按钮执行的操作
        [alert addAction:cancelAction];
        //代码块前的括号是代码块返回的数据类型
        [alert addAction:OkAction];
        [self presentViewController: alert animated:YES completion:nil];
        // 收回左滑出现的按钮(退出编辑模式)
        tableView.editing = NO;
    }];
    
    
    UITableViewRowAction *action1 = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:delete handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
        NSString *post = [NSString stringWithFormat:@"%@%@%@%@%@",@"paraName={\"name\":method,\"value\":PhoneDeleteDev},{\"name\":user,\"value\":",[defaults objectForKey:@"userName"],@"},{\"name\":mac,\"value\":", self.mac[indexPath.row],@"}"];
        [self postToData:post postType:@"delecte"];
        tableView.editing = NO;
    }];
    
    return @[action1, action0];
}

//unicode 转换为汉字
- (NSString *)replaceUnicode:(NSString *)unicodeStr
{
    NSString *tempStr1 = [unicodeStr stringByReplacingOccurrencesOfString:@"\\u" withString:@"\\U"];
    NSString *tempStr2 = [tempStr1 stringByReplacingOccurrencesOfString:@"\"" withString:@" \\\""];
    NSString *tempStr3 = [[@"\"" stringByAppendingString:tempStr2] stringByAppendingString:@"\""];
    NSData *tempData = [tempStr3 dataUsingEncoding:NSUTF8StringEncoding];
    NSString* returnStr = [NSPropertyListSerialization propertyListFromData:tempData
                                                           mutabilityOption:NSPropertyListImmutable
                                                                     format:NULL
                                                           errorDescription:NULL];
    return [returnStr stringByReplacingOccurrencesOfString:@"\\r\\n"withString:@"\n"];
}

/**
 处理textfield的赋值事件

 @param notification textfield的内容
 */
-(void)handlerTextFieldTextDidChangeNotification:(NSNotification*) notification
{
    UITextField *textField=notification.object;
    _tname = textField.text;
//    self.secureTextAlertAction.enabled=textField.text.length>=5;
}


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
