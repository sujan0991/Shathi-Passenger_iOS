//
//  EditPrifileViewController.h
//  Shathi
//
//  Created by Sujan on 5/31/17.
//  Copyright © 2017 Sujan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImageView+WebCache.h"



@interface EditPrifileViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,UIActionSheetDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate,UITextFieldDelegate,SDWebImageManagerDelegate>

@property (weak, nonatomic) IBOutlet UIView *navView;

@property (weak, nonatomic) IBOutlet UIImageView *profilePicture;

@property (weak, nonatomic) IBOutlet UIButton *changePhotoButton;

@property (weak, nonatomic) IBOutlet UIView *centerCircleView;

@property (weak, nonatomic) IBOutlet UITableView *editProfileTableView;

@property (weak, nonatomic) IBOutlet UIButton *connectWithFbButton;

@property (weak, nonatomic) IBOutlet UIButton *doneButton;









@end
