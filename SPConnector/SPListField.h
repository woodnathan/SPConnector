//
//  SPListField.h
//  SPTest
//
//  Created by Nathan Wood on 15/01/13.
//  Copyright (c) 2013 Nathan Wood. All rights reserved.
//

#import "SPObject.h"

@interface SPListField : SPObject

@property (nonatomic, readonly) NSString *fieldID;
@property (nonatomic, readonly) NSString *name;

@end