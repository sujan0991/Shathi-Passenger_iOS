//
//  DetailHistoryViewController.h
//  Shathi
//
//  Created by Sujan on 8/20/17.
//  Copyright © 2017 Sujan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailHistoryViewController : UIViewController

@property (nonatomic,strong) NSMutableDictionary* rideInfo;

@property (weak, nonatomic) IBOutlet UILabel *navtitleLabel;

@property (weak, nonatomic) IBOutlet UILabel *bikeModelLabel;

@property (weak, nonatomic) IBOutlet UILabel *costLabel;
@property (weak, nonatomic) IBOutlet UILabel *pickupTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *driverNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *paymentMethodLabel;
@property (weak, nonatomic) IBOutlet UILabel *pickupLocationLabel;
@property (weak, nonatomic) IBOutlet UILabel *destinationLabel;
@property (weak, nonatomic) IBOutlet UIImageView *staticMap;


@property (weak, nonatomic) IBOutlet UIButton *removeButton;

@end
