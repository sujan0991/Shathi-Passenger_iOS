//
//  SearchLocationViewController.h
//  Shathi
//
//  Created by Sujan on 11/8/17.
//  Copyright © 2017 Sujan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GooglePlaces/GooglePlaces.h>

@protocol SendDataBackDelegate <NSObject>

-(void)dataFromSearchLocation:(NSMutableDictionary *)backDataDic;

@end

@interface SearchLocationViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,GMSAutocompleteFetcherDelegate,UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *searchTextField;
@property (weak, nonatomic) IBOutlet UIButton *crossButton;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UITableView *searchLocationTableView;

@property (nonatomic,strong) NSDictionary * userInfo;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewHeight;

@property(nonatomic,assign)id <SendDataBackDelegate>dataBackDelegate;



@end
