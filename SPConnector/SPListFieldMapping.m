//
//  SPListFieldMapping.m
//  SPTest
//
//  Created by Nathan Wood on 12/02/13.
//  Copyright (c) 2013 Nathan Wood. All rights reserved.
//

#import "SPListFieldMapping.h"

@implementation SPListFieldMapping

- (id)init
{
    self = [super init];
    if (self)
    {
        [self mapKeyPath:@"fieldID" toAttribute:@"ID"];
        [self mapKeyPath:@"name" toAttribute:@"Name"];
        [self mapKeyPath:@"displayName" toAttribute:@"DisplayName"];
        [self mapKeyPath:@"type" toAttribute:@"Type"];
        [self mapKeyPath:@"required" toAttribute:@"Required"];
        [self mapKeyPath:@"readOnly" toAttribute:@"ReadOnly"];
        [self mapKeyPath:@"min" toAttribute:@"Min"];
        [self mapKeyPath:@"max" toAttribute:@"Max"];
    }
    return self;
}

@end
