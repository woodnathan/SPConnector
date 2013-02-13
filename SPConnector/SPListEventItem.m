//
//  SPListEventItem.m
//  SPTest
//
//  Created by Nathan Wood on 12/02/13.
//  Copyright (c) 2013 Nathan Wood. All rights reserved.
//

#import "SPListEventItem.h"
#import "SPGetListItems.h"
#import "SPListItemMapping.h"

@implementation SPListEventItem

@dynamic startDate, endDate;
@dynamic location;

+ (void)load
{
    SPListItemMapping *mapping = [[SPListItemMapping alloc] init];
    [mapping mapKeyPath:@"startDate" toAttribute:@"ows_EventDate"];
    [mapping mapKeyPath:@"endDate" toAttribute:@"ows_EndDate"];
    [mapping mapKeyPath:@"location" toAttribute:@"ows_Location"];
    
    [SPObjectMappingFactory registerObjectMapping:mapping forClass:self];
    
    [SPGetListItems registerClass:self forContentType:@"Event"];
}

@end
