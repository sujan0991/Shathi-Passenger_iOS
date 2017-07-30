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
#import "DDHTimerControl.h"
#import "ServerManager.h"
#import "NSDictionary+NullReplacement.h"
#import "UserAccount.h"


@interface MapViewController (){

    AKFAccountKit *_accountKit;
    
    CLLocationManager *locationManager;

    CLLocationCoordinate2D currentLocation;
    
    //CLLocationCoordinate2D googleMarkerLocation;
    
    CLLocationCoordinate2D googleSearchLocation;
    
    
    CLLocation *picupPoint ;
    CLLocation *destinationPoint;
    
    GMSAutocompleteFetcher *fetcher;
    
    NSMutableArray *searchResults;
    NSMutableArray *searchResultsPlaceId;
    //NSMutableDictionary *reverseGeoResult;
    NSMutableDictionary *rideInfo;
    
    NSMutableDictionary*riderInfo;
    
    NSMutableArray *homeWorkArray;
    
    BOOL isUpdateCameraPosition;
    BOOL isPolyLineBlue;
    BOOL isEditPictupText;
    
    
}

@property (nonatomic, strong) DDHTimerControl *timerControl;
@property (nonatomic, strong) NSDate *endDate;



@end




@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    //demo access token
    
    [UserAccount sharedManager].accessToken = @"eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsImp0aSI6IjBlNWU0NWQyZjJhZTU5OWYyYTJmNzlhYjZlNzNhNjQ3MWQyZDA4YTY1M2Q5M2E2NmFmZTY0ZDIwNTFmYTVjNDc0ZDI0OWEyZmQ5ZmVjYjcyIn0.eyJhdWQiOiIxIiwianRpIjoiMGU1ZTQ1ZDJmMmFlNTk5ZjJhMmY3OWFiNmU3M2E2NDcxZDJkMDhhNjUzZDkzYTY2YWZlNjRkMjA1MWZhNWM0NzRkMjQ5YTJmZDlmZWNiNzIiLCJpYXQiOjE0OTYzMDQ2ODIsIm5iZiI6MTQ5NjMwNDY4MiwiZXhwIjoxNTI3ODQwNjgyLCJzdWIiOiI4Iiwic2NvcGVzIjpbXX0.mxVI2uHlq8Mt5czIiNd6vov1bwdhodKjU2TL9ym97fgQ3qSerc7o4p1zL-sbieTTqUCeMTRqwFegILCB6yw0XE7pHS4cVNVYQanAxKlqy2JJC8P-giNJz06qjGzfbrsDV16o5IY8mU5BZaDHFwUkcl4WX1Jl0Um3UvW3fgDLEVG6JmMetWl2je-EfZWesnwSfdEsVKXP8hTedOi3t7m3cy24vRvIjDBZ2tLmVhj6bKPR9I5yEyidp5nDfu5eEeCMNUjWYKodosdD37VEXH4pdVPzrFmrhSihmyRfB4wkNMjqMBOMIACUqVH4m0G8hqAogsDjfHvje9LSJZKDJOYB5snXELVa9iToKzqJXEEA7SMrzpVtKwmnLeSUwOf6sgxSQn9oVmffhoLv349x4gX8B4zN319sJIV8cjCFD3vvOH9xNSVBE3Be21ihjZdpHxdEwlMAfTRUuOAYJ4aXX3h-BaZN9gltIK2nDx0ysO5ezZqG-tYAQx1kxNUT_NEsiUEqGpdhq9zp0SFrXl31OqNZIdaeXuDO_TRMK_uh1NGONF5i2UnzcqxVBr0e0BLrN-zPtits8wTRY8XGGDpyE2naR2SFegKixpeQPfo9pbzNmkILTu3polO__pAGfBofS3Rs-7znfWgJcItRzpQkLNFLQEx6zWerXZ9Mi5Ako4xq8Dc";
    
    
    isUpdateCameraPosition = 1;
    isPolyLineBlue = 1;
    
    [self checkLocationService];
    
    [self firstViewSetUp];
    [self drawShadow:self.navView];
    [self drawShadow:self.whereToButton];
    [self drawShadow:self.locationView];
    
   
    [self setMap];
    [self setGooglePlacefetcher];
    
    homeWorkArray = [[NSMutableArray alloc]init];
    rideInfo = [[NSMutableDictionary alloc]init];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{

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
    
    self.pickUpTextView.delegate = self;
    self.destinationTextView.delegate = self;
    
    self.crossButtonInPicupTextField.hidden = YES;
    self.crossButtonInDestinationTextField.hidden = YES;
    
    self.backButton.hidden = YES;
    self.locationView.hidden = YES;
    self.searchLocationTableView.hidden = YES;
    
    self.crossButtonInPicupTextField.hidden = YES;
    self.crossButtonInDestinationTextField.hidden= YES;
    

    self.staticPin.hidden = YES;
    self.setPinPointButton.hidden =YES;
    
    self.fareView.hidden = YES;
    self.driverSuggestionView.hidden = YES;
    
    self.timerSupewView.hidden = YES;
    
    self.driverPhoto.layer.cornerRadius = self.driverPhoto.frame.size.width / 2;
    self.driverPhoto.clipsToBounds = YES;
    self.driverPhoto.layer.borderWidth = 5.0f;
    self.driverPhoto.layer.borderColor = [[UIColor hx_colorWithHexString:@"#E9E9E9"]CGColor];
    
    
    
    
    
    self.searchLocationTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.searchLocationTableView.frame.size.width, 1)];
    
    
    [UIView animateWithDuration:2.5
                          delay:0
                        options: UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         
                         CGRect frame = self.whereToButton.frame;
                         frame.origin.y = self.view.frame.size.height - 20;
                         self.whereToButton.frame = frame;
                         
                         
                     }
                     completion:^(BOOL finished){
                         
                     }];
    

    

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidHide:)
                                                 name:UIKeyboardDidHideNotification
                                               object:nil];
    
    
    

    _timerControl = [DDHTimerControl timerControlWithType:DDHTimerTypeEqualElements];
    _timerControl.translatesAutoresizingMaskIntoConstraints = NO;
    _timerControl.color = [UIColor orangeColor];
    _timerControl.highlightColor = [UIColor redColor];
    _timerControl.minutesOrSeconds = 9;
    _timerControl.titleLabel.text = @"sec";
    _timerControl.userInteractionEnabled = NO;
    [self.timerSupewView addSubview:_timerControl];
    

    
    
    [self.timerSupewView addConstraint:[NSLayoutConstraint constraintWithItem:_timerControl attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.timerSupewView attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0.0f]];
    
    [self.timerSupewView addConstraint:[NSLayoutConstraint constraintWithItem:_timerControl attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.timerSupewView attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:0.0f]];
    
    [self.timerSupewView addConstraint:[NSLayoutConstraint constraintWithItem:_timerControl attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:_timerControl attribute:NSLayoutAttributeHeight multiplier:1.0f constant:0.0f]];

    NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(_timerControl);
    
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[_timerControl(100)]" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewsDictionary]];
    
   
    
    
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
    
    
//    self.googleMapView.settings.scrollGestures = YES;
//    self.googleMapView.settings.zoomGestures = YES;
    
    
    currentLocation = locationManager.location.coordinate;
    
    NSLog(@"Current Location = %f, %f",currentLocation.latitude,currentLocation.longitude);
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:currentLocation.latitude longitude:currentLocation.longitude zoom:16];
    
    [self.googleMapView animateToCameraPosition:camera];
    
    self.googleMapView.settings.consumesGesturesInView = YES;
    
    
    

    
    

    
    //Api Call
    
    
    //[self makeRequest];
    
    
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
        
