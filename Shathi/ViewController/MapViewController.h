//
//  MapViewController.h
//  Shathi
//
//  Created by Sujan on 5/16/17.
//  Copyright © 2017 Sujan. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <GoogleMaps/GoogleMaps.h>
#import <CoreLocation/CoreLocation.h>
#import <GooglePlaces/GooglePlaces.h>
#import "RateView.h"
#import "SearchLocationViewController.h"

@interface MapViewController : UIViewController<CLLocationManagerDelegate, UITableViewDataSource,UITableViewDelegate,GMSMapViewDelegate,GMSAutocompleteFetcherDelegate,UITextFieldDelegate,UITextViewDelegate,RateViewDelegate,SendDataBackDelegate>




@property (weak, nonatomic) IBOutlet GMSMapView *googleMapView;
@property (weak, nonatomic) IBOutlet UIView *navView;

@property (weak, nonatomic) IBOutlet UIImageView *staticPin;

@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIButton *settingButton;


@property (weak, nonatomic) IBOutlet UIView *locationView;
@property (weak, nonatomic) IBOutlet UIButton *whereToButton;
@property (weak, nonatomic) IBOutlet UITableView *searchLocationTableView;
@property (weak, nonatomic) IBOutlet UITextField *pickUpTextView;
@property (weak, nonatomic) IBOutlet UITextField *destinationTextView;

@property (weak, nonatomic) IBOutlet UIButton *crossButtonInPicupTextField;
@property (weak, nonatomic) IBOutlet UIButton *crossButtonInDestinationTextField;


@property (weak, nonatomic) IBOutlet UIButton *setPinPointButton;
@property (weak, nonatomic) IBOutlet UIButton *setPinPointDoneButton;

@property (weak, nonatomic) IBOutlet UIView *locationServiceView;
@property (weak, nonatomic) IBOutlet UIButton *tuenOnLocationButton;
@property (weak, nonatomic) IBOutlet UIButton *enterPicupButton;

@property (weak, nonatomic) IBOutlet UIView *fareView;
@property (weak, nonatomic) IBOutlet UILabel *estimatedTimeLabel;
@property (weak, nonatomic) IBOutlet UIButton *requestRideButton;
@property (weak, nonatomic) IBOutlet UILabel *fareLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@property (weak, nonatomic) IBOutlet UIView *driverSuggestionView;
@property (weak, nonatomic) IBOutlet UILabel *bikeNoLabel;
@property (weak, nonatomic) IBOutlet UILabel *bikeModelLabel;
@property (weak, nonatomic) IBOutlet UILabel *driverNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *driverPhoto;
@property (weak, nonatomic) IBOutlet UIButton *cancelButtonInDriverSuggestionView;
@property (weak, nonatomic) IBOutlet UILabel *ratingInDriverSuggestionView;
@property (weak, nonatomic) IBOutlet UIButton *phoneButtonInDriverSuggestionView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cancelButtonHeight;
@property (weak, nonatomic) IBOutlet UILabel *estimatedTimeLabelInDriverView;
@property (weak, nonatomic) IBOutlet UILabel *timeLabelInDriverView;


@property (weak, nonatomic) IBOutlet UIView *submitFareView;
@property (weak, nonatomic) IBOutlet UIImageView *driverPhotoInSubmitFareView;
@property (weak, nonatomic) IBOutlet UILabel *driverNameLabelInSubmitFareView;
@property (weak, nonatomic) IBOutlet UILabel *bikeModelLabelInSubmitFareView;
@property (weak, nonatomic) IBOutlet RateView *rateView;
@property (weak, nonatomic) IBOutlet UILabel *rideCostLabel;
@property (weak, nonatomic) IBOutlet UIButton *submitButton;
@property (weak, nonatomic) IBOutlet UILabel *ratingLabelInSubmitFareView;



//@property (weak, nonatomic) IBOutlet UIView *timewView;
@property (weak, nonatomic) IBOutlet UIView *timerSupewView;

@property (weak, nonatomic) IBOutlet UIView *cancelReasonView;
@property (weak, nonatomic) IBOutlet UITableView *cancelReasonTableView;
@property (weak, nonatomic) IBOutlet UITextView *cancelReasonTextView;
@property (weak, nonatomic) IBOutlet UIButton *cancelReasonSubmitButton;
@property (weak, nonatomic) IBOutlet UILabel *otherReasonLabel;
@property (weak, nonatomic) IBOutlet UIView *shadeView;
@property (weak, nonatomic) IBOutlet UIView *otherReasonsView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cancelReasonViewCenterConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *otherReasonsBottomConstraint;






@end
