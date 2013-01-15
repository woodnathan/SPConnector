//
//  SPGetList.h
//  SPTest
//
//  Created by Nathan Wood on 15/01/13.
//  Copyright (c) 2013 Nathan Wood. All rights reserved.
//

#import "SPListMethod.h"

@class SPList;

@interface SPGetList : SPListMethod

@property (nonatomic, copy) NSString *listName;

@property (nonatomic, strong) SPList *list;

@end