//        NSLog(@"searchResults place ID ::::: %@",prediction.placeID);
    }

    
   // NSLog(@"searchResults place ID ::::: %@",predictions.);
    
    [self.searchLocationTableView reloadData];
    
}

- (void)didFailAutocompleteWithError:(NSError *)error {
    
    //_resultText.text = [NSString stringWithFormat:@"%@", error.localizedDescription];
    
    NSLog(@"didFailAutocompleteWithError %@",error.localizedDescription);
    
}



- (IBAction)whereToButtonAction:(id)sender {
    

    [UIView animateWithDuration:0.2
                          delay:0.2
                        options: UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.whereToButton.frame = CGRectMake(20, 15 ,self.whereToButton.frame.size.width, self.whereToButton.frame.size.height);
                         
                                            }
                     completion:^(BOOL finished){
                         

                         self.whereToButton.hidden = YES;
                         self.backButton.hidden = NO;
                         
                         self.locationView.hidden = NO;
                         self.searchLocationTableView.hidden = NO;
                         
                         self.destinationTextView.text = nil;
                         [searchResults removeAllObjects];
                         
                         if([CLLocationManager locationServicesEnabled]){
                             
                             
                             [[GMSGeocoder geocoder] reverseGeocodeCoordinate:CLLocationCoordinate2DMake(currentLocation.latitude,currentLocation.longitude) completionHandler:^(GMSReverseGeocodeResponse* response, NSError* error) {
                                 
                                 
                                 GMSAddress* firstaddressObj = [response firstResult];
                                 
                                 self.pickUpTextView.text = [NSString stringWithFormat:@"%@", firstaddressObj.thoroughfare];
//                                 NSLog(@"coordinate.latitude=%f", firstaddressObj.coordinate.latitude);
//                                 NSLog(@"coordinate.longitude=%f", firstaddressObj.coordinate.longitude);
                                 
                                 [rideInfo setObject:[NSString stringWithFormat:@"%@", firstaddressObj.thoroughfare] forKey:@"pickup_address"];
                                 [rideInfo setObject:[NSString stringWithFormat:@"%f",firstaddressObj.coordinate.latitude] forKey:@"pickup_latitude"];
                                 [rideInfo setObject:[NSString stringWithFormat:@"%f", firstaddressObj.coordinate.longitude] forKey:@"pickup_longitude"];
                                 
                                
                             }];
                             
                             
                             [self.destinationTextView becomeFirstResponder];
                             
                         }else
                         {
                             
                             [self.pickUpTextView becomeFirstResponder];
                             
                         }
                         [self.searchLocationTableView reloadData];
                     }];
    
    

    
}

