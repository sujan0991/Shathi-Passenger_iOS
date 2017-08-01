//
//  EditPrifileViewController.m
//  Shathi
//
//  Created by Sujan on 5/31/17.
//  Copyright © 2017 Sujan. All rights reserved.
//

#import "EditPrifileViewController.h"
#import "HexColors.h"
#import "ServerManager.h"
#import "Constants.h"
#import "EditProfileTableViewCell.h"

#import "NSDictionary+NullReplacement.h"

@interface EditPrifileViewController (){


    NSArray *titleList;
    UIImage *chosenImage;
    
    NSMutableDictionary *userInfo;

}

@end

@implementation EditPrifileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
   
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
    self.profilePicture.layer.borderColor = [[UIColor hx_colorWithHexString:@"#E9E9E9"]CGColor];
    

    self.centerCircleView.layer.cornerRadius = self.centerCircleView.frame.size.width / 2;
    
    
    self.editProfileTableView.delegate = self;
    self.editProfileTableView.dataSource = self;
    
    
    self.editProfileTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.editProfileTableView.frame.size.width, 1)];
    
    
    titleList = [[NSArray alloc] initWithObjects:@"Name",@"Phone",@"Sex",@"Email", nil];
    

}

-(void) drawShadow:(UIView *)view{
    
    
    view.layer.shadowColor = [[UIColor blackColor]CGColor];
    view.layer.shadowOffset = CGSizeMake(0, 4.0);
    view.layer.shadowOpacity = 0.3;
    view.layer.shadowRadius = 5.0;
    
    
}

-(void) getUserInfo{


    [[ServerManager sharedManager] getUserInfoWithCompletion:^(BOOL success, NSMutableDictionary *responseObject) {
        
        
        if ( responseObject!=nil) {
            
            
            
            userInfo= [[NSMutableDictionary alloc] initWithDictionary:[responseObject dictionaryByReplacingNullsWithBlanks]];

            NSLog(@"user info %@",userInfo);
            
            [self.profilePicture sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@",BASE_API_URL,[userInfo objectForKey:@"profile_picture"]]]];

            [self.editProfileTableView reloadData];
            

        }else{
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                NSLog(@"no user info");

               
            });
            
        }
    }];
   

}

#pragma mark - UITableView DataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return titleList.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"EditProfileCell";
    
    EditProfileTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell)
        cell  = [[EditProfileTableViewCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier: CellIdentifier];
    
    
    
    
    cell.titleTextLabel.text =[NSString stringWithFormat:@"%@",[titleList objectAtIndex:indexPath.row]];
    
    
    
    
    cell.userInfoTextField.tag=indexPath.row;
    cell.userInfoTextField.delegate=self;
    
    [cell.userInfoTextField addTarget:self
                 action:@selector(textFieldDidChange:)
                 forControlEvents:UIControlEventEditingChanged];
    
    
     if (indexPath.row == 0) {
        
         NSLog(@"user name %@",[userInfo objectForKey:@"name"]);
        cell.userInfoTextField.text = [NSString stringWithFormat:@"%@",[userInfo objectForKey:@"name"]];
        
    }else if (indexPath.row == 1)
    {
        cell.userInfoTextField.text = [NSString stringWithFormat:@"%@",[userInfo objectForKey:@"phone"]];
        cell.userInfoTextField.userInteractionEnabled = NO;
        
    }else if (indexPath.row == 2)
    {
        
    }else if (indexPath.row == 3)
    {
        
        cell.userInfoTextField.text = [NSString stringWithFormat:@"%@",[userInfo objectForKey:@"email"]];
        

    }
    
    
    
    return cell;
}

#pragma mark - UITableView Delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.row == 0)
    {
        
    }
    
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    
    NSLog(@"end");
    
}
- (IBAction)changePhotoButtonAction:(id)sender {
    
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                         destructiveButtonTitle:nil
                                              otherButtonTitles:NSLocalizedString(@"Open camera", nil),NSLocalizedString(@"Select from Library", nil), nil];
    
    
    
    [sheet showInView:self.view];
    
 }


