//
//  SPList.m
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

#import "SPList.h"
#import "SPListAttachedObject.h"
#import "SPListMapping.h"

@implementation SPList

@synthesize items = _items, fields = _fields, views = _views;
@dynamic title, identifier, listName;
@dynamic enableAttachments;

+ (void)initialize
{
    if (self == [SPList class])
        [SPObjectMappingFactory registerObjectMapping:[[SPListMapping alloc] init]
                                             forClass:self];
}

- (void)dealloc
{
    [self.items makeObjectsPerformSelector:@selector(setList:) withObject:nil];
    [self.fields makeObjectsPerformSelector:@selector(setList:) withObject:nil];
    [self.views makeObjectsPerformSelector:@selector(setList:) withObject:nil];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p, title: %@>", NSStringFromClass([self class]), self, self.title];
}

- (void)makeParentOfObjects:(NSArray *)objects
{
    [self.items makeObjectsPerformSelector:@selector(setList:) withObject:self];
}

- (void)setItems:(NSArray *)items
{
    if (self->_items != items)
    {
        self->_items = [items copy];
        [self makeParentOfObjects:self->_items];
    }
}

- (void)setFields:(NSArray *)fields
{
    if (self->_fields != fields)
    {
        self->_fields = [fields copy];
        [self makeParentOfObjects:self->_fields];
    }
}

- (void)setViews:(NSArray *)views
{
    if (self->_views != views)
    {
        self->_views = [views copy];
        [self makeParentOfObjects:self->_views];
    }
}

@end
