//
//  SPListItemMapping.m
//  SPTest
//
//  Created by Nathan Wood on 12/02/13.
//  Copyright (c) 2013 Nathan Wood. All rights reserved.
//

#import "SPListItemMapping.h"

@implementation SPListItemMapping

- (id)init
{
    self = [super init];
    if (self)
    {
        [self mapKeyPath:@"itemID" toAttribute:@"ows_ID"];
        [self mapKeyPath:@"itemUniqueID" toAttribute:@"ows_UniqueId"];
        [self mapKeyPath:@"title" toAttribute:@"ows_Title"];
        [self mapKeyPath:@"contentType" toAttribute:@"ows_ContentType"];
        [self mapKeyPath:@"baseName" toAttribute:@"ows_BaseName"];
        [self mapKeyPath:@"fileRef" toAttribute:@"ows_FileRef"];
    }
    return self;
}

@end
