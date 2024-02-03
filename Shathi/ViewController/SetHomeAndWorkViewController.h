//
//  SetHomeAndWorkViewController.h
//  Shathi
//
//  Created by Sujan on 10/29/17.
//  Copyright © 2017 Sujan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleMaps/GoogleMaps.h>
#import <CoreLocation/CoreLocation.h>
#import <GooglePlaces/GooglePlaces.h>


@interface SetHomeAndWorkViewController : UIViewController<CLLocationManagerDelegate,GMSMapViewDelegate,GMSAutocompleteFetcherDelegate,UITextFieldDelegate,UITableViewDataSource,UITableViewDelegate>


@property (weak, nonatomic) IBOutlet GMSMapView *googleMapView;

@property (weak, nonatomic) IBOutlet UIImageView *staticPin;
@property (weak, nonatomic) IBOutlet UITableView *searchLocationTableView;
@property (weak, nonatomic) IBOutlet UITextField *locationTextField;
@property (weak, nonatomic) IBOutlet UIButton *crossButton;

@property (weak, nonatomic) IBOutlet UIButton *doneButton;

@property BOOL isSaveHomeAddress;

@end
