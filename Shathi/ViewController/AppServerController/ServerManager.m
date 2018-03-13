//
//  ServerManager.m
//  ArteVue
//
//  Created by Tanvir Palash on 1/4/17.
//  Copyright © 2016 Tanvir Palash. All rights reserved.
//

#import "ServerManager.h"
#import "UserAccount.h"
#import "Constants.h"
#import "SynthesizeSingleton.h"
#import <AFNetworking/AFNetworking.h>

#import "NSDictionary+NullReplacement.h"
#import "NSArray+NullReplacement.h"

#pragma mark - interface
@interface ServerManager(){
    Reachability *networkReachability;
}

DECLARE_SINGLETON_FOR_CLASS(ServerManager)

@end

#pragma mark - imlementation
@implementation ServerManager

SYNTHESIZE_SINGLETON_FOR_CLASS(ServerManager)

@synthesize isNetworkAvailable;

#pragma mark - init
- (id)init{
    if (self = [super init]){
    }
    return self;
}




/* ***** API ***** */

#pragma mark -  API - FUNCTIONS


- (void)postLoginWithPhone:(NSString*)phone accessToken:(NSString*)accesstoken completion:(api_Completion_Handler_Status)completion{
    
    if ([self checkForNetworkAvailability]) {
        
        NSMutableDictionary *parameterDic = [[NSMutableDictionary alloc] init];
        
        [parameterDic setObject:phone forKey:@"phone"];
        [parameterDic setObject:accesstoken forKey:@"social_media_access_token"];
        [parameterDic setObject:[UserAccount sharedManager].gcmRegKey forKey:@"gcm_registration_key"];
        [parameterDic setObject:@"3" forKey:@"user_type_id"];

       
        dispatch_queue_t backgroundQueue = dispatch_queue_create("Background Queue", NULL);
      
        dispatch_async(backgroundQueue, ^{
            
            [self postServerRequestWithParams:parameterDic forUrl:[NSString stringWithFormat:@"%@/api/user",BASE_API_URL] withResponseCallback:^(NSDictionary *responseDictionary) {
                //[self validateResponseData:responseDictionary] &&
                if ( responseDictionary!=nil) {
                    //Valid Data From Server
                    
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        [UserAccount sharedManager].accessToken = [responseDictionary objectForKey:@"access_token"];
                        
                        NSLog(@"access token from api %@",[[UserAccount sharedManager]accessToken]);
                        
                        completion(TRUE);
                    });
                    
                }else{
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completion(FALSE);
                    });
                    
                }

            }];
            
            
        });
    }else{
        
        [self showAlertForNoInternet];
    }
    
}

- (void)postLogOutWithCompletion:(api_Completion_Handler_Data)completion{
    
    if ([self checkForNetworkAvailability]) {
        
        
        dispatch_queue_t backgroundQueue = dispatch_queue_create("Background Queue", NULL);
        
        dispatch_async(backgroundQueue, ^{
            
            [self postServerRequestWithParams:nil forUrl:[NSString stringWithFormat:@"%@/api/logout",BASE_API_URL] withResponseCallback:^(NSDictionary *responseDictionary) {
                //[self validateResponseData:responseDictionary] &&
                if ( responseDictionary!=nil) {
                    //Valid Data From Server
                    
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        
                        completion(TRUE,[responseDictionary mutableCopy]);
                        
                    });
                    
                }else{
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completion(FALSE,nil);
                    });
                    
                }
                
            }];
            
            
        });
    }else{
        
        [self showAlertForNoInternet];
    }
    
}


- (void)postProfilePicture:(UIImage*)image completion:(api_Completion_Handler_Data)completion{
    
    if ([self checkForNetworkAvailability]) {
        
        
        NSString *urlString=[NSString stringWithFormat:@"%@/api/update-profile-picture",BASE_API_URL];
        
        
        dispatch_queue_t backgroundQueue = dispatch_queue_create("Background Queue", NULL);
        
        dispatch_async(backgroundQueue, ^{
            
            NSData *imageData = [self compressImageForPP:image];
            
            [self postServerRequestForImage:imageData WithParams:nil forUrl:urlString keyValue:@"profile_picture" withResponseCallback:^(NSDictionary *responseDictionary) {
                
 
                if ( responseDictionary!=nil) {
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        completion(TRUE,[responseDictionary mutableCopy]);
                    });
                    
                }else{
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completion(FALSE,nil);
                    });
                    
                }
                
            }];
            
            
        });
    }else{
        [self showAlertForNoInternet];
    }
    
}