-(void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
   
        
        if (buttonIndex == 0) {
            
            if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                
                UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                      message:@"Device has no camera"
                                                                     delegate:nil
                                                            cancelButtonTitle:@"OK"
                                                            otherButtonTitles: nil];
                
                [myAlertView show];
                
            }
            else
            {
                

                UIImagePickerControllerSourceType source = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] ? UIImagePickerControllerSourceTypeCamera : UIImagePickerControllerSourceTypeSavedPhotosAlbum;
                UIImagePickerController *cameraController = [[UIImagePickerController alloc] init];
                cameraController.delegate = self;
                cameraController.sourceType = source;
                //cameraController.allowsEditing = YES;
                [self presentViewController:cameraController animated:YES completion:^{
                    //iOS 8 bug.  the status bar will sometimes not be hidden after the camera is displayed, which causes the preview after an image is captured to be black
                    if (source == UIImagePickerControllerSourceTypeCamera) {
                        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
                    }
                }];
            }
        }else if(buttonIndex ==1)
        {
            UIImagePickerControllerSourceType source = UIImagePickerControllerSourceTypePhotoLibrary;
            UIImagePickerController *cameraController = [[UIImagePickerController alloc] init];
            cameraController.delegate = self;
            cameraController.sourceType = source;
            //cameraController.allowsEditing = YES;
            [self presentViewController:cameraController animated:YES completion:^{
                //iOS 8 bug.  the status bar will sometimes not be hidden after the camera is displayed, which causes the preview after an image is captured to be black
                if (source == UIImagePickerControllerSourceTypeCamera) {
                    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
                }
            }];
            
        }

    
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    
    
        chosenImage = info[UIImagePickerControllerOriginalImage];
        self.profilePicture.image=chosenImage;
    
    [picker dismissViewControllerAnimated:NO completion:^{
        
         [self updateProfilePic];
        
    }];
    
 
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    chosenImage=nil;
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}



-(void)updateProfilePic{
    
    //self.profilePicture.image=chosenImage;
    
    [[ServerManager sharedManager] postProfilePicture:chosenImage completion:^(BOOL success) {
        if (success) {
            
            NSLog(@"successfully changed pro pic");
            
        }
        else{
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                
                chosenImage = nil;
                

                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Failed!"
                                                                message:@"Couldnt change the profile pic, please try again"
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles: nil];
                [alert show];
                
            });
        }
        
    }];
    
    
}

- (IBAction)connectWithFBButtonAction:(id)sender {
    
    
}

- (IBAction)doneButtonAction:(id)sender {
    
    NSMutableDictionary* postData=[[NSMutableDictionary alloc] init];
    
    [postData setObject:[userInfo objectForKey:@"name"] forKey:@"name"];
    [postData setObject:[userInfo objectForKey:@"email"] forKey:@"email"];
    //[postData setObject:[userInfo objectForKey:@"phone"] forKey:@"phone"];
    //[postData setObject:[userInfo objectForKey:@"sex"] forKey:@"sex"];

    NSLog(@"post data %@",postData);
    
    [[ServerManager sharedManager] updateUserDetailsWithData:postData withCompletion:^(BOOL success) {
        

        if (success) {
            
            NSLog(@"successfully");
            
        }
        else{
            
            dispatch_async(dispatch_get_main_queue(), ^{
                

                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Failed!"
                                                                message:@"Please try again"
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles: nil];
                [alert show];
                
            });
        }
        
    }];
    
}

- (IBAction)backButtonAction:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];

}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];

    return YES;
}

- (void)textFieldDidChange:(UITextField*)textField
{
    NSString *keyName;
    
    switch (textField.tag) {
        case 0:
            keyName=@"name";
            break;
        case 1:
            keyName=@"phone";
            break;
        case 2:
            keyName=@"sex";
            break;
        case 3:
            keyName=@"email";
            break;
   
        default:
            keyName=@"Default";
            
            break;
    }
    
    [userInfo setObject:textField.text forKey:keyName];
    //NSLog(@"text %@",textField.text);
}



@end
