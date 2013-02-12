//
//  SPListMapping.m
//  SPTest
//
//  Created by Nathan Wood on 12/02/13.
//  Copyright (c) 2013 Nathan Wood. All rights reserved.
//

#import "SPListMapping.h"

@implementation SPListMapping

- (id)init
{
    self = [super init];
    if (self)
    {
        [self mapKeyPath:@"identifier" toAttribute:@"ID"];
        [self mapKeyPath:@"listName" toAttribute:@"Name"];
        [self mapKeyPath:@"title" toAttribute:@"Title"];
    }
    return self;
}

@end