- (void)getUserInfoWithCompletion:(api_Completion_Handler_Data)completion{
    
    if ([self checkForNetworkAvailability]) {
        
        
        NSString *httpUrl=[NSString stringWithFormat:@"%@/api/user",BASE_API_URL];
        
        dispatch_queue_t backgroundQueue = dispatch_queue_create("Background Queue", NULL);
        dispatch_async(backgroundQueue, ^{
            
            [self getServerRequestForUrl:httpUrl withResponseCallback:^(NSDictionary *responseDictionary) {
                
                
                if ( responseDictionary!=nil) {
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                       [UserAccount sharedManager].name = [responseDictionary objectForKey:@"name"];
                       [UserAccount sharedManager].phoneNumber = [responseDictionary objectForKey:@"phone"];
                       [UserAccount sharedManager].email = [responseDictionary objectForKey:@"email"];
                        
                       completion(TRUE,[responseDictionary mutableCopy]);
                        
                    });
                    
                }else{
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completion(FALSE,nil);
                    });
                }
            }];
        });
        
    }else{
        [self showAlertForNoInternet];
    }
}

-(void)patchUpdateHomeAndWork:(NSDictionary*)dataDic withCompletion:(api_Completion_Handler_Data)completion{

    if ([self checkForNetworkAvailability]) {
        
        
        NSString *urlString=[NSString stringWithFormat:@"%@/api/update-home-and-work",BASE_API_URL];
        
        
        dispatch_queue_t backgroundQueue = dispatch_queue_create("Background Queue", NULL);
        
        dispatch_async(backgroundQueue, ^{
            
            [self patchServerRequestWithParams:dataDic forUrl:urlString withResponseCallback:^(NSDictionary *responseDictionary) {
                
                if ( responseDictionary!=nil) {
                    //Valid Data From Server
                    
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completion(TRUE,[responseDictionary mutableCopy]);
                    });
                    
                }else{
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completion(FALSE,nil);
                    });
                    
                }
            }];
            
        });
    }else{
        [self showAlertForNoInternet];
    }
    
    
}

- (void)getBackgroundScenarioWithCompletion:(api_Completion_Handler_Data)completion{
    
    if ([self checkForNetworkAvailability]) {
        
        
        NSString *httpUrl=[NSString stringWithFormat:@"%@/api/user-app-background-scenario",BASE_API_URL];
        
        dispatch_queue_t backgroundQueue = dispatch_queue_create("Background Queue", NULL);
        dispatch_async(backgroundQueue, ^{
            
            [self getServerRequestForUrl:httpUrl withResponseCallback:^(NSDictionary *responseDictionary) {
                
                
                if ( responseDictionary!=nil) {
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        
                        
                        completion(TRUE,[responseDictionary mutableCopy]);
                        
                    });
                    
                }else{
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completion(FALSE,nil);
                    });
                }
            }];
        });
        
    }else{
        [self showAlertForNoInternet];
    }
}
-(void) updateUserDetailsWithData:(NSDictionary*)dataDic withCompletion:(api_Completion_Handler_Data)completion
{
    if ([self checkForNetworkAvailability]) {
        
        
        NSString *urlString=[NSString stringWithFormat:@"%@/api/user",BASE_API_URL];
    
        
        dispatch_queue_t backgroundQueue = dispatch_queue_create("Background Queue", NULL);
        
        dispatch_async(backgroundQueue, ^{
            
            [self patchServerRequestWithParams:dataDic forUrl:urlString withResponseCallback:^(NSDictionary *responseDictionary) {
                
                if ( responseDictionary!=nil) {
                    //Valid Data From Server
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completion(TRUE,[responseDictionary mutableCopy]);

                    });
                    
                }else{
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completion(FALSE,nil);
                    });
                    
                }
            }];
            
        });
    }else{
        [self showAlertForNoInternet];
    }



}

