//
//  SPContext.m
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

#import "SPContext.h"
#import "SPMethodRequest.h"
#import "SPMethod.h"

#import "SPGetListCollection.h"
#import "SPGetListItems.h"

#import "SPGetWebCollection.h"

@interface SPContext ()

@property (nonatomic, copy, readwrite) NSURL *siteURL;

@property (nonatomic, strong) NSOperationQueue *methodQueue;

@end


@implementation SPContext

- (id)initWithSiteURL:(NSURL *)url
{
    self = [super init];
    if (self)
    {
        self.siteURL = url;
        
        self.methodQueue = [[NSOperationQueue alloc] init];
    }
    return self;
}

- (NSURL *)URLRelativeToSiteWithString:(NSString *)URLString
{
    return [NSURL URLWithString:URLString relativeToURL:self.siteURL];
}

- (id)requestOperationWithRequest:(NSURLRequest *)request
{
    id <SPMethodRequest> operation = [self.requestOperationClass alloc];
    
    NSAssert([operation conformsToProtocol:@protocol(SPMethodRequest)], @"Operation does not conform to SPMethodRequest");
    
    operation = [operation initWithRequest:request];
    
    if (self.requestSetupBlock)
        self.requestSetupBlock(operation);
    
    return operation;
}

- (void)enqueueMethod:(SPMethod *)method
{
    [self.methodQueue addOperation:method];
}

- (void)getWebCollection:(void (^)(NSArray *webs))completion
{
    SPGetWebCollection *op = [[SPGetWebCollection alloc] initWithContext:self];
    
    if (completion)
        [op setCompletionBlock:^{
            completion(op.responseObjects);
        }];
    
    [self enqueueMethod:op];
}

- (void)getListCollection:(void (^)(NSArray *lists))completion
{
    SPGetListCollection *op = [[SPGetListCollection alloc] initWithContext:self];
    
    if (completion)
        [op setCompletionBlock:^{
            completion(op.responseObjects);
        }];
    
    [self enqueueMethod:op];
}

- (void)getList:(NSString *)listName items:(void (^)(NSArray *items))completion
{
    [self getList:listName parentRef:nil items:completion];
}

- (void)getList:(NSString *)listName parentRef:(NSString *)parentRef items:(void (^)(NSArray *items))completion
{
    SPGetListItems *op = [[SPGetListItems alloc] initWithContext:self];
    
    op.listName = listName;
    op.parentFileRef = parentRef;
    
    if (completion)
        [op setCompletionBlock:^{
            completion(op.responseObjects);
        }];
    
    [self enqueueMethod:op];
}

@end
