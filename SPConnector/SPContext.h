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
#import "SPURLConnectionOperation.h"

extern NSString *const SPContextWillBeDeallocated;

typedef NS_ENUM(unsigned char, SPSOAPVersion) {
    SPSOAPVersion12 = 0,
    SPSOAPVersion11
};

@class SPMethod;
@class SPWeb, SPList;
@class SPGetListItems;

typedef void(^SPContextRequestSetup)(id requestOperation);

@interface SPContext : NSObject

- (id)initWithSiteURL:(NSURL *)url; // Default: SOAP 1.2
- (id)initWithSiteURL:(NSURL *)url version:(SPSOAPVersion)version;

@property (nonatomic, copy, readonly) NSURL *siteURL;
@property (nonatomic, assign, readonly) SPSOAPVersion version;

/**
 *  Instances of class must conform to SPMethodRequestOperation
 *  Has a default value of the SPURLConnectionOperation class
 */
@property (nonatomic, assign) Class requestOperationClass;

@property (nonatomic, copy) SPContextRequestSetup requestSetupBlock;
- (void)setRequestSetupBlock:(void (^)(id requestOperation))block;

- (NSURL *)URLRelativeToSiteWithString:(NSString *)URLString;
- (id)requestOperationWithRequest:(NSURLRequest *)request;

- (void)enqueueMethod:(SPMethod *)method;

@end

#pragma mark - Operations

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
- (void)createList:(NSString *)listName itemWithFields:(NSDictionary *)fields results:(void (^)(NSArray *results))completion;

// Views
- (void)getList:(NSString *)listName views:(void (^)(NSArray *views))completion;

@end