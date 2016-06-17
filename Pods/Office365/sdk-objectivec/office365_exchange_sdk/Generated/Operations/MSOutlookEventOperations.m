/*******************************************************************************
 * Copyright (c) Microsoft Open Technologies, Inc.
 * All Rights Reserved
 * Licensed under the Apache License, Version 2.0.
 * See License.txt in the project root for license information.
 *
 * Warning: This code was generated automatically. Edits will be overwritten.
 * To make changes to this code, please make changes to the generation framework itself:
 * https://github.com/MSOpenTech/odata-codegen
 *******************************************************************************/

#import "MSOutlookEventOperations.h"

/**
* The implementation file for type MSOutlookEventOperations.
*/

@implementation MSOutlookEventOperations

-(id)initWithUrl:(NSString *)urlComponent parent:(id<MSODataExecutable>)parent{
    return [super initOperationWithUrl:urlComponent parent:parent];
}

-(NSURLSessionDataTask*)accept : (NSString *) comment : (void (^)(int returnValue, MSODataException *error))callback{

	id<MSODataRequest> request = [[self getResolver] createODataRequest];
		
	NSArray* parameters = [[NSArray alloc] initWithObjects:
	[[NSDictionary alloc] initWithObjectsAndKeys :comment,@"Comment",nil ],nil];

	NSData* payload = [[MSODataBaseContainerHelper generatePayload:parameters :[self getResolver]]dataUsingEncoding:NSUTF8StringEncoding];
	[[request getUrl] appendPathComponent:@"Accept"];
	[request setContent:payload];
	[request setVerb:POST];

	NSURLSessionDataTask* task = [super oDataExecuteWithRequest:request callback:^(id<MSODataResponse> r, MSODataException *error) {
       if(error == nil){
			int result = (int)[[[self getResolver]getJsonSerializer] deserialize:[r getPayload] : nil];
            callback(result, error);
        }
        else{
            callback([r getStatus], error);
        }
    }];
    
    return task;
}			


-(NSURLSessionDataTask*)decline : (NSString *) comment : (void (^)(int returnValue, MSODataException *error))callback{

	id<MSODataRequest> request = [[self getResolver] createODataRequest];
		
	NSArray* parameters = [[NSArray alloc] initWithObjects:
	[[NSDictionary alloc] initWithObjectsAndKeys :comment,@"Comment",nil ],nil];

	NSData* payload = [[MSODataBaseContainerHelper generatePayload:parameters :[self getResolver]]dataUsingEncoding:NSUTF8StringEncoding];
	[[request getUrl] appendPathComponent:@"Decline"];
	[request setContent:payload];
	[request setVerb:POST];

	NSURLSessionDataTask* task = [super oDataExecuteWithRequest:request callback:^(id<MSODataResponse> r, MSODataException *error) {
       if(error == nil){
			int result = (int)[[[self getResolver]getJsonSerializer] deserialize:[r getPayload] : nil];
            callback(result, error);
        }
        else{
            callback([r getStatus], error);
        }
    }];
    
    return task;
}			


-(NSURLSessionDataTask*)tentativelyAccept : (NSString *) comment : (void (^)(int returnValue, MSODataException *error))callback{

	id<MSODataRequest> request = [[self getResolver] createODataRequest];
		
	NSArray* parameters = [[NSArray alloc] initWithObjects:
	[[NSDictionary alloc] initWithObjectsAndKeys :comment,@"Comment",nil ],nil];

	NSData* payload = [[MSODataBaseContainerHelper generatePayload:parameters :[self getResolver]]dataUsingEncoding:NSUTF8StringEncoding];
	[[request getUrl] appendPathComponent:@"TentativelyAccept"];
	[request setContent:payload];
	[request setVerb:POST];

	NSURLSessionDataTask* task = [super oDataExecuteWithRequest:request callback:^(id<MSODataResponse> r, MSODataException *error) {
       if(error == nil){
			int result = (int)[[[self getResolver]getJsonSerializer] deserialize:[r getPayload] : nil];
            callback(result, error);
        }
        else{
            callback([r getStatus], error);
        }
    }];
    
    return task;
}			
@end