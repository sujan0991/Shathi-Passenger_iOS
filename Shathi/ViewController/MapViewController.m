//
//  MapViewController.m
//  Shathi
//
//  Created by Sujan on 5/16/17.
//  Copyright © 2017 Sujan. All rights reserved.
//

#import "MapViewController.h"
#import <AccountKit/AccountKit.h>
#import "SettingViewController.h"
#import "HexColors.h"
#import "UIView+SimpleRipple.h"
#import "ServerManager.h"
#import "NSDictionary+NullReplacement.h"
#import "UserAccount.h"
#import "CancelReasonTableViewCell.h"
#import "SearchLocationViewController.h"




@interface MapViewController (){

    AKFAccountKit *_accountKit;
    
    CLLocationManager *locationManager;

    CLLocationCoordinate2D currentLocation;
    
    //CLLocationCoordinate2D googleMarkerLocation;
    
    CLLocationCoordinate2D googleSearchLocation;
    
    
    CLLocation *pickupPoint ;
    CLLocation *destinationPoint;
    
    GMSAutocompleteFetcher *fetcher;
    
    NSMutableArray *searchResults;
    NSMutableArray *searchResultsPlaceId;
    NSMutableArray *cancelReasonArray;
    NSMutableDictionary *rideInfo;
    
   // NSMutableDictionary*riderInfo;
    
    NSMutableArray *homeWorkArray;
    

    
    BOOL isUpdateCameraPosition;
    BOOL isPolyLineBlue;
    BOOL isCalculateFare;
    BOOL isEditPictupText;
    BOOL isSaveHomeAddress;
    BOOL isSaveWorkAddress;
    BOOL isComeFromBackground;

    NSString* cancelReasonId;
    NSString* rideId;
    
    GMSMarker *pickUpMarker;
    GMSMarker *destinationMarker;
    
    float totalRating;
    
    float estimatedTime;
    float totalDistance;
    
    NSString *phoneNo;
    
    NSTimer *countDown;
    NSTimer* timerForRiderPosition;
    int riderId;
    
    GMSPolyline *ridePolyline;
    GMSPolyline *driverPolyline;
    GMSPolyline *polylineGray;
    int i;
    GMSMutablePath *path2;
    NSMutableArray *arrayPolylineGray;
    NSTimer *animationTimer;
    
    GMSMarker *riderMarker;
    
   
    
}


@property (nonatomic, strong) NSDate *endTime;



@end




@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    arrayPolylineGray = [[NSMutableArray alloc] init];
    path2 = [[GMSMutablePath alloc]init];
    i = 0;
    
    //[self timer];
    
    [[NSNotificationCenter defaultCenter ]addObserver:self selector:@selector(rideInfo:) name:@"rideNotification" object:nil];
    [[NSNotificationCenter defaultCenter ]addObserver:self selector:@selector(appBecomeActive:) name:@"becomeActiveNotification" object:nil];
    
    isUpdateCameraPosition = 1;
    isPolyLineBlue = 1;
    isCalculateFare = 1;
    isComeFromBackground = 0;
    
    [self checkLocationService];
    
    [self firstViewSetUp];
    [self drawShadow:self.navView];
    [self drawShadow:self.whereToButton];
    [self drawShadow:self.locationView];
    
   
    [self setMap];
    [self setGooglePlacefetcher];
    
    //[self getUserInfo];
    
    homeWorkArray = [[NSMutableArray alloc]init];
    rideInfo = [[NSMutableDictionary alloc]init];
    

    
   
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{

    if ([UserAccount sharedManager].userStatus == 1) {
        
        NSMutableDictionary* dataDic=[[NSMutableDictionary alloc] init];
        
        
        
        [dataDic setObject:[NSString stringWithFormat:@"%f", currentLocation.latitude] forKey:@"current_latitude"];
        [dataDic setObject:[NSString stringWithFormat:@"%f", currentLocation.longitude] forKey:@"current_longitude"];
        
        NSLog(@"dataDic %@",dataDic);

        
        [[ServerManager sharedManager] getAvailableRider:dataDic WithCompletion :^(BOOL success, NSMutableDictionary *responseObject) {
            
            
            if ( responseObject!=nil) {
                
                NSLog(@"available rider  %@",responseObject);
                
                
            }else{
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    NSLog(@"no user info");
                    
                    
                });
                
            }
        }];
        
    }
    
}


-(void)checkLocationService{


    if([CLLocationManager locationServicesEnabled]){
        
        [locationManager startUpdatingLocation];
        
        self.googleMapView.myLocationEnabled = YES;
        
        self.locationServiceView.hidden = YES;
        
        // NSLog(@"Enable");
    }else
    {
    
       self.locationServiceView.hidden = NO;
    
    }


}

-(void) drawShadow:(UIView *)view{
    
    
    view.layer.shadowColor = [[UIColor blackColor]CGColor];
    view.layer.shadowOffset = CGSizeMake(0, 4.0);
    view.layer.shadowOpacity = 0.3;
    view.layer.shadowRadius = 5.0;
    
    
}

-(void) firstViewSetUp{

    

    self.searchLocationTableView.delegate = self;
    self.searchLocationTableView.dataSource = self;
    
    self.cancelReasonTableView.delegate = self;
    self.cancelReasonTableView.dataSource = self;
    self.cancelReasonTextView.delegate = self;
    
    self.pickUpTextView.delegate = self;
    self.destinationTextView.delegate = self;
    
    self.crossButtonInPicupTextField.hidden = YES;
    self.crossButtonInDestinationTextField.hidden = YES;
    
    self.backButton.hidden = YES;
    self.locationView.hidden = NO;
    self.searchLocationTableView.hidden = YES;
    
    

    self.staticPin.hidden = YES;
    self.setPinPointButton.hidden =YES;
    self.setPinPointDoneButton.hidden =YES;
    
    self.fareView.hidden = YES;
    self.driverSuggestionView.hidden = YES;
    
    self.cancelReasonView.hidden = YES;
    self.shadeView.hidden = YES;
    
    self.timerSupewView.hidden = YES;
    
    self.submitFareView.hidden = YES;
    
    self.backButton.layer.cornerRadius = self.backButton.frame.size.width / 2;
    self.backButton.clipsToBounds = YES;
    
    self.settingButton.layer.cornerRadius = self.settingButton.frame.size.width / 2;
    self.settingButton.clipsToBounds = YES;
    
    self.phoneButtonInDriverSuggestionView.layer.cornerRadius = self.phoneButtonInDriverSuggestionView.frame.size.width / 2;
    self.phoneButtonInDriverSuggestionView.clipsToBounds = YES;
    
    self.cameraButton.layer.cornerRadius = self.cameraButton.frame.size.width / 2;
    self.cameraButton.clipsToBounds = YES;
    
    
    self.driverPhoto.layer.cornerRadius = self.driverPhoto.frame.size.width / 2;
    self.driverPhoto.clipsToBounds = YES;
//    self.driverPhoto.layer.borderWidth = 5.0f;
//    self.driverPhoto.layer.borderColor = [[UIColor hx_colorWithHexString:@"#E9E9E9"]CGColor];
    
    self.bikeNoLabel.layer.cornerRadius = 5;
    self.bikeNoLabel.clipsToBounds = YES;
    self.bikeNoLabel.layer.borderWidth = 1.0f;
    self.bikeNoLabel.layer.borderColor = [[UIColor hx_colorWithHexString:@"#262C4E"]CGColor];

    self.bikeNoLabelInSibmitFareView.layer.cornerRadius = 5;
    self.bikeNoLabelInSibmitFareView.clipsToBounds = YES;
    self.bikeNoLabelInSibmitFareView.layer.borderWidth = 1.0f;
    self.bikeNoLabelInSibmitFareView.layer.borderColor = [[UIColor hx_colorWithHexString:@"#262C4E"]CGColor];
    
//    self.enterPicupButton.layer.cornerRadius = self.driverPhoto.frame.size.width / 2;
//    self.driverPhoto.clipsToBounds = YES;
    self.enterPicupButton.layer.borderWidth = 3.0f;
    self.enterPicupButton.layer.borderColor = [[UIColor hx_colorWithHexString:@"#323B61"]CGColor];
    
    self.ratingInDriverSuggestionView.layer.cornerRadius = self.ratingInDriverSuggestionView.frame.size.width/2;
    self.ratingInDriverSuggestionView.layer.masksToBounds= YES;
    
    self.driverPhotoInSubmitFareView.layer.cornerRadius = self.driverPhotoInSubmitFareView.frame.size.width / 2;
    self.driverPhotoInSubmitFareView.clipsToBounds = YES;
    
    
    self.ratingLabelInSubmitFareView.layer.cornerRadius = self.ratingLabelInSubmitFareView.frame.size.width/2;
    self.ratingLabelInSubmitFareView.layer.masksToBounds= YES;
    
    
    
    
    self.cancelReasonTableView.estimatedRowHeight = 40.0;
    self.cancelReasonTableView.rowHeight = UITableViewAutomaticDimension;
    
    self.searchLocationTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.searchLocationTableView.frame.size.width, 1)];
    self.cancelReasonTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.cancelReasonTableView.frame.size.width, 1)];
    
    
    [UIView animateWithDuration:2.5
                          delay:0
                        options: UIViewAnimationOptionTransitionNone
                     animations:^{
                         
                         CGRect frame = self.locationView.frame;
                         frame.origin.y = self.view.frame.size.height - 20;
                         self.locationView.frame = frame;
                         
                         
                     }
                     completion:^(BOOL finished){
                         
                           if([CLLocationManager locationServicesEnabled]){
                         
                         
                                [[GMSGeocoder geocoder] reverseGeocodeCoordinate:CLLocationCoordinate2DMake(currentLocation.latitude,currentLocation.longitude) completionHandler:^(GMSReverseGeocodeResponse* response, NSError* error) {
                         
                         
                                             GMSAddress* firstaddressObj = [response firstResult];
                         
                                              self.pickUpTextView.text = [NSString stringWithFormat:@"%@", firstaddressObj.thoroughfare];
                       
                         
                                               [rideInfo setObject:[NSString stringWithFormat:@"%@", firstaddressObj.thoroughfare] forKey:@"pickup_address"];
                                               [rideInfo setObject:[NSString stringWithFormat:@"%f",firstaddressObj.coordinate.latitude] forKey:@"pickup_latitude"];
                                               [rideInfo setObject:[NSString stringWithFormat:@"%f", firstaddressObj.coordinate.longitude] forKey:@"pickup_longitude"];
                         
                         
                                  }];
                             }
                         
                     }];
    

    

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidHide:)
                                                 name:UIKeyboardDidHideNotification
                                               object:nil];
    
 
    totalRating = 0;
    
}



-(void)setMap{
    
    //Map
    
    self.googleMapView.delegate = self;
    
    
    if (locationManager==nil)
    {
        locationManager = [[CLLocationManager alloc] init];
    }
    
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    locationManager.headingFilter = 1;
    locationManager.distanceFilter = kCLDistanceFilterNone;
  
    [locationManager requestWhenInUseAuthorization];
    
    
  //  NSLog(@"current Device %lf",[[[UIDevice currentDevice] systemName] floatValue]);
    
    if ([[[UIDevice currentDevice] systemName] floatValue] >= 8.0)
    {
        [locationManager requestWhenInUseAuthorization];
        // NSLog(@"Requested");
    }
    else
    {
        [locationManager requestWhenInUseAuthorization];
        [locationManager startUpdatingLocation];
    }

    
    
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{
    
    
    CLLocation *currentPostion=locations.lastObject;
    
    //CLLocation *currentPostion=locations.lastObject;
    currentLocation.latitude=currentPostion.coordinate.latitude;
    currentLocation.longitude=currentPostion.coordinate.longitude;
    
    NSLog(@"got the location");
    
    
    
    NSLog(@"Current Location = %f, %f",currentLocation.latitude,currentLocation.longitude);
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:currentLocation.latitude longitude:currentLocation.longitude zoom:16];
    
    [self.googleMapView animateToCameraPosition:camera];
    
    
    
    [manager stopUpdatingLocation];
    
    

    
    
}


