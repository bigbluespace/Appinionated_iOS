//
//  TCL.m
//  TCL
//
//  Created by Mamun on 9/20/14.
//  Copyright (c) 2014 ABCoder. All rights reserved.
//

#import "AppAPI.h"

@implementation AppAPI

#pragma mark convert UIView to UIImage

+ (UIImage *) imageWithView:(UIView *)view
{
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, 0.0f);
    [view drawViewHierarchyInRect:view.bounds afterScreenUpdates:NO];
    UIImage * snapshotImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return snapshotImage;
}

#pragma mark - Utility methods - image cache read/write to local Document file

+(void)writeImage:(UIImage*)image fileName:(NSString*)fileName{
    NSString  *filePath = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@", fileName]];
    // Write a UIImage to JPEG with minimum compression (best quality)
    // The value 'image' must be a UIImage object
    // The value '1.0' represents image compression quality as value from 0.0 to 1.0
    [UIImageJPEGRepresentation(image, 1.0) writeToFile:filePath atomically:YES];
}

+(UIImage*)readImage:(NSString*)fileName{
    NSString  *filePath = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@", fileName]];
    return [UIImage imageWithContentsOfFile:filePath];
}

+(void)storeData:(NSDictionary*)json storageName:(NSString*)name {
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:json options:kNilOptions error:nil];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults setObject:data forKey:name];    
    [defaults synchronize];
    
}
+(NSMutableDictionary*)readData:(NSString*)name{
   // NSDictionary* data;
    NSError* error;
    NSData * data = [[NSUserDefaults standardUserDefaults] objectForKey:name];
    if (data != nil) {
        NSDictionary* dic = [NSJSONSerialization
                              JSONObjectWithData:data
                              options:kNilOptions
                              error:&error];
        
        NSMutableDictionary *mDic = [[NSMutableDictionary alloc] initWithDictionary:dic];
        return mDic;
    }
    return nil;
}



#pragma mark - Error handling

