//
//  RideHistoryTableViewCell.h
//  Oye Driver
//
//  Created by Sujan on 8/17/17.
//  Copyright © 2017 Sujan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RideHistoryTableViewCell : UITableViewCell




@property (weak, nonatomic) IBOutlet UIImageView *rideStaticMap;
@property (weak, nonatomic) IBOutlet UILabel *rideDate;
@property (weak, nonatomic) IBOutlet UILabel *bikeModel;

@property (weak, nonatomic) IBOutlet UILabel *totalCost;

@end