-(void)setGooglePlacefetcher{


    // Set up the autocomplete filter.
    GMSAutocompleteFilter *filter = [[GMSAutocompleteFilter alloc] init];
    filter.type = kGMSPlacesAutocompleteTypeFilterEstablishment;
    filter.country = @"BD";
    
    // Create the fetcher.
    fetcher = [[GMSAutocompleteFetcher alloc] initWithBounds:nil
                                                       filter:filter];
    fetcher.delegate = self;
    
    [self.pickUpTextView addTarget:self
                   action:@selector(textFieldDidChange:)
         forControlEvents:UIControlEventEditingChanged];
    
    [self.destinationTextView addTarget:self
                   action:@selector(textFieldDidChange:)
         forControlEvents:UIControlEventEditingChanged];


}

- (void)textFieldDidChange:(UITextField *)textField {
    NSLog(@"textField text %@", textField.text);
    
    [fetcher sourceTextHasChanged:textField.text];
}

#pragma mark - GMSAutocompleteFetcherDelegate
- (void)didAutocompleteWithPredictions:(NSArray *)predictions {
    
     NSLog(@"searchResults predictions::::: %@",predictions);
    
    NSMutableString *resultsStr = [NSMutableString string];
    
    searchResults = [[NSMutableArray alloc] init];
    searchResultsPlaceId = [[NSMutableArray alloc]init];
    
    
    for (GMSAutocompletePrediction *prediction in predictions) {
        [resultsStr appendFormat:@"%@\n", [prediction.attributedPrimaryText string]];
        
        [searchResults addObject:prediction.attributedFullText.string];
        
        [searchResultsPlaceId addObject:prediction.placeID];
        

    }

    
  
    
    [self.searchLocationTableView reloadData];
    
}

- (void)didFailAutocompleteWithError:(NSError *)error {
    
   
    
    NSLog(@"didFailAutocompleteWithError %@",error.localizedDescription);
    
}



- (IBAction)whereToButtonAction:(id)sender {
    

    
    
//    [UIView animateWithDuration:0.2
//                          delay:0
//                        options: UIViewAnimationOptionCurveEaseOut
//                     animations:^{
//
//                         self.whereToButton.frame = CGRectMake(20,-45 ,self.whereToButton.frame.size.width, self.whereToButton.frame.size.height);
//
//                                            }
//                     completion:^(BOOL finished){
//
//
//                         self.whereToButton.hidden = YES;
//                         self.backButton.hidden = NO;
//
//                         self.locationView.hidden = NO;
//                         self.searchLocationTableView.hidden = NO;
//
//                         self.destinationTextView.text = nil;
//                         [searchResults removeAllObjects];
//
//                         if([CLLocationManager locationServicesEnabled]){
//
//
//                             [[GMSGeocoder geocoder] reverseGeocodeCoordinate:CLLocationCoordinate2DMake(currentLocation.latitude,currentLocation.longitude) completionHandler:^(GMSReverseGeocodeResponse* response, NSError* error) {
//
//
//                                 GMSAddress* firstaddressObj = [response firstResult];
//
//                                 self.pickUpTextView.text = [NSString stringWithFormat:@"%@", firstaddressObj.thoroughfare];
////                                 NSLog(@"coordinate.latitude=%f", firstaddressObj.coordinate.latitude);
////                                 NSLog(@"coordinate.longitude=%f", firstaddressObj.coordinate.longitude);
//
//                                 [rideInfo setObject:[NSString stringWithFormat:@"%@", firstaddressObj.thoroughfare] forKey:@"pickup_address"];
//                                 [rideInfo setObject:[NSString stringWithFormat:@"%f",firstaddressObj.coordinate.latitude] forKey:@"pickup_latitude"];
//                                 [rideInfo setObject:[NSString stringWithFormat:@"%f", firstaddressObj.coordinate.longitude] forKey:@"pickup_longitude"];
//
//
//                             }];
//
//
//                             [self.destinationTextView becomeFirstResponder];
//
//                         }else
//                         {
//
//                             [self.pickUpTextView becomeFirstResponder];
//
//                         }
//                         [self.searchLocationTableView reloadData];
//                     }];
//
    

    
}

#pragma mark - UITableView DataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    if (tableView == self.cancelReasonTableView) {
        
        return cancelReasonArray.count;
        
    }else
        return 0;
 
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.cancelReasonTableView) {
        
        static NSString *CellIdentifier = @"reasonCell";
        
        CancelReasonTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (!cell)
            cell = [[CancelReasonTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
        
         cell.reasonLabel.text = [[cancelReasonArray objectAtIndex:indexPath.row] objectForKey:@"reason"];
        
        
        
        return cell;
        
        
    }
    
    return nil;
}

#pragma mark - UITableView Delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.cancelReasonTableView) {
        
        //[tableView deselectRowAtIndexPath:indexPath animated:NO];
        
        cancelReasonId = [[cancelReasonArray objectAtIndex:indexPath.row] objectForKey:@"id"];
        
        NSLog(@"cancelReasonId  %@",cancelReasonId);
        NSLog(@"selected index  %lu",(cancelReasonArray.count - 1));
        
        if (indexPath.row == (cancelReasonArray.count - 1)) {
            
            [self.cancelReasonTextView becomeFirstResponder];
            
        }else{
        
            [self.cancelReasonTextView resignFirstResponder];
        }
        
        
    }
    
    
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if (!self.cancelReasonView.isHidden) {
        
        [self.cancelReasonTextView resignFirstResponder];
        
        NSLog(@"Is it called");
    }
    
}




-(void)drawpoliline:(CLLocation *)origin destination:(CLLocation *)destination isfor:(BOOL)isForRider{


    //draw poliline
    
    NSLog(@"origin.coordinate.latitude  %f  longitude%f",origin.coordinate.latitude,origin.coordinate.longitude);
    NSLog(@"destination.coordinate.latitude %f  longitude%f",destination.coordinate.latitude,destination.coordinate.longitude);
    
    
    
    [self fetchPolylineWithOrigin:origin destination:destination isfor:isForRider completionHandler:^(GMSPolyline *polyline)
     {
         
         
         if(polyline)

            polyline.map = self.googleMapView;
         
         
         }];
    

  
    GMSMutablePath *path = [[GMSMutablePath alloc] init];
    
    [path addLatitude:origin.coordinate.latitude longitude:origin.coordinate.longitude];
    [path addLatitude:destination.coordinate.latitude longitude:destination.coordinate.longitude];
    
    if (isUpdateCameraPosition) {
        
        [self updateCameraPosition:path];
        
        
        
    }else
    {
        isUpdateCameraPosition = 1;
    
    }
    
    

}

- (void)fetchPolylineWithOrigin:(CLLocation *)origin destination:(CLLocation *)destination isfor:(BOOL)isForRider completionHandler:(void (^)(GMSPolyline *))completionHandler
{
    
    
    NSString *originString = [NSString stringWithFormat:@"%f,%f", origin.coordinate.latitude, origin.coordinate.longitude];
    NSString *destinationString = [NSString stringWithFormat:@"%f,%f", destination.coordinate.latitude, destination.coordinate.longitude];
    NSString *directionsAPI = @"https://maps.googleapis.com/maps/api/directions/json?";
    NSString *directionsUrlString = [NSString stringWithFormat:@"%@&origin=%@&destination=%@&mode=driving", directionsAPI, originString, destinationString];
    NSURL *directionsUrl = [NSURL URLWithString:directionsUrlString];
    
    
    NSURLSessionDataTask *fetchDirectionsTask = [[NSURLSession sharedSession] dataTaskWithURL:directionsUrl completionHandler:
                                                 ^(NSData *data, NSURLResponse *response, NSError *error)
                                                 {
                                                     NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
                                                     if(error)
                                                     {
                                                         if(completionHandler)
                                                             completionHandler(nil);
                                                         return;
                                                     }
                                                     
                                                     NSArray *routesArray = [json objectForKey:@"routes"];
                                                     
                                                    
                                                     
                                                     ridePolyline = nil;
                                                     driverPolyline = nil;
                                                     GMSPath *path;
                                                     
                                                     if ([routesArray count] > 0)
                                                     {
                                                         NSDictionary *routeDict = [routesArray objectAtIndex:0];
                                                         
                                                        // NSLog(@"routeDict   %@",routeDict);
                                                         
                                                         NSDictionary *routeOverviewPolyline = [routeDict objectForKey:@"overview_polyline"];
                                                         NSString *points = [routeOverviewPolyline objectForKey:@"points"];
                                                         path = [GMSPath pathFromEncodedPath:points];
                                                         
                                                         if (isForRider) {
                                                             
                                                             NSLog(@"driverPolylinePolyLine");
                                                             
                                                             driverPolyline = [GMSPolyline polylineWithPath:path];
                                                             driverPolyline.strokeWidth = 3.f;
                                                             driverPolyline.strokeColor = [UIColor redColor];
                                                             
                                                         }else{
                                                             
                                                             NSLog(@"ridePolyLine");
                                                             
                                                             ridePolyline = [GMSPolyline polylineWithPath:path];
                                                             ridePolyline.strokeWidth = 3.f;
                                                             ridePolyline.strokeColor = [UIColor hx_colorWithHexString:@"262C4E"];
                                                            
                                                         }
                                                         
                                                             
                                                         
                                                         NSArray * legs = [[NSArray alloc]init];
                                                         
                                                         legs = [routeDict objectForKey:@"legs"];
                                                         
                                                         //NSLog(@"legs   %@",legs);
                                                         
                                                         NSString *distance = [[[legs objectAtIndex:0]objectForKey:@"distance"]objectForKey:@"text"];
                                                         
                                                         NSLog(@"distance   %@",distance);
                                                         
                                                         NSString *time = [[[legs objectAtIndex:0]objectForKey:@"duration"]objectForKey:@"text"];
                                                         
                                                         NSLog(@"duration   %@",time);
                                                         
                                                         totalDistance = [distance floatValue];
                                                         estimatedTime = [time floatValue] ;
                                                         
                                                         
                                                     }
                                                     
                                                     // run completionHandler on main thread                                           
                                                     dispatch_sync(dispatch_get_main_queue(), ^{
                                                        
                                                         if (isForRider) {
                                                             
                                                             if(completionHandler)
                                                                 
                                                                 completionHandler(driverPolyline);
                                                             
                                                         }else{
                                                             
                                                             if(completionHandler)
                                                                 
                                                                 completionHandler(ridePolyline);
                                                             
                                                             NSLog(@"path.count  %lu",(unsigned long)path.count);
                                                             
                                                             if (isComeFromBackground) {
                                                             
                                                                 NSLog(@"come from background");
                                                                 isComeFromBackground = 0;
                                                                 
                                                             }else{
                                                               
                                                                 // animate gray path with timer
                                                                 animationTimer =  [NSTimer scheduledTimerWithTimeInterval:0.04 repeats:true block:^(NSTimer * _Nonnull timer) {
                                                                     
                                                                                                   //arrayPolylineGray = [[NSMutableArray alloc] init];
                                                                                                   [self animate:path];
                                                                 
                                                                                     }];
                                                             }
                                                             
                                                         }
                                                         
                                                         if (isCalculateFare) {
                                                         
                                                             if (totalDistance > 0) {
                                                                 
                                                                 [self calculateFare];
                                                                 NSLog(@"calculateFare");
                                                                 
                                                             }else{
                                                                 
                                                                 NSLog(@"try again");
                                                             }
                                                             
                                                             
                                                             
                                                                 
                                                          }else{
                                                         
                                                             NSLog(@"not calculateFare");
                                                           }
                                                      

                                                     });
                                                 }];
    [fetchDirectionsTask resume];
}