#pragma mark - UITableView DataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

        
        if ([self.pickUpTextView isFirstResponder] ) {
            
           // NSLog(@"self.pickUpTextView.text.length %u %u",self.pickUpTextView.text.length,homeWorkArray.count);
            
            if(self.pickUpTextView.text.length == 0 )
            {
                return homeWorkArray.count + 1;
            }
                else{
                //    NSLog(@"searchResults %lu",(unsigned long)searchResults.count);
                 return searchResults.count;
            }
        }
        else if ([self.destinationTextView isFirstResponder]){
           // NSLog(@"destinationTextView %u %u",self.destinationTextView.text.length,homeWorkArray.count);
            
            if(self.destinationTextView.text.length == 0 )
            {
                
                return homeWorkArray.count + 1;
                
            }
            else{
              //  NSLog(@"searchResults  destinationTextView %lu",(unsigned long)searchResults.count);
                
                return searchResults.count;
            }
        
         }
        else
            return 0;

    

    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.pickUpTextView isFirstResponder] ) {
        
        if(self.pickUpTextView.text.length == 0 )
        {
            if(indexPath.row == 0){
                
                static NSString *CellIdentifier = @"Cell";
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
                
                if (!cell)
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
                
                
                cell.textLabel.text = @"Set pin Location";
                cell.textLabel.font = [UIFont systemFontOfSize:13.0];
                cell.imageView.image = [UIImage imageNamed:@"Location.png"];
                
                return cell;
                
            }else {
                
                
                static NSString *CellIdentifier = @"Cell";
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
                
                if (!cell)
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
                
                cell.textLabel.text = @"Home";
                cell.detailTextLabel.text = @"Malibahg";
                cell.textLabel.font = [UIFont systemFontOfSize:13.0];
                cell.imageView.image = [UIImage imageNamed:@"Location.png"];
                
                return cell;
            }
        } else
        {
            static NSString *CellIdentifier = @"Cell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
            
            
            cell.textLabel.text = [searchResults objectAtIndex:indexPath.row];
            cell.textLabel.font = [UIFont systemFontOfSize:13.0];
            cell.imageView.image = [UIImage imageNamed:@"Location.png"];
            
            
            return cell;
        }


    }
    else if ([self.destinationTextView isFirstResponder]){
        
        if(self.destinationTextView.text.length == 0 )
        {
            if(indexPath.row == 0){
                
                static NSString *CellIdentifier = @"Cell";
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
                
                if (!cell)
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
                
                
                cell.textLabel.text = @"Set pin Location";
                cell.textLabel.font = [UIFont systemFontOfSize:13.0];
                cell.imageView.image = [UIImage imageNamed:@"Location.png"];
                
                return cell;
                
            }else {
                
                
                static NSString *CellIdentifier = @"Cell";
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
                
                if (!cell)
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
                
                cell.textLabel.text = @"Home";
                cell.detailTextLabel.text = @"Malibahg";
                cell.textLabel.font = [UIFont systemFontOfSize:13.0];
                cell.imageView.image = [UIImage imageNamed:@"Location.png"];
                
                return cell;
            }

            
        } else
        {
            static NSString *CellIdentifier = @"Cell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
            
            
            cell.textLabel.text = [searchResults objectAtIndex:indexPath.row];
            cell.textLabel.font = [UIFont systemFontOfSize:13.0];
            cell.imageView.image = [UIImage imageNamed:@"Location.png"];
            
            
            return cell;
        }


        
    }
    else
    {
        static NSString *CellIdentifier = @"Cell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
      
        return cell;
    }
    

    
}

