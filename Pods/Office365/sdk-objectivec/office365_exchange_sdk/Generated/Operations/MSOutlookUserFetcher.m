/*******************************************************************************
Copyright (c) Microsoft Open Technologies, Inc. All Rights Reserved.
Licensed under the MIT or Apache License; see LICENSE in the source repository
root for authoritative license information.﻿

**NOTE** This code was generated by a tool and will occasionally be
overwritten. We welcome comments and issues regarding this code; they will be
addressed in the generation tool. If you wish to submit pull requests, please
do so for the templates in that tool.

This code was generated by Vipr (https://github.com/microsoft/vipr) using
the T4TemplateWriter (https://github.com/msopentech/vipr-t4templatewriter).
******************************************************************************/

#import "MSOutlookODataEntities.h"

@implementation MSOutlookUserFetcher

@synthesize operations = _operations;

- (instancetype)initWithUrl:(NSString *)urlComponent parent:(id<MSODataExecutable>)parent {

    if (self = [super initWithUrl:urlComponent parent:parent asClass:[MSOutlookUser class]]) {

		_operations = [[MSOutlookUserOperations alloc] initOperationWithUrl:urlComponent parent:parent];
    }

    return self;
}

- (NSURLSessionTask *)updateUser:(id)entity callback:(void (^)(MSOutlookUser *user, MSODataException *exception))callback {

	return [super updateEntity:entity callback:callback];
}

- (NSURLSessionTask *)deleteUser:(void (^)(int status, MSODataException *exception))callback {

	return [super deleteWithCallback:callback];
}

- (MSOutlookFolderCollectionFetcher *)getFolders {

    return [[MSOutlookFolderCollectionFetcher alloc] initWithUrl:@"Folders" parent:self asClass:[MSOutlookFolder class]];
}

- (id<MSOutlookFolderFetcher>)getFoldersById:(NSString *)_id {

    return [[[MSOutlookFolderCollectionFetcher alloc] initWithUrl:@"Folders" parent:self asClass:[MSOutlookFolder class]] getById:_id];
}

- (MSOutlookMessageCollectionFetcher *)getMessages {

    return [[MSOutlookMessageCollectionFetcher alloc] initWithUrl:@"Messages" parent:self asClass:[MSOutlookMessage class]];
}

- (id<MSOutlookMessageFetcher>)getMessagesById:(NSString *)_id {

    return [[[MSOutlookMessageCollectionFetcher alloc] initWithUrl:@"Messages" parent:self asClass:[MSOutlookMessage class]] getById:_id];
}

- (MSOutlookFolderFetcher *) getRootFolder {

	 return [[MSOutlookFolderFetcher alloc] initWithUrl:@"RootFolder" parent:self asClass:[MSOutlookFolder class]];
}

- (MSOutlookCalendarCollectionFetcher *)getCalendars {

    return [[MSOutlookCalendarCollectionFetcher alloc] initWithUrl:@"Calendars" parent:self asClass:[MSOutlookCalendar class]];
}

- (id<MSOutlookCalendarFetcher>)getCalendarsById:(NSString *)_id {

    return [[[MSOutlookCalendarCollectionFetcher alloc] initWithUrl:@"Calendars" parent:self asClass:[MSOutlookCalendar class]] getById:_id];
}

- (MSOutlookCalendarFetcher *) getCalendar {

	 return [[MSOutlookCalendarFetcher alloc] initWithUrl:@"Calendar" parent:self asClass:[MSOutlookCalendar class]];
}

- (MSOutlookCalendarGroupCollectionFetcher *)getCalendarGroups {

    return [[MSOutlookCalendarGroupCollectionFetcher alloc] initWithUrl:@"CalendarGroups" parent:self asClass:[MSOutlookCalendarGroup class]];
}

- (id<MSOutlookCalendarGroupFetcher>)getCalendarGroupsById:(NSString *)_id {

    return [[[MSOutlookCalendarGroupCollectionFetcher alloc] initWithUrl:@"CalendarGroups" parent:self asClass:[MSOutlookCalendarGroup class]] getById:_id];
}

- (MSOutlookEventCollectionFetcher *)getEvents {

    return [[MSOutlookEventCollectionFetcher alloc] initWithUrl:@"Events" parent:self asClass:[MSOutlookEvent class]];
}

- (id<MSOutlookEventFetcher>)getEventsById:(NSString *)_id {

    return [[[MSOutlookEventCollectionFetcher alloc] initWithUrl:@"Events" parent:self asClass:[MSOutlookEvent class]] getById:_id];
}

- (MSOutlookEventCollectionFetcher *)getCalendarView {

    return [[MSOutlookEventCollectionFetcher alloc] initWithUrl:@"CalendarView" parent:self asClass:[MSOutlookEvent class]];
}

- (id<MSOutlookEventFetcher>)getCalendarViewById:(NSString *)_id {

    return [[[MSOutlookEventCollectionFetcher alloc] initWithUrl:@"CalendarView" parent:self asClass:[MSOutlookEvent class]] getById:_id];
}

- (MSOutlookContactCollectionFetcher *)getContacts {

    return [[MSOutlookContactCollectionFetcher alloc] initWithUrl:@"Contacts" parent:self asClass:[MSOutlookContact class]];
}

- (id<MSOutlookContactFetcher>)getContactsById:(NSString *)_id {

    return [[[MSOutlookContactCollectionFetcher alloc] initWithUrl:@"Contacts" parent:self asClass:[MSOutlookContact class]] getById:_id];
}

- (MSOutlookContactFolderCollectionFetcher *)getContactFolders {

    return [[MSOutlookContactFolderCollectionFetcher alloc] initWithUrl:@"ContactFolders" parent:self asClass:[MSOutlookContactFolder class]];
}

- (id<MSOutlookContactFolderFetcher>)getContactFoldersById:(NSString *)_id {

    return [[[MSOutlookContactFolderCollectionFetcher alloc] initWithUrl:@"ContactFolders" parent:self asClass:[MSOutlookContactFolder class]] getById:_id];
}

@end