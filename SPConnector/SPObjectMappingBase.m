//
//  SPObjectMappingBase.m
//  SPTest
//
//  Created by Nathan Wood on 12/02/13.
//  Copyright (c) 2013 Nathan Wood. All rights reserved.
//

#import "SPObjectMappingBase.h"


@interface SPObjectMappingBase ()

@property (nonatomic, readonly) NSMutableDictionary *attributeMappings;
//@property (nonatomic, readonly) NSMutableDictionary *fieldMappings;

@end


@implementation SPObjectMappingBase

@synthesize attributeMappings = _attributeMappings;

- (NSMutableDictionary *)attributeMappings
{
    if (self->_attributeMappings == nil)
        self->_attributeMappings = [[NSMutableDictionary alloc] init];
    return self->_attributeMappings;
}

- (void)mapKeyPath:(NSString *)keyPath toAttribute:(NSString *)attribute
{
    [self.attributeMappings setObject:attribute forKey:keyPath];
}

- (void)removeMappingForKeyPath:(NSString *)keyPath
{
    [self.attributeMappings removeObjectForKey:keyPath];
}

- (NSString *)attributeForKeyPath:(NSString *)keyPath
{
    return [self.attributeMappings objectForKey:keyPath];
}

#pragma mark NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.attributeMappings forKey:NSStringFromSelector(@selector(attributeMappings))];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self)
    {
        self->_attributeMappings = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(attributeMappings))];
    }
    return self;
}

@end