#pragma mark - UITableView Delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    self.searchLocationTableView.hidden = YES;
    
    if ([self.pickUpTextView isFirstResponder]) {
        
        [self.pickUpTextView resignFirstResponder];
        
        
        
        if(self.pickUpTextView.text.length == 0 )
        {
            if (indexPath.row == 0) {
                
                NSLog(@"set pin for picup");
                
                self.staticPin.hidden = NO;
                
            }
            else if (indexPath.row == 1){
                
                NSLog(@"Home or work");
                
            }
            else if (indexPath.row == 2){
                
                NSLog(@"work or home");
                
            }
            
            

        }else
        {
            
            self.setPinPointButton.hidden = NO;
            self.pickUpTextView.text=[NSString stringWithFormat:@"%@",[searchResults objectAtIndex:indexPath.row]];
            
            GMSPlacesClient *placesClient = [[GMSPlacesClient alloc]init];
            
            [placesClient lookUpPlaceID:[searchResultsPlaceId objectAtIndex:indexPath.row] callback:^(GMSPlace *place, NSError *error) {
                if (error != nil) {
                    NSLog(@"Place Details error %@", [error localizedDescription]);
                    return;
                }
                
                if (place != nil) {
                    
                    [rideInfo setObject:[NSString stringWithFormat:@"%@", self.pickUpTextView.text] forKey:@"pickup_address"];
                    [rideInfo setObject:[NSString stringWithFormat:@"%f",place.coordinate.latitude] forKey:@"pickup_latitude"];
                    [rideInfo setObject:[NSString stringWithFormat:@"%f", place.coordinate.longitude] forKey:@"pickup_longitude"];
                   
                    GMSMarker *searchMarker = [[GMSMarker alloc] init];
                    
                    searchMarker.position = CLLocationCoordinate2DMake(place.coordinate.latitude, place.coordinate.longitude);
                    
                    searchMarker.icon = [UIImage imageNamed:@"Pin.png"];
                    
                    searchMarker.map = self.googleMapView;
                    
                    
                    //remove after home /work integration
                    
                    if (self.destinationTextView.text.length > 0) {
                        
                        [self getPositionOfTheMarkerForIndex:indexPath.row];
                        
                    }else{
                        
                        [self.destinationTextView becomeFirstResponder];
                        
                    }
                    
                    //
                    
                    
                } else {
                    NSLog(@"No place details for ");
                }
            }];

          
            
        }
        
     

        //after integrating home/work
//        if (self.destinationTextView.text.length > 0) {
//            
//            [self getPositionOfTheMarkerForIndex:indexPath.row];
//            
//        }else{
//            
//            [self.destinationTextView becomeFirstResponder];
//            
//        }
        
    }
    else if([self.destinationTextView isFirstResponder])
    {
        [self.destinationTextView resignFirstResponder];
        
         if(self.destinationTextView.text.length == 0) {
           
             if (indexPath.row == 0) {
                 
                 NSLog(@"set pin for des");
                 
                 self.staticPin.hidden = NO;
                 [self.destinationTextView resignFirstResponder];
                 self.setPinPointButton.hidden = NO;
                 
             }
             else if (indexPath.row == 1){
                 
                 NSLog(@"Home or work");
             }
             else if (indexPath.row == 2){
                 
                 NSLog(@"work or home");
             }

         }else
         {
             self.destinationTextView.text=[NSString stringWithFormat:@"%@",[searchResults objectAtIndex:indexPath.row]];
             
             NSLog(@"[searchResults objectAtIndex:indexPath.row] %@",[searchResults objectAtIndex:indexPath.row]);
             
             NSLog(@" select destination place id %@   ",[searchResultsPlaceId objectAtIndex:indexPath.row]);
             
             GMSPlacesClient *placesClient = [[GMSPlacesClient alloc]init];
             
             [placesClient lookUpPlaceID:[searchResultsPlaceId objectAtIndex:indexPath.row] callback:^(GMSPlace *place, NSError *error) {
                 if (error != nil) {
                     NSLog(@"Place Details error %@", [error localizedDescription]);
                     return;
                 }
                 
                 if (place != nil) {
                     
                     NSLog(@"got destination");
                     
                     [rideInfo setObject:[NSString stringWithFormat:@"%@", self.destinationTextView.text] forKey:@"destination_address"];
                     [rideInfo setObject:[NSString stringWithFormat:@"%f",place.coordinate.latitude] forKey:@"destination_latitude"];
                     [rideInfo setObject:[NSString stringWithFormat:@"%f", place.coordinate.longitude] forKey:@"destination_longitude"];
                     
                     GMSMarker *searchMarker = [[GMSMarker alloc] init];
                     
                     searchMarker.position = CLLocationCoordinate2DMake(place.coordinate.latitude, place.coordinate.longitude);
                     
                     searchMarker.icon = [UIImage imageNamed:@"Pin.png"];
                     
                     searchMarker.map = self.googleMapView;
                     
                     
                     if (self.pickUpTextView.text.length > 0) {
                         
                         [self getPositionOfTheMarkerForIndex:indexPath.row];
                         
                     }else{
                         
                         [self.pickUpTextView becomeFirstResponder];
                         
                     }
                     
                     
                 } else {
                     
                     NSLog(@"No place details for ");
                 }
             }];
             
//             if (self.pickUpTextView.text.length > 0) {
//                 
//                 [self getPositionOfTheMarkerForIndex:indexPath.row];
//                 
//             }else{
//                 
//                 [self.pickUpTextView becomeFirstResponder];
//                 
//             }
            
             

         }
        
    }
    
    
    
}

