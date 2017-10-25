//
//  DetailHistoryViewController.m
//  Shathi
//
//  Created by Sujan on 8/20/17.
//  Copyright © 2017 Sujan. All rights reserved.
//

#import "DetailHistoryViewController.h"
#import "ServerManager.h"
#import "JTMaterialSpinner.h"

@interface DetailHistoryViewController (){
    
    JTMaterialSpinner *spinner;
    
    NSMutableDictionary *singleRide;
}

@end

@implementation DetailHistoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    spinner=[[JTMaterialSpinner alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2 - 17, self.view.frame.size.height/2 - 17, 35, 35)];
    [self.view bringSubviewToFront:spinner];
    [self.view addSubview:spinner];
    spinner.hidden =YES;
    
    
     [self apiCallFroHistory];
    
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)apiCallFroHistory{
    
    spinner.hidden =NO;
    [spinner beginRefreshing];
    
    NSDictionary *parms = [[NSMutableDictionary alloc]init];
    
    [parms setValue:self.rideId forKey:@"ride_id"];
    
    [[ServerManager sharedManager] getSingleHistoryInfo:parms    WithCompletion:^(BOOL success, NSMutableDictionary *responseObject) {
        
        
        if ( responseObject!=nil) {
            
           
            
            singleRide = [responseObject objectForKey:@"data"];
            
            
             [self viewSetup];
            
            spinner.hidden =YES;
            [spinner endRefreshing];
            
            
        }else{
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                NSLog(@"no user info");
                
                spinner.hidden =YES;
                [spinner endRefreshing];
                
                
            });
            
        }
    }];
    
}

-(void)viewSetup{

    self.costLabel.text =[NSString stringWithFormat:@"Total Cost : %@ INR", [[singleRide objectForKey:@"detail"]objectForKey:@"total_payable_fare"]];

    self.driverNameLabel.text = [[singleRide objectForKey:@"rider"] objectForKey:@"name"];
    self.paymentMethodLabel.text = @"Cash";
    self.pickupLocationLabel.text = [singleRide objectForKey:@"pickup_address"];
    self.destinationLabel.text = [singleRide objectForKey:@"destination_address"];

    NSString *bal = @"%7C";

    NSString *urlString =[NSString stringWithFormat:@"http://maps.google.com/maps/api/staticmap?size=350x200&maptype=roadmap&markers=size:mid%@color:purple%@label:P%@%f,%f&markers=size:mid%@color:red%@label:D%@%f,%f",bal,bal,bal,[[singleRide objectForKey:@"pickup_latitude"] floatValue],[[singleRide objectForKey:@"pickup_longitude"] floatValue],bal,bal,bal,[[singleRide objectForKey:@"destination_latitude"] floatValue], [[singleRide objectForKey:@"destination_longitude"] floatValue]];

    urlString = [urlString stringByAppendingString:@"&key=AIzaSyDh0V-13fNhKpvJaMF-kvfTFEE-tpOZJJk"];

    self.staticMap.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:urlString]]];



    NSString * timeStampString = [[singleRide objectForKey:@"detail"]objectForKey:@"start_time"];
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