-(void) postRequestRideWithInfo:(NSMutableDictionary*)rideInfo completion:(api_Completion_Handler_Data)completion{
 
        
        if ([self checkForNetworkAvailability]) {
            
//            NSMutableDictionary *parameterDic = [[NSMutableDictionary alloc] init];
//            
//            parameterDic = rideInfo;
//            
//             NSLog(@"parameterDic %@",parameterDic);
            
            dispatch_queue_t backgroundQueue = dispatch_queue_create("Background Queue", NULL);
            
            dispatch_async(backgroundQueue, ^{
                
                
                
                
                [self postServerRequestWithParams:rideInfo forUrl:[NSString stringWithFormat:@"%@/api/request-ride",BASE_API_URL] withResponseCallback:^(NSDictionary *responseDictionary) {
                    //[self validateResponseData:responseDictionary] &&
                    if ( responseDictionary!=nil) {
                        //Valid Data From Server
                        
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            

                           // NSLog(@"requset ride return %@",responseDictionary);
                            
                            completion(TRUE,[responseDictionary mutableCopy]);
                            
                        });
                        
                    }else{
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            
                            completion(FALSE,nil);
                            
                        });
                        
                    }
                    
                }];
                
                
            });
        }else{
            
            [self showAlertForNoInternet];
        }
        

    
    
}

- (void)getRideCancelReasosnsWithCompletion:(api_Completion_Handler_Data)completion{
    
    if ([self checkForNetworkAvailability]) {
        
        
        NSString *httpUrl=[NSString stringWithFormat:@"%@/api/get-cancel-reasons",BASE_API_URL];
        
        dispatch_queue_t backgroundQueue = dispatch_queue_create("Background Queue", NULL);
        dispatch_async(backgroundQueue, ^{
            
            [self getServerRequestForUrl:httpUrl withResponseCallback:^(NSDictionary *responseDictionary) {
                
                
                if ( responseDictionary!=nil) {
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        NSLog(@"reasons %@",responseDictionary);
                        
                        completion(TRUE,[responseDictionary mutableCopy]);
                        
                    });
                    
                }else{
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completion(FALSE,nil);
                    });
                }
            }];
        });
        
    }else{
        [self showAlertForNoInternet];
    }
}

-(void) cancelRideWithReason:(NSDictionary *)dataDic withCompletion:(api_Completion_Handler_Status)completion
{
    if ([self checkForNetworkAvailability]) {
        
        
        NSString *urlString=[NSString stringWithFormat:@"%@/api/cancel-ride",BASE_API_URL];
        
        
        dispatch_queue_t backgroundQueue = dispatch_queue_create("Background Queue", NULL);
        
        dispatch_async(backgroundQueue, ^{
            
            [self patchServerRequestWithParams:dataDic forUrl:urlString withResponseCallback:^(NSDictionary *responseDictionary) {
                
                if ( responseDictionary!=nil) {
                    //Valid Data From Server
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completion(TRUE);
                    });
                    
                }else{
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completion(FALSE);
                    });
                    
                }
            }];
            
        });
    }else{
        [self showAlertForNoInternet];
    }
    
    
    
}

-(void)patchUpdateGcmKey:(NSDictionary*)dataDic withCompletion:(api_Completion_Handler_Data)completion{
    
    
    
    if ([self checkForNetworkAvailability]) {
        
        
        NSString *urlString=[NSString stringWithFormat:@"%@/api/update-gcm-registration-key",BASE_API_URL];
        
        
        dispatch_queue_t backgroundQueue = dispatch_queue_create("Background Queue", NULL);
        
        dispatch_async(backgroundQueue, ^{
            
            [self patchServerRequestWithParams:dataDic forUrl:urlString withResponseCallback:^(NSDictionary *responseDictionary) {
                
                if ( responseDictionary!=nil) {
                    //Valid Data From Server
                    
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completion(TRUE,[responseDictionary mutableCopy]);
                    });
                    
                }else{
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completion(FALSE,nil);
                    });
                    
                }
            }];
            
        });
    }else{
        [self showAlertForNoInternet];
    }
    
    
}

