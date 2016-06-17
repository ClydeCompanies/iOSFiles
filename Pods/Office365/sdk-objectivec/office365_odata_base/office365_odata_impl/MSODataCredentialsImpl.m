/*******************************************************************************
 * Copyright (c) Microsoft Open Technologies, Inc.
 * All Rights Reserved
 * Licensed under the Apache License, Version 2.0.
 * See License.txt in the project root for license information.
 ******************************************************************************/

#import "MSODataCredentialsImpl.h"

@interface MSODataCredentialsImpl()

@property id<MSODataCredentials> mCredentials;

@end

@implementation MSODataCredentialsImpl


-(void)setCredentials : (id<MSODataCredentials>) credentials{
    self.mCredentials = credentials;
}

-(id<MSODataCredentials>)getCredentials{
    return self.mCredentials;
}

@end