-(void)animate:(GMSPath *)path {

   // NSLog(@"i  %d",i);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (i < path.count) {
            [path2 addCoordinate:[path coordinateAtIndex:i]];
            polylineGray = [GMSPolyline polylineWithPath:path2];
            polylineGray.strokeColor = [UIColor lightGrayColor];
            polylineGray.strokeWidth = 3;
            polylineGray.map = self.googleMapView;
            [arrayPolylineGray addObject:polylineGray];
            i++;
            
            
        }else  {
            
            NSLog(@"path no animation");
           
           

            i = 0;
            path2 = [[GMSMutablePath alloc] init];
            
           // polylineGreen.map = nil;
            
            
            for (GMSPolyline *line in arrayPolylineGray) {

                line.map = nil;
                arrayPolylineGray = [[NSMutableArray alloc] init];
            }
            
        }
    });
}


-(void)updateCameraPosition:(GMSMutablePath*)path {
    
   
    
    GMSCoordinateBounds *bounds =[[GMSCoordinateBounds alloc] initWithPath:path];
    
    GMSCameraUpdate *update = [GMSCameraUpdate fitBounds:bounds withEdgeInsets:UIEdgeInsetsMake(200.0, 50.0, 200.0, 50.0)];
    [self.googleMapView moveCamera:update];
    //[self.googleMapView animateToZoom:12];
    [self.googleMapView animateToViewingAngle:35];
    
    
   // [self performSelector:@selector(showFareView) withObject:self afterDelay:2.0 ];
    
    
    

}

- (void) mapView:(GMSMapView *)mapView idleAtCameraPosition:(GMSCameraPosition *)position{
    
    if (!self.staticPin.isHidden) {
        
        self.setPinPointButton.hidden = NO;
        
        NSLog(@"position.target.latitude %f",position.target.latitude);
        NSLog(@"position.target.longitude %f",position.target.longitude);
        
        [[GMSGeocoder geocoder] reverseGeocodeCoordinate:CLLocationCoordinate2DMake(position.target.latitude,position.target.longitude) completionHandler:^(GMSReverseGeocodeResponse* response, NSError* error) {
            
            
            GMSAddress* firstaddressObj = [response firstResult];
            
            if (isEditPictupText) {
            
               self.pickUpTextView.text = [NSString stringWithFormat:@"%@", firstaddressObj.thoroughfare];
                
                [rideInfo setObject:[NSString stringWithFormat:@"%@", self.pickUpTextView.text] forKey:@"pickup_address"];
                [rideInfo setObject:[NSString stringWithFormat:@"%f",position.target.latitude] forKey:@"pickup_latitude"];
                [rideInfo setObject:[NSString stringWithFormat:@"%f", position.target.longitude] forKey:@"pickup_longitude"];
                
                
                
                
            }else{
            
               self.destinationTextView.text = [NSString stringWithFormat:@"%@", firstaddressObj.thoroughfare];
               
                [rideInfo setObject:[NSString stringWithFormat:@"%@", self.destinationTextView.text] forKey:@"destination_address"];
                [rideInfo setObject:[NSString stringWithFormat:@"%f",position.target.latitude] forKey:@"destination_latitude"];
                [rideInfo setObject:[NSString stringWithFormat:@"%f", position.target.longitude] forKey:@"destination_longitude"];
                
 
                
            }
            NSLog(@"reverse geocoding firstaddressObj: %@",firstaddressObj.thoroughfare);
        }];
        
        
        
        
        
    }
    
}


- (IBAction)setPinPointButtonAction:(id)sender {
    
     if (isEditPictupText) {
         
         if (isSaveHomeAddress) {
             
             NSLog(@"api call for home in pickup");
             
             [self saveHomeAndWorkAddress];
             
         }else if (isSaveWorkAddress){
             
             NSLog(@"api call for work in pickup");
             
             [self saveHomeAndWorkAddress];
         }
         
         if (self.destinationTextView.text.length > 0 && [[rideInfo objectForKey:@"destination_latitude"]floatValue] != 0.000000) {
             
             self.staticPin.hidden = YES;
             self.setPinPointButton.hidden = YES;
             self.setPinPointDoneButton.hidden = NO;

         }else{
             
            // [self.destinationTextView becomeFirstResponder];
             self.staticPin.hidden = YES;
             self.setPinPointButton.hidden = YES;
 
         }
         
         //set picup marker
         
         if (pickUpMarker) {
             
             pickUpMarker.map = nil;
         }
         pickUpMarker = [[GMSMarker alloc] init];
         
         pickUpMarker.position = CLLocationCoordinate2DMake([[rideInfo objectForKey:@"pickup_latitude"] floatValue], [[rideInfo objectForKey:@"pickup_longitude"] floatValue]);
         
         pickUpMarker.icon = [UIImage imageNamed:@"Pickup.png"];
         
         pickUpMarker.map = self.googleMapView;
         
         
     }else{
         
         if (isSaveHomeAddress) {
             
             NSLog(@"api call for home in des");
             
             [self saveHomeAndWorkAddress];
             
         }else if (isSaveWorkAddress){
             
             [self saveHomeAndWorkAddress];
             
             NSLog(@"api call for work in des");
         }
         
         if (self.pickUpTextView.text.length > 0 && [[rideInfo objectForKey:@"pickup_latitude"]floatValue] != 0.000000) {
             
             self.staticPin.hidden = YES;
             self.setPinPointButton.hidden = YES;
             self.setPinPointDoneButton.hidden = NO;

         }else{
             
            // [self.pickUpTextView becomeFirstResponder];
             self.staticPin.hidden = YES;
             self.setPinPointButton.hidden = YES;
             self.setPinPointDoneButton.hidden = YES;
         }
         
         // set destination pin
         if (destinationMarker) {
             
             destinationMarker.map = nil;
         }
         
         destinationMarker= [[GMSMarker alloc] init];
         
         destinationMarker.position = CLLocationCoordinate2DMake([[rideInfo objectForKey:@"destination_latitude"] floatValue], [[rideInfo objectForKey:@"destination_longitude"] floatValue]);
         
         destinationMarker.icon = [UIImage imageNamed:@"Destination.png"];
         
         destinationMarker.map = self.googleMapView;
         
     }
    
}



- (IBAction)setPinPointDoneButtonAction:(id)sender {
    
    if(self.pickUpTextView.text.length == 0)
    {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Please enter your pickup point." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        
        [alert show];
        
        
    }if(self.destinationTextView.text.length == 0)
    {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Please enter your destination." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        
        [alert show];
        
        
    }else{
        
        
    
        self.staticPin.hidden = YES;
        self.setPinPointDoneButton.hidden = YES;
        self.locationView.hidden = NO;
        
        if (animationTimer) {

            [animationTimer invalidate];
            animationTimer = nil;
            [polylineGray setMap:nil];
        }

        if (!self.fareView.isHidden) {

            self.fareView.hidden = YES;
        }
        
        [self.googleMapView clear];
        
        pickupPoint = [[CLLocation alloc] initWithLatitude:[[rideInfo objectForKey:@"pickup_latitude"] floatValue] longitude:[[rideInfo objectForKey:@"pickup_longitude"] floatValue]];
        destinationPoint = [[CLLocation alloc] initWithLatitude:[[rideInfo objectForKey:@"destination_latitude"] floatValue] longitude:[[rideInfo objectForKey:@"destination_longitude"] floatValue]];
        
        
        NSLog(@"ride info array in setPinPointButtonAction %@",rideInfo);
        
        if ((pickupPoint.coordinate.latitude != 0.0 || pickupPoint.coordinate.longitude != 0.0) && (destinationPoint.coordinate.latitude != 0.0 || destinationPoint.coordinate.longitude != 0.0)) {
            
            //set picup marker

            if (pickUpMarker) {

                pickUpMarker.map = nil;
            }
            pickUpMarker = [[GMSMarker alloc] init];

            pickUpMarker.position = CLLocationCoordinate2DMake(pickupPoint.coordinate.latitude, pickupPoint.coordinate.longitude);

            pickUpMarker.icon = [UIImage imageNamed:@"Pickup.png"];

            pickUpMarker.map = self.googleMapView;
            
            // set destination pin
            if (destinationMarker) {

                destinationMarker.map = nil;
            }

            destinationMarker= [[GMSMarker alloc] init];

            destinationMarker.position = CLLocationCoordinate2DMake(destinationPoint.coordinate.latitude, destinationPoint.coordinate.longitude);

            destinationMarker.icon = [UIImage imageNamed:@"Destination.png"];

            destinationMarker.map = self.googleMapView;
            
            isCalculateFare = 1;
            isPolyLineBlue =1;
            
            arrayPolylineGray = [[NSMutableArray alloc] init];
            
            if (animationTimer) {
                
                [animationTimer invalidate];
                animationTimer = nil;
                [polylineGray setMap:nil];
            }
            
            
            [self drawpoliline:pickupPoint destination:destinationPoint isfor:0];
            
        }else
        {
            
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Please give valid address." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            
            [alert show];
            
            self.backButton.hidden= YES;
            self.staticPin.hidden =YES;
            self.setPinPointButton.hidden = YES;
            
            //self.fareView.hidden = YES;
            
            //self.whereToButton.hidden = NO;
            
            self.locationView.hidden = NO;
            self.searchLocationTableView.hidden = YES;
            
            [self.googleMapView clear];
            
        }
    
    }
}
-(void) saveHomeAndWorkAddress{
    
    NSMutableDictionary* postData=[[NSMutableDictionary alloc] init];
    
    if (isSaveHomeAddress) {
        
        if (isEditPictupText) {
          
            NSLog(@"Pp");
            
            [postData setObject:[NSString stringWithFormat:@"%@",[rideInfo objectForKey:@"pickup_address"]] forKey:@"home_address_title"];
            [postData setObject:[NSString stringWithFormat:@"%@",[rideInfo objectForKey:@"pickup_latitude"]] forKey:@"home_latitude"];
            [postData setObject:[NSString stringWithFormat:@"%@",[rideInfo objectForKey:@"pickup_longitude"]] forKey:@"home_longitude"];
            
        }else{
            
            NSLog(@"Pd");
            [postData setObject:[NSString stringWithFormat:@"%@",[rideInfo objectForKey:@"destination_address"]] forKey:@"home_address_title"];
            [postData setObject:[NSString stringWithFormat:@"%@",[rideInfo objectForKey:@"destination_latitude"]] forKey:@"home_latitude"];
            [postData setObject:[NSString stringWithFormat:@"%@",[rideInfo objectForKey:@"destination_longitude"]] forKey:@"home_longitude"];
        }
        
        
        
    }else if (isSaveWorkAddress)
    {
        if (isEditPictupText) {
            
            NSLog(@"dp");
            
            [postData setObject:[NSString stringWithFormat:@"%@",[rideInfo objectForKey:@"pickup_address"]] forKey:@"work_address_title"];
            [postData setObject:[NSString stringWithFormat:@"%@",[rideInfo objectForKey:@"pickup_latitude"]] forKey:@"work_latitude"];
            [postData setObject:[NSString stringWithFormat:@"%@",[rideInfo objectForKey:@"pickup_longitude"]] forKey:@"work_longitude"];
            
        }else
        {
            NSLog(@"dd");
            
            [postData setObject:[NSString stringWithFormat:@"%@",[rideInfo objectForKey:@"destination_address"]] forKey:@"work_address_title"];
            [postData setObject:[NSString stringWithFormat:@"%@",[rideInfo objectForKey:@"destination_latitude"]] forKey:@"work_latitude"];
            [postData setObject:[NSString stringWithFormat:@"%@",[rideInfo objectForKey:@"destination_longitude"]] forKey:@"work_longitude"];
            
        }
    }
    
    
    [[ServerManager sharedManager] patchUpdateHomeAndWork:postData withCompletion:^(BOOL success, NSMutableDictionary *resultDataDictionary) {
    
        if ( resultDataDictionary!=nil) {
    
            NSLog(@"  info  %@",resultDataDictionary);
            
    
            ;
    
    
        }else{
    
            dispatch_async(dispatch_get_main_queue(), ^{
    
                NSLog(@"no  info");
    
    
            });
    
        }
    
    
    
    }];
    
}
-(void)calculateFare{

    [[ServerManager sharedManager] getFareInfoWithCompletion:^(BOOL success, NSMutableDictionary *responseObject) {
        
        
        if ( responseObject!=nil) {
            
            
            NSMutableDictionary *userInfo;
            
            userInfo= [[NSMutableDictionary alloc] initWithDictionary:[responseObject dictionaryByReplacingNullsWithBlanks]];
            
            NSLog(@"totalDistance in fareCalculation %f",totalDistance);
            
            self.timeLabel.text = [NSString stringWithFormat:@"%.1f mins", estimatedTime ];
            
            float estimatedFare = [[userInfo objectForKey:@"base_fare"]floatValue] + ( [[userInfo objectForKey:@"per_kilometer_fare"]floatValue] * totalDistance )+ ([[userInfo objectForKey:@"per_minute_fare"]floatValue] * estimatedTime);
            
            NSLog(@"estimatedFare %.2f",estimatedFare);
            
            self.fareLabel.text = [NSString stringWithFormat:@"%.2f",estimatedFare];
            
            [self showFareView];

        }else{
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                NSLog(@"no user info");
                
                
            });
            
        }
    }];

}
-(void) showFareView{

    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.requestRideButton.bounds byRoundingCorners:( UIRectCornerBottomLeft | UIRectCornerBottomRight) cornerRadii:CGSizeMake(5.0, 5.0)];
    
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.view.bounds;
    maskLayer.path  = maskPath.CGPath;
    self.requestRideButton.layer.mask = maskLayer;

    self.fareView.hidden = NO;
    self.fareView.frame = CGRectMake(20,self.view.frame.size.height ,self.fareView.frame.size.width,self.fareView.frame.size.height);
    

    [UIView animateWithDuration:.5
                          delay:0
                        options: UIViewAnimationOptionTransitionNone
                     animations:^{
                         
                         
                         self.fareView.frame = CGRectMake(20,(self.view.frame.size.height - self.fareView.frame.size.height-20) ,self.fareView.frame.size.width,self.fareView.frame.size.height);
                         
                         
                     }
                     completion:^(BOOL finished){
                         
                         self.backButton.hidden = NO;
                         
                     }];


}

