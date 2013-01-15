//
//  SPView.h
//  SPTest
//
//  Created by Nathan Wood on 15/01/13.
//  Copyright (c) 2013 Nathan Wood. All rights reserved.
//

#import "SPListAttachedObject.h"

@class SPList;

@interface SPView : SPListAttachedObject

@property (nonatomic, readonly) NSString *viewName;
@property (nonatomic, readonly) NSString *type;
@property (nonatomic, readonly) NSString *displayName;

@end
