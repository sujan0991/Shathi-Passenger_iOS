//
//  Recipe.m
//  RecipeApp
//
//  Created by Simon on 25/12/13.
//  Copyright (c) 2013 Appcoda. All rights reserved.
//

#import "UserAccount.h"


@interface UserAccount ()

DECLARE_SINGLETON_FOR_CLASS(UserAccount)

@property (nonatomic, retain) NSUserDefaults *userDefaults;

@end


@implementation UserAccount

SYNTHESIZE_SINGLETON_FOR_CLASS(UserAccount)
@synthesize userDefaults = _userDefaults;


#pragma mark - init
- (id)init{
    if (self = [super init]){
        
        self.userDefaults = [NSUserDefaults standardUserDefaults];
        [self.userDefaults synchronize];
    }
    return self;
}

-(int)userId{
    return [[self.userDefaults stringForKey:@"userId"] intValue];
}

- (void)setUserId:(int)value
{
    [self.userDefaults setInteger:value forKey:@"userId"];
    [self.userDefaults synchronize];
}


-(NSString*) isLoggedIn
{
    return [self.userDefaults objectForKey:@"isLoggedIn"];
}

- (void)setIsLoggedIn:(NSString *)value
{
    [self.userDefaults setObject:value forKey:@"isLoggedIn"];
    [self.userDefaults synchronize];
}


-(NSString*) userType
{
    return [self.userDefaults objectForKey:@"userType"];
}

- (void)setUserType:(NSString *)value
{
    [self.userDefaults setObject:value forKey:@"userType"];
    [self.userDefaults synchronize];
}

-(NSString*) userTypeId
{
    return [self.userDefaults objectForKey:@"userTypeId"];
}

- (void)setUserTypeId:(NSString *)value
{
    [self.userDefaults setObject:value forKey:@"userTypeId"];
    [self.userDefaults synchronize];
}

-(NSString*)phoneNumber
{
    return [self.userDefaults objectForKey:@"phoneNumber"];
}

- (void)setPhoneNumber:(NSString *)value
{
    [self.userDefaults setObject:value forKey:@"phoneNumber"];
    [self.userDefaults synchronize];
}
-(NSString*)name
{
    return [self.userDefaults objectForKey:@"name"];
}

- (void)setName:(NSString *)value
{
    [self.userDefaults setObject:value forKey:@"name"];
    [self.userDefaults synchronize];
}
-(NSString*)lastName
{
    return [self.userDefaults objectForKey:@"lastName"];
}

- (void)setLastName:(NSString *)value
{
    [self.userDefaults setObject:value forKey:@"lastName"];
    [self.userDefaults synchronize];
}
-(NSString*)sex
{
    return [self.userDefaults objectForKey:@"sex"];
}

- (void)setSex:(NSString *)value
{
    [self.userDefaults setObject:value forKey:@"sex"];
    [self.userDefaults synchronize];
}

-(NSString*)email
{
    return [self.userDefaults objectForKey:@"email"];
}

- (void)setEmail:(NSString *)value
{
    [self.userDefaults setObject:value forKey:@"email"];
    [self.userDefaults synchronize];
}



-(NSString*)accessToken
{
    return [self.userDefaults objectForKey:@"accessToken"];
}

- (void)setAccessToken:(NSString *)value
{
    [self.userDefaults setObject:value forKey:@"accessToken"];
    [self.userDefaults synchronize];
}

-(NSString*)gcmRegKey
{
    return [self.userDefaults objectForKey:@"gcmRegKey"];
}

- (void)setGcmRegKey:(NSString *)value
{
    [self.userDefaults setObject:value forKey:@"gcmRegKey"];
    [self.userDefaults synchronize];
}


-(NSString*)deviceToken
{
    return [self.userDefaults objectForKey:@"deviceToken"];
}

- (void)setDeviceToken:(NSString *)value
{
    [self.userDefaults setObject:value forKey:@"deviceToken"];
    [self.userDefaults synchronize];
}



- (NSMutableDictionary *)toNSDictionary
{
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    
    [dictionary setObject:@"flowdigital" forKey:@"access_key"];
    //[dictionary setValue:[NSNumber numberWithInt:self.userId] forKey:@"user_id"];
    return dictionary;

}




@end
