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

@class SPContext;
@class SPMethod;
@class SPWeb, SPList;
@class SPGetListItems;

typedef void(^SPContextRequestSetup)(id requestOperation);

@protocol SPContextDelegate <NSObject>

- (void)context:(SPContext *)context didFailWithError:(NSError *)error;

@end

@interface SPContext : NSObject

- (id)initWithSiteURL:(NSURL *)url; // Default: SOAP 1.2
- (id)initWithSiteURL:(NSURL *)url version:(SPSOAPVersion)version;

@property (nonatomic, copy, readonly) NSURL *siteURL;
@property (nonatomic, assign, readonly) SPSOAPVersion version;

@property (nonatomic, weak) id <SPContextDelegate> delegate;

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
- (void)getWebCollection:(void (^)(NSArray *webs, NSError *error))completion;
- (void)getWeb:(NSString *)webURL completion:(void (^)(SPWeb *web, NSError *error))completion;

// Lists
- (void)getListCollection:(void (^)(NSArray *lists, NSError *error))completion;
- (void)getListWithList:(SPList *)list completion:(void (^)(SPList *list, NSError *error))completion;
- (void)getList:(NSString *)listName completion:(void (^)(SPList *list, NSError *error))completion;
- (void)getList:(NSString *)listName items:(void (^)(NSArray *items, NSError *error))completion;
- (void)getList:(NSString *)listName parentRef:(NSString *)parentRef items:(void (^)(NSArray *items, NSError *error))completion;
- (void)getList:(NSString *)listName parentRef:(NSString *)parentRef setup:(void (^)(SPGetListItems *op))setup items:(void (^)(NSArray *items, NSError *error))completion;
- (void)getList:(NSString *)listName itemID:(NSString *)itemID attachments:(void (^)(NSArray *attachments, NSError *error))completion;
- (void)createList:(NSString *)listName itemWithFields:(NSDictionary *)fields results:(void (^)(NSArray *results, NSError *error))completion;

// Views
- (void)getList:(NSString *)listName views:(void (^)(NSArray *views, NSError *error))completion;

@end