//
//  SPViewMapping.m
//  SPTest
//
//  Created by Nathan Wood on 12/02/13.
//  Copyright (c) 2013 Nathan Wood. All rights reserved.
//

#import "SPViewMapping.h"

@implementation SPViewMapping

- (id)init
{
    self = [super init];
    if (self)
    {
        [self mapKeyPath:@"viewName" toAttribute:@"Name"];
        [self mapKeyPath:@"type" toAttribute:@"Type"];
        [self mapKeyPath:@"displayName" toAttribute:@"DisplayName"];
    }
    return self;
}

@end
