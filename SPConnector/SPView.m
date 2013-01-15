//
//  SPView.m
//  SPTest
//
//  Created by Nathan Wood on 15/01/13.
//  Copyright (c) 2013 Nathan Wood. All rights reserved.
//

#import "SPView.h"

@implementation SPView

@dynamic viewName, type, displayName;

+ (NSDictionary *)propertyToAttributeMap
{
    return @{ @"viewName" : @"Name", @"type" : @"Type", @"displayName" : @"DisplayName" };
}

@end
