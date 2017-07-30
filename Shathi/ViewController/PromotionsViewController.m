//
//  PromotionsViewController.m
//  Shathi
//
//  Created by Sujan on 6/8/17.
//  Copyright © 2017 Sujan. All rights reserved.
//

#import "PromotionsViewController.h"

@interface PromotionsViewController ()

@end

@implementation PromotionsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setUpView];
    [self drawShadow:self.navView];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) drawShadow:(UIView *)view{
    
    
    view.layer.shadowColor = [[UIColor blackColor]CGColor];
    view.layer.shadowOffset = CGSizeMake(0, 4.0);
    view.layer.shadowOpacity = 0.3;
    view.layer.shadowRadius = 5.0;
    
    
}

-(void) setUpView{
    
    self.promoTextField.delegate = self;
    
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    
    return YES;
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    
    [self.promoTextField resignFirstResponder];
    
}

- (IBAction)applyCodeButtonAction:(id)sender {
    
}

- (IBAction)inviteFriendButtonAction:(id)sender {
    
    
}


- (IBAction)crossButtonAction:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
