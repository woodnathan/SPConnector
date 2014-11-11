//
//  SPListItem.h
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

#import "SPListAttachedObject.h"

@class SPList;

@interface SPListItem : SPListAttachedObject

@property (nonatomic, readonly) NSString *itemID;
@property (nonatomic, readonly) NSString *itemUniqueID;

@property (nonatomic, readonly) NSString *title;
@property (nonatomic, readonly) NSString *contentType;
@property (nonatomic, readonly) NSString *baseName;
@property (nonatomic, readonly) NSString *docIcon;

@property (nonatomic, readonly) NSString *fileRef;

@property (nonatomic, weak) SPListItem *parent;
@property (nonatomic, copy) NSArray *children;
@property (nonatomic, copy) NSArray *attachments;

- (void)loadChildren:(void (^)(NSArray *items, NSError *error))completion;
- (void)loadAttachments:(void (^)(NSArray *attachments, NSError *error))completion;

@end
