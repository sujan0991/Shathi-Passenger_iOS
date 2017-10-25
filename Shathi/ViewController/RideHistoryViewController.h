//
//  RideHistoryViewController.h
//  Shathi
//
//  Created by Sujan on 8/20/17.
//  Copyright © 2017 Sujan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImageView+WebCache.h"

@interface RideHistoryViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,SDWebImageManagerDelegate>



@property (weak, nonatomic) IBOutlet UILabel *navTitileLabel;

@property (weak, nonatomic) IBOutlet UITableView *historyTableView;

@end
