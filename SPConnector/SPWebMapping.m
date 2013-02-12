//
//  SPWebMapping.m
//  SPTest
//
//  Created by Nathan Wood on 12/02/13.
//  Copyright (c) 2013 Nathan Wood. All rights reserved.
//

#import "SPWebMapping.h"

@implementation SPWebMapping

- (id)init
{
    self = [super init];
    if (self)
    {
        [self mapKeyPath:@"title" toAttribute:@"Title"];
        [self mapKeyPath:@"URLString" toAttribute:@"Url"];
    }
    return self;
}

@end
