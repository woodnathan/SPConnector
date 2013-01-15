//
//  SPGetList.m
//  SPTest
//
//  Created by Nathan Wood on 15/01/13.
//  Copyright (c) 2013 Nathan Wood. All rights reserved.
//

#import "SPGetList.h"
#import "SPMessage.h"
#import "SPList.h"
#import "SPListField.h"


@interface SPGetList ()

- (NSArray *)responseListFieldsWithListIndex:(NSInteger)index;

@end


@implementation SPGetList

@synthesize listName = _listName, list = _list;

+ (NSString *)method
{
    return @"GetList";
}

+ (NSString *)objectPath
{
    return @"//soap:GetListResult/soap:List";
}

- (void)setList:(SPList *)list
{
    if (self->_list != list)
    {
        self->_list = list;
        self.listName = list.listName;
    }
}

- (NSArray *)responseListFieldsWithListIndex:(NSInteger)index
{
    if (index < 1)
        index = 1;
    
    NSString *path = [NSString stringWithFormat:@"//soap:Lists/soap:List[%li]/soap:Fields/soap:Field", index];
    NSMutableArray *fields = [[NSMutableArray alloc] init];
    [self.responseMessage enumerateNodesForXPath:path withBlock:^(xmlNodePtr node, BOOL *stop) {
        SPListField *field = [[SPListField alloc] initWithNode:node context:self.context];
        [fields addObject:field];
    }];
    
    return fields;
}

- (void)parseResponseMessage
{
    __block SPList *list = nil;
    if (self.list != nil)
    {
        list = self.list;
        list.fields = [self responseListFieldsWithListIndex:1];
    }
    else
    {
        NSString *path = [[self class] objectPath];
        [self.responseMessage enumerateNodesForXPath:path withBlock:^(xmlNodePtr node, BOOL *stop) {
            list = [[SPList alloc] initWithNode:node context:self.context];
            
            list.fields = [self responseListFieldsWithListIndex:1];
            
            *stop = YES;
        }];
    }
    
    if (list != nil)
        self->_responseObjects = [NSArray arrayWithObject:list];
}

@end
