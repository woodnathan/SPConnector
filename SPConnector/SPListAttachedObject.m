//
//  SPListAttachedObject.m
//  SPTest
//
//  Created by Nathan Wood on 15/01/13.
//  Copyright (c) 2013 Nathan Wood. All rights reserved.
//

#import "SPListAttachedObject.h"
#import "SPList.h"


@interface SPListAttachedObject ()

@property (nonatomic, strong, readwrite) NSString *listName;

@end


@implementation SPListAttachedObject

@synthesize listName = _listName, list = _list;

- (void)setList:(SPList *)list
{
    if (self->_list != list)
    {
        self->_list = list;
        self->_listName = list.listName;
    }
}

@end