-(void) getPositionOfTheMarkerForIndex:(NSInteger) index
{
    
    
    NSLog(@"ride info array %@",rideInfo);
    
    
    self.locationView.hidden = YES;
    self.searchLocationTableView.hidden = YES;
    
    picupPoint = [[CLLocation alloc] initWithLatitude:[[rideInfo objectForKey:@"pickup_latitude"] floatValue] longitude:[[rideInfo objectForKey:@"pickup_longitude"] floatValue]];
    destinationPoint = [[CLLocation alloc] initWithLatitude:[[rideInfo objectForKey:@"destination_latitude"] floatValue] longitude:[[rideInfo objectForKey:@"destination_longitude"] floatValue]];
    

    [self drawpoliline:picupPoint destination:destinationPoint];

}

-(void)drawpoliline:(CLLocation *)origin destination:(CLLocation *)destination{


    //draw poliline
    
    NSLog(@"origin.coordinate.latitude  %f  longitude%f",origin.coordinate.latitude,origin.coordinate.longitude);
    NSLog(@"destination.coordinate.latitude %f  longitude%f",destination.coordinate.latitude,destination.coordinate.longitude);
    
    [self fetchPolylineWithOrigin:origin destination:destination completionHandler:^(GMSPolyline *polyline)
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

- (void)fetchPolylineWithOrigin:(CLLocation *)origin destination:(CLLocation *)destination completionHandler:(void (^)(GMSPolyline *))completionHandler
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
                                                     
                                                    
                                                     
                                                     GMSPolyline *polyline = nil;
                                                     if ([routesArray count] > 0)
                                                     {
                                                         NSDictionary *routeDict = [routesArray objectAtIndex:0];
                                                         
                                                        // NSLog(@"routeDict   %@",routeDict);
                                                         
                                                         NSDictionary *routeOverviewPolyline = [routeDict objectForKey:@"overview_polyline"];
                                                         NSString *points = [routeOverviewPolyline objectForKey:@"points"];
                                                         GMSPath *path = [GMSPath pathFromEncodedPath:points];
                                                         polyline = [GMSPolyline polylineWithPath:path];
                                                         polyline.strokeWidth = 3.f;
                                                         
                                                         if (isPolyLineBlue) {

                                                           polyline.strokeColor = [UIColor hx_colorWithHexString:@"262C4E"];
                                                         }else
                                                         {
                                                            polyline.strokeColor = [UIColor lightGrayColor];
                                                            isPolyLineBlue = 1;
                                                             
                                                         }
                                                         NSArray * legs = [[NSArray alloc]init];
                                                         
                                                         legs = [routeDict objectForKey:@"legs"];
                                                         
                                                         //NSLog(@"legs   %@",legs);
                                                         
                                                         NSString *distance = [[[legs objectAtIndex:0]objectForKey:@"distance"]objectForKey:@"text"];
                                                         
                                                         NSLog(@"distance   %@",distance);
                                                         
                                                         NSString *time = [[[legs objectAtIndex:0]objectForKey:@"duration"]objectForKey:@"text"];
                                                         
                                                         NSLog(@"duration   %@",time);
                                                         
                                                         
                                                     }
                                                     
                                                     // run completionHandler on main thread                                           
                                                     dispatch_sync(dispatch_get_main_queue(), ^{
                                                         
                                                         if(completionHandler)
                                                             completionHandler(polyline);
                                                         
                                                     });
                                                 }];
    [fetchDirectionsTask resume];
}

