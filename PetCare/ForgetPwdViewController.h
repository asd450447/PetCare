//
//  ForgetPwdViewController.h
//  PetCare
//
//  Created by mao ke on 2017/3/23.
//  Copyright © 2017年 江苏科茂. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ForgetPwdViewController : UIViewController<UITextFieldDelegate>{
    NSTimer *_timerView;
}
@property (retain,nonatomic)NSTimer* timerView;
@end