- (IBAction)tapOnTextField:(UITextField*)sender {
    
    SearchLocationViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"SearchLocationViewController"];
    
      //vc.userInfo = userInfo;
      vc.dataBackDelegate = self;
    
   
    
    if([sender isEqual:self.pickUpTextView])
    {
        
        [self.pickUpTextView resignFirstResponder];
        isEditPictupText = 1;
        
    }
    else{
        
        [self.destinationTextView resignFirstResponder];
        isEditPictupText = 0;
    }

    NSLog(@"isEditPictupText  %d",isEditPictupText);

     [self.navigationController pushViewController:vc animated:YES];
   
}



-(void)textViewDidBeginEditing:(UITextView *)textView{
 
    NSLog(@"Did begin editing");
    
    self.otherReasonLabel.hidden = YES;
    
}

-(void) textViewDidEndEditing:(UITextView *)textView{


    if (textView.text.length == 0) {
        
        self.otherReasonLabel.hidden = NO;
    }


}



- (IBAction)textFieldCrossButtonAction:(UIButton*)sender {
    
}




- (IBAction)myLocationButtonAction:(id)sender {
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:currentLocation.latitude longitude:currentLocation.longitude zoom:16];
    
    [self.googleMapView animateToCameraPosition:camera];
}


- (IBAction)customPicupButtonAction:(id)sender {
    
    self.staticPin.hidden = NO;
    
    [self.pickUpTextView resignFirstResponder];
    
}


- (IBAction)customDestinationButtonAction:(id)sender {
    
    self.staticPin.hidden = NO;
    
    [self.destinationTextView resignFirstResponder];

}


- (void)keyboardDidShow: (NSNotification *) notif{
    
    if (animationTimer) {
        
        [animationTimer invalidate];
        animationTimer = nil;
        [polylineGray setMap:nil];
    }
    
    [self.googleMapView clear];
    
    if (!self.fareView.isHidden) {

        self.fareView.hidden = YES;
    }
    
   
    if (!self.cancelReasonView.isHidden) {
        
         self.searchLocationTableView.hidden = YES;

        
        NSDictionary* info = [notif userInfo];
        
        CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;

        NSLog(@"keyboard height %f",kbSize.height);
        
        //self.cancelReasonViewCenterConstraint.constant = -kbSize.height * 0.6;
        
         self.otherReasonsBottomConstraint.constant = kbSize.height * 0.6;
        
        NSLog(@"cancelReasonViewCenterConstraint %f",self.cancelReasonViewCenterConstraint.constant);

        
    }else{
        
         self.searchLocationTableView.hidden = NO;
    }
}

- (void)keyboardDidHide: (NSNotification *) notif{
    
     if (!self.cancelReasonView.isHidden) {
         
        //self.cancelReasonViewCenterConstraint.constant = 0;
         self.otherReasonsBottomConstraint.constant = 0;
         
         
     }else{
         
       self.searchLocationTableView.hidden = YES;
     }
}



- (IBAction)turnOnLocationServiceButtonAction:(id)sender {
    
    

    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:nil];
        
        
   
}

- (IBAction)enterPicupButtonAction:(id)sender {
    
    
    self.locationServiceView.hidden = YES;
    self.whereToButton.hidden = YES;
    self.locationView.hidden = NO;
    self.backButton.hidden = NO;
    
    //[self.pickUpTextView becomeFirstResponder];
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:23.8103 longitude:90.4125 zoom:16];
    
    [self.googleMapView animateToCameraPosition:camera];
    
    
}
- (IBAction)requestRideButtonAction:(id)sender {
    
    NSLog(@"ride info in request ride %@",rideInfo);
    
    
    
    
    [[ServerManager sharedManager] postRequestRideWithInfo:rideInfo completion:^(BOOL success, NSMutableDictionary *responseObject) {
        
        
        if ( responseObject!=nil) {
            
            NSLog(@"  info  %@",responseObject);
            
            rideId = [responseObject objectForKey:@"data"];
            
            NSLog(@"rideId %@",rideId);
            
            
            
        }else{
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [countDown invalidate];
                self.timerSupewView.hidden = YES;
                
                NSLog(@"no  info");
                
                
            });
            
        }
    }];
    
    self.timerSupewView.hidden = NO;
    
    countDown =  [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(continuoousripples) userInfo:nil repeats:YES];
    
    self.endTime = [NSDate dateWithTimeIntervalSinceNow:60.0f];
    
//    [UIView animateWithDuration:.5
//                          delay:0
//                        options: UIViewAnimationOptionTransitionNone
//                     animations:^{
//
//
//                         self.fareView.frame = CGRectMake(0,self.view.frame.size.height ,self.fareView.frame.size.width, 0);
//
//
//                     }
//                     completion:^(BOOL finished){
//
//                         self.fareView.hidden = YES;
//                         self.timerSupewView.hidden = NO;
//
//                         countDown =  [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(continuoousripples) userInfo:nil repeats:YES];
//
//                         self.endTime = [NSDate dateWithTimeIntervalSinceNow:60.0f];
//
//
//
//
//
//                     }];
    

    
}



-(void)continuoousripples{
    
    CGPoint origin = CGPointMake(self.timerSupewView.frame.size.width / 2,
                                 self.timerSupewView.frame.size.height / 2);
    
    
    float radius = self.timerSupewView.frame.size.width / 2 - 50;
    float duration = 2;
    float fadeAfter = duration * 0.75f;

    [self.timerSupewView rippleStartingAt:origin withColor:[UIColor whiteColor] duration:duration radius:radius fadeAfter:fadeAfter];
    
    
    
    NSInteger secondsSinceStart = -(NSInteger)[self.endTime timeIntervalSinceNow];
    NSLog(@"secondsSinceStart %ld", secondsSinceStart);
    
    if (secondsSinceStart >= 0) {
       
        [countDown invalidate];
        
        if (!self.timerSupewView.hidden) {
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                            message:@"No rider found"
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles: nil];
            [alert show];
            
            
            self.timerSupewView.hidden = YES;
            
            
            
            
        }
        

    }
    
}