- (void)getHistoryInfoWithCompletion:(api_Completion_Handler_Data)completion{
    
    if ([self checkForNetworkAvailability]) {
        
        
        NSString *httpUrl=[NSString stringWithFormat:@"%@/api/ride-history",BASE_API_URL];
        
        dispatch_queue_t backgroundQueue = dispatch_queue_create("Background Queue", NULL);
        dispatch_async(backgroundQueue, ^{
            
            [self getServerRequestForUrl:httpUrl withResponseCallback:^(NSDictionary *responseDictionary) {
                
                
                if ( responseDictionary!=nil) {
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        
                        
                        completion(TRUE,[responseDictionary mutableCopy]);
                        
                    });
                    
                }else{
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completion(FALSE,nil);
                    });
                }
            }];
        });
        
    }else{
        [self showAlertForNoInternet];
    }
}
- (void)getSingleHistoryInfo:(NSDictionary*)dataDic  WithCompletion:(api_Completion_Handler_Data)completion{
    
    if ([self checkForNetworkAvailability]) {
        
        
        NSString *httpUrl=[NSString stringWithFormat:@"%@/api/single-ride-history",BASE_API_URL];
        
        dispatch_queue_t backgroundQueue = dispatch_queue_create("Background Queue", NULL);
        dispatch_async(backgroundQueue, ^{
            
            [self getServerRequestForUrl:httpUrl withparameters:dataDic  withResponseCallback:^(NSDictionary *responseDictionary) {
                
                
                if ( responseDictionary!=nil) {
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        
                        
                        completion(TRUE,[responseDictionary mutableCopy]);
                        
                    });
                    
                }else{
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completion(FALSE,nil);
                    });
                }
            }];
        });
        
    }else{
        [self showAlertForNoInternet];
    }
}

-(void)patchRating:(NSDictionary*)dataDic withCompletion:(api_Completion_Handler_Data)completion{
    
    
    
    if ([self checkForNetworkAvailability]) {
        
        
        NSString *urlString=[NSString stringWithFormat:@"%@/api/ride-rating",BASE_API_URL];
        
        
        dispatch_queue_t backgroundQueue = dispatch_queue_create("Background Queue", NULL);
        
        dispatch_async(backgroundQueue, ^{
            
            [self patchServerRequestWithParams:dataDic forUrl:urlString withResponseCallback:^(NSDictionary *responseDictionary) {
                
                if ( responseDictionary!=nil) {
                    //Valid Data From Server
                    
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completion(TRUE,[responseDictionary mutableCopy]);
                    });
                    
                }else{
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completion(FALSE,nil);
                    });
                    
                }
            }];
            
        });
    }else{
        [self showAlertForNoInternet];
    }
    
    
}

- (void)getFareInfoWithCompletion:(api_Completion_Handler_Data)completion{
    
    if ([self checkForNetworkAvailability]) {
        
        
        NSString *httpUrl=[NSString stringWithFormat:@"%@/api/fare-settings",BASE_API_URL];
        
        dispatch_queue_t backgroundQueue = dispatch_queue_create("Background Queue", NULL);
        dispatch_async(backgroundQueue, ^{
            
            [self getServerRequestForUrl:httpUrl withResponseCallback:^(NSDictionary *responseDictionary) {
                
                
                if ( responseDictionary!=nil) {
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        
                        
                        completion(TRUE,[responseDictionary mutableCopy]);
                        
                    });
                    
                }else{
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completion(FALSE,nil);
                    });
                }
            }];
        });
        
    }else{
        [self showAlertForNoInternet];
    }
}

- (void)getRiderPosition:(NSDictionary*)dataDic WithCompletion:(api_Completion_Handler_Data)completion{
    
    
        
        if ([self checkForNetworkAvailability]) {
            
            
            NSString *httpUrl=[NSString stringWithFormat:@"%@/api/rider-current-location",BASE_API_URL];
            
            dispatch_queue_t backgroundQueue = dispatch_queue_create("Background Queue", NULL);
            dispatch_async(backgroundQueue, ^{
                
                [self getServerRequestForUrl:httpUrl withparameters:dataDic withResponseCallback:^(NSDictionary *responseDictionary) {
                    
                    
                    if ( responseDictionary!=nil) {
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            
                            
                            
                            completion(TRUE,[responseDictionary mutableCopy]);
                            
                        });
                        
                    }else{
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            completion(FALSE,nil);
                        });
                    }
                }];
            });
            
        }else{
            [self showAlertForNoInternet];
        }
    
}

