//
//  LandingViewController.m
//  Shathi
//
//  Created by Sujan on 5/15/17.
//  Copyright © 2017 Sujan. All rights reserved.
//

#import "LandingViewController.h"
#import <AccountKit/AccountKit.h>
#import "MapViewController.h"
#import "ServerManager.h"
#import "UserAccount.h"
#import "AppDelegate.h"


@interface LandingViewController () <AKFViewControllerDelegate>

@end

@implementation LandingViewController{

    AKFAccountKit *_accountKit;
    NSString *_authorizationCode;

    
    UIViewController<AKFViewController> *_pendingLoginViewController;
    BOOL _showAccountOnAppear;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
 

}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSLog(@"navigationController %@",self.navigationController);
    
    NSLog(@"[[UserAccount sharedManager]accesstoken]  %@",[UserAccount sharedManager].accessToken);
    
    if ([[UserAccount sharedManager]accessToken].length) {
        
//        AppDelegate *appDelegateTemp = [[UIApplication sharedApplication]delegate];
//        
//        [appDelegateTemp askForNotificationPermission];
        
        MapViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"MapViewController"];
        
        [self.navigationController pushViewController:vc animated:YES];
        
    }
    
    else{
        
        //FB Account kit
        
        _accountKit = nil;
        
        if (_accountKit == nil) {
            
            NSLog(@"fb kit");
            
            _accountKit = [[AKFAccountKit alloc] initWithResponseType:AKFResponseTypeAccessToken];
            
            UIViewController<AKFViewController> *viewController = [_accountKit viewControllerForPhoneLoginWithPhoneNumber:nil
                                                                                                                    state:nil];
            [self _prepareLoginViewController:viewController];
            [self presentViewController:viewController animated:YES completion:NULL];
            
            _showAccountOnAppear = (_accountKit.currentAccessToken != nil);
            _pendingLoginViewController = [_accountKit viewControllerForLoginResume];
            
        }
        
    }
    
    
   
}

- (void)viewDidAppear:(BOOL)animated
{
    
    NSLog(@"viewdid");
    
    if (_showAccountOnAppear) {
        _showAccountOnAppear = NO;
        //[self _presentWithSegueIdentifier:@"showAccount" animated:animated];
        
        
    } else if (_pendingLoginViewController != nil) {
        [self _prepareLoginViewController:_pendingLoginViewController];
        [self presentViewController:_pendingLoginViewController animated:animated completion:NULL];
        _pendingLoginViewController = nil;
    }
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)LoginWithMobileButtonAction:(id)sender {
    
}

#pragma mark - AKFViewControllerDelegate;

- (void)viewController:(UIViewController<AKFViewController> *)viewController didCompleteLoginWithAccessToken:(id<AKFAccessToken>)accessToken state:(NSString *)state
{
    
    NSLog(@"complete with access token: %@",accessToken.tokenString);
    
    [UserAccount sharedManager].accessToken =accessToken.tokenString;
    
    [self userLogin:accessToken.tokenString];
    
}

- (void)viewController:(UIViewController<AKFViewController> *)viewController didFailWithError:(NSError *)error
{
    NSLog(@"%@ did fail with error: %@", viewController, error);
}


-(void)userLogin:(NSString*)accessToken{


    [_accountKit requestAccount:^(id<AKFAccount> account, NSError *error) {
        

        if (error != nil) {
            
            NSLog(@"error error %@",[error description]);
            
        }
        else if (account.accountID !=nil){
            
//            AppDelegate *appDelegateTemp = [[UIApplication sharedApplication]delegate];
//            
//            [appDelegateTemp askForNotificationPermission];
            
            [[ServerManager sharedManager] postLoginWithPhone:[account.phoneNumber stringRepresentation] accessToken:accessToken completion:^(BOOL success) {
                
               
                
                
                
                MapViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"MapViewController"];
                
                [self.navigationController pushViewController:vc animated:YES];
                
               // NSLog(@"access token from api %@",[[UserAccount sharedManager]accessToken]);
                

            }];
            
            NSLog(@"account.accountID  %@", account.accountID);
            
            
            
            if ([account phoneNumber] != nil) {
                
                NSLog(@"account.phone  %@",[account.phoneNumber stringRepresentation]);
                
                 [UserAccount sharedManager].phoneNumber = [account.phoneNumber stringRepresentation];
            }
        }
    }];




}

#pragma mark - Helper Methods

- (void)_prepareLoginViewController:(UIViewController<AKFViewController> *)loginViewController
{
    
    
    loginViewController.delegate = self;
    
    loginViewController.theme=[self customTheme];
    
    loginViewController.defaultCountryCode = @"BD";
    
}

- (AKFTheme *)customTheme
{
    AKFTheme *theme = [AKFTheme outlineThemeWithPrimaryColor:[self _colorWithHex:0x262C4E]
                                            primaryTextColor:[UIColor whiteColor]
                                          secondaryTextColor:[UIColor whiteColor]
                                              statusBarStyle:UIStatusBarStyleBlackOpaque];
    
    theme.backgroundImage = [UIImage imageNamed:@"OYE-Logo"];
    theme.backgroundColor = [self _colorWithHex:0x262C4E];
    theme.inputBackgroundColor = [self _colorWithHex:0x081029];
    theme.inputBorderColor = [UIColor whiteColor];
    theme.buttonBackgroundColor = [self _colorWithHex:0x081029];
    theme.buttonDisabledBackgroundColor = [self _colorWithHex:0x081029];
    theme.headerBackgroundColor = [UIColor blackColor];
    
    
    return theme;
}

- (UIColor *)_colorWithHex:(NSUInteger)hex
{
    CGFloat alpha = ((CGFloat)((hex & 0xff000000) >> 24)) / 255.0;
    CGFloat red = ((CGFloat)((hex & 0x00ff0000) >> 16)) / 255.0;
    CGFloat green = ((CGFloat)((hex & 0x0000ff00) >> 8)) / 255.0;
    CGFloat blue = ((CGFloat)((hex & 0x000000ff) >> 0)) / 255.0;
    return [UIColor colorWithRed:red green:green blue:blue alpha:0.95];
}

@end
