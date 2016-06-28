/*******************************************************************************
 * Copyright (c) Microsoft Open Technologies, Inc.
 * All Rights Reserved
 * Licensed under the Apache License, Version 2.0.
 * See License.txt in the project root for license information.
 ******************************************************************************/

#import "MSODataException.h"

@implementation MSODataException

@synthesize response = _response;
@synthesize payload = _payload;

- (instancetype)initWithResponse:(id<MSODataResponse>)response andMessage:(NSString *)message {
    
    _response = response;
    
    NSArray *msj = [NSJSONSerialization JSONObjectWithData:response.data options
                                                          :NSJSONReadingMutableContainers error:nil];
    
    return [super initWithDomain: response.response.URL.path
                            code:((NSHTTPURLResponse *)response).statusCode
                        userInfo:(NSDictionary *)msj];
}

- (instancetype)initWithResponse:(id<MSODataResponse>)response andError:(NSError *)error {
    
    _response = response;
    
    return [super initWithDomain:error.domain code:error.code userInfo:error.userInfo];
}
@end
