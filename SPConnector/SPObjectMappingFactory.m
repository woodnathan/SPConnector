//
//  SPObjectMappingFactory.m
//  SPTest
//
//  Created by Nathan Wood on 12/02/13.
//  Copyright (c) 2013 Nathan Wood. All rights reserved.
//

#import "SPObjectMappingFactory.h"

@interface SPObjectMappingFactory ()

@end

@implementation SPObjectMappingFactory

+ (NSMutableDictionary *)objectMappings
{
    static __DISPATCH_ONCE__ NSMutableDictionary *objectMappings = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        objectMappings = [[NSMutableDictionary alloc] init];
    });
    
    return objectMappings;
}

+ (id <SPObjectMapping>)objectMappingForClass:(Class)objectClass
{
    return [[self objectMappings] objectForKey:NSStringFromClass(objectClass)];
}

+ (void)registerObjectMapping:(id <SPObjectMapping>)mapping forClass:(Class)objectClass
{
    [[self objectMappings] setObject:mapping forKey:NSStringFromClass(objectClass)];
}

@end