-(void)updateCameraPosition:(GMSMutablePath*)path {
    
    
    
    GMSCoordinateBounds *bounds =[[GMSCoordinateBounds alloc] initWithPath:path];
    
    GMSCameraUpdate *update = [GMSCameraUpdate fitBounds:bounds
                                             withPadding:100.0f];
    [self.googleMapView moveCamera:update];
    //[self.googleMapView animateToZoom:14];
    [self.googleMapView animateToViewingAngle:35];
    
    
    [self performSelector:@selector(showFareView) withObject:self afterDelay:2.0 ];

}

- (void) mapView:(GMSMapView *)mapView idleAtCameraPosition:(GMSCameraPosition *)position{
    
    if (!self.staticPin.isHidden) {
        
        
        
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
    
    self.staticPin.hidden = YES;
    self.setPinPointButton.hidden = YES;
    self.locationView.hidden = YES;
    
    picupPoint = [[CLLocation alloc] initWithLatitude:[[rideInfo objectForKey:@"pickup_latitude"] floatValue] longitude:[[rideInfo objectForKey:@"pickup_longitude"] floatValue]];
    destinationPoint = [[CLLocation alloc] initWithLatitude:[[rideInfo objectForKey:@"destination_latitude"] floatValue] longitude:[[rideInfo objectForKey:@"destination_longitude"] floatValue]];
    
    
    NSLog(@"ride info array in setPinPointButtonAction %@",rideInfo);
    
    GMSMarker *searchMarker = [[GMSMarker alloc] init];
    
    searchMarker.position = CLLocationCoordinate2DMake(destinationPoint.coordinate.latitude, destinationPoint.coordinate.longitude);
    
    searchMarker.icon = [UIImage imageNamed:@"Pin.png"];
    
    searchMarker.map = self.googleMapView;
    
    
    
    [self drawpoliline:picupPoint destination:destinationPoint];
    
    
}

-(void) showFareView{


    self.fareView.hidden = NO;
    self.fareView.frame = CGRectMake(0,self.view.frame.size.height ,self.fareView.frame.size.width,self.fareView.frame.size.height);
    
    [UIView animateWithDuration:.5
                          delay:0
                        options: UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         
                         
                         self.fareView.frame = CGRectMake(0,(self.view.frame.size.height - self.fareView.frame.size.height) ,self.fareView.frame.size.width,self.fareView.frame.size.height);
                         
                         
                     }
                     completion:^(BOOL finished){
                         
                     }];


}

- (IBAction)tapOnTextField:(UITextField*)sender {
    
    
    if([sender isEqual:self.pickUpTextView])
    {
        [self.destinationTextView resignFirstResponder];
        self.crossButtonInDestinationTextField.hidden = YES;

        
        if(self.pickUpTextView.text.length>0)
        {
            self.crossButtonInPicupTextField.hidden = NO;
            
        }
        else
            self.crossButtonInPicupTextField.hidden = YES;
        
    }
    else{
        
        [self.pickUpTextView resignFirstResponder];
        self.crossButtonInPicupTextField.hidden = YES;
        
        if(self.destinationTextView.text.length>0)
        {
            self.crossButtonInDestinationTextField.hidden = NO;
            
        }
        else
            self.crossButtonInDestinationTextField.hidden = YES;

    }
    [sender becomeFirstResponder];
    
    

    [self.searchLocationTableView reloadData];
   
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    
    if ([textField isEqual:self.pickUpTextView]) {
        
        isEditPictupText = 1;
        
    }else if ([textField isEqual:self.destinationTextView])
    {
    
        isEditPictupText = 0;

    }
    [self.searchLocationTableView reloadData];
    
    
    NSLog(@"isEditPictupText  %hhd",isEditPictupText);
    
    return YES;
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{

//    NSString *textString =[textField.text stringByReplacingCharactersInRange:range withString:string];
// 
//    if([textField isEqual:self.pickUpTextView] )
//    {
//        if(textString.length<=0)
//        {
//            self.crossButtonInPicupTextField.hidden = YES;
//
//        }
//        else
//        {
//            self.crossButtonInPicupTextField.hidden = NO;
//
//        }
//        
//    }
//    else if ([textField isEqual:self.destinationTextView])
//    {
//        if(textString.length <= 0)
//        {
//            self.crossButtonInDestinationTextField.hidden = YES;
//        }
//        else
//        {
//            self.crossButtonInDestinationTextField.hidden = NO;
//        }
//      
//    }
    self.searchLocationTableView.hidden = NO;
    


    
    return YES;
}



- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    [self.pickUpTextView resignFirstResponder];
    [self.destinationTextView resignFirstResponder];
    
    
    return YES;
}

