//
//  SPContext.h
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

#import <Foundation/Foundation.h>

extern NSString *const SPContextWillBeDeallocated;

@class SPMethod;
@class SPWeb, SPList;
@class SPGetListItems;

typedef void(^SPContextRequestSetup)(id requestOperation);

@interface SPContext : NSObject

- (id)initWithSiteURL:(NSURL *)url;

@property (nonatomic, copy, readonly) NSURL *siteURL;
@property (nonatomic, assign) Class requestOperationClass;

@property (nonatomic, copy) SPContextRequestSetup requestSetupBlock;
- (void)setRequestSetupBlock:(void (^)(id requestOperation))block;

- (NSURL *)URLRelativeToSiteWithString:(NSString *)URLString;
- (id)requestOperationWithRequest:(NSURLRequest *)request;

- (void)enqueueMethod:(SPMethod *)method;

@end

@interface SPContext (Operations)

// Webs
- (void)getWebCollection:(void (^)(NSArray *webs))completion;
- (void)getWeb:(NSString *)webURL completion:(void (^)(SPWeb *web))completion;

// Lists
- (void)getListCollection:(void (^)(NSArray *lists))completion;
- (void)getListWithList:(SPList *)list completion:(void (^)(SPList *list))completion;
- (void)getList:(NSString *)listName completion:(void (^)(SPList *list))completion;
- (void)getList:(NSString *)listName items:(void (^)(NSArray *items))completion;
- (void)getList:(NSString *)listName parentRef:(NSString *)parentRef items:(void (^)(NSArray *items))completion;
- (void)getList:(NSString *)listName parentRef:(NSString *)parentRef setup:(void (^)(SPGetListItems *op))setup items:(void (^)(NSArray *items))completion;
- (void)getList:(NSString *)listName itemID:(NSString *)itemID attachments:(void (^)(NSArray *attachments))completion;

// Views
- (void)getList:(NSString *)listName views:(void (^)(NSArray *views))completion;

@end