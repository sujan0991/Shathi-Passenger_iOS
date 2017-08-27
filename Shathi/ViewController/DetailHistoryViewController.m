//
//  DetailHistoryViewController.m
//  Shathi
//
//  Created by Sujan on 8/20/17.
//  Copyright © 2017 Sujan. All rights reserved.
//

#import "DetailHistoryViewController.h"

@interface DetailHistoryViewController ()

@end

@implementation DetailHistoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"single ride  %@",self.rideInfo);
    
    [self viewSetup];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewSetup{

    self.costLabel.text =[NSString stringWithFormat:@"Total Cost : %@ INR", [[self.rideInfo objectForKey:@"detail"]objectForKey:@"total_payable_fare"]];
    
    self.driverNameLabel.text = [[self.rideInfo objectForKey:@"rider"] objectForKey:@"name"];
    self.paymentMethodLabel.text = @"Cash";
    self.pickupLocationLabel.text = [self.rideInfo objectForKey:@"pickup_address"];
    self.destinationLabel.text = [self.rideInfo objectForKey:@"destination_address"];

    NSString *bal = @"%7C";
    
    NSString *urlString =[NSString stringWithFormat:@"http://maps.google.com/maps/api/staticmap?size=350x200&maptype=roadmap&markers=size:mid%@color:purple%@label:P%@%f,%f&markers=size:mid%@color:red%@label:D%@%f,%f",bal,bal,bal,[[self.rideInfo objectForKey:@"pickup_latitude"] floatValue],[[self.rideInfo objectForKey:@"pickup_longitude"] floatValue],bal,bal,bal,[[self.rideInfo objectForKey:@"destination_latitude"] floatValue], [[self.rideInfo objectForKey:@"destination_longitude"] floatValue]];
    
    urlString = [urlString stringByAppendingString:@"&key=AIzaSyDh0V-13fNhKpvJaMF-kvfTFEE-tpOZJJk"];

    self.staticMap.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:urlString]]];
    
    
    
    NSString * timeStampString = [[self.rideInfo objectForKey:@"detail"]objectForKey:@"start_time"];
    NSTimeInterval _interval=[timeStampString doubleValue];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:_interval];
    
    
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc]init];
    
    timeFormatter.dateFormat = @"hh:mm a";
 
    NSString *dateString = [timeFormatter stringFromDate: date];
    
    self.pickupTimeLabel.text = dateString;
    
}


- (IBAction)backButtonAction:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}


@end
