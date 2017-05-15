//
//  DevTableViewCell.h
//  PetCare
//
//  Created by mao ke on 2017/3/1.
//  Copyright © 2017年 江苏科茂. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DevTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *DevImage;
@property (weak, nonatomic) IBOutlet UILabel *DevName;
@property (weak, nonatomic) IBOutlet UILabel *DevOnline;

@end