#pragma mark - Server Request
-(void)postServerRequestWithParams:(NSDictionary*)params forUrl:(NSString*)url withResponseCallback:(void (^)(NSDictionary *responseDictionary))callback
{
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes=[NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html", nil];
    
    
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@",[UserAccount sharedManager].accessToken] forHTTPHeaderField:@"Authorization"];
    
    [manager POST:[url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]] parameters:params progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        
        NSHTTPURLResponse *response = (NSHTTPURLResponse *) [task response];
    
        if ([response statusCode] == 200) {
            
            callback([responseObject dictionaryByReplacingNullsWithBlanks]);
            
        }
        else{
            callback(nil);
        }
        
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"error %@ error %@",operation.response,error);
        
        NSLog(@"operation  response %@",operation.response);
        
        callback(nil);
    }];
    

}

-(void)getServerRequestForUrl:(NSString*)url withResponseCallback:(void (^)(NSDictionary *responseDictionary))callback
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes=[NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html", nil];
    
   // NSLog(@"JSON: %@", [UserAccount sharedManager].accessToken);
    
    
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@",[UserAccount sharedManager].accessToken] forHTTPHeaderField:@"Authorization"];
    
    [manager GET:[url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]] parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        
        
        NSLog(@"JSON: %@", responseObject);
        
        NSHTTPURLResponse *response = (NSHTTPURLResponse *) [task response];
        
        if ([response statusCode] == 200) {
            
            callback([responseObject dictionaryByReplacingNullsWithBlanks]);
            
        }
        else{
            callback(nil);
        }
        
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        
        NSLog(@"error %@ ", operation.response);
        
        callback(nil);
    }];
    

}
-(void)getServerRequestForUrl:(NSString*)url withparameters:(NSDictionary*)params withResponseCallback:(void (^)(NSDictionary *responseDictionary))callback
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes=[NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html", nil];
    
    
    
    
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@",[UserAccount sharedManager].accessToken] forHTTPHeaderField:@"Authorization"];
    
    [manager GET:[url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]] parameters:params progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        
        
        NSLog(@"JSON: %@", responseObject);
        
        NSHTTPURLResponse *response = (NSHTTPURLResponse *) [task response];
        
        if ([response statusCode] == 200) {
            
            callback([responseObject dictionaryByReplacingNullsWithBlanks]);
            
        }
        else{
            callback(nil);
        }
        
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        
        NSLog(@"error %@ ", operation.response);
        
        callback(nil);
    }];
    
    
}

//-(void)deleteServerRequestForUrl:(NSString*)url withResponseCallback:(void (^)(NSDictionary *responseDictionary))callback
//{
//    
//    AFHTTPRequestOperationManager *apiLoginManager = [AFHTTPRequestOperationManager manager];
//    apiLoginManager.responseSerializer = [AFJSONResponseSerializer serializer];
//    
//    [apiLoginManager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@",[UserAccount sharedManager].accessToken] forHTTPHeaderField:@"Authorization"];
//    
//    [apiLoginManager DELETE:[url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSLog(@"responseObject %@",responseObject);
//        
//        if ([operation.response statusCode] == 200) {
//            
//            callback([responseObject dictionaryByReplacingNullsWithBlanks]);
//            
//        }
//        else{
//            callback(nil);
//        }
//        
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        NSLog(@"error %@",error);
//        callback(nil);
//    }];
//}
//
//-(void)putServerRequestWithParams:(NSDictionary*)params forUrl:(NSString*)url withResponseCallback:(void (^)(NSDictionary *responseDictionary))callback
//{
//    AFHTTPRequestOperationManager *apiLoginManager = [AFHTTPRequestOperationManager manager];
//    apiLoginManager.responseSerializer = [AFJSONResponseSerializer serializer];
//    apiLoginManager.requestSerializer = [AFJSONRequestSerializer serializer];
//    
//    
//    [apiLoginManager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@",[UserAccount sharedManager].accessToken] forHTTPHeaderField:@"Authorization"];
//    //[apiLoginManager.requestSerializer setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
//    
//    [apiLoginManager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
//    
//    [apiLoginManager PUT:[url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        
//        NSLog(@"responseObject %@",responseObject);
//        if ([operation.response statusCode] == 200) {
//            
//            callback([responseObject dictionaryByReplacingNullsWithBlanks]);
//            
//        }
//        else{
//            callback(nil);
//        }
//        
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        NSLog(@"error %@ %@",error,operation.responseString);
//        callback(nil);;
//    }];
//}
//
//
-(void)patchServerRequestWithParams:(NSDictionary*)params forUrl:(NSString*)url withResponseCallback:(void (^)(NSDictionary *responseDictionary))callback
{
    
    NSLog(@"params %@ url %@",params,url);
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer=[AFJSONResponseSerializer serializer];
    

    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@",[UserAccount sharedManager].accessToken] forHTTPHeaderField:@"Authorization"];
    [manager.requestSerializer setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    [manager PATCH:[url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]] parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSLog(@"JSON update user: %@", responseObject);
        
        NSHTTPURLResponse *response = (NSHTTPURLResponse *) [task response];
        
        if ([response statusCode] == 200) {
            
            callback([responseObject dictionaryByReplacingNullsWithBlanks]);
            
        }
        else{
            callback(nil);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        NSLog(@"error %@ ",error);
        callback(nil);
        
    }];
    
    
}