+(void)handleError:(NSError*)error {
    NSLog(@"e %@", error);
    NSString *errorMessage = [[NSString alloc] init];
    if ([error.domain isEqualToString:NSURLErrorDomain]) {
        //errorMessage = [[error.userInfo objectForKey:NSUnderlyingErrorKey] localizedDescription];
        errorMessage = @"Network Error. Please try again later.";
        //errorMessage = [error.userInfo valueForKey: NSLocalizedDescriptionKey];
    } else if ([error.domain isEqualToString:AFURLResponseSerializationErrorDomain]){
        NSData *responseData = [error.userInfo valueForKey:AFNetworkingOperationFailingURLResponseDataErrorKey];
        NSError* localError;
        NSDictionary *katchUpError = [[NSDictionary alloc] init];
        katchUpError = [NSJSONSerialization JSONObjectWithData:responseData
                                                       options:0
                                                         error:&localError];
        NSLog(@" ***** APP Error **** %@", katchUpError);
        
        // weirdo!!!
        // from api the "listError" is just "EmailAlreadyExists", "errorMessage" contains the full textual description
        // but for other cases "listError" contains the full description
        // dirty trick! :( [get the longest string as error msg]
        // errorMessage = [katchUpError valueForKeyPath:@"errorMessage"];
        errorMessage = @"Network Error. Please try again.";
        NSString *listError = [[katchUpError valueForKeyPath:@"listError"] firstObject];
        if ([listError length] < [errorMessage length]) { // EmailAlreadyExists
            listError = errorMessage;
        }
        if (listError != nil) {
            errorMessage = listError;
        }
        
        // log out if token is expired
        if ([errorMessage isEqualToString:@"You need a valid token to access to a /auth/ path."]){
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"auth"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
       
    
    
    if (errorMessage == nil) {
        errorMessage =  @"Service unavailable, please try again later.";
    }
    
    
    //NSLog(@" ERROR JSON %@", errorMessage);
    
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning" message:errorMessage delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
//    [alert show];
}

#pragma mark - TCL API Methods


// Login
+ (NSURLSessionDataTask *)login:(NSDictionary*)parameters block:(void (^)(NSDictionary *JSON, NSError *error))block {
    
    NSString *path = @"users/login";
    
    NSLog(@"parameters %@",parameters);
    
    
    return [[AppAPIClient sharedClient]
            POST:path
            parameters:parameters
            success:^(NSURLSessionDataTask * __unused task, id JSON) {
                NSLog(@"login  %@", JSON);
                if (block) {
                    block(JSON, nil);
                }
            }
            failure:^(NSURLSessionDataTask *__unused task, NSError *error) {
                if (block) {
                    [self handleError:error];
                    block(nil, error);
                }
            }];
}
// Facebook Login
+ (NSURLSessionDataTask *)facebookLogin:(NSDictionary*)parameters block:(void (^)(NSDictionary *JSON, NSError *error))block {
    
    NSString *path = @"users/login";
    
    NSLog(@"parameters %@",parameters);
    
    
    return [[AppAPIClient sharedClient]
            POST:path
            parameters:parameters
            success:^(NSURLSessionDataTask * __unused task, id JSON) {
                NSLog(@"login  %@", JSON);
                if (block) {
                    block(JSON, nil);
                }
            }
            failure:^(NSURLSessionDataTask *__unused task, NSError *error) {
                if (block) {
                    [self handleError:error];
                    block(nil, error);
                }
            }];
}

// signup
+ (NSURLSessionDataTask *)signup:(NSDictionary*)parameters block:(void (^)(NSDictionary *JSON, NSError *error))block {
    
    NSString *path = @"users/register";
    
    NSLog(@"parameters %@",parameters);
    
    
    return [[AppAPIClient sharedClient]
            POST:path
            parameters:parameters
            success:^(NSURLSessionDataTask * __unused task, id JSON) {
                NSLog(@"register  %@", JSON);
                if (block) {
                    block(JSON, nil);
                }
            }
            failure:^(NSURLSessionDataTask *__unused task, NSError *error) {
                if (block) {
                    [self handleError:error];
                    block(nil, error);
                }
            }];
}

//Forgot Password(Raaz)
+ (NSURLSessionDataTask *)forgotPassword:(NSDictionary*)parameters block:(void (^)(NSDictionary *JSON, NSError *error))block {
    
    NSString *path = @"users/forgot_password";
    NSLog(@"parameters %@",parameters);
    
    
    return [[AppAPIClient sharedClient]
            POST:path
            parameters:parameters
            success:^(NSURLSessionDataTask * __unused task, id JSON) {
                NSLog(@"forgot password  %@", JSON);
                if (block) {
                    block(JSON, nil);
                }
            }
            failure:^(NSURLSessionDataTask *__unused task, NSError *error) {
                if (block) {
                    [self handleError:error];
                    block(nil, error);
                }
            }];
}

//All details search param value(Bidisha apu)
+ (NSURLSessionDataTask*)recentQ:(NSUInteger)userID
                           limit:(NSUInteger)limit
                          offset:(NSUInteger)offset
                           block:(void (^)(NSDictionary *JSON, NSError *error))block {
    
    NSString *path = [NSString stringWithFormat:@"questions/recent_questions/%lu/%lu/%lu", (unsigned long)userID, (unsigned long)offset, (unsigned long)limit];
    
    NSLog(@"recent q params URL %@", path);
    
    return [[AppAPIClient sharedClient]
            GET:path
            parameters:nil
            success:^(NSURLSessionDataTask * __unused task, id JSON) {
                NSLog(@"recent Q  %@", JSON);
                if (block) {
                    block(JSON, nil);
                }
            }
            failure:^(NSURLSessionDataTask *__unused task, NSError *error) {
                if (block) {
                    [self handleError:error];
                    block(nil, error);
                }
            }];
}

//Ask new Question

+ (NSURLSessionDataTask *)askQuestion:(NSDictionary*)parameters
            constructingBodyWithBlock:(void (^)(id <AFMultipartFormData> formData))formDataBlock
                                block:(void (^)(NSDictionary *JSON, NSError *error))block {
    
    NSString *path = @"questions/ask_question";
    NSLog(@"parameters %@",parameters);
    
    
    return [[AppAPIClient sharedClient]
            POST:path
            parameters:parameters
            constructingBodyWithBlock:formDataBlock
            success:^(NSURLSessionDataTask * __unused task, id JSON) {
                NSLog(@"Ask New question  %@", JSON);
                if (block) {
                    block(JSON, nil);
                }
            }
            failure:^(NSURLSessionDataTask *__unused task, NSError *error) {
                if (block) {
                    [self handleError:error];
                    block(nil, error);
                }
            }];
}


// Invite Contacts
+ (NSURLSessionDataTask *)inviteContacts:(NSDictionary*)parameters
                              questionID:(NSUInteger)questionID
                                  userID:(NSUInteger)userID
                                   block:(void (^)(NSDictionary *JSON, NSError *error))block{
    
    
    NSString *path = [NSString stringWithFormat:@"questions_users/send_question_contacts/%lu/%lu",(unsigned long)userID,(unsigned long)questionID];
    
    NSLog(@"parameters %@",parameters);
    NSLog(@"path %@",path);
    
    return [[AppAPIClient sharedClient]
            POST:path
            parameters:parameters
            success:^(NSURLSessionDataTask * __unused task, id JSON) {
                NSLog(@"Invite Contacts  %@", JSON);
                if (block) {
                    block(JSON, nil);
                }
            }
            failure:^(NSURLSessionDataTask *__unused task, NSError *error) {
                if (block) {
                    [self handleError:error];
                    block(nil, error);
                }
            }];

}
// Invite Groups
+ (NSURLSessionDataTask *)inviteGroups:(NSDictionary*)parameters
                              questionID:(NSUInteger)questionID
                                  userID:(NSUInteger)userID
                                   block:(void (^)(NSDictionary *JSON, NSError *error))block{
    
    
    NSString *path = [NSString stringWithFormat:@"questions_users/send_question_group/%lu/%lu",(unsigned long)userID,(unsigned long)questionID];
    
    NSLog(@"parameters %@",parameters);
    
    
    return [[AppAPIClient sharedClient]
            POST:path
            parameters:parameters
            success:^(NSURLSessionDataTask * __unused task, id JSON) {
                NSLog(@"Invite Groups  %@", JSON);
                if (block) {
                    block(JSON, nil);
                }
            }
            failure:^(NSURLSessionDataTask *__unused task, NSError *error) {
                if (block) {
                    [self handleError:error];
                    block(nil, error);
                }
            }];
    
}
//Create Group

+ (NSURLSessionDataTask *)createGroup:(NSDictionary *)parameters
                               userID:(NSUInteger)userID
            constructingBodyWithBlock:(void (^)(id <AFMultipartFormData> formData))formDataBlock
                                block:(void (^)(NSDictionary *, NSError *))block {
    
    NSString *path = [NSString stringWithFormat:@"mygroups/create_group/%lu",(unsigned long)userID];
    //NSLog(@"parameters %@",parameters);
    
    
    return [[AppAPIClient sharedClient]
            POST:path
            parameters:parameters
            constructingBodyWithBlock:formDataBlock
            success:^(NSURLSessionDataTask * __unused task, id JSON) {
                NSLog(@"New Group  %@", JSON);
                if (block) {
                    block(JSON, nil);
                }
            }
            failure:^(NSURLSessionDataTask *__unused task, NSError *error) {
                if (block) {
                    [self handleError:error];
                    block(nil, error);
                }
            }];
}
// Update Group
+ (NSURLSessionDataTask *)updateGroup:(NSDictionary*)parameters
                               userID:(NSUInteger)userID
                              groupID:(NSUInteger)groupID
            constructingBodyWithBlock:(void (^)(id <AFMultipartFormData> formData))formDataBlock
                                block:(void (^)(NSDictionary *JSON, NSError *error))block{
    
    
    NSString *path = [NSString stringWithFormat:@"mygroups/edit_group/%lu/%lu",(unsigned long)userID,(unsigned long)groupID];
    NSLog(@"path %@",path);
    NSLog(@"parameters %@",parameters);
    
    
    return [[AppAPIClient sharedClient]
            POST:path
            parameters:parameters
            constructingBodyWithBlock:formDataBlock
            success:^(NSURLSessionDataTask * __unused task, id JSON) {
                NSLog(@"Update Group  %@", JSON);
                if (block) {
                    block(JSON, nil);
                }
            }
            failure:^(NSURLSessionDataTask *__unused task, NSError *error) {
                if (block) {
                    [self handleError:error];
                    block(nil, error);
                }
            }];
    
}

//All details of all Group
+ (NSURLSessionDataTask*)showGroupList:(NSUInteger)userID block:(void (^)(NSDictionary *, NSError *))block{
    
    NSString *path = [NSString stringWithFormat:@"mygroups/all_groups/%lu", (unsigned long)userID];
    
    NSLog(@"recent q params URL %@", path);
    
    return [[AppAPIClient sharedClient]
            GET:path
            parameters:nil
            success:^(NSURLSessionDataTask * __unused task, id JSON) {
                NSLog(@"recent Q  %@", JSON);
                if (block) {
                    block(JSON, nil);
                }
            }
            failure:^(NSURLSessionDataTask *__unused task, NSError *error) {
                if (block) {
                    [self handleError:error];
                    block(nil, error);
                }
            }];
}
//My Question List
+ (NSURLSessionDataTask*)myQuestionList:(NSUInteger)userID
                                 offset:(NSUInteger)offset
                                  limit:(NSUInteger)limit
                                  block:(void (^)(NSDictionary *, NSError *))block{
    
    NSString *path = [NSString stringWithFormat:@"questions_users/my_questions/%lu/%lu/%lu", (unsigned long)userID, (unsigned long)offset, (unsigned long)limit];
    
    NSLog(@"recent q params URL %@", path);
    
    return [[AppAPIClient sharedClient]
            GET:path
            parameters:nil
            success:^(NSURLSessionDataTask * __unused task, id JSON) {
                NSLog(@"My Question  %@", JSON);
                if (block) {
                    block(JSON, nil);
                }
            }
            failure:^(NSURLSessionDataTask *__unused task, NSError *error) {
                if (block) {
                    [self handleError:error];
                    block(nil, error);
                }
            }];
}
//Update Profile

+ (NSURLSessionDataTask *)updateProfile:(NSDictionary*)parameters
            constructingBodyWithBlock:(void (^)(id <AFMultipartFormData> formData))formDataBlock
                                block:(void (^)(NSDictionary *JSON, NSError *error))block {
    
    NSString *path = @"users/update";
    NSLog(@"parameters %@",parameters);
    
    
    return [[AppAPIClient sharedClient]
            POST:path
            parameters:parameters
            constructingBodyWithBlock:formDataBlock
            success:^(NSURLSessionDataTask * __unused task, id JSON) {
                NSLog(@"Update Profile  %@", JSON);
                if (block) {
                    block(JSON, nil);
                }
            }
            failure:^(NSURLSessionDataTask *__unused task, NSError *error) {
                if (block) {
                    [self handleError:error];
                    block(nil, error);
                }
            }];
}
//Show Group Information
+ (NSURLSessionDataTask*)showGroupInfo:(NSUInteger)userID groupID:(NSUInteger)groupID block:(void (^)(NSDictionary *, NSError *))block{
    
    NSString *path = [NSString stringWithFormat:@"questions/group_questions/%lu/%lu", (unsigned long)userID, (unsigned long)groupID];
    
    NSLog(@"recent q params URL %@", path);
    
    return [[AppAPIClient sharedClient]
            GET:path
            parameters:nil
            success:^(NSURLSessionDataTask * __unused task, id JSON) {
                NSLog(@"Group Json  %@", JSON);
                if (block) {
                    block(JSON, nil);
                }
            }
            failure:^(NSURLSessionDataTask *__unused task, NSError *error) {
                if (block) {
                    [self handleError:error];
                    block(nil, error);
                }
            }];
}
//Delete Group
+ (NSURLSessionDataTask*)deleteGroup:(NSUInteger)userID groupID:(NSUInteger)groupID block:(void (^)(NSDictionary *, NSError *))block{
    
    NSString *path = [NSString stringWithFormat:@"mygroups/delete_group/%lu/%lu", (unsigned long)userID, (unsigned long)groupID];
    
    NSLog(@"recent q params URL %@", path);
    
    return [[AppAPIClient sharedClient]
            GET:path
            parameters:nil
            success:^(NSURLSessionDataTask * __unused task, id JSON) {
                NSLog(@"Delete Group  %@", JSON);
                if (block) {
                    block(JSON, nil);
                }
            }
            failure:^(NSURLSessionDataTask *__unused task, NSError *error) {
                if (block) {
                    [self handleError:error];
                    block(nil, error);
                }
            }];
}
//Question Detail
+ (NSURLSessionDataTask*)questionDetail:(NSUInteger)questionID block:(void (^)(NSDictionary *, NSError *))block{
    
    NSString *path = [NSString stringWithFormat:@"questions_users/question_details/%lu", (unsigned long)questionID];
    
    NSLog(@"recent q params URL %@", path);
    
    return [[AppAPIClient sharedClient]
            GET:path
            parameters:nil
            success:^(NSURLSessionDataTask * __unused task, id JSON) {
                NSLog(@"Question Detail  %@", JSON);
                if (block) {
                    block(JSON, nil);
                }
            }
            failure:^(NSURLSessionDataTask *__unused task, NSError *error) {
                if (block) {
                    [self handleError:error];
                    block(nil, error);
                }
            }];
}
//Delete Account
+ (NSURLSessionDataTask*)deleteAccount:(NSString*)email block:(void (^)(NSDictionary *, NSError *))block{
    
    NSString *path = [NSString stringWithFormat:@"users/delete_account/%@", email];
    
    NSLog(@"recent q params URL %@", path);
    
    return [[AppAPIClient sharedClient]
            GET:path
            parameters:nil
            success:^(NSURLSessionDataTask * __unused task, id JSON) {
                NSLog(@"Delete Account  %@", JSON);
                if (block) {
                    block(JSON, nil);
                }
            }
            failure:^(NSURLSessionDataTask *__unused task, NSError *error) {
                if (block) {
                    [self handleError:error];
                    block(nil, error);
                }
            }];
}
//Response Question
+ (NSURLSessionDataTask*)responseQuestion:(NSUInteger)questionID block:(void (^)(NSDictionary *, NSError *))block{
    
    NSString *path = [NSString stringWithFormat:@"mygroups_users/view_all_responses_group/%lu", (unsigned long)questionID];
    
    NSLog(@"Response Question URL %@", path);
    
    return [[AppAPIClient sharedClient]
            GET:path
            parameters:nil
            success:^(NSURLSessionDataTask * __unused task, id JSON) {
                NSLog(@"Response Question  %@", JSON);
                if (block) {
                    block(JSON, nil);
                }
            }
            failure:^(NSURLSessionDataTask *__unused task, NSError *error) {
                if (block) {
                    [self handleError:error];
                    block(nil, error);
                }
            }];
}
// Answer a Question
+ (NSURLSessionDataTask *)answerQuestion:(NSDictionary *)parameters block:(void (^)(NSDictionary *, NSError *))block {
    
    NSString *path = [NSString stringWithFormat:@"answers_users/answer_question"];
    
    NSLog(@"parameters %@",parameters);
     NSLog(@"path %@",path);
    
    return [[AppAPIClient sharedClient]
            POST:path
            parameters:parameters
            success:^(NSURLSessionDataTask * __unused task, id JSON) {
                NSLog(@"Answered Question  %@", JSON);
                if (block) {
                    block(JSON, nil);
                }
            }
            failure:^(NSURLSessionDataTask *__unused task, NSError *error) {
                if (block) {
                    [self handleError:error];
                    block(nil, error);
                }
            }];
}
//Question Delete
+ (NSURLSessionDataTask*)deleteQuestion:(NSUInteger)questionID userID:(NSUInteger)userID block:(void (^)(NSDictionary *, NSError *))block{
    
    NSString *path = [NSString stringWithFormat:@"questions/delete_question/%lu/%lu", (unsigned long)questionID, (unsigned long)userID];
    
    NSLog(@"recent q params URL %@", path);
    
    return [[AppAPIClient sharedClient]
            GET:path
            parameters:nil
            success:^(NSURLSessionDataTask * __unused task, id JSON) {
                NSLog(@"Question Delete  %@", JSON);
                if (block) {
                    block(JSON, nil);
                }
            }
            failure:^(NSURLSessionDataTask *__unused task, NSError *error) {
                if (block) {
                    [self handleError:error];
                    block(nil, error);
                }
            }];
}
//Settings
+ (NSURLSessionDataTask *)settings:(void (^)(NSDictionary *JSON, NSError *error))block{
    
    NSString *path = @"settings/g";
    
    NSLog(@" URL %@", path);
    
    return [[AppAPIClient sharedClient]
            GET:path
            parameters:nil
            success:^(NSURLSessionDataTask * __unused task, id JSON) {
                NSLog(@"Settings  %@", JSON);
                if (block) {
                    block(JSON, nil);
                }
            }
            failure:^(NSURLSessionDataTask *__unused task, NSError *error) {
                if (block) {
                    [self handleError:error];
                    block(nil, error);
                }
            }];
}
//Report Abuse
+ (NSURLSessionDataTask *) reportAbuse:(NSDictionary *)parameters block:(void (^)(NSDictionary *, NSError *))block{
    NSString *path = @"users/report_abuse";
    
    NSLog(@"parameters %@",parameters);
    
    
    return [[AppAPIClient sharedClient]
            POST:path
            parameters:parameters
            success:^(NSURLSessionDataTask * __unused task, id JSON) {
                NSLog(@"Report  %@", JSON);
                if (block) {
                    block(JSON, nil);
                }
            }
            failure:^(NSURLSessionDataTask *__unused task, NSError *error) {
                if (block) {
                    [self handleError:error];
                    block(nil, error);
                }
            }];
}
//Question Forward
+ (NSURLSessionDataTask*)forwardQuestion:(NSUInteger)questionID userID:(NSUInteger)userID block:(void (^)(NSDictionary *, NSError *))block{
    
    NSString *path = [NSString stringWithFormat:@"questions/copy_question/%lu/%lu", (unsigned long)questionID, (unsigned long)userID];
    
    NSLog(@"recent q params URL %@", path);
    
    return [[AppAPIClient sharedClient]
            GET:path
            parameters:nil
            success:^(NSURLSessionDataTask * __unused task, id JSON) {
                NSLog(@"Question Delete  %@", JSON);
                if (block) {
                    block(JSON, nil);
                }
            }
            failure:^(NSURLSessionDataTask *__unused task, NSError *error) {
                if (block) {
                    [self handleError:error];
                    block(nil, error);
                }
            }];
}

//Check Already Answered
+ (NSURLSessionDataTask*)alreadyAnswered:(NSUInteger)userID questionID:(NSUInteger)questionID block:(void (^)(NSDictionary *, NSError *))block{
    
    NSString *path = [NSString stringWithFormat:@"answers_users/is_duplicate_ans/%lu/%lu", (unsigned long)userID,(unsigned long)questionID];
    
    NSLog(@"Already Answered Path %@", path);
    
    return [[AppAPIClient sharedClient]
            GET:path
            parameters:nil
            success:^(NSURLSessionDataTask * __unused task, id JSON) {
                NSLog(@"Already Answered  %@", JSON);
                if (block) {
                    block(JSON, nil);
                }
            }
            failure:^(NSURLSessionDataTask *__unused task, NSError *error) {
                if (block) {
                    [self handleError:error];
                    block(nil, error);
                }
            }];
}

// Count New Question
+ (NSURLSessionDataTask*)getQuestionCounter:(NSUInteger)userID block:(void (^)(NSDictionary *, NSError *))block{
    
    NSString *path = [NSString stringWithFormat:@"questions/count/%lu", (unsigned long)userID];
    
    NSLog(@"GetCounter Path %@", path);
    
    return [[AppAPIClient sharedClient]
            GET:path
            parameters:nil
            success:^(NSURLSessionDataTask * __unused task, id JSON) {
                NSLog(@"GetCounter  %@", JSON);
                if (block) {
                    block(JSON, nil);
                }
            }
            failure:^(NSURLSessionDataTask *__unused task, NSError *error) {
                if (block) {
                    [self handleError:error];
                    block(nil, error);
                }
            }];
}

// Show Profile Info
+ (NSURLSessionDataTask*)showProfileInfo:(NSUInteger)userID block:(void (^)(NSDictionary *, NSError *))block{
    
    NSString *path = [NSString stringWithFormat:@"users/g/%lu", (unsigned long)userID];
    
    NSLog(@"showProfileInfo URL %@", path);
    
    return [[AppAPIClient sharedClient]
            GET:path
            parameters:nil
            success:^(NSURLSessionDataTask * __unused task, id JSON) {
                NSLog(@"showProfileInfo  %@", JSON);
                if (block) {
                    block(JSON, nil);
                }
            }
            failure:^(NSURLSessionDataTask *__unused task, NSError *error) {
                if (block) {
                    [self handleError:error];
                    block(nil, error);
                }
            }];
}

@end
