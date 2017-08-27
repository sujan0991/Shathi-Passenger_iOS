//
//  RideHistoryViewController.m
//  Shathi
//
//  Created by Sujan on 8/20/17.
//  Copyright © 2017 Sujan. All rights reserved.
//

#import "RideHistoryViewController.h"
#import "ServerManager.h"
#import "RideHistoryTableViewCell.h"
#import "NSDictionary+NullReplacement.h"
#import "DetailHistoryViewController.h"

@interface RideHistoryViewController (){

    NSMutableArray *historyArray;
    NSMutableArray *mapArray;

}

@end

@implementation RideHistoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.historyTableView.delegate = self;
    self.historyTableView.dataSource = self;
    
    [self apiCallForHistory];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) apiCallForHistory{
    
    
    [[ServerManager sharedManager] getHistoryInfoWithCompletion:^(BOOL success, NSMutableDictionary *responseObject) {
        
        
        if ( responseObject!=nil) {
            
            
            NSMutableDictionary *userInfo;
            
            userInfo= [[NSMutableDictionary alloc] initWithDictionary:[responseObject dictionaryByReplacingNullsWithBlanks]];
            
            historyArray = [[NSMutableArray alloc]init];
            
            historyArray = [userInfo objectForKey:@"data"];
            
            [self callStaticMapApi];
            
            [self.historyTableView reloadData];
            
        }else{
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                NSLog(@"no user info");
                
                
            });
            
        }
    }];
    
    
}

-(void)callStaticMapApi{
    
    NSMutableDictionary * singleRide = [[NSMutableDictionary alloc]init];
    
    mapArray = [[NSMutableArray alloc]init];
    
    for (int i = 0; i<historyArray.count; i++) {
        
        singleRide = [historyArray objectAtIndex:i];
        
        NSString *bal = @"%7C";
        
        NSString *urlString =[NSString stringWithFormat:@"http://maps.google.com/maps/api/staticmap?size=350x200&maptype=roadmap&markers=size:mid%@color:purple%@label:P%@%f,%f&markers=size:mid%@color:red%@label:D%@%f,%f",bal,bal,bal,[[singleRide objectForKey:@"pickup_latitude"] floatValue],[[singleRide objectForKey:@"pickup_longitude"] floatValue],bal,bal,bal,[[singleRide objectForKey:@"destination_latitude"] floatValue], [[singleRide objectForKey:@"destination_longitude"] floatValue]];
        
        urlString = [urlString stringByAppendingString:@"&key=AIzaSyDh0V-13fNhKpvJaMF-kvfTFEE-tpOZJJk"];
        
        
        
        [mapArray addObject:urlString];
    }
    
    NSLog(@"mapArray %@",mapArray);
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return historyArray.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 15;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *header = [[UIView alloc]init];
    header.backgroundColor = [UIColor clearColor];
    return header;
    
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"historyCell";
    
    RideHistoryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell)
        cell  = [[RideHistoryTableViewCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier: CellIdentifier];
    
    NSString *mapUrl =[NSString stringWithFormat:@"%@",[mapArray objectAtIndex:indexPath.section]];
    
    NSLog(@"static map url  %@",mapUrl);
    
    cell.rideStaticMap.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:mapUrl]]];
    
    
    return cell;
}

#pragma mark - UITableView Delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    DetailHistoryViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"DetailHistoryViewController"];
    
    NSMutableDictionary *singleRide = [[NSMutableDictionary alloc]init];
    
    singleRide = [historyArray objectAtIndex:indexPath.section];
    
    vc.rideInfo = singleRide;
    
    //NSLog(@"single ride  %@",singleRide);
    
    [self.navigationController pushViewController:vc animated:YES];
    
    
}

- (IBAction)backButtonAction:(id)sender {
    
     [self.navigationController popViewControllerAnimated:YES];
}


@end
