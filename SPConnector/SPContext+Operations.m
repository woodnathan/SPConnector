//
//  SPContext+Operations.m
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

#import "SPContext.h"
#import "SPMethod.h"

#import "SPGetListCollection.h"
#import "SPGetList.h"
#import "SPGetListItems.h"
#import "SPGetAttachmentCollection.h"
#import "SPUpdateListItems.h"

#import "SPGetViewCollection.h"

#import "SPGetWebCollection.h"
#import "SPGetWeb.h"

typedef void (^SPContextCompletionBlock)(NSArray *items, NSError *error);

@interface SPContext (OperationsPrivate)

- (SPMethod *)methodForClass:(Class)class setup:(void (^)(id op))setup completion:(SPContextCompletionBlock)completion;
- (SPMethod *)methodForClass:(Class)class setup:(void (^)(id op))setup completion:(SPContextCompletionBlock)completion enqueue:(BOOL)enqueue;
- (void)setMethod:(SPMethod *)method completionBlock:(SPContextCompletionBlock)completion;

@end

@implementation SPContext (OperationsPrivate)

- (SPMethod *)methodForClass:(Class)class setup:(void (^)(id op))setup completion:(SPContextCompletionBlock)completion
{
    return [self methodForClass:class setup:setup completion:completion enqueue:YES];
}

- (SPMethod *)methodForClass:(Class)class setup:(void (^)(id op))setup completion:(SPContextCompletionBlock)completion enqueue:(BOOL)enqueue
{
    SPMethod *method = [[class alloc] initWithContext:self];
    
    if (setup)
        setup(method);
    
    [self setMethod:method completionBlock:completion];
    
    if (enqueue)
        [self enqueueMethod:method];
    
    return method;
}

- (void)setMethod:(SPMethod *)method completionBlock:(SPContextCompletionBlock)completion
{
    if (completion)
    {
        __unsafe_unretained SPMethod *uMethod = method;
        [method setCompletionBlock:^{
            NSArray *respObjs = uMethod.responseObjects;
            NSError *error = uMethod.error;
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(respObjs, error);
            });
        }];
    }
}

@end

@implementation SPContext (Operations)

- (void)getWebCollection:(void (^)(NSArray *webs, NSError *error))completion
{
    [self methodForClass:[SPGetWebCollection class] setup:NULL completion:completion];
}

- (void)getWeb:(NSString *)webURL completion:(void (^)(SPWeb *web, NSError *error))completion
{
    void(^compBlock)(NSArray *, NSError *) = NULL;
    if (completion)
        compBlock = ^(NSArray *items, NSError *error) {
            completion([items lastObject], error);
        };
    
    [self methodForClass:[SPGetWeb class]
                   setup:^(SPGetWeb *op) {
                       op.webURL = webURL;
                   }
              completion:compBlock];
}

- (void)getListCollection:(void (^)(NSArray *lists, NSError *error))completion
{
    [self methodForClass:[SPGetListCollection class] setup:NULL completion:completion];
}

- (void)getListWithList:(SPList *)list completion:(void (^)(SPList *list, NSError *error))completion
{
    void(^compBlock)(NSArray *, NSError *) = NULL;
    if (completion)
        compBlock = ^(NSArray *items, NSError *error) {
            completion([items lastObject], error);
        };
    
    [self methodForClass:[SPGetList class]
                   setup:^(SPGetList *op) {
                       op.list = list;
                   }
              completion:compBlock];
}

- (void)getList:(NSString *)listName completion:(void (^)(SPList *list, NSError *error))completion
{
    void(^compBlock)(NSArray *, NSError *) = NULL;
    if (completion)
        compBlock = ^(NSArray *items, NSError *error) {
            completion([items lastObject], error);
        };
    
    [self methodForClass:[SPGetList class]
                   setup:^(SPGetList *op) {
                       op.listName = listName;
                   }
              completion:compBlock];
}

- (void)getList:(NSString *)listName items:(void (^)(NSArray *items, NSError *error))completion
{
    [self getList:listName parentRef:nil items:completion];
}

- (void)getList:(NSString *)listName parentRef:(NSString *)parentRef items:(void (^)(NSArray *items, NSError *error))completion
{
    [self getList:listName parentRef:parentRef setup:NULL items:completion];
}

- (void)getList:(NSString *)listName parentRef:(NSString *)parentRef setup:(void (^)(SPGetListItems *op))setup items:(void (^)(NSArray *items, NSError *error))completion
{
    [self methodForClass:[SPGetListItems class]
                   setup:^(SPGetListItems *op) {
                       op.listName = listName;
                       op.parentFileRef = parentRef;
                       
                       if (setup)
                           setup(op);
                   }
              completion:completion];
}

- (void)getList:(NSString *)listName itemID:(NSString *)itemID attachments:(void (^)(NSArray *attachments, NSError *error))completion
{
    [self methodForClass:[SPGetAttachmentCollection class]
                   setup:^(SPGetAttachmentCollection *op) {
                       op.listName = listName;
                       op.listItemID = itemID;
                   }
              completion:completion];
}

- (void)createList:(NSString *)listName itemWithFields:(NSDictionary *)fields results:(void (^)(NSArray *results, NSError *error))completion
{
    [self methodForClass:[SPUpdateListItems class]
                   setup:^(SPUpdateListItems *op) {
                       op.listName = listName;
                       [op.batch createWithFields:fields];
                   }
              completion:completion];
}

- (void)getList:(NSString *)listName views:(void (^)(NSArray *views, NSError *error))completion
{
    [self methodForClass:[SPGetViewCollection class]
                   setup:^(SPGetViewCollection *op) {
                       op.listName = listName;
                   }
              completion:completion];
}

@end
