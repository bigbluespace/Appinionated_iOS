//
//  TCL.h
//  TCL
//
//  Created by Mamun on 9/20/14.
//  Copyright (c) 2014 ABCoder. All rights reserved.
//

//#import <Foundation/Foundation.h>
#import "AppAPIClient.h"

@interface AppAPI : NSObject

// snapshot capture (convert view to image!)
+ (UIImage *) imageWithView:(UIView *)view;
// image file cache write
+(void)writeImage:(UIImage*)image fileName:(NSString*)fileName;

// image file cache read
+(UIImage*)readImage:(NSString*)fileName;

//Login Apps (RAAZ)
+ (NSURLSessionDataTask *)login:(NSDictionary*)parameters block:(void (^)(NSDictionary *JSON, NSError *error))block;
//Facebook Login App
+ (NSURLSessionDataTask *)facebookLogin:(NSDictionary*)parameters block:(void (^)(NSDictionary *JSON, NSError *error))block;
//signup
+ (NSURLSessionDataTask *)signup:(NSDictionary*)parameters block:(void (^)(NSDictionary *JSON, NSError *error))block;
//Forgot Password(Raaz)
+ (NSURLSessionDataTask *)forgotPassword:(NSDictionary*)parameters block:(void (^)(NSDictionary *JSON, NSError *error))block;

// recently asked q by me
+ (NSURLSessionDataTask*)recentQ:(NSUInteger)userID
                           limit:(NSUInteger)limit
                          offset:(NSUInteger)offset
                           block:(void (^)(NSDictionary *JSON, NSError *error))block;
// Ask new question
+ (NSURLSessionDataTask *)askQuestion:(NSDictionary*)parameters
            constructingBodyWithBlock:(void (^)(id <AFMultipartFormData> formData))formDataBlock
                                block:(void (^)(NSDictionary *JSON, NSError *error))block;
// Invite Contacts
+ (NSURLSessionDataTask *)inviteContacts:(NSDictionary*)parameters
                              questionID:(NSUInteger)questionID
                                  userID:(NSUInteger)userID
                                   block:(void (^)(NSDictionary *JSON, NSError *error))block;
// Invite Groups
+ (NSURLSessionDataTask *)inviteGroups:(NSDictionary*)parameters
                              questionID:(NSUInteger)questionID
                                  userID:(NSUInteger)userID
                                   block:(void (^)(NSDictionary *JSON, NSError *error))block;
// Create Group
+ (NSURLSessionDataTask *)createGroup:(NSDictionary*)parameters
                               userID:(NSUInteger)userID
            constructingBodyWithBlock:(void (^)(id <AFMultipartFormData> formData))formDataBlock
                                block:(void (^)(NSDictionary *JSON, NSError *error))block;
// Show Group List
+ (NSURLSessionDataTask*)showGroupList:(NSUInteger)userID block:(void (^)(NSDictionary *JSON, NSError *error))block;
// My Question List
+ (NSURLSessionDataTask*)myQuestionList:(NSUInteger)userID
                                 offset:(NSUInteger)offset
                                  limit:(NSUInteger)limit
                                  block:(void (^)(NSDictionary *JSON, NSError *error))block;
// Update Profile
+ (NSURLSessionDataTask *)updateProfile:(NSDictionary*)parameters
            constructingBodyWithBlock:(void (^)(id <AFMultipartFormData> formData))formDataBlock
                                block:(void (^)(NSDictionary *JSON, NSError *error))block;
// Show Group Information
+ (NSURLSessionDataTask*)showGroupInfo:(NSUInteger)userID
                               groupID:(NSUInteger)groupID
                                 block:(void (^)(NSDictionary *JSON, NSError *error))block;
// Delete Group
+ (NSURLSessionDataTask*)deleteGroup:(NSUInteger)userID
                               groupID:(NSUInteger)groupID
                                 block:(void (^)(NSDictionary *JSON, NSError *error))block;
// Question Detail 
+ (NSURLSessionDataTask*)questionDetail:(NSUInteger)questionID
                                  block:(void (^)(NSDictionary *JSON, NSError *error))block;
// Delete Account
+ (NSURLSessionDataTask*)deleteAccount:(NSString*)email
                               block:(void (^)(NSDictionary *JSON, NSError *error))block;
// Update Group
+ (NSURLSessionDataTask *)updateGroup:(NSDictionary*)parameters
                               userID:(NSUInteger)userID
                              groupID:(NSUInteger)groupID
            constructingBodyWithBlock:(void (^)(id <AFMultipartFormData> formData))formDataBlock
                                block:(void (^)(NSDictionary *JSON, NSError *error))block;
// Response Question
+ (NSURLSessionDataTask*)responseQuestion:(NSUInteger)questionID
                                    block:(void (^)(NSDictionary *JSON, NSError *error))block;
//Answer a Question
+ (NSURLSessionDataTask *)answerQuestion:(NSDictionary*)parameters
                                   block:(void (^)(NSDictionary *JSON, NSError *error))block;
// Question Delete
+ (NSURLSessionDataTask*)deleteQuestion:(NSUInteger)questionID
                                 userID:(NSUInteger)userID
                                  block:(void (^)(NSDictionary *JSON, NSError *error))block;
// Settings
+ (NSURLSessionDataTask *)settings:(void (^)(NSDictionary *JSON, NSError *error))block;
//Report Abuse
+ (NSURLSessionDataTask *)reportAbuse:(NSDictionary*)parameters block:(void (^)(NSDictionary *JSON, NSError *error))block;
// Question Forwarding
+ (NSURLSessionDataTask*)forwardQuestion:(NSUInteger)questionID
                                 userID:(NSUInteger)userID
                                  block:(void (^)(NSDictionary *JSON, NSError *error))block;
// Check if Already Answered
+ (NSURLSessionDataTask*)alreadyAnswered:(NSUInteger)userID
                                  questionID:(NSUInteger)questionID
                                   block:(void (^)(NSDictionary *JSON, NSError *error))block;

// Count New Question
+ (NSURLSessionDataTask*)getQuestionCounter:(NSUInteger)userID
                                   block:(void (^)(NSDictionary *JSON, NSError *error))block;

// Show Profile Info
+ (NSURLSessionDataTask*)showProfileInfo:(NSUInteger)userID
                                  block:(void (^)(NSDictionary *JSON, NSError *error))block;
@end
