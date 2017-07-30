//
//  PromotionsViewController.h
//  Shathi
//
//  Created by Sujan on 6/8/17.
//  Copyright © 2017 Sujan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PromotionsViewController : UIViewController<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIView *navView;

@property (weak, nonatomic) IBOutlet UITextField *promoTextField;
@property (weak, nonatomic) IBOutlet UIButton *applyCodeButton;
@property (weak, nonatomic) IBOutlet UIButton *inviteFriendButton;

@end
