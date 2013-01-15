//
//  SPListField.m
//  SPTest
//
//  Created by Nathan Wood on 15/01/13.
//  Copyright (c) 2013 Nathan Wood. All rights reserved.
//

#import "SPListField.h"

@implementation SPListField

@dynamic fieldID, name;

+ (NSDictionary *)propertyToAttributeMap
{
    return @{ @"fieldID" : @"ID", @"name" : @"Name" };
}

@end
