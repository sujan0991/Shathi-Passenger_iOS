//
//  SearchLocationViewController.m
//  Shathi
//
//  Created by Sujan on 11/8/17.
//  Copyright © 2017 Sujan. All rights reserved.
//

#import "SearchLocationViewController.h"
#import "ServerManager.h"
#import "NSDictionary+NullReplacement.h"


@interface SearchLocationViewController (){
    
    GMSAutocompleteFetcher *fetcher;
    NSMutableArray *secondarySearchResults;
    NSMutableArray *primarySearchResults;
    NSMutableArray *searchResultsPlaceId;
    
    NSMutableDictionary *backDataDictionary;
}



@end

@implementation SearchLocationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
    
    
    self.searchTextField.delegate = self;
    self.searchLocationTableView.delegate = self;
    self.searchLocationTableView.dataSource = self;
    
    [self setGooglePlacefetcher];
    
    self.searchLocationTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.searchLocationTableView.frame.size.width, 1)];
    
    [self.searchTextField becomeFirstResponder];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    
    self.searchLocationTableView.estimatedRowHeight = 60.0;
    self.searchLocationTableView.rowHeight = UITableViewAutomaticDimension;
    
    
    [self getUserInfo];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) getUserInfo{
    
    
    [[ServerManager sharedManager] getUserInfoWithCompletion:^(BOOL success, NSMutableDictionary *responseObject) {
        
        
        if ( responseObject!=nil) {
            
            
            
            self.userInfo= [[NSMutableDictionary alloc] initWithDictionary:[responseObject dictionaryByReplacingNullsWithBlanks]];
            
            NSLog(@"user info %@",self.userInfo);
            
            [self.searchLocationTableView reloadData];
            
        }else{
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                NSLog(@"no user info");
                
                
            });
            
        }
    }];
    
    
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
    
    [self.searchTextField addTarget:self
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
    
    secondarySearchResults = [[NSMutableArray alloc] init];
    primarySearchResults = [[NSMutableArray alloc] init];
    searchResultsPlaceId = [[NSMutableArray alloc]init];
    
    
    for (GMSAutocompletePrediction *prediction in predictions) {
        [resultsStr appendFormat:@"%@\n", [prediction.attributedPrimaryText string]];
        
        NSLog(@"attributedPrimaryText %@",resultsStr);
        
        [primarySearchResults addObject:prediction.attributedPrimaryText.string];
        [secondarySearchResults addObject:prediction.attributedSecondaryText.string];
        
        [searchResultsPlaceId addObject:prediction.placeID];
        
        //        NSLog(@"secondary place ID ::::: %@",prediction.placeID);
    }
    
    
    // NSLog(@"secondary place ID ::::: %@",predictions.);
    
    [self.searchLocationTableView reloadData];
    
}

- (void)didFailAutocompleteWithError:(NSError *)error {
    
    //_resultText.text = [NSString stringWithFormat:@"%@", error.localizedDescription];
    
    NSLog(@"didFailAutocompleteWithError %@",error.localizedDescription);
    
}

#pragma mark - UITableView DataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
   
    NSLog(@"self.searchTextField.text.length %lu",self.searchTextField.text.length);
    
            if(self.searchTextField.text.length == 0 )
            {
               
                return 3;
            }
            else{
                
                return primarySearchResults.count;
            }
    
        
   
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if (!cell)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    
    cell.textLabel.font = [UIFont systemFontOfSize:13.0];
    
    if(self.searchTextField.text.length == 0 )
    {
        if(indexPath.row == 0){
            
            
            
            
            cell.textLabel.text = @"Set pin Location";
            cell.detailTextLabel.text =@"";
            
            cell.imageView.image = [UIImage imageNamed:@"Location.png"];
            
            return cell;
            
        }else if(indexPath.row == 1){
            
            NSString *homeAddress=[NSString stringWithFormat:@"%@",[[self.userInfo objectForKey:@"metadata"]objectForKey:@"home_latitude"] ];
            
            NSLog(@"homeAddress %@",homeAddress);
            cell.imageView.image = [UIImage imageNamed:@"home.png"];
            
            if ([homeAddress length] > 0) {
                
                cell.textLabel.text = @"Home";
                cell.detailTextLabel.text =@"";
            }
            else
            {
                cell.textLabel.text = @"Add Home Address";
                cell.detailTextLabel.text =@"";
                
            }
            //cell.detailTextLabel.text = @"Malibahg";
            
            //cell.imageView.image = [UIImage imageNamed:@"Location.png"];
            
            return cell;
            
        }else if(indexPath.row == 2){
            
            NSString *workAddress=[NSString stringWithFormat:@"%@",[[self.userInfo objectForKey:@"metadata"]objectForKey:@"work_latitude"] ];
            
            NSLog(@"workAddress %@",workAddress);
            
            cell.imageView.image = [UIImage imageNamed:@"work.png"];
            
            if ([workAddress length] > 0) {
                
                cell.textLabel.text = @"Work";
                cell.detailTextLabel.text =@"";
            }
            else
            {
                cell.textLabel.text = @"Add Work Address";
                cell.detailTextLabel.text =@"";
                
            }
            
            //cell.imageView.image = [UIImage imageNamed:@"Location.png"];
            
            return cell;
        }
    } else
    {
        
        cell.textLabel.text = [primarySearchResults objectAtIndex:indexPath.row];
        cell.detailTextLabel.text = [secondarySearchResults objectAtIndex:indexPath.row];
        // cell.textLabel.font = [UIFont systemFontOfSize:13.0];
        cell.imageView.image = [UIImage imageNamed:@"Location.png"];
        
        
        return cell;
   
     }
    
    return nil;
}

