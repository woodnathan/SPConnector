//
//  SPList.h
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

#import "SPObject.h"

@interface SPList : SPObject

@property (nonatomic, readonly) NSString *title;
@property (nonatomic, readonly) NSString *identifier;
@property (nonatomic, readonly) NSString *listName;

@property (nonatomic, readonly) BOOL enableAttachments;

@property (nonatomic, copy) NSArray *items;
@property (nonatomic, copy) NSArray *fields;
@property (nonatomic, copy) NSArray *views;

@end

@interface SPList (Operations)

- (void)createItemWithFields:(NSDictionary *)fields completion:(void (^)(NSArray *results, NSError *error))completion;

- (void)loadItems:(void (^)(NSArray *items, NSError *error))completion;
- (void)loadFields:(void (^)(NSArray *fields, NSError *error))completion;
- (void)loadViews:(void (^)(NSArray *views, NSError *error))completion;

@end
