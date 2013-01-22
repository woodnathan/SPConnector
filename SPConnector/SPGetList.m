//
//  SPGetList.m
//
//  Copyright (c) 2013 Nathan Wood (http://www.woodnathan.com/)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

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
    
    NSString *path = [NSString stringWithFormat:@"//soap:GetListResult/soap:List[%li]/soap:Fields/soap:Field", index];
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
