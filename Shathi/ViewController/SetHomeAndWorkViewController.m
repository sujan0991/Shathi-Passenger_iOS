//
//  SetHomeAndWorkViewController.m
//  Shathi
//
//  Created by Sujan on 10/29/17.
//  Copyright © 2017 Sujan. All rights reserved.
//

#import "SetHomeAndWorkViewController.h"
#import "ServerManager.h"
#import "JTMaterialSpinner.h"

@interface SetHomeAndWorkViewController (){
    
    JTMaterialSpinner *spinner;
    
    CLLocationManager *locationManager;
    
    CLLocationCoordinate2D currentLocation;
    
    CLLocationCoordinate2D googleSearchLocation;

    GMSAutocompleteFetcher *fetcher;
    
    NSMutableArray *searchResults;
    NSMutableArray *searchResultsPlaceId;
    NSString * selectedPlaceId;
    
    NSMutableDictionary * selectedLocationDic;
    
    BOOL isSelectFromTable;
    
}

@end

@implementation SetHomeAndWorkViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"isSaveHomeAddress %d",self.isSaveHomeAddress);
    
    [self viewSetUp];
    
    [self setMap];
    [self setGooglePlacefetcher];
    
    isSelectFromTable = 0;
    
    spinner=[[JTMaterialSpinner alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2 - 17, self.view.frame.size.height/2 - 17, 35, 35)];
    [self.view bringSubviewToFront:spinner];
    [self.view addSubview:spinner];
    spinner.hidden =YES;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) viewSetUp
{
    self.searchLocationTableView.delegate = self;
    self.searchLocationTableView.dataSource = self;
  
    self.locationTextField.delegate = self;
    
    self.searchLocationTableView.hidden = YES;
    
  
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
    

    
    [self.locationTextField addTarget:self
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
    
    
    [self.searchLocationTableView reloadData];
    
}

- (void)didFailAutocompleteWithError:(NSError *)error {
    
    //_resultText.text = [NSString stringWithFormat:@"%@", error.localizedDescription];
    
    NSLog(@"didFailAutocompleteWithError %@",error.localizedDescription);
    
}

#pragma mark - UITableView DataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return searchResults.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if (!cell)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    
    
    cell.textLabel.text = [searchResults objectAtIndex:indexPath.row];
    cell.textLabel.font = [UIFont systemFontOfSize:13.0];
    cell.imageView.image = [UIImage imageNamed:@"Location.png"];
   
    
    return cell;
    
}

#pragma mark - UITableView Delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    self.searchLocationTableView.hidden = YES;
    [self.locationTextField resignFirstResponder];
    
    self.locationTextField.text=[NSString stringWithFormat:@"%@",[searchResults objectAtIndex:indexPath.row]];
    
//    selectedPlaceId = [searchResultsPlaceId objectAtIndex:indexPath.row];
//
//    NSLog(@" selectedPlaceId %@",selectedPlaceId);
    
    
    GMSPlacesClient *placesClient = [[GMSPlacesClient alloc]init];
    
    [placesClient lookUpPlaceID:[searchResultsPlaceId objectAtIndex:indexPath.row] callback:^(GMSPlace *place, NSError *error) {
        if (error != nil) {
            NSLog(@"Place Details error %@", [error localizedDescription]);
            return;
        }
        
        if (place != nil) {
            
            selectedLocationDic = [[NSMutableDictionary alloc]init];
            
            [selectedLocationDic setObject:[NSString stringWithFormat:@"%@", self.locationTextField.text] forKey:@"address"];
            [selectedLocationDic setObject:[NSString stringWithFormat:@"%f",place.coordinate.latitude] forKey:@"latitude"];
            [selectedLocationDic setObject:[NSString stringWithFormat:@"%f", place.coordinate.longitude] forKey:@"longitude"];
            
            NSLog(@"selectedLocationDic  %@",selectedLocationDic);
            
            
            GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:place.coordinate.latitude longitude:place.coordinate.longitude zoom:16];
            
            [self.googleMapView animateToCameraPosition:camera];
            
            isSelectFromTable = 1;

            
        } else {
            NSLog(@"No place details for ");
        }
    }];
    
}

