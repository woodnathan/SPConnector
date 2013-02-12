//
//  SPObjectMappingBase.h
//  SPTest
//
//  Created by Nathan Wood on 12/02/13.
//  Copyright (c) 2013 Nathan Wood. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SPObjectMapping.h"

@interface SPObjectMappingBase : NSObject <SPObjectMapping>

- (void)mapKeyPath:(NSString *)keyPath toAttribute:(NSString *)attribute;
- (void)mapKeyPath:(NSString *)keyPath toField:(NSString *)field;
- (void)removeMappingForKeyPath:(NSString *)keyPath;

@end