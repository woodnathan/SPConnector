//
//  SPListItem.m
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


#import "SPListItem.h"
#import "SPContext.h"
#import "SPListItemMapping.h"

@implementation SPListItem

@dynamic itemID, itemUniqueID;
@dynamic title, contentType;
@dynamic fileRef;
@synthesize parent = _parent, children = _children, attachments = _attachments;

+ (void)initialize
{
    if (self == [SPListItem class])
        [SPObjectMappingFactory registerObjectMapping:[[SPListItemMapping alloc] init]
                                             forClass:self];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p, title: %@>", NSStringFromClass([self class]), self, self.title];
}

- (void)dealloc
{
    [self.children makeObjectsPerformSelector:@selector(setParent:) withObject:nil];
}

- (void)loadChildren:(void (^)(NSArray *items, NSError *error))completion
{
    [self.context getList:self.listName
                parentRef:self.fileRef
                    items:^(NSArray *items, NSError *error) {
                        self.children = items;
                        [self.children makeObjectsPerformSelector:@selector(setParent:) withObject:self];
                        
                        if (completion)
                            completion(items, error);
                    }];
}

- (void)loadAttachments:(void (^)(NSArray *attachments, NSError *error))completion
{
    [self.context getList:self.listName
                   itemID:self.itemID
              attachments:^(NSArray *attachments, NSError *error) {
                  self.attachments = attachments;
                  [self.attachments makeObjectsPerformSelector:@selector(setParent:) withObject:self];
                  
                  if (completion)
                      completion(attachments, error);
              }];
}

@end
