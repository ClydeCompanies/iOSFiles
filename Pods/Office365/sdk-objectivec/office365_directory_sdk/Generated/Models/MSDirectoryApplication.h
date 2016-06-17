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

@class MSDirectoryAppRole;
@class MSDirectoryKeyCredential;
@class MSDirectoryOAuth2Permission;
@class MSDirectoryPasswordCredential;
@class MSDirectoryRequiredResourceAccess;
@class MSDirectoryExtensionProperty;

#import <Foundation/Foundation.h>
#import "MSDirectoryProtocols.h"
#import "MSDirectoryDirectoryObject.h"

/**
* The header for type Application.
*/

@interface MSDirectoryApplication : MSDirectoryDirectoryObject


@property NSString *appId;

@property NSMutableArray<MSDirectoryAppRole> *appRoles;

@property bool availableToOtherTenants;

@property NSString *displayName;

@property NSString *errorUrl;

@property NSString *groupMembershipClaims;

@property NSString *homepage;

@property NSMutableArray *identifierUris;

@property NSMutableArray<MSDirectoryKeyCredential> *keyCredentials;

@property NSMutableArray *knownClientApplications;

@property NSStream *mainLogo;

@property NSString *logoutUrl;

@property bool oauth2AllowImplicitFlow;

@property bool oauth2AllowUrlPathMatching;

@property NSMutableArray<MSDirectoryOAuth2Permission> *oauth2Permissions;

@property bool oauth2RequirePostResponse;

@property NSMutableArray<MSDirectoryPasswordCredential> *passwordCredentials;

@property bool publicClient;

@property NSMutableArray *replyUrls;

@property NSMutableArray<MSDirectoryRequiredResourceAccess> *requiredResourceAccess;

@property NSString *samlMetadataUrl;


@end