#pragma mark - UITableView Delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    backDataDictionary = [[NSMutableDictionary alloc]init];
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
      self.searchLocationTableView.hidden = YES;
      [self.searchTextField resignFirstResponder];
    
    if(self.searchTextField.text.length == 0 )
    {
        if (indexPath.row == 0) {
            
            [backDataDictionary setObject:@"0" forKey:@"Index"];
            
            [self.dataBackDelegate dataFromSearchLocation:backDataDictionary];
            
            [self.navigationController popViewControllerAnimated:YES];
            
        }else if (indexPath.row == 1){
            
            [backDataDictionary setObject:@"1" forKey:@"Index"];
            
            [backDataDictionary setObject:[NSString stringWithFormat:@"%@", [[self.userInfo objectForKey:@"metadata"]objectForKey:@"home_address_title"]] forKey:@"address"];
            [backDataDictionary setObject:[NSString stringWithFormat:@"%@",[[self.userInfo objectForKey:@"metadata"]objectForKey:@"home_latitude"]] forKey:@"latitude"];
            [backDataDictionary setObject:[NSString stringWithFormat:@"%@", [[self.userInfo objectForKey:@"metadata"]objectForKey:@"home_longitude"]] forKey:@"longitude"];
            
            [self.dataBackDelegate dataFromSearchLocation:backDataDictionary];
            
            [self.navigationController popViewControllerAnimated:YES];
            

            
        }else if (indexPath.row == 2){
            
            [backDataDictionary setObject:@"2" forKey:@"Index"];
            
            [backDataDictionary setObject:[NSString stringWithFormat:@"%@", [[self.userInfo objectForKey:@"metadata"]objectForKey:@"work_address_title"]] forKey:@"address"];
            [backDataDictionary setObject:[NSString stringWithFormat:@"%@",[[self.userInfo objectForKey:@"metadata"]objectForKey:@"work_latitude"]] forKey:@"latitude"];
            [backDataDictionary setObject:[NSString stringWithFormat:@"%@", [[self.userInfo objectForKey:@"metadata"]objectForKey:@"work_longitude"]] forKey:@"longitude"];
            
            
            [self.dataBackDelegate dataFromSearchLocation:backDataDictionary];
            
            [self.navigationController popViewControllerAnimated:YES];
        }
        
    }else{
        
        self.searchTextField.text=[NSString stringWithFormat:@"%@",[primarySearchResults objectAtIndex:indexPath.row]];
        
        GMSPlacesClient *placesClient = [[GMSPlacesClient alloc]init];
        
        NSLog(@" select destination place id %@   ",[searchResultsPlaceId objectAtIndex:indexPath.row]);
       

        [placesClient lookUpPlaceID:[searchResultsPlaceId objectAtIndex:indexPath.row] callback:^(GMSPlace *place, NSError *error) {
            if (error != nil) {
                NSLog(@"Place Details error %@", [error localizedDescription]);
                return;
            }
            
            if (place != nil) {
                
                [backDataDictionary setObject:[NSString stringWithFormat:@"%@", [primarySearchResults objectAtIndex:indexPath.row]] forKey:@"address"];
                [backDataDictionary setObject:[NSString stringWithFormat:@"%f",place.coordinate.latitude] forKey:@"latitude"];
                [backDataDictionary setObject:[NSString stringWithFormat:@"%f", place.coordinate.longitude] forKey:@"longitude"];
                
                [self.dataBackDelegate dataFromSearchLocation:backDataDictionary];
                
                [self.navigationController popViewControllerAnimated:YES];
                
            }else {
                NSLog(@"No place details for ");
            }
        }];
        
        
    }
    
    
}

- (IBAction)tapOnTextField:(UITextField *)sender {
    
//    if(self.searchTextField.text.length>0)
//    {
//        self.crossButton.hidden = NO;
//
//    }
//    else
//        self.crossButton.hidden = YES;
    
    
    [sender becomeFirstResponder];

    [self.searchLocationTableView reloadData];
    
}
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    
    [self.searchLocationTableView reloadData];
    
//    if(self.searchTextField.text.length>0)
//    {
//        self.crossButton.hidden = NO;
//
//    }
//    else
//        self.crossButton.hidden = YES;
//
    
    
    
   
    
    return YES;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    [self.searchTextField resignFirstResponder];
    
    return YES;
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *textString =[textField.text stringByReplacingCharactersInRange:range withString:string];
    
    if(textString.length<=0)
    {
        self.crossButton.hidden = YES;
        
    }
    else
    {
       self.crossButton.hidden = NO;
        
    }
    
    self.searchLocationTableView.hidden = NO;

    return YES;
}
- (IBAction)crossButtonAction:(UIButton*)sender {
    
    self.searchTextField.text = nil;
    
    sender.hidden=YES;
    [self.searchLocationTableView reloadData];

}

- (void)keyboardDidShow: (NSNotification *) notif{
    
    
    NSDictionary* info = [notif userInfo];
    
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    NSLog(@"keyboard height %f",kbSize.height);
    
    //self.cancelReasonViewCenterConstraint.constant = -kbSize.height * 0.6;
    
    self.tableViewHeight.constant = (self.view.bounds.size.height - kbSize.height -80);
    
}

-(void)viewWillDisappear:(BOOL)animated
{
   // [self.dataBackDelegate sendDataToMap:backDataDictionary];
    
}

- (IBAction)backButtonAction:(id)sender {
    
   [self.navigationController popViewControllerAnimated:YES];
}


@end