-(void)postServerRequestForImage:(NSData*)imageData WithParams:(NSDictionary*)params forUrl:(NSString*)url keyValue:(NSString*)keyName withResponseCallback:(void (^)(NSDictionary *responseDictionary))callback
{
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
        
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@",[UserAccount sharedManager].accessToken] forHTTPHeaderField:@"Authorization"];
    
    [manager POST:[url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]] parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
        [formData appendPartWithFileData:imageData
                                    name:keyName
                                fileName:[NSString stringWithFormat:@"%@.jpg",keyName ] mimeType:@"image/jpeg"];
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
        
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        
        NSHTTPURLResponse *response = (NSHTTPURLResponse *) [task response];
        
        NSLog(@"responseDictionary pro pic change %@",response);
        
        if ([response statusCode] == 200) {
            
            callback([responseObject dictionaryByReplacingNullsWithBlanks]);
            
        }
        else{
            callback(nil);
        }
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"error %@ ",error);
        callback(nil);
    }];
        
    
}

//Call to server for data
//- (void) makeServerRequestWithStringParams:(NSString*)params withResponseCallback:(void (^)(NSDictionary *responseDictionary))callback {
//    dispatch_queue_t apiQueue = dispatch_queue_create("API Queue", NULL);
//    dispatch_async(apiQueue, ^{
//        
//        @autoreleasepool {
//            NSURL *url = [NSURL URLWithString:SERVER_BASE_API_URL];
//            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
//            request.HTTPMethod = @"POST";
//            request.HTTPBody = [params dataUsingEncoding:NSUTF8StringEncoding];
//            
//            NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
//            sessionConfiguration.timeoutIntervalForResource = 60.0;
//            NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration];
//            NSURLSessionDataTask *postDataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
//                if (!error) {
//                    NSHTTPURLResponse *httpResp = (NSHTTPURLResponse*) response;
//                    //XLog(@"#### %@ ####", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
//                    if (httpResp.statusCode == 200) {
//                        NSError *jsonError;
//                        //XLog(@"Data 2: %@",data);
//                        NSDictionary *jsonData =
//                        [NSJSONSerialization JSONObjectWithData:data
//                                                        options:NSJSONReadingAllowFragments
//                                                          error:&jsonError];
//                        if (!jsonError) {
//                            //XLog(@"jsonData # %@ - Data - %@",params,jsonData);
//                            callback(jsonData);
//                        }else{
//                            //XLog(@"JsonError # Error - %@",jsonError);
//                            callback(nil);
//                        }
//                    }
//                }else{
//                    callback(nil);
//                }
//            }];
//            
//            [postDataTask resume];
//        }
//    });
//    
//}
//#pragma mark -
//#pragma mark - Server Request
////Call to server for data
//- (void) makeServerRequestWithParams:(NSDictionary*)params withResponseCallback:(void (^)(NSDictionary *responseDictionary))callback {
//
//    dispatch_queue_t apiQueue = dispatch_queue_create("API Queue", NULL);
//    dispatch_async(apiQueue, ^{
//        
//        NSURL *url = [NSURL URLWithString:SERVER_BASE_API_URL];
//        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
//        request.HTTPMethod = @"POST";
//        request.HTTPBody = [[self urlStringFromDictionary:params] dataUsingEncoding:NSUTF8StringEncoding];
//        
//        NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
//        NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration];
//        NSURLSessionDataTask *postDataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
//            if (!error) {
//                NSHTTPURLResponse *httpResp = (NSHTTPURLResponse*) response;
//                //XLog(@"#### %@ ####", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
//                if (httpResp.statusCode == 200) {
//                    NSError *jsonError;
//                    //XLog(@"Data 2: %@",data);
//                    NSDictionary *jsonData =
//                    [NSJSONSerialization JSONObjectWithData:data
//                                                    options:NSJSONReadingAllowFragments
//                                                      error:&jsonError];
//                    if (!jsonError) {
//                        //XLog(@"jsonData # %@ - Data - %@",params,jsonData);
//                        callback(jsonData);
//                    }else{
//                        //XLog(@"JsonError # Error - %@",jsonError);
//                        callback(nil);
//                    }
//                }
//            }else{
//                callback(nil);
//            }
//        }];
//        
//        [postDataTask resume];
//    });
//    
//}
//