- (IBAction)textFieldCrossButtonAction:(UIButton*)sender {
    
    //self.searchLocationTableView.hidden=YES;
    
    
    if([sender isEqual:self.crossButtonInPicupTextField]){
        
        self.pickUpTextView.text = nil;
       // self.customPicUpButton.hidden = NO;
        
    }else{
        
        self.destinationTextView.text =nil;
        //self.customDestinationButton.hidden = NO;
        
    }
    sender.hidden=YES;
    [self.searchLocationTableView reloadData];

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
   
     self.searchLocationTableView.hidden = NO;
}

- (void)keyboardDidHide: (NSNotification *) notif{
    
    self.searchLocationTableView.hidden = YES;
}



- (IBAction)turnOnLocationServiceButtonAction:(id)sender {
    
    

    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:nil];
        
        
   
}

- (IBAction)enterPicupButtonAction:(id)sender {
    
    
    self.locationServiceView.hidden = YES;
    self.whereToButton.hidden = YES;
    self.locationView.hidden = NO;
    self.backButton.hidden = NO;
    
    [self.pickUpTextView becomeFirstResponder];
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:23.8103 longitude:90.4125 zoom:16];
    
    [self.googleMapView animateToCameraPosition:camera];
    
    
}
- (IBAction)requestRideButtonAction:(id)sender {
    
    //NSLog(@"ride info  %@",rideInfo);
    
    [UIView animateWithDuration:.5
                          delay:0
                        options: UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         
                         
                         self.fareView.frame = CGRectMake(0,self.view.frame.size.height ,self.fareView.frame.size.width, 0);
                         
                         
                     }
                     completion:^(BOOL finished){
                         
                         self.fareView.hidden = YES;
                         self.timerSupewView.hidden = NO;
                         
                          [self timer];
                         

                         
                         [[ServerManager sharedManager] postRequestRideWithInfo:rideInfo completion:^(BOOL success, NSMutableDictionary *responseObject) {
                             
                             
                             if ( responseObject!=nil) {
                                 
                                 
                                 
                                 riderInfo= [[NSMutableDictionary alloc] initWithDictionary:[responseObject dictionaryByReplacingNullsWithBlanks]];
                                 
                                 NSLog(@"responseObject %@",riderInfo);
                                 
                                 self.timerSupewView.hidden = YES;
                                 
                                 [self performSelector:@selector(showDriverSuggestionView) withObject:self afterDelay:1.0 ];
                                 
                             }else{
                                 
                                 dispatch_async(dispatch_get_main_queue(), ^{
                                     
                                     NSLog(@"no  info");
                                     
                                     
                                 });
                                 
                             }
                         }];

                         
                     }];
    

    
}

-(void) timer{
    
    [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(changeTimer:) userInfo:nil repeats:YES];
    self.endDate = [NSDate dateWithTimeIntervalSinceNow:60.0f];
    
}


- (void)changeTimer:(NSTimer*)timer {
    
    NSTimeInterval timeInterval = [self.endDate timeIntervalSinceNow];
    
    self.timerControl.minutesOrSeconds = ((NSInteger)timeInterval)%60;
    
    if (self.timerControl.minutesOrSeconds == 0) {
        
        self.timerSupewView.hidden = YES;
        
        
    }
}

