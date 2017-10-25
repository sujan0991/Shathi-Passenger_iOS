//
//  SettingViewController.m
//  Shathi
//
//  Created by Sujan on 5/24/17.
//  Copyright © 2017 Sujan. All rights reserved.
//

#import "SettingViewController.h"
#import <AccountKit/AccountKit.h>
#import "LandingViewController.h"
#import "EditPrifileViewController.h"
#import "PromotionsViewController.h"
#import "UserAccount.h"
#import "ServerManager.h"
#import "NSDictionary+NullReplacement.h"
#import "Constants.h"
#import "RideHistoryViewController.h"


@interface SettingViewController (){

    AKFAccountKit *accountKit;
    
    NSArray *settingList;
    NSArray *imageArray;

    NSDictionary * userInfo;
}

@end

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];


    if (accountKit == nil) {
        accountKit = [[AKFAccountKit alloc] initWithResponseType:AKFResponseTypeAccessToken];
    }
    [self setUpView];
    [self drawShadow:self.navView];
    
    [self getUserInfo];

}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) setUpView{



    self.profilePicture.layer.cornerRadius = self.profilePicture.frame.size.width / 2;
    self.profilePicture.clipsToBounds = YES;
    self.profilePicture.layer.borderWidth = 5.0f;
    self.profilePicture.layer.borderColor = [[UIColor whiteColor]CGColor];
    
    self.editProfileButton.layer.cornerRadius = self.editProfileButton.frame.size.width / 2;
    

    self.settingTableView.delegate = self;
    self.settingTableView.dataSource = self;
    
    
    settingList = [[NSArray alloc] initWithObjects:@"Free Rides",@"Payment",@"Promotions",@"Language",@"Support",@"History",@"About",@"Logout", nil];
    
    UIImage *image1 = [UIImage imageNamed:@"free_ride"];
    UIImage *image2 = [UIImage imageNamed:@"Payment"];
    UIImage *image3 = [UIImage imageNamed:@"Promotions"];
    UIImage *image4 = [UIImage imageNamed:@"Language"];
    UIImage *image5 = [UIImage imageNamed:@"Support"];
    UIImage *image6 = [UIImage imageNamed:@"History"];
    UIImage *image7 = [UIImage imageNamed:@"about"];
    UIImage *image8 = [UIImage imageNamed:@"logout"];

    imageArray = [[NSArray alloc] initWithObjects:image1,image2,image3,image4,image5,image6,image7,image8, nil];


}

-(void) drawShadow:(UIView *)view{
    
    
    view.layer.shadowColor = [[UIColor blackColor]CGColor];
    view.layer.shadowOffset = CGSizeMake(0, 4.0);
    view.layer.shadowOpacity = 0.3;
    view.layer.shadowRadius = 5.0;
    
    
}


#pragma mark - UITableView DataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return settingList.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SettingfCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell)
        cell  = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier: CellIdentifier];
    
    
    UIImageView *settingIcon = (UIImageView*) [cell viewWithTag:1];
    
    settingIcon.image=[imageArray objectAtIndex:indexPath.row];
    
    
    UILabel *settingOption= (UILabel*) [cell viewWithTag:2];
    
    
    settingOption.text =[NSString stringWithFormat:@"%@",[settingList objectAtIndex:indexPath.row]];
    
    
    
    return cell;
}

#pragma mark - UITableView Delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    if (indexPath.row == 0)
    {
        
        
    }else if (indexPath.row ==2)
    {
        PromotionsViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"PromotionsViewController"];
        
        [self presentViewController:vc animated:YES completion:nil];
        
    }else if (indexPath.row ==5)
    {
        RideHistoryViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"RideHistoryViewController"];
        
       [self.navigationController pushViewController:vc animated:YES];
        
    }else if (indexPath.row ==7)
    {
    
        [[ServerManager sharedManager] postLogOutWithCompletion:^(BOOL success, NSMutableDictionary *resultDataDictionary) {
            
            if (resultDataDictionary!=nil) {
                
                [accountKit logOut];
                
                
                [UserAccount sharedManager].accessToken= @"" ;
                
                [self.navigationController popToRootViewControllerAnimated:YES];
                
                
            }else{
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    NSLog(@"no user info");
                    
                    
                });
                
            }
            
        }];
        
      
        

    
    }
    
}

-(void) getUserInfo{
    
    
    [[ServerManager sharedManager] getUserInfoWithCompletion:^(BOOL success, NSMutableDictionary *responseObject) {
        
        
        if ( responseObject!=nil) {
            
            
            
            userInfo= [[NSMutableDictionary alloc] initWithDictionary:[responseObject dictionaryByReplacingNullsWithBlanks]];
            
            NSLog(@"user info %@",userInfo);
            
            [self.profilePicture sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@",BASE_API_URL,[userInfo objectForKey:@"profile_picture"]]]];
            self.userNameLabel.text = [NSString stringWithFormat:@"%@",[userInfo objectForKey:@"name"]];
            self.phoneNoLabel.text = [NSString stringWithFormat:@"%@",[userInfo objectForKey:@"phone"]];
           
            
            
        }else{
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                NSLog(@"no user info");
                
                
            });
            
        }
    }];
    
    
}


- (IBAction)editProfileAction:(id)sender {
    
    
    EditPrifileViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"EditPrifileViewController"];
    
    vc.userInfo = userInfo;
    
    [self.navigationController pushViewController:vc animated:YES];
    
}

- (IBAction)backButtonAction:(id)sender {
    
     [self.navigationController popViewControllerAnimated:YES];
    
}

@end
