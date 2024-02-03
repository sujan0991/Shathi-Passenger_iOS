//
//  SettingViewController.h
//  Shathi
//
//  Created by Sujan on 5/24/17.
//  Copyright © 2017 Sujan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImageView+WebCache.h"

@interface SettingViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,SDWebImageManagerDelegate>


@property (weak, nonatomic) IBOutlet UIView *navView;

@property (weak, nonatomic) IBOutlet UIImageView *profilePicture;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *phoneNoLabel;
@property (weak, nonatomic) IBOutlet UIButton *editProfileButton;

@property (weak, nonatomic) IBOutlet UITableView *settingTableView;


@end