-(NSData*)compressImageForPP: (UIImage *)img
{
    float MAX_UPLOAD_SIZE=100;
    float MIN_UPLOAD_RESOLUTION=100*100;
    float factor;
    float resol = img.size.height*img.size.width;
    if (resol >MIN_UPLOAD_RESOLUTION){
        factor = sqrt(resol/MIN_UPLOAD_RESOLUTION)*2;
        img = [self scaleDown:img withSize:CGSizeMake(img.size.width/factor, img.size.height/factor)];
    }
    
    //Compress the image
    CGFloat compression = 1.0f;
    CGFloat maxCompression = 0.5f;
    
    NSData *imageData = UIImageJPEGRepresentation(img, compression);
    
    while ([imageData length] > MAX_UPLOAD_SIZE && compression > maxCompression)
    {
        compression -= 0.10;
        imageData = UIImageJPEGRepresentation(img, compression);
        NSLog(@"Compress : %lu",(unsigned long)imageData.length);
    }
    return imageData;
}

- (UIImage*)scaleDown:(UIImage*)img withSize:(CGSize)newSize{
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [img drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}


//Check status for valid data from server
- (BOOL)validateResponseData:(NSDictionary*)responseDictionary{
    
    if ([[responseDictionary objectForKey:@"status"] integerValue]==5) {

        dispatch_async(dispatch_get_main_queue(), ^{
            [self performSelector:@selector(present) withObject:nil afterDelay: 0.1];
        });
        
    }
    
    return [[responseDictionary objectForKey:@"status"] integerValue]!=1?FALSE:TRUE;
}

- (void)present{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"xxx" object:nil];
}

//Convert Parameter Dictionary to Single string parameter
//#pragma mark - Dictionary to String
//- (NSString *)urlStringFromDictionary:(NSDictionary*)dict{
//    NSArray *keys;
//    int i, count;
//    id key, value;
//    
//    keys = [dict allKeys];
//    count = (int)[keys count];
//    
//    NSString *paramString = @"";
//    
//    for (i = count-1; i >= 0; i--){
//        key = [keys objectAtIndex: i];
//        value = [dict objectForKey: key];
//        if (![paramString isEqualToString:@""])paramString = [paramString stringByAppendingString:@"&"];
//        paramString = [paramString stringByAppendingString:[NSString stringWithFormat:@"%@=%@",key,value]];
//        
//    }
//    
//    return paramString;
//}

#pragma mark - Network Reachability
- (BOOL)checkForNetworkAvailability{
    networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    
    if ((networkStatus != ReachableViaWiFi) && (networkStatus != ReachableViaWWAN)) {
        self.isNetworkAvailable = FALSE;
    }else{
        self.isNetworkAvailable = TRUE;
    }
    
    return self.isNetworkAvailable;
}




//server not available
- (void)showAlertForNoInternet{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"No internet connection available" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        alert = nil;
        
          });
}

@end
