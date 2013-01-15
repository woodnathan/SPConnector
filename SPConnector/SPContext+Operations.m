//
//  SPContext+Operations.m
//  SPTest
//
//  Created by Nathan Wood on 15/01/13.
//  Copyright (c) 2013 Nathan Wood. All rights reserved.
//

#import "SPContext.h"
#import "SPMethod.h"

#import "SPGetListCollection.h"
#import "SPGetList.h"
#import "SPGetListItems.h"
#import "SPGetAttachmentCollection.h"

#import "SPGetViewCollection.h"

#import "SPGetWebCollection.h"
#import "SPGetWeb.h"

@interface SPContext (OperationsPrivate)

- (SPMethod *)methodForClass:(Class)class setup:(void (^)(id op))setup completion:(void (^)(NSArray *items))completion;
- (SPMethod *)methodForClass:(Class)class setup:(void (^)(id op))setup completion:(void (^)(NSArray *items))completion enqueue:(BOOL)enqueue;
- (void)setMethod:(SPMethod *)method completionBlock:(void (^)(NSArray *items))completion;

@end

@implementation SPContext (OperationsPrivate)

- (SPMethod *)methodForClass:(Class)class setup:(void (^)(id op))setup completion:(void (^)(NSArray *items))completion
{
    return [self methodForClass:class setup:setup completion:completion enqueue:YES];
}

- (SPMethod *)methodForClass:(Class)class setup:(void (^)(id op))setup completion:(void (^)(NSArray *items))completion enqueue:(BOOL)enqueue
{
    SPMethod *method = [[class alloc] initWithContext:self];
    
    if (setup)
        setup(method);
    
    [self setMethod:method completionBlock:completion];
    
    if (enqueue)
        [self enqueueMethod:method];
    
    return method;
}

- (void)setMethod:(SPMethod *)method completionBlock:(void (^)(NSArray *items))completion
{
    if (completion)
    {
        __unsafe_unretained SPMethod *uMethod = method;
        [method setCompletionBlock:^{
            NSArray *respObjs = uMethod.responseObjects;
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(respObjs);
            });
        }];
    }
}

@end

@implementation SPContext (Operations)

- (void)getWebCollection:(void (^)(NSArray *webs))completion
{
    [self methodForClass:[SPGetWebCollection class] setup:NULL completion:completion];
}

- (void)getWeb:(NSString *)webURL completion:(void (^)(SPWeb *web))completion
{
    void(^compBlock)(NSArray *) = NULL;
    if (completion)
        compBlock = ^(NSArray *items) {
            completion([items lastObject]);
        };
    
    [self methodForClass:[SPGetWeb class]
                   setup:^(SPGetWeb *op) {
                       op.webURL = webURL;
                   }
              completion:compBlock];
}

- (void)getListCollection:(void (^)(NSArray *lists))completion
{
    [self methodForClass:[SPGetListCollection class] setup:NULL completion:completion];
}

- (void)getList:(NSString *)listName completion:(void (^)(SPList *list))completion
{
    void(^compBlock)(NSArray *) = NULL;
    if (completion)
        compBlock = ^(NSArray *items) {
            completion([items lastObject]);
        };
    
    [self methodForClass:[SPGetList class]
                   setup:^(SPGetList *op) {
                       op.listName = listName;
                   }
              completion:compBlock];
}

- (void)getList:(NSString *)listName items:(void (^)(NSArray *items))completion
{
    [self getList:listName parentRef:nil items:completion];
}

- (void)getList:(NSString *)listName parentRef:(NSString *)parentRef items:(void (^)(NSArray *items))completion
{
    [self getList:listName parentRef:parentRef setup:NULL items:completion];
}

- (void)getList:(NSString *)listName parentRef:(NSString *)parentRef setup:(void (^)(SPGetListItems *op))setup items:(void (^)(NSArray *items))completion
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

- (void)getList:(NSString *)listName itemID:(NSString *)itemID attachments:(void (^)(NSArray *attachments))completion
{
    [self methodForClass:[SPGetAttachmentCollection class]
                   setup:^(SPGetAttachmentCollection *op) {
                       op.listName = listName;
                       op.listItemID = itemID;
                   }
              completion:completion];
}

- (void)getList:(NSString *)listName views:(void (^)(NSArray *views))completion
{
    [self methodForClass:[SPGetViewCollection class]
                   setup:^(SPGetViewCollection *op) {
                       op.listName = listName;
                   }
              completion:completion];
}

@end
