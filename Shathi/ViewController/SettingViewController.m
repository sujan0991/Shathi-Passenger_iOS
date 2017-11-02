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
#import "JTMaterialSpinner.h"
#import "SetHomeAndWorkViewController.h"


@interface SettingViewController (){

    JTMaterialSpinner *spinner;
    
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
    
    spinner=[[JTMaterialSpinner alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2 - 17, self.view.frame.size.height/2 - 17, 35, 35)];
    [self.view bringSubviewToFront:spinner];
    [self.view addSubview:spinner];
    spinner.hidden =YES;
    
    

}

-(void) viewWillAppear:(BOOL)animated{
    
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
    
    
//    settingList = [[NSArray alloc] initWithObjects:@"Free Rides",@"Payment",@"Promotions",@"Language",@"Support",@"History",@"About",@"Logout", nil];
    
    settingList = [[NSArray alloc] initWithObjects:@"Language",@"History",@"About",@"Logout", nil];
    
//    UIImage *image1 = [UIImage imageNamed:@"free_ride"];
//    UIImage *image2 = [UIImage imageNamed:@"Payment"];
//    UIImage *image3 = [UIImage imageNamed:@"Promotions"];
    UIImage *image4 = [UIImage imageNamed:@"Language"];
   // UIImage *image5 = [UIImage imageNamed:@"Support"];
    UIImage *image6 = [UIImage imageNamed:@"History"];
    UIImage *image7 = [UIImage imageNamed:@"about"];
    UIImage *image8 = [UIImage imageNamed:@"logout"];

    //imageArray = [[NSArray alloc] initWithObjects:image1,image2,image3,image4,image5,image6,image7,image8, nil];
    imageArray = [[NSArray alloc] initWithObjects:image4,image6,image7,image8, nil];


}

-(void) drawShadow:(UIView *)view{
    
    
    view.layer.shadowColor = [[UIColor blackColor]CGColor];
    view.layer.shadowOffset = CGSizeMake(0, 4.0);
    view.layer.shadowOpacity = 0.3;
    view.layer.shadowRadius = 5.0;
    
    
}





#pragma mark - UITableView DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 3;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        
        return 1;
        
    }else if (section == 1) {
        
        return 1;
        
    }else
        
        return settingList.count;
        
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 2) {
        
        UIView *firstView = [[UIView  alloc] init];
        
        firstView.backgroundColor =[UIColor lightGrayColor];
        
        return firstView;
        
    }else{
        
        UIView *othersView = [[UIView  alloc] init];
        othersView.backgroundColor =[UIColor lightGrayColor];
        
        
        UILabel *headerLabel = [[UILabel alloc]initWithFrame:CGRectMake(30, 0, 300, 20)];
        //headerLabel.font = [UIFont fontWithName:@"AzoSans-Regular" size:12];
        headerLabel.numberOfLines = 1;
        headerLabel.baselineAdjustment = UIBaselineAdjustmentAlignBaselines; // or UIBaselineAdjustmentAlignCenters, or UIBaselineAdjustmentNone
        headerLabel.adjustsFontSizeToFitWidth = YES;
        headerLabel.adjustsLetterSpacingToFitWidth = YES;
        headerLabel.textColor = [UIColor blackColor];
        
        if (section == 0) {
            
            headerLabel.text = @"Home";
            headerLabel.font = [UIFont systemFontOfSize:13.0];
            
        }else if (section == 1){
            
            headerLabel.text = @"Work";
            headerLabel.font = [UIFont systemFontOfSize:13.0];
            
        }
        
        [othersView addSubview:headerLabel];
        
        return othersView;
        
    }
    
    return nil;
    
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SettingfCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell)
        cell  = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier: CellIdentifier];
    
    
    UIImageView *settingIcon = (UIImageView*) [cell viewWithTag:1];
    
    if (indexPath.section == 0)
    {
        
    }else if (indexPath.section == 1){
        
        
    }else{
        
       settingIcon.image=[imageArray objectAtIndex:indexPath.row];
    }
    
    UILabel *settingOption= (UILabel*) [cell viewWithTag:2];
    
    if (indexPath.section == 0)
    {
        NSString *homeAddress=[NSString stringWithFormat:@"%@",[[userInfo objectForKey:@"metadata"]objectForKey:@"home_address_title"]];
        settingOption.text =[ [userInfo objectForKey:@"metadata"]objectForKey:@"home_address_title"]? homeAddress : @"Home address"  ;
        
    }else if (indexPath.section == 1){
        
        NSString *workAddress=[NSString stringWithFormat:@"%@",[[userInfo objectForKey:@"metadata"]objectForKey:@"work_address_title"]];
        settingOption.text =[ [userInfo objectForKey:@"metadata"]objectForKey:@"work_address_title"]? workAddress : @"Work address"  ;
        
    }else{
        
        settingOption.text =[NSString stringWithFormat:@"%@",[settingList objectAtIndex:indexPath.row]];
        
    }
    
    
    
    return cell;
}

#pragma mark - UITableView Delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    if (indexPath.section == 0)
    {
        
        SetHomeAndWorkViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"SetHomeAndWorkViewController"];
        
        vc.isSaveHomeAddress = 1;
        
        [self.navigationController pushViewController:vc animated:YES];
        
    }else if (indexPath.section == 1){
        
        SetHomeAndWorkViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"SetHomeAndWorkViewController"];
        
        vc.isSaveHomeAddress = 0;
        
        [self.navigationController pushViewController:vc animated:YES];
        
    }else{
        
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
    
    
    
}

-(void) getUserInfo{
    
    spinner.hidden =NO;
    [spinner beginRefreshing];
    
    [[ServerManager sharedManager] getUserInfoWithCompletion:^(BOOL success, NSMutableDictionary *responseObject) {
        
        
        if ( responseObject!=nil) {
            
            spinner.hidden =YES;
            [spinner endRefreshing];
            
            userInfo= [[NSMutableDictionary alloc] initWithDictionary:[responseObject dictionaryByReplacingNullsWithBlanks]];
            
            NSLog(@"user info %@",userInfo);
            
            [self.profilePicture sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@",BASE_API_URL,[userInfo objectForKey:@"profile_picture"]]]];
            self.userNameLabel.text = [NSString stringWithFormat:@"%@",[userInfo objectForKey:@"name"]];
            self.phoneNoLabel.text = [NSString stringWithFormat:@"%@",[userInfo objectForKey:@"phone"]];
           
            [self.settingTableView reloadData];
            
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