-(void) showDriverSuggestionView{
    
    
    isUpdateCameraPosition = 0;
    isPolyLineBlue = 0;
    
    self.driverNameLabel.text = [NSString stringWithFormat:@"%@", [[riderInfo objectForKey:@"data"] objectForKey:@"name"]];
    
    

    self.driverSuggestionView.hidden = NO;
    self.driverSuggestionView.frame = CGRectMake(20,self.view.frame.size.height ,self.driverSuggestionView.frame.size.width,self.driverSuggestionView.frame.size.height);
    
    [UIView animateWithDuration:.5
                          delay:0
                        options: UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         
                         
                         self.driverSuggestionView.frame = CGRectMake(20,(self.view.frame.size.height - self.driverSuggestionView.frame.size.height-20) ,self.driverSuggestionView.frame.size.width,self.driverSuggestionView.frame.size.height);
                         
                         
                     }
                     completion:^(BOOL finished){
                         
                         
                     }];
    
    
    
    
    NSString * riderlat =[[riderInfo objectForKey:@"data"] objectForKey:@"current_latitude"];
    NSString * riderlong = [[riderInfo objectForKey:@"data"] objectForKey:@"current_longitude"];

    CLLocation *passengerLocation = [[CLLocation alloc] initWithLatitude:currentLocation.latitude longitude:currentLocation.longitude];
    CLLocation *riderLocation = [[CLLocation alloc] initWithLatitude:[riderlat floatValue] longitude:[riderlong floatValue]];
 
    //GMSMarker *riderMarker = [[GMSMarker alloc] init];
    
    CLLocationCoordinate2D position = CLLocationCoordinate2DMake([riderlat floatValue], [riderlong floatValue]);
    
    GMSMarker *riderMarker = [GMSMarker markerWithPosition:position];
    
    riderMarker.icon = [UIImage imageNamed:@"bike.png"];
    
    riderMarker.map = self.googleMapView;
    
    
    
    [self drawpoliline:passengerLocation destination:riderLocation];
    
    
}

- (IBAction)paymentButtonAction:(id)sender {
    
    
}
- (IBAction)smsDriverButtonAction:(id)sender {
    
    
}
- (IBAction)phoneDriverButtonAction:(id)sender {
    
    
}
- (IBAction)cancelRideButtonAction:(id)sender {
    

    [UIView animateWithDuration:.5
                          delay:0
                        options: UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         
                         
                         self.driverSuggestionView.frame = CGRectMake(20,self.view.frame.size.height ,self.driverSuggestionView.frame.size.width, 0);
                         
                         
                     }
                     completion:^(BOOL finished){
                         
                         self.driverSuggestionView.hidden = YES;
                         
                         self.whereToButton.hidden = NO;
                         self.backButton.hidden = YES;
                         
                         [self.googleMapView clear];
                         
                         GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:currentLocation.latitude longitude:currentLocation.longitude zoom:16];
                         
                         [self.googleMapView animateToCameraPosition:camera];
                         
                         
                     }];
}

- (IBAction)timerViewCrossButtonAction:(id)sender {
    
    self.timerSupewView.hidden = YES;
    
}


- (IBAction)backButtonAction:(id)sender {
    
    self.backButton.hidden= YES;
    self.staticPin.hidden =YES;
    //self.fareView.hidden = YES;
    
    self.whereToButton.hidden = NO;
    
    self.locationView.hidden = YES;
    self.searchLocationTableView.hidden = YES;
    
    [self.googleMapView clear];
    
    [self.pickUpTextView resignFirstResponder];
    [self.destinationTextView resignFirstResponder];
    
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:currentLocation.latitude longitude:currentLocation.longitude zoom:16];
    
    [self.googleMapView animateToCameraPosition:camera];
   
    
    
    
    
    [UIView animateWithDuration:.5
                          delay:0
                        options: UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         
                         
                         self.fareView.frame = CGRectMake(0,self.view.frame.size.height ,self.fareView.frame.size.width, 0);
                         
                         
                     }
                     completion:^(BOOL finished){
                         
                         self.fareView.hidden = YES;
                         
                     }];
    
    [UIView animateWithDuration:.5
                          delay:0
                        options: UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         
                         
                         self.driverSuggestionView.frame = CGRectMake(20,self.view.frame.size.height ,self.driverSuggestionView.frame.size.width, 0);
                         
                         
                     }
                     completion:^(BOOL finished){
                         
                         self.driverSuggestionView.hidden = YES;
                         
                     }];
    
    
}

- (IBAction)settingButtonAction:(id)sender {
    
    SettingViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"SettingViewController"];
    
    [self.navigationController pushViewController:vc animated:YES];
    
}






@end
