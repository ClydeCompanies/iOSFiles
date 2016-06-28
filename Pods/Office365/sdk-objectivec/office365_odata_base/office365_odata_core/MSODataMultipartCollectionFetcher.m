/*******************************************************************************
 * Copyright (c) Microsoft Open Technologies, Inc.
 * All Rights Reserved
 * Licensed under the Apache License, Version 2.0.
 * See License.txt in the project root for license information.
 ******************************************************************************/

#import "MSODataMultipartCollectionFetcher.h"
#import "MSODataRequest.h"

@implementation MSODataMultipartCollectionFetcher

-(instancetype)initWithUrl:(NSString *)urlComponent parent:(id<MSODataExecutable>)parent asClass:(Class)clazz{
   
    self = [super initWithUrl:urlComponent parent:parent asClass:clazz];
    
    return self;
}

- (NSURLSessionTask *)addParts:(NSArray<MSODataMultiPartElement> *)parts withCallback:(void (^)(id<MSODataResponse> response, MSODataException *exception))callback {
    
    NSString *random = [[NSUUID UUID] UUIDString];
    
    id<MSODataRequest> request = [self.resolver createODataRequest];
    
    NSMutableData *content = [NSMutableData alloc];
    
    for (int i = 0; i < [parts count]; i++) {
        
        MSODataMultiPartElement *element = [parts objectAtIndex:i];
        
        NSMutableString *line = [[NSMutableString alloc] initWithString:@"--"];
        
        [line appendString:@"MultiPartBoundary"];
        [line appendString:random];
        [line appendString:@"\r\n"];
        [line appendFormat:@"Content-Disposition:form-data; name=%@%@", [element name], @"\r\n"];
        [line appendFormat:@"Content-type:%@%@%@", [element contentType], @"\r\n",@"\r\n"];

        [content appendData:[line dataUsingEncoding:NSUTF8StringEncoding]];
        [content appendData:[element content]];
        [content appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    [content appendData:[[[NSString alloc] initWithFormat:@"\r\n--MultiPartBoundary%@--", random]
                                        dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request addHeaderWithName:@"Content-Type"
                         value:[[NSString alloc] initWithFormat:@"multipart/form-data; boundary=MultiPartBoundary%@", random]];
    
    [request setContent:content];
    [request setVerb:HTTP_VERB_POST];
    
    return [self oDataExecuteRequest:request callback:^(id<MSODataResponse> r, MSODataException *e) {
        
        if (e == nil) {
            
            return callback(r, e);
        }
        
        callback(r, e);
    }];
}

- (MSODataMediaEntityFetcher *)getById:(NSString *)Id {
    
    return [[MSODataMediaEntityFetcher alloc] initWithUrl:[[NSString alloc] initWithFormat:@"('%@')" ,Id]
                                                   parent:self
                                                  asClass:nil];
}

@end