-(void)rideInfo: (NSNotification *)notification
{
    
    NSDictionary* riderInfo = [notification userInfo];
    
    NSLog(@"ride info %@",riderInfo);
    
    
    NSData *webData = [[riderInfo objectForKey:@"gcm.notification.data" ] dataUsingEncoding:NSUTF8StringEncoding];
    
    NSError *error;
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:webData options:0 error:&error];
    NSLog(@"JSON DIct: %@", jsonDict);
    
    int notificationType = [[jsonDict objectForKey:@"notification_type"]intValue];
    
    if (notificationType == 2) {

        self.cameraButton.hidden = YES;
        self.onTripLabel.hidden = YES;
        self.locationView.hidden = YES;
        self.backButton.hidden = YES;
        
        //driver found or driver accept
        
        if (animationTimer) {
            
            NSLog(@"[animationTimer invalidate]");
            
            [animationTimer invalidate];
            animationTimer = nil;
            [polylineGray setMap:nil];
        }
        
        
        
        [countDown invalidate];
        self.timerSupewView.hidden = YES;
        
        self.bikeNoLabel.text = [[[[jsonDict objectForKey:@"ride_info" ] objectForKey:@"rider"] objectForKey:@"rider_metadata"] objectForKey:@"bike_number"];
        
        //set label size
        CGSize maximumLabelSize = CGSizeMake(80, FLT_MAX);
        
        NSAttributedString *attributedText =
        [[NSAttributedString alloc] initWithString:self.bikeNoLabel.text attributes:@ {
        NSFontAttributeName: self.bikeNoLabel.font
        }];
        CGRect expectedLabelSize = [attributedText boundingRectWithSize:maximumLabelSize
                                                                options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                                                context:nil];
        
        
        CGRect newFrameforLabel=CGRectMake(self.bikeNoLabel.frame.origin.x, self.bikeNoLabel.frame.origin.y, expectedLabelSize.size.width+20, expectedLabelSize.size.height);
        
        self.bikeNoLabel.frame=newFrameforLabel;
        
        NSLog(@"self.bikeNoLabel %f",self.bikeNoLabel.frame.size.width);
        
        //
        
        self.driverNameLabel.text = [[[jsonDict objectForKey:@"ride_info" ] objectForKey:@"rider"] objectForKey:@"name"];
        
        self.ratingInDriverSuggestionView.text =[NSString stringWithFormat:@"%@",[[[[jsonDict objectForKey:@"ride_info" ] objectForKey:@"rider"] objectForKey:@"rider_metadata"]objectForKey:@"rating_avg"]];
        self.bikeModelLabel.text = [NSString stringWithFormat:@"%@",[[[[jsonDict objectForKey:@"ride_info" ] objectForKey:@"rider"] objectForKey:@"rider_metadata"]objectForKey:@"bike_model"]];
        
        phoneNo = [[[jsonDict objectForKey:@"ride_info" ] objectForKey:@"rider"] objectForKey:@"phone"];
        
        
        
        NSString * riderlat =[[[[jsonDict objectForKey:@"ride_info" ] objectForKey:@"rider"] objectForKey:@"rider_metadata"] objectForKey:@"current_latitude"];
        NSString * riderlong = [[[[jsonDict objectForKey:@"ride_info" ] objectForKey:@"rider"] objectForKey:@"rider_metadata"] objectForKey:@"current_longitude"];
        
         NSLog(@"rider_metadata %@",[[[jsonDict objectForKey:@"ride_info" ] objectForKey:@"rider"] objectForKey:@"rider_metadata"]);

       // [self riderPositionWithLat:riderlat andLong:riderlong];
        
        CLLocation *passengerLocation = [[CLLocation alloc] initWithLatitude:[[rideInfo objectForKey:@"pickup_latitude"] floatValue] longitude:[[rideInfo objectForKey:@"pickup_longitude"] floatValue]];
        CLLocation *riderLocation = [[CLLocation alloc] initWithLatitude:[riderlat floatValue] longitude:[riderlong floatValue]];
        
        NSLog(@"riderLocation %@",riderLocation);
        
        //GMSMarker *riderMarker = [[GMSMarker alloc] init];
        
        CLLocationCoordinate2D position = CLLocationCoordinate2DMake([riderlat floatValue], [riderlong floatValue]);
        
        riderMarker = [GMSMarker markerWithPosition:position];
        
        riderMarker.icon = [UIImage imageNamed:@"bike.png"];
        
        riderMarker.map = self.googleMapView;
        
        
        isUpdateCameraPosition = 0;
        isPolyLineBlue = 0;
        isCalculateFare = 0;
        NSLog(@"notif 2");
        
        [self drawpoliline:passengerLocation destination:riderLocation isfor:1];
        
       [self performSelector:@selector(showDriverSuggestionView) withObject:self afterDelay:1.0 ];
        
        riderId = [[[[jsonDict objectForKey:@"ride_info" ] objectForKey:@"rider"] objectForKey:@"id"]intValue];
        
        timerForRiderPosition = [NSTimer scheduledTimerWithTimeInterval: 60.0 target: self
                                                        selector: @selector(driverCurrentPosition) userInfo: nil repeats: YES];
        
        
    }else if (notificationType == 3){
        
        NSLog(@"Rider cancel the request");
        
        //self.whereToButton.hidden = NO;
        //self.driverSuggestionView.hidden = YES;
        self.fareView.hidden = YES;
        self.locationView.hidden = NO;
        self.backButton.hidden = YES;
        self.destinationTextView.text = @"";
        
        [UIView animateWithDuration:.5
                              delay:0
                            options: UIViewAnimationOptionTransitionNone
                         animations:^{
                             
                             
                             self.driverSuggestionView.frame = CGRectMake(0,self.view.frame.size.height ,self.driverSuggestionView.frame.size.width, self.driverSuggestionView.frame.size.height);
                             
                             
                         }
                         completion:^(BOOL finished){
                             
                             self.driverSuggestionView.hidden = YES;
                             
                         }];
        
        
        if (animationTimer) {
            
            [animationTimer invalidate];
            animationTimer = nil;
            [polylineGray setMap:nil];
        }
        
        [self.googleMapView clear];
        
        GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:currentLocation.latitude longitude:currentLocation.longitude zoom:16];
        
        [self.googleMapView animateToCameraPosition:camera];
        

        
        
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil
                                                                       message:@""
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        NSMutableAttributedString *alertMsg = [[NSMutableAttributedString alloc] initWithString:@"Rider cancel the request"];
        [alertMsg addAttribute:NSFontAttributeName
                      value:[UIFont systemFontOfSize:15.0]
                      range:NSMakeRange(0, alertMsg.length)];
        [alert setValue:alertMsg forKey:@"attributedTitle"];

        
        [self presentViewController:alert animated:YES completion:nil];
        
        int duration = 2; // duration in seconds
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, duration * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            
            [alert dismissViewControllerAnimated:YES completion:nil];
        });
        
        
        
        [timerForRiderPosition invalidate];
        
    }else if (notificationType == 5){
        
        NSLog(@"ride start");
        
        [timerForRiderPosition invalidate];
        
        
        [driverPolyline setMap:nil];
        
        if (animationTimer) {
            
            [animationTimer invalidate];
            animationTimer = nil;
            [polylineGray setMap:nil];
        }
        

        self.onTripLabel.hidden = NO;
        self.cancelButtonHeight.constant = 0;
        self.phoneButtonInDriverSuggestionView.hidden = YES;
        self.cameraButton.hidden = NO;
        self.locationView.hidden = YES;
        self.backButton.hidden = YES;
      
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil
                                                                       message:@""
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        NSMutableAttributedString *alertMsg = [[NSMutableAttributedString alloc] initWithString:@"Trip started"];
        [alertMsg addAttribute:NSFontAttributeName
                         value:[UIFont systemFontOfSize:15.0]
                         range:NSMakeRange(0, alertMsg.length)];
        [alert setValue:alertMsg forKey:@"attributedTitle"];
        
        [self presentViewController:alert animated:YES completion:nil];
        
        int duration = 2; // duration in seconds
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, duration * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            
            [alert dismissViewControllerAnimated:YES completion:nil];
        });
        
        
        
        
    }else if (notificationType == 6){
        
         NSLog(@"trip end");
        
                [UIView animateWithDuration:.5
                                      delay:0
                                    options: UIViewAnimationOptionTransitionNone
                                 animations:^{
        
        
                                     self.driverSuggestionView.frame = CGRectMake(0,self.view.frame.size.height ,self.driverSuggestionView.frame.size.width, self.driverSuggestionView.frame.size.height);
        
        
                                 }
                                 completion:^(BOOL finished){
        
                                     self.driverSuggestionView.hidden = YES;
        
                                 }];
        
        self.destinationTextView.text = @"";
        self.locationView.hidden = YES;
        self.backButton.hidden = YES;
        
        self.bikeNoLabelInSibmitFareView.text = [[[[jsonDict objectForKey:@"data" ] objectForKey:@"rider"] objectForKey:@"rider_metadata"] objectForKey:@"bike_number"];
        
        NSLog(@"self.bikeNoLabelInSibmitFareView.text  %@",self.bikeNoLabelInSibmitFareView.text);
        
        //set label size
        CGSize maximumLabelSize = CGSizeMake(80, FLT_MAX);
        
        NSAttributedString *attributedText =
        [[NSAttributedString alloc] initWithString:self.bikeNoLabelInSibmitFareView.text attributes:@ {
        NSFontAttributeName: self.bikeNoLabelInSibmitFareView.font
        }];
        CGRect expectedLabelSize = [attributedText boundingRectWithSize:maximumLabelSize
                                                                options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                                                context:nil];
        
        
        CGRect newFrameforLabel=CGRectMake(self.bikeNoLabelInSibmitFareView.frame.origin.x, self.bikeNoLabelInSibmitFareView.frame.origin.y, expectedLabelSize.size.width+20, expectedLabelSize.size.height);
        
        self.bikeNoLabelInSibmitFareView.frame=newFrameforLabel;
        
        NSLog(@"self.bikeNoLabel %f",self.bikeNoLabel.frame.size.width);
        
        //
        
        self.driverNameLabelInSubmitFareView.text = [[[jsonDict objectForKey:@"data" ]objectForKey:@"rider" ] objectForKey:@"name"];
        self.bikeModelLabelInSubmitFareView.text = [NSString stringWithFormat:@"%@",[[[[jsonDict objectForKey:@"data" ] objectForKey:@"rider"] objectForKey:@"rider_metadata"]objectForKey:@"bike_model"]];
        self.ratingLabelInSubmitFareView.text =[NSString stringWithFormat:@"%@",[[[[jsonDict objectForKey:@"data" ] objectForKey:@"rider"] objectForKey:@"rider_metadata"]objectForKey:@"rating_avg"]];
        self.rideCostLabel.text =[NSString stringWithFormat:@"%@", [[[jsonDict objectForKey:@"data" ]objectForKey:@"detail"] objectForKey:@"total_payable_fare"]];
        
        [self performSelector:@selector(showSubmitFareView) withObject:self afterDelay:1.0 ];
        
   
        

        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil
                                                                       message:@""
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        NSMutableAttributedString *alertMsg = [[NSMutableAttributedString alloc] initWithString:@"Trip ended"];
        [alertMsg addAttribute:NSFontAttributeName
                         value:[UIFont systemFontOfSize:15.0]
                         range:NSMakeRange(0, alertMsg.length)];
        [alert setValue:alertMsg forKey:@"attributedTitle"];
        
        [self presentViewController:alert animated:YES completion:nil];
        
        int duration = 2; // duration in seconds
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, duration * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [alert dismissViewControllerAnimated:YES completion:nil];
        });
        
       
        
    }else if (notificationType == 7){
        
//        [timerForRiderPosition invalidate];
//
//
//        [driverPolyline setMap:nil];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                        message:@"Rider arrived"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles: nil];
        [alert show];
        
       
        
    }else if (notificationType == 8){
        

        
        [countDown invalidate];
        self.timerSupewView.hidden = YES;
        
      
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil
                                                                       message:@""
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        NSMutableAttributedString *alertMsg = [[NSMutableAttributedString alloc] initWithString:@"No rider found"];
        [alertMsg addAttribute:NSFontAttributeName
                         value:[UIFont systemFontOfSize:15.0]
                         range:NSMakeRange(0, alertMsg.length)];
        [alert setValue:alertMsg forKey:@"attributedTitle"];
        
        
        [self presentViewController:alert animated:YES completion:nil];
        
        int duration = 2; // duration in seconds
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, duration * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [alert dismissViewControllerAnimated:YES completion:nil];
        });
        
       
        
        if (animationTimer) {
            
            [animationTimer invalidate];
            animationTimer = nil;
            [polylineGray setMap:nil];
        }
        
        self.backButton.hidden= NO;
        self.staticPin.hidden =YES;
        self.setPinPointButton.hidden = YES;
        self.setPinPointDoneButton.hidden = YES;
        self.locationView.hidden = NO;
        
        self.searchLocationTableView.hidden = YES;
        
        [self.googleMapView clear];
        
        [self.pickUpTextView resignFirstResponder];
        [self.destinationTextView resignFirstResponder];
        
        //self.destinationTextView.text = @"";
        
        GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:currentLocation.latitude longitude:currentLocation.longitude zoom:16];
        
        [self.googleMapView animateToCameraPosition:camera];
        
        
        NSLog(@"rider not found");
        
    }else if (notificationType == 11){
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                        message:@"eneric"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles: nil];
        [alert show];
        
        NSLog(@"generic");
    }
    
}



-(void)driverCurrentPosition{
    
    NSLog(@"driverCurrentPosition");
    
    
    
    NSMutableDictionary* dataDic=[[NSMutableDictionary alloc] init];
    
    
    
    [dataDic setObject:[NSString stringWithFormat:@"%d", riderId] forKey:@"rider_id"];
    
    NSLog(@"dataDic %@",dataDic);
    
    [[ServerManager sharedManager] getRiderPosition:dataDic WithCompletion:^(BOOL success, NSMutableDictionary *responseObject) {
        
       // NSLog(@"responseObject %@",responseObject);
        
        if ( responseObject!=nil) {
            
            
            NSMutableDictionary *userInfo;
            
            userInfo= [[NSMutableDictionary alloc] initWithDictionary:[responseObject dictionaryByReplacingNullsWithBlanks]];
            
            NSLog(@"rider position %@",userInfo);
            
            NSString * riderlat =[userInfo objectForKey:@"current_latitude"];
            NSString * riderlong = [userInfo objectForKey:@"current_longitude"];
            
            CLLocationCoordinate2D position = CLLocationCoordinate2DMake([riderlat floatValue], [riderlong floatValue]);
            

            [CATransaction begin];
            [CATransaction setAnimationDuration:2.0];
            riderMarker.position = position;
            [CATransaction commit];
            
            
            
        }else{
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                NSLog(@"no user info");
                
                
            });
            
        }
    }];
}


