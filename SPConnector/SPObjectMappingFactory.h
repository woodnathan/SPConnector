//
//  SPObjectMappingFactory.h
//  SPTest
//
//  Created by Nathan Wood on 12/02/13.
//  Copyright (c) 2013 Nathan Wood. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SPObjectMapping.h"

@interface SPObjectMappingFactory : NSObject

+ (id <SPObjectMapping>)objectMappingForClass:(Class)objectClass;
+ (void)registerObjectMapping:(id <SPObjectMapping>)mapping forClass:(Class)objectClass;

@end
