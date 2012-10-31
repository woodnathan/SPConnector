//
//  SPList.m
//
//  Copyright (c) 2012 Nathan Wood (http://www.woodnathan.com/)
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
#import "SPContext.h"
#import "SPListItem.h"

@implementation SPList

@dynamic title, identifier, name;

+ (NSDictionary *)propertyToAttributeMap
{
    return @{ @"identifier" : @"ID", @"title" : @"Title", @"name" : @"Name" };
}

- (void)loadItems:(void (^)(NSArray *items))completion
{
    [self.context getList:self.name
                    items:^(NSArray *items) {
                        self.items = items;
                        [self.items makeObjectsPerformSelector:@selector(setList:) withObject:self];
                        
                        if (completion)
                            completion(items);
                    }];
}

@end