-(void) showDriverSuggestionView{
    
    self.fareView.hidden = YES;
    self.driverSuggestionView.hidden = NO;
    
    self.driverSuggestionView.frame = CGRectMake(20,self.view.frame.size.height ,self.driverSuggestionView.frame.size.width,self.driverSuggestionView.frame.size.height);
    
    [UIView animateWithDuration:.5
                          delay:0
                        options: UIViewAnimationOptionTransitionNone
                     animations:^{
                         
                         
                         self.driverSuggestionView.frame = CGRectMake(20,(self.view.frame.size.height - self.driverSuggestionView.frame.size.height-20) ,self.driverSuggestionView.frame.size.width,self.driverSuggestionView.frame.size.height);
                         
                         
                     }
                     completion:^(BOOL finished){
                         
                         
                     }];
    
  
}

-(void) showSubmitFareView{


    
    self.submitFareView.hidden = NO;
    self.submitFareView.frame = CGRectMake(20,self.view.frame.size.height ,self.submitFareView.frame.size.width,self.submitFareView.frame.size.height);
    
    [UIView animateWithDuration:.5
                          delay:0
                        options: UIViewAnimationOptionTransitionNone
                     animations:^{
                         
                         
                         self.submitFareView.frame = CGRectMake(20,(self.view.frame.size.height - self.submitFareView.frame.size.height-20) ,self.submitFareView.frame.size.width,self.submitFareView.frame.size.height);
                         
                         
                     }
     
                     completion:^(BOOL finished){
                         
                         
                     }];
    
    
    self.rateView.notSelectedImage = [UIImage imageNamed:@"Star_deactive.png"];
    self.rateView.halfSelectedImage = [UIImage imageNamed:@"Star_active_half.png"];
    self.rateView.fullSelectedImage = [UIImage imageNamed:@"Star_active.png"];
    self.rateView.rating = 0;
    self.rateView.editable = YES;
    self.rateView.maxRating = 5;
    self.rateView.delegate = self;


}

- (void)rateView:(RateView *)rateView ratingDidChange:(float)rating {
    
    
    
    totalRating =  rating;
    
    NSLog(@"RATING is :)%f",totalRating);
    
}


- (IBAction)paymentButtonAction:(id)sender {
    
    
}
- (IBAction)smsDriverButtonAction:(id)sender {
    
    if([[UIDevice currentDevice].systemVersion floatValue] >= 10.0){
        
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"sms:%@", phoneNo]] options:@{} completionHandler:^(BOOL success) {
            if (success) {
                
                NSLog(@"Opened url sms");
            }
        }];
    }else{
        
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"sms:%@", phoneNo]]];
        
    }
    
}
- (IBAction)phoneDriverButtonAction:(id)sender {
    
    if([[UIDevice currentDevice].systemVersion floatValue] >= 10.0){
        
       
         
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", phoneNo]] options:@{} completionHandler:^(BOOL success) {
            if (success) {
                
                NSLog(@"Opened url");
            }
            else {
                NSLog(@"cancel");
            }
        }];
        
    }else{
    
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", phoneNo]]];
    
    }
}
- (IBAction)cameraButtonAction:(id)sender {
    
}


- (IBAction)cancelRideButtonAction:(id)sender {
    
    [countDown invalidate];
    
    cancelReasonArray = [[NSMutableArray alloc]init];
    
    [[ServerManager sharedManager] getRideCancelReasosnsWithCompletion:^(BOOL success, NSMutableDictionary *responseObject) {
        
        
        if ( responseObject!=nil) {
            

            cancelReasonArray = [responseObject objectForKey:@"data"];
            NSLog(@"reasons in mapview  %@",cancelReasonArray);
            
            [self.cancelReasonTableView reloadData];
            
            
        }else{
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                NSLog(@"no user info");
                
                
            });
            
        }
    }];

    
    if (!self.timerSupewView.isHidden ) {
        
        self.timerSupewView.hidden = YES;
  
        self.backButton.hidden = YES;
        
        
    }else{
    
       [UIView animateWithDuration:.5
                          delay:0
                        options: UIViewAnimationOptionTransitionNone
                     animations:^{
                         
                         
                         self.driverSuggestionView.frame = CGRectMake(20,self.view.frame.size.height ,self.driverSuggestionView.frame.size.width, self.driverSuggestionView.frame.size.height);
                         
                         
                     }
                     completion:^(BOOL finished){
                         
                         self.driverSuggestionView.hidden = YES;
 
                         self.backButton.hidden = YES;
                         
                         
                         
                         
                     }];
        
    }
    
    self.cancelReasonView.hidden = NO;
    self.shadeView.hidden = NO;

    
}

- (IBAction)cancelReasonSubmitButtonAction:(id)sender {
    
    if (animationTimer) {
        
        [animationTimer invalidate];
        animationTimer = nil;
        [polylineGray setMap:nil];
    }
    
   // self.whereToButton.hidden = NO;
    self.cancelReasonView.hidden = YES;
    self.shadeView.hidden = YES;
    self.fareView.hidden = YES;
    
    self.searchLocationTableView.hidden = YES;
    
    [self.cancelReasonTextView resignFirstResponder];
    
    self.destinationTextView.text = @"";
    
    
    NSMutableDictionary* reasons=[[NSMutableDictionary alloc] init];
    
    [reasons setObject:rideId forKey:@"ride_id"];
    [reasons setObject:cancelReasonId forKey:@"ride_cancel_reason_id"];
    
     if (self.cancelReasonTextView.text.length>0) {
        
       [reasons setObject:self.cancelReasonTextView.text forKey:@"other_cancel_reason"];

     }

    
    NSLog(@"post data %@",reasons);
    
    [[ServerManager sharedManager] cancelRideWithReason:reasons withCompletion:^(BOOL success) {
        
        
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


    [self.googleMapView clear];
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:currentLocation.latitude longitude:currentLocation.longitude zoom:16];
    
    [self.googleMapView animateToCameraPosition:camera];
    
}

- (IBAction)submitButtonActionInFareView:(id)sender {

    NSMutableDictionary* postData=[[NSMutableDictionary alloc] init];
    
    [postData setObject:[NSString stringWithFormat:@"%@",rideId] forKey:@"ride_id"];
    [postData setObject:[NSString stringWithFormat:@"%.1f",totalRating] forKey:@"rating"];
    
    [[ServerManager sharedManager] patchRating:postData withCompletion:^(BOOL success, NSMutableDictionary *resultDataDictionary) {
        
        if ( resultDataDictionary!=nil) {
            
            NSLog(@"  info  %@",resultDataDictionary);
            
            [UIView animateWithDuration:.5
                                  delay:0
                                options: UIViewAnimationOptionTransitionNone
                             animations:^{
                                 
                                 
                                 self.submitFareView.frame = CGRectMake(20,self.view.frame.size.height ,self.submitFareView.frame.size.width, self.submitFareView.frame.size.height);
                                 
                                 
                             }
                             completion:^(BOOL finished){
                                 
                                 //self.whereToButton.hidden = NO;
                                 
                                 self.locationView.hidden = NO;
                                 self.submitFareView.hidden = YES;
                                 self.backButton.hidden = YES;
                                 
                                 [self.googleMapView clear];
                                 
                                 if (animationTimer) {
                                     
                                     [animationTimer invalidate];
                                     animationTimer = nil;
                                     [polylineGray setMap:nil];
                                 }
                                 
                                 GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:currentLocation.latitude longitude:currentLocation.longitude zoom:16];
                                 
                                 [self.googleMapView animateToCameraPosition:camera];
                                 
                                 
                             }];

            
        }else{
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                NSLog(@"no  info");
                
                
            });
            
        }

        
        
    }];
    

}

