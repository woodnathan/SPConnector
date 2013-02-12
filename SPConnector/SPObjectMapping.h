//
//  SPObjectMapping.h
//  SPTest
//
//  Created by Nathan Wood on 12/02/13.
//  Copyright (c) 2013 Nathan Wood. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SPObjectMapping <NSObject>

- (NSString *)attributeForKeyPath:(NSString *)keyPath;

@end