- (void)mapView:(GMSMapView *)mapView willMove:(BOOL)gesture{
    
    NSLog(@"gesture  %d",gesture);
    
    if (gesture) {
        
        isSelectFromTable = 0;
    }
    
}


- (void) mapView:(GMSMapView *)mapView idleAtCameraPosition:(GMSCameraPosition *)position{
    
    if (!isSelectFromTable) {
        
        
        NSLog(@"position.target.latitude %f",position.target.latitude);
        NSLog(@"position.target.longitude %f",position.target.longitude);
        
        [[GMSGeocoder geocoder] reverseGeocodeCoordinate:CLLocationCoordinate2DMake(position.target.latitude,position.target.longitude) completionHandler:^(GMSReverseGeocodeResponse* response, NSError* error) {
            
            
            GMSAddress* firstaddressObj = [response firstResult];

                self.locationTextField.text = [NSString stringWithFormat:@"%@", firstaddressObj.thoroughfare];
            
                selectedLocationDic = [[NSMutableDictionary alloc]init];
            
                [selectedLocationDic setObject:[NSString stringWithFormat:@"%@", self.locationTextField.text] forKey:@"address"];
                [selectedLocationDic setObject:[NSString stringWithFormat:@"%f",position.target.latitude] forKey:@"latitude"];
                [selectedLocationDic setObject:[NSString stringWithFormat:@"%f", position.target.longitude] forKey:@"longitude"];
                
            NSLog(@"selectedLocationDic  %@",selectedLocationDic);
            
            NSLog(@"reverse geocoding firstaddressObj: %@",firstaddressObj.thoroughfare);
        }];

    }
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{

        [self.locationTextField resignFirstResponder];
        
        NSLog(@"Is it called");
   
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    [self.locationTextField resignFirstResponder];
    
    self.searchLocationTableView.hidden = YES;
    
    return YES;
}
- (IBAction)tapOnTextField:(id)sender {
    
    self.searchLocationTableView.hidden = NO;
    
    if(self.locationTextField.text.length>0)
    {
        self.crossButton.hidden = NO;
        
    }
    else
        self.crossButton.hidden = YES;
    
    
}


- (IBAction)textFieldCrossButtonAction:(UIButton *)sender {
    
    self.locationTextField.text =nil;

    sender.hidden=YES;
    [self.searchLocationTableView reloadData];
    
}
- (IBAction)doneButtonAction:(id)sender {
    
    spinner.hidden =NO;
    [spinner beginRefreshing];
    
    NSMutableDictionary* postData=[[NSMutableDictionary alloc] init];
    
    if (self.isSaveHomeAddress) {
        
        [postData setObject:[NSString stringWithFormat:@"%@",[selectedLocationDic objectForKey:@"address"]] forKey:@"home_address_title"];
        [postData setObject:[NSString stringWithFormat:@"%@",[selectedLocationDic objectForKey:@"latitude"]] forKey:@"home_latitude"];
        [postData setObject:[NSString stringWithFormat:@"%@",[selectedLocationDic objectForKey:@"longitude"]] forKey:@"home_longitude"];
        
    }else{
        
        [postData setObject:[NSString stringWithFormat:@"%@",[selectedLocationDic objectForKey:@"address"]] forKey:@"work_address_title"];
        [postData setObject:[NSString stringWithFormat:@"%@",[selectedLocationDic objectForKey:@"latitude"]] forKey:@"work_latitude"];
        [postData setObject:[NSString stringWithFormat:@"%@",[selectedLocationDic objectForKey:@"longitude"]] forKey:@"work_longitude"];
    }
    
    [[ServerManager sharedManager] patchUpdateHomeAndWork:postData withCompletion:^(BOOL success, NSMutableDictionary *resultDataDictionary) {
        
        if ( resultDataDictionary!=nil) {
            
            NSLog(@"  info  %@",resultDataDictionary);
          
            spinner.hidden =YES;
            [spinner endRefreshing];
            
            [self.navigationController popViewControllerAnimated:YES];
            
        }else{
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                NSLog(@"no  info");
                
                
            });
            
        }
        
        
        
    }];
    
}

- (IBAction)currentLocationbuttonAction:(id)sender {
    
    
}


- (IBAction)backButtonAction:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}


@end