-(void)appBecomeActive: (NSNotification *)notification
{
    
    NSDictionary* info = [notification userInfo];
    
    NSLog(@"ride info %@",info);
    
    NSLog(@"app become active");
    int status = [[info objectForKey:@"status"]intValue];
    
    if (status == 2) {
        
        
        
        NSString * riderlat =[[[[info objectForKey:@"data" ]objectForKey:@"rider" ] objectForKey:@"rider_metadata"] objectForKey:@"current_latitude"];
        NSString * riderlong = [[[[info objectForKey:@"data" ]objectForKey:@"rider" ] objectForKey:@"rider_metadata"] objectForKey:@"current_longitude"];
        
        
        CLLocation *passengerLocation = [[CLLocation alloc] initWithLatitude:[[[info objectForKey:@"data"]objectForKey:@"pickup_latitude"] floatValue] longitude:[[[info objectForKey:@"data"]objectForKey:@"pickup_longitude"] floatValue]];
        CLLocation *riderLocation = [[CLLocation alloc] initWithLatitude:[riderlat floatValue] longitude:[riderlong floatValue]];
        
       
        
        CLLocationCoordinate2D position = CLLocationCoordinate2DMake([riderlat floatValue], [riderlong floatValue]);
        
        if (riderMarker) {
            

            [CATransaction begin];
            [CATransaction setAnimationDuration:2.0];
            riderMarker.position = position;
            [CATransaction commit];
            
        }else{
            
            riderMarker = [GMSMarker markerWithPosition:position];
        
            riderMarker.icon = [UIImage imageNamed:@"bike.png"];
        
            riderMarker.map = self.googleMapView;
        }
        
        isUpdateCameraPosition = 0;
        isPolyLineBlue = 0;
        isCalculateFare = 0;
        
        [self drawpoliline:passengerLocation destination:riderLocation isfor:1];
        
        [self reSetViewWhenActive:info];
        
        self.bikeNoLabel.text = [[[[info objectForKey:@"data" ] objectForKey:@"rider"] objectForKey:@"rider_metadata"] objectForKey:@"bike_number"];
        
        //set label size
        CGSize maximumLabelSize = CGSizeMake(80, FLT_MAX);
        
        NSAttributedString *attributedText =
        [[NSAttributedString alloc] initWithString:self.bikeNoLabel.text attributes:@ {
        NSFontAttributeName: self.bikeNoLabel.font
        }];
        CGRect expectedLabelSize = [attributedText boundingRectWithSize:maximumLabelSize
                                                                options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                                                context:nil];
        
        
        CGRect newFrameforLabel=CGRectMake(self.bikeNoLabel.frame.origin.x, self.bikeNoLabel.frame.origin.y, expectedLabelSize.size.width+20, expectedLabelSize.size.height);
        
        self.bikeNoLabel.frame=newFrameforLabel;

        //
        
        
        self.driverNameLabel.text = [[[info objectForKey:@"data" ]objectForKey:@"rider"] objectForKey:@"name"];
        self.ratingInDriverSuggestionView.text =[NSString stringWithFormat:@"%@", [[[[info objectForKey:@"data" ] objectForKey:@"rider"] objectForKey:@"rider_metadata"]objectForKey:@"rating_avg"]];
        self.bikeModelLabel.text = [NSString stringWithFormat:@"%@",[[[[info objectForKey:@"data" ] objectForKey:@"rider"] objectForKey:@"rider_metadata"]objectForKey:@"bike_model"]];
        
        phoneNo = [[[info objectForKey:@"data" ]objectForKey:@"rider"] objectForKey:@"phone"];
        
        riderId = [[[[info objectForKey:@"data" ] objectForKey:@"rider"] objectForKey:@"id"]intValue];
        
        [timerForRiderPosition invalidate];
        
        timerForRiderPosition = [NSTimer scheduledTimerWithTimeInterval: 60.0 target: self
                                                               selector: @selector(driverCurrentPosition) userInfo: nil repeats: YES];
        
        
        
        self.timerSupewView.hidden = YES;
        

        
       if (self.driverSuggestionView.isHidden) {
           
           self.onTripLabel.hidden = YES;
           self.phoneButtonInDriverSuggestionView.hidden = NO;
           self.cameraButton.hidden = YES;
           self.locationView.hidden = YES;
           self.backButton.hidden = YES;
           
           if (animationTimer) {
               
               [animationTimer invalidate];
               animationTimer = nil;
               [polylineGray setMap:nil];
           }
           
         [self performSelector:@selector(showDriverSuggestionView) withObject:self afterDelay:1.0 ];
           
       }
    }else if (status == 3){
        
       
            
        [driverPolyline setMap:nil];
        
        isComeFromBackground = 1;
        
        
        [self reSetViewWhenActive:info];
        
        NSLog(@"ride info in when status 3 %@",rideInfo);
        
        self.bikeNoLabel.text = [[[[info objectForKey:@"data" ] objectForKey:@"rider"] objectForKey:@"rider_metadata"] objectForKey:@"bike_number"];

        //set label size
        CGSize maximumLabelSize = CGSizeMake(80, FLT_MAX);

        NSAttributedString *attributedText =
        [[NSAttributedString alloc] initWithString:self.bikeNoLabel.text attributes:@ {
        NSFontAttributeName: self.bikeNoLabel.font
        }];
        CGRect expectedLabelSize = [attributedText boundingRectWithSize:maximumLabelSize
                                                                options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                                                context:nil];


        CGRect newFrameforLabel=CGRectMake(self.bikeNoLabel.frame.origin.x, self.bikeNoLabel.frame.origin.y, expectedLabelSize.size.width+20, expectedLabelSize.size.height);

        self.bikeNoLabel.frame=newFrameforLabel;
        
        
        
        //
        
        self.driverNameLabel.text = [[[info objectForKey:@"data" ]objectForKey:@"rider"] objectForKey:@"name"];
        self.ratingInDriverSuggestionView.text = [NSString stringWithFormat:@"%@", [[[[info objectForKey:@"data" ] objectForKey:@"rider"] objectForKey:@"rider_metadata"]objectForKey:@"rating_avg"]];
        self.bikeModelLabel.text = [NSString stringWithFormat:@"%@",[[[[info objectForKey:@"data" ] objectForKey:@"rider"] objectForKey:@"rider_metadata"]objectForKey:@"bike_model"]];
        
        phoneNo = [[[info objectForKey:@"data" ]objectForKey:@"rider"] objectForKey:@"phone"];
        
        riderId = [[[[info objectForKey:@"data" ] objectForKey:@"rider"] objectForKey:@"id"]intValue];
        
        if (self.driverSuggestionView.isHidden) {
            
            self.onTripLabel.hidden = NO;
            self.cancelButtonHeight.constant = 0;
            self.phoneButtonInDriverSuggestionView.hidden = YES;
            self.cameraButton.hidden = NO;
            self.locationView.hidden = YES;
            self.backButton.hidden = YES;
            
            if (animationTimer) {
                
                [animationTimer invalidate];
                animationTimer = nil;
                [polylineGray setMap:nil];
            }
            
            [self performSelector:@selector(showDriverSuggestionView) withObject:self afterDelay:1.0 ];
            
        }
        
        
        
    }else if (status == 4){
        
        self.whereToButton.hidden = YES;
        
        [self reSetViewWhenActive:info];
        
        if(self.submitFareView.isHidden){
            
            self.bikeNoLabelInSibmitFareView.text = [[[[info objectForKey:@"data" ] objectForKey:@"rider"] objectForKey:@"rider_metadata"] objectForKey:@"bike_number"];
            
            //set label size
            CGSize maximumLabelSize = CGSizeMake(80, FLT_MAX);
            
            NSAttributedString *attributedText =
            [[NSAttributedString alloc] initWithString:self.bikeNoLabelInSibmitFareView.text attributes:@ {
            NSFontAttributeName: self.bikeNoLabelInSibmitFareView.font
            }];
            CGRect expectedLabelSize = [attributedText boundingRectWithSize:maximumLabelSize
                                                                    options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                                                    context:nil];
            
            
            CGRect newFrameforLabel=CGRectMake(self.bikeNoLabelInSibmitFareView.frame.origin.x, self.bikeNoLabelInSibmitFareView.frame.origin.y, expectedLabelSize.size.width+20, expectedLabelSize.size.height);
            
            self.bikeNoLabelInSibmitFareView.frame=newFrameforLabel;
            
            NSLog(@"self.bikeNoLabel %f",self.bikeNoLabel.frame.size.width);
            
            //
            
            self.driverSuggestionView.hidden = YES;
            self.backButton.hidden = YES;
            self.locationView.hidden = YES;
            self.driverNameLabelInSubmitFareView.text = [[[info objectForKey:@"data" ]objectForKey:@"rider"] objectForKey:@"name"];
            self.bikeModelLabelInSubmitFareView.text = [[[[info objectForKey:@"data" ]objectForKey:@"rider"] objectForKey:@"rider_metadata"] objectForKey:@"bike_model"];
            self.rideCostLabel.text =[NSString stringWithFormat:@"%@", [[[info objectForKey:@"data" ]objectForKey:@"detail"] objectForKey:@"total_payable_fare"]];
            self.ratingLabelInSubmitFareView.text = [NSString stringWithFormat:@"%@",[[[[info objectForKey:@"data" ]objectForKey:@"rider"] objectForKey:@"rider_metadata"] objectForKey:@"rating_avg"]];
            
            [self showSubmitFareView];
            
            
        }
            
        
        
    }
    
}

-(void)reSetViewWhenActive:(NSDictionary*)info{
    
    
    self.whereToButton.hidden = YES;
    
    rideId = [[info objectForKey:@"data"]objectForKey:@"id"];
    

    NSLog(@"rider coming");
    [rideInfo setObject:[[info objectForKey:@"data"]objectForKey:@"pickup_address"] forKey:@"pickup_address"];
    [rideInfo setObject:[[info objectForKey:@"data"]objectForKey:@"pickup_latitude"] forKey:@"pickup_latitude"];
    [rideInfo setObject:[[info objectForKey:@"data"]objectForKey:@"pickup_longitude"] forKey:@"pickup_longitude"];
    
    [rideInfo setObject:[[info objectForKey:@"data"]objectForKey:@"destination_address"]forKey:@"destination_address"];
    [rideInfo setObject:[[info objectForKey:@"data"]objectForKey:@"destination_latitude"] forKey:@"destination_latitude"];
    [rideInfo setObject:[[info objectForKey:@"data"]objectForKey:@"destination_longitude"] forKey:@"destination_longitude"];
    
    //NSLog(@"ride info in when status  %@",rideInfo);
    
    
    
    
        
        
        
        pickupPoint = [[CLLocation alloc] initWithLatitude:[[rideInfo objectForKey:@"pickup_latitude"] floatValue] longitude:[[rideInfo objectForKey:@"pickup_longitude"] floatValue]];
        destinationPoint = [[CLLocation alloc] initWithLatitude:[[rideInfo objectForKey:@"destination_latitude"] floatValue] longitude:[[rideInfo objectForKey:@"destination_longitude"] floatValue]];
        
        NSLog(@"pickupPoint %@",pickupPoint);
        
        //set picup marker
        
        if (pickUpMarker) {
            
            pickUpMarker.map = nil;
        }
        pickUpMarker = [[GMSMarker alloc] init];
        
        pickUpMarker.position = CLLocationCoordinate2DMake(pickupPoint.coordinate.latitude, pickupPoint.coordinate.longitude);
        
        pickUpMarker.title = [NSString stringWithFormat:@"%@",[rideInfo objectForKey:@"pickup_address"]];
        
        pickUpMarker.icon = [UIImage imageNamed:@"Pickup.png"];
        
        pickUpMarker.map = self.googleMapView;
        
        // set destination pin
        if (destinationMarker) {
            
            destinationMarker.map = nil;
        }
        
        destinationMarker= [[GMSMarker alloc] init];
        
        destinationMarker.position = CLLocationCoordinate2DMake(destinationPoint.coordinate.latitude, destinationPoint.coordinate.longitude);
        
        destinationMarker.title = [NSString stringWithFormat:@"%@",[rideInfo objectForKey:@"destination_address"]];
        
        destinationMarker.icon = [UIImage imageNamed:@"Destination.png"];
        
        destinationMarker.map = self.googleMapView;
        
        isCalculateFare =0;
        isPolyLineBlue = 1;
        
        [self drawpoliline:pickupPoint destination:destinationPoint isfor:0];
        

    
}

