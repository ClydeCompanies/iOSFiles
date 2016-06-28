/*******************************************************************************
 * Copyright (c) Microsoft Open Technologies, Inc.
 * All Rights Reserved
 * Licensed under the Apache License, Version 2.0.
 * See License.txt in the project root for license information.
 ******************************************************************************/

#import "MSODataLoggerImpl.h"
#import "MSODataLogger.h"
#import "MSODataLogLevel.h"

@implementation MSODataLoggerImpl

- (void)logMessage:(NSString *)message withLevel:(MSODataLogLevel)logLevel {
    
    NSString *levelString;
    
    switch (logLevel) {
        case LOG_LEVEL_ERROR:
            levelString = @"ERROR";
            break;
        case LOG_LEVEL_INFO:
            levelString = @"INFO";
            break;
        case LOG_LEVEL_VERBOSE:
            levelString = @"VERBOSE";
            break;
        case LOG_LEVEL_WARNING:
            levelString = @"WARNING";
            break;
        default:
            levelString = @"LOG";
    }
    
    NSLog(@"%@ : %@",levelString, message);
}

@end