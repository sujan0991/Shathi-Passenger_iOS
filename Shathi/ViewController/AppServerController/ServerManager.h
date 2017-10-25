//
//  ServerManager.h
//  ArteVue
//
//  Created by Tanvir Palash on 1/4/17.
//  Copyright © 2016 Tanvir Palash. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "Reachability.h"

@interface ServerManager : NSObject

@property (nonatomic, readwrite) BOOL isNetworkAvailable;

+ (ServerManager *)sharedManager;

- (BOOL)checkForNetworkAvailability;

typedef void (^api_Completion_Handler_Status)(BOOL success);
typedef void (^api_Completion_Handler_Data)(BOOL success, NSMutableDictionary *resultDataDictionary);
typedef void (^api_Completion_Handler_Status_String)(BOOL success, NSString* resultString);



//User SignUp/Login

- (void)postLoginWithPhone:(NSString*)phone accessToken:(NSString*)accesstoken  completion:(api_Completion_Handler_Status)completion;

//User Logout

- (void)postLogOutWithCompletion:(api_Completion_Handler_Data)completion;

//change profile picture

- (void)postProfilePicture:(UIImage*)image completion:(api_Completion_Handler_Data)completion;

//get current user info
- (void)getUserInfoWithCompletion:(api_Completion_Handler_Data)completion;

//get background scenario
- (void)getBackgroundScenarioWithCompletion:(api_Completion_Handler_Data)completion;

//update userInfo

-(void) updateUserDetailsWithData:(NSDictionary*)dataDic withCompletion:(api_Completion_Handler_Data)completion;

//ride request
-(void) postRequestRideWithInfo:(NSMutableDictionary*)rideInfo completion:(api_Completion_Handler_Data)completion;


//get cancel reasons
- (void)getRideCancelReasosnsWithCompletion:(api_Completion_Handler_Data)completion;

//cancel ride with rason

-(void) cancelRideWithReason:(NSDictionary*)dataDic withCompletion:(api_Completion_Handler_Status)completion;

//update gcm key
-(void)patchUpdateGcmKey:(NSDictionary*)dataDic withCompletion:(api_Completion_Handler_Data)completion;

//get history info
- (void)getHistoryInfoWithCompletion:(api_Completion_Handler_Data)completion;

//get single history info
- (void)getSingleHistoryInfo:(NSDictionary*)dataDic  WithCompletion:(api_Completion_Handler_Data)completion;

//rating
-(void)patchRating:(NSDictionary*)dataDic withCompletion:(api_Completion_Handler_Data)completion;

//get fare info
- (void)getFareInfoWithCompletion:(api_Completion_Handler_Data)completion;

//get rider current position
- (void)getRiderPosition:(NSDictionary*)dataDic WithCompletion:(api_Completion_Handler_Data)completion;

@end