-(void) dataFromSearchLocation:(NSMutableDictionary *)backDataDic{
    
    NSLog(@"backDataDic  %@",backDataDic);
    
    
    
    
    if (isEditPictupText) {
        
        if ([[backDataDic objectForKey:@"Index"] isEqualToString:@"0"]) {
            
            isSaveHomeAddress = 0;
            isSaveWorkAddress = 0;
            
            NSLog(@"set pin for picup");
            
            self.staticPin.hidden = NO;
            
            self.setPinPointDoneButton.hidden = YES;
            
        }else if ([[backDataDic objectForKey:@"Index"] isEqualToString:@"1"])
        {
            NSLog(@"home");
            
            NSString *homeAddress=[NSString stringWithFormat:@"%@",[backDataDic objectForKey:@"latitude"]];
            
            if ([homeAddress length] > 0) {
                
                self.pickUpTextView.text = [NSString stringWithFormat:@"%@", [backDataDic objectForKey:@"address"]];
                
                [rideInfo setObject:[NSString stringWithFormat:@"%@", self.pickUpTextView.text] forKey:@"pickup_address"];
                [rideInfo setObject:[NSString stringWithFormat:@"%@",[backDataDic objectForKey:@"latitude"]] forKey:@"pickup_latitude"];
                [rideInfo setObject:[NSString stringWithFormat:@"%@", [backDataDic objectForKey:@"longitude"]] forKey:@"pickup_longitude"];
                
                if (self.destinationTextView.text.length > 0 && ![self.destinationTextView.text isEqualToString:@"(null)"]) {
                    
                    // [self getPositionOfTheMarkerForIndex:indexPath.row];
                    
                    self.setPinPointDoneButton.hidden = NO;
                    [UIView animateWithDuration:1.0
                                          delay:0
                                        options: UIViewAnimationOptionTransitionNone
                                     animations:^{
                                         
                                         
                                         self.setPinPointDoneButton.frame = CGRectMake(0,(self.view.frame.size.height - self.setPinPointDoneButton.frame.size.height) ,self.setPinPointDoneButton.frame.size.width,self.setPinPointDoneButton.frame.size.height);
                                         
                                         
                                     }
                                     completion:^(BOOL finished){
                                         
                                         
                                     }];
                    
                }
                
            }else
            {
                isSaveHomeAddress = 1;
                isSaveWorkAddress = 0;
                
                NSLog(@"set pin for home");
                
                self.staticPin.hidden = NO;
                
                self.setPinPointDoneButton.hidden = YES;
                
                
            }
            
        }else if ([[backDataDic objectForKey:@"Index"] isEqualToString:@"2"])
        {
            NSLog(@"work");
            
            NSString *workAddress=[NSString stringWithFormat:@"%@",[backDataDic objectForKey:@"latitude"]];
            
            if ([workAddress length] > 0) {
                
                self.pickUpTextView.text = [NSString stringWithFormat:@"%@", [backDataDic objectForKey:@"address"]];
                
                [rideInfo setObject:[NSString stringWithFormat:@"%@", self.pickUpTextView.text] forKey:@"pickup_address"];
                [rideInfo setObject:[NSString stringWithFormat:@"%@",[backDataDic objectForKey:@"latitude"]] forKey:@"pickup_latitude"];
                [rideInfo setObject:[NSString stringWithFormat:@"%@", [backDataDic objectForKey:@"longitude"]] forKey:@"pickup_longitude"];
                
                if (self.destinationTextView.text.length > 0 && ![self.destinationTextView.text isEqualToString:@"(null)"]) {
                    
                    // [self getPositionOfTheMarkerForIndex:indexPath.row];
                    
                    self.setPinPointDoneButton.hidden = NO;
                    
                    [UIView animateWithDuration:1.0
                                          delay:0
                                        options: UIViewAnimationOptionTransitionNone
                                     animations:^{
                                         
                                         
                                         self.setPinPointDoneButton.frame = CGRectMake(0,(self.view.frame.size.height - self.setPinPointDoneButton.frame.size.height) ,self.setPinPointDoneButton.frame.size.width,self.setPinPointDoneButton.frame.size.height);
                                         
                                         
                                     }
                                     completion:^(BOOL finished){
                                         
                                         
                                     }];
                    
                    
                }
                
            }else
            {
                
                isSaveWorkAddress = 1;
                isSaveHomeAddress = 0;
                
                NSLog(@"set pin for work");
                
                self.staticPin.hidden = NO;
                
                self.setPinPointDoneButton.hidden = YES;
                
            }
            
        }else{
        
            self.setPinPointButton.hidden = YES;
            self.setPinPointDoneButton.hidden = YES;

            
            self.pickUpTextView.text =[NSString stringWithFormat:@"%@", [backDataDic objectForKey:@"address"]];
            
            [rideInfo setObject:[NSString stringWithFormat:@"%@", self.pickUpTextView.text] forKey:@"pickup_address"];
            [rideInfo setObject:[NSString stringWithFormat:@"%@",[backDataDic objectForKey:@"latitude"]] forKey:@"pickup_latitude"];
            [rideInfo setObject:[NSString stringWithFormat:@"%@", [backDataDic objectForKey:@"longitude"]] forKey:@"pickup_longitude"];
            
            if (self.destinationTextView.text.length > 0) {
                
                self.setPinPointDoneButton.hidden = NO;
                
                [UIView animateWithDuration:1.0
                                      delay:0
                                    options: UIViewAnimationOptionTransitionNone
                                 animations:^{
                                     
                                     
                                     self.setPinPointDoneButton.frame = CGRectMake(0,(self.view.frame.size.height - self.setPinPointDoneButton.frame.size.height) ,self.setPinPointDoneButton.frame.size.width,self.setPinPointDoneButton.frame.size.height);
                                     
                                     
                                 }
                                 completion:^(BOOL finished){
                                     
                                     
                                 }];
                
                
                
            }
        }
        
        //set picup marker
        
//        if (pickUpMarker) {
//
//            pickUpMarker.map = nil;
//        }
//        pickUpMarker = [[GMSMarker alloc] init];
//
//        pickUpMarker.position = CLLocationCoordinate2DMake([[rideInfo objectForKey:@"pickup_latitude"] floatValue], [[rideInfo objectForKey:@"pickup_longitude"] floatValue]);
//
//        pickUpMarker.icon = [UIImage imageNamed:@"Pickup.png"];
//
//        pickUpMarker.map = self.googleMapView;
        
    }else{
        
        if ([[backDataDic objectForKey:@"Index"] isEqualToString:@"0"]) {
            
            isSaveHomeAddress = 0;
            isSaveWorkAddress = 0;
            
            NSLog(@"set pin for des");
            
            self.staticPin.hidden = NO;
            
            self.setPinPointDoneButton.hidden = YES;
            
        }else if ([[backDataDic objectForKey:@"Index"] isEqualToString:@"1"])
        {
            NSLog(@"home");
            

            NSString *homeAddress=[NSString stringWithFormat:@"%@",[backDataDic objectForKey:@"latitude"]];
            
            if ([homeAddress length] > 0) {
                
                self.destinationTextView.text = [NSString stringWithFormat:@"%@", [backDataDic objectForKey:@"address"]];
                
                [rideInfo setObject:[NSString stringWithFormat:@"%@", self.destinationTextView.text] forKey:@"destination_address"];
                [rideInfo setObject:[NSString stringWithFormat:@"%@",[backDataDic objectForKey:@"latitude"]] forKey:@"destination_latitude"];
                [rideInfo setObject:[NSString stringWithFormat:@"%@", [backDataDic objectForKey:@"longitude"]] forKey:@"destination_longitude"];
                
                if (self.pickUpTextView.text.length > 0 && ![self.pickUpTextView.text isEqualToString:@"(null)"]) {
                    
                    // [self getPositionOfTheMarkerForIndex:indexPath.row];
                    
                    self.setPinPointDoneButton.hidden = NO;
                    [UIView animateWithDuration:1.0
                                          delay:0
                                        options: UIViewAnimationOptionTransitionNone
                                     animations:^{
                                         
                                         
                                         self.setPinPointDoneButton.frame = CGRectMake(0,(self.view.frame.size.height - self.setPinPointDoneButton.frame.size.height) ,self.setPinPointDoneButton.frame.size.width,self.setPinPointDoneButton.frame.size.height);
                                         
                                         
                                     }
                                     completion:^(BOOL finished){
                                         
                                         
                                     }];
                    
                }
                
            }else
            {
                isSaveHomeAddress = 1;
                isSaveWorkAddress = 0;
                
                NSLog(@"set pin for home");
                
                self.staticPin.hidden = NO;
                
                self.setPinPointDoneButton.hidden = YES;
                
            }
            
        }else if ([[backDataDic objectForKey:@"Index"] isEqualToString:@"2"]) {
            
            NSLog(@"work");
            
            NSString *workAddress=[NSString stringWithFormat:@"%@",[backDataDic objectForKey:@"latitude"]];
            
            if ([workAddress length] > 0) {
                
                self.destinationTextView.text = [NSString stringWithFormat:@"%@", [backDataDic objectForKey:@"address"]];
                
                [rideInfo setObject:[NSString stringWithFormat:@"%@", self.destinationTextView.text] forKey:@"destination_address"];
                [rideInfo setObject:[NSString stringWithFormat:@"%@",[backDataDic objectForKey:@"latitude"]] forKey:@"destination_latitude"];
                [rideInfo setObject:[NSString stringWithFormat:@"%@", [backDataDic objectForKey:@"longitude"]] forKey:@"destination_longitude"];
                
                if (self.pickUpTextView.text.length > 0 && ![self.pickUpTextView.text isEqualToString:@"(null)"]) {
                    
                    // [self getPositionOfTheMarkerForIndex:indexPath.row];
                    
                    self.setPinPointDoneButton.hidden = NO;
                    
                    [UIView animateWithDuration:1.0
                                          delay:0
                                        options: UIViewAnimationOptionTransitionNone
                                     animations:^{
                                         
                                         
                                         self.setPinPointDoneButton.frame = CGRectMake(0,(self.view.frame.size.height - self.setPinPointDoneButton.frame.size.height) ,self.setPinPointDoneButton.frame.size.width,self.setPinPointDoneButton.frame.size.height);
                                         
                                         
                                     }
                                     completion:^(BOOL finished){
                                         
                                         
                                     }];
                    
                    
                }
            }else
            {
                
                isSaveWorkAddress = 1;
                isSaveHomeAddress = 0;
                
                NSLog(@"set pin for work");
                
                self.staticPin.hidden = NO;
                
                self.setPinPointDoneButton.hidden = YES;
                
            }
            
        }else{
            
           
            
            self.setPinPointButton.hidden = YES;
            self.setPinPointDoneButton.hidden = YES;
            
            
            self.destinationTextView.text =[NSString stringWithFormat:@"%@", [backDataDic objectForKey:@"address"]];
            
            [rideInfo setObject:[NSString stringWithFormat:@"%@", self.destinationTextView.text] forKey:@"destination_address"];
            [rideInfo setObject:[NSString stringWithFormat:@"%@",[backDataDic objectForKey:@"latitude"]] forKey:@"destination_latitude"];
            [rideInfo setObject:[NSString stringWithFormat:@"%@", [backDataDic objectForKey:@"longitude"]] forKey:@"destination_longitude"];
            
            if (self.pickUpTextView.text.length > 0) {
                
                self.setPinPointDoneButton.hidden = NO;
                
                [UIView animateWithDuration:1.0
                                      delay:0
                                    options: UIViewAnimationOptionTransitionNone
                                 animations:^{
                                     
                                     
                                     self.setPinPointDoneButton.frame = CGRectMake(0,(self.view.frame.size.height - self.setPinPointDoneButton.frame.size.height) ,self.setPinPointDoneButton.frame.size.width,self.setPinPointDoneButton.frame.size.height);
                                     
                                     
                                 }
                                 completion:^(BOOL finished){
                                     
                                     
                                 }];
                
                
                
            }
        }
        
        // set destination pin
//        if (destinationMarker) {
//
//            destinationMarker.map = nil;
//        }
//
//        destinationMarker= [[GMSMarker alloc] init];
//
//        destinationMarker.position = CLLocationCoordinate2DMake([[rideInfo objectForKey:@"destination_latitude"] floatValue], [[rideInfo objectForKey:@"destination_longitude"] floatValue]);
//
//        destinationMarker.icon = [UIImage imageNamed:@"Destination.png"];
//
//        destinationMarker.map = self.googleMapView;
    }
    
}

- (IBAction)backButtonAction:(id)sender {
    
    if (animationTimer) {
        
        [animationTimer invalidate];
        animationTimer = nil;
        [polylineGray setMap:nil];
    }
    
    self.backButton.hidden= YES;
    self.staticPin.hidden =YES;
    self.setPinPointButton.hidden = YES;
    self.setPinPointDoneButton.hidden = YES;
    
    //self.fareView.hidden = YES;
    
    //self.whereToButton.hidden = NO;
    
    self.locationView.hidden = NO;
    self.searchLocationTableView.hidden = YES;
    
    [self.googleMapView clear];
    
    [self.pickUpTextView resignFirstResponder];
    [self.destinationTextView resignFirstResponder];
    
    self.destinationTextView.text = @"";
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:currentLocation.latitude longitude:currentLocation.longitude zoom:16];
    
    [self.googleMapView animateToCameraPosition:camera];
   
    
    
//    if (!self.fareView.isHidden) {
//
//        [UIView animateWithDuration:.5
//                              delay:0
//                            options: UIViewAnimationOptionTransitionNone
//                         animations:^{
//
//
//                             self.fareView.frame = CGRectMake(20,self.fareView.frame.size.height ,self.fareView.frame.size.width, 0);
//
//
//                         }
//                         completion:^(BOOL finished){
    
                             self.fareView.hidden = YES;
                             
                        // }];
        
//    }
    
    
    if (!self.driverSuggestionView.isHidden) {
        
        [UIView animateWithDuration:.5
                              delay:0
                            options: UIViewAnimationOptionTransitionNone
                         animations:^{
                             
                             
                             self.driverSuggestionView.frame = CGRectMake(20,self.view.frame.size.height ,self.driverSuggestionView.frame.size.width, self.driverSuggestionView.frame.size.height);
                             
                             
                         }
                         completion:^(BOOL finished){
                             
                             self.driverSuggestionView.hidden = YES;
                             
                         }];
    }
    
   
    
    
}

- (IBAction)settingButtonAction:(id)sender {
    
    SettingViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"SettingViewController"];
    
    
    [self.navigationController pushViewController:vc animated:YES];
    
}






@end
