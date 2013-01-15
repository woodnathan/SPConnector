//
//  SPListAttachedObject.h
//  SPTest
//
//  Created by Nathan Wood on 15/01/13.
//  Copyright (c) 2013 Nathan Wood. All rights reserved.
//

#import "SPObject.h"

@class SPList;

@interface SPListAttachedObject : SPObject

@property (nonatomic, strong, readonly) NSString *listName;

@property (nonatomic, weak) SPList *list;

@end
