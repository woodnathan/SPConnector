//
//  SPMethod.m
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

#import "SPMethod.h"
#import "SPMessage.h"
#import "SPMethodRequest.h"
#import "SPContext.h"
#import "SPObject.h"
#import <libxml/tree.h>
#import <libxml/xpath.h>
#import <libxml/xpathInternals.h>

@interface SPMethod ()

@property (nonatomic, assign, readwrite) BOOL isExecuting;
@property (nonatomic, assign, readwrite) BOOL isFinished;

@property (nonatomic, weak, readwrite) SPContext *context;

@property (nonatomic, strong, readwrite) SPMessage *requestMessage;
@property (nonatomic, strong, readwrite) SPMessage *responseMessage;
@property (nonatomic, strong, readwrite) NSArray *responseObjects;

@property (nonatomic, strong, readwrite) NSError *error;

@property (nonatomic, strong) NSObject <SPMethodRequest>* requestOperation;

- (void)finish;

@end


@implementation SPMethod

- (id)initWithContext:(SPContext *)context
{
    self = [super init];
    if (self)
    {
        self.context = context;
        
        self.requestMessage = [[SPMessage alloc] initWithMethod:[[self class] method]];
    }
    return self;
}

+ (NSString *)method
{
    return nil;
}

+ (NSString *)endpoint
{
    return nil;
}

+ (NSString *)objectPath
{
    return nil;
}

+ (Class)objectClass
{
    return Nil;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object == self.requestOperation)
        [self finish];
}

- (void)start
{
    [self willChangeValueForKey:@"isExecuting"];
    self.isExecuting = YES;
    [self didChangeValueForKey:@"isExecuting"];
    
    NSURL *URL = [self.context URLRelativeToSiteWithString:[[self class] endpoint]];
    NSMutableURLRequest *URLRequest = [[NSMutableURLRequest alloc] initWithURL:URL];
    
    [self prepareRequestMessage];
    
    NSData *XMLData = [self.requestMessage XMLData];
    
    [URLRequest setHTTPMethod:@"POST"];
    [URLRequest setValue:@"application/soap+xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [URLRequest setValue:@"application/soap+xml; charset=utf-8" forHTTPHeaderField:@"Accept"];
    [URLRequest setHTTPBody:XMLData];
    
    self.requestOperation = [self.context requestOperationWithRequest:URLRequest];
    [self.requestOperation addObserver:self
                            forKeyPath:@"isFinished"
                               options:(NSKeyValueObservingOptionOld |  NSKeyValueObservingOptionNew)
                               context:NULL];
    [self.requestOperation start];
}

- (void)finish
{
    NSError *error = nil;
    self.responseMessage = [[SPMessage alloc] initWithData:[self.requestOperation responseData]
                                                     error:&error];
    self.error = error;
    
    [self parseResponseMessage];
    
    [self willChangeValueForKey:@"isExecuting"];
    [self willChangeValueForKey:@"isFinished"];
    self.isExecuting = NO;
    self.isFinished = YES;
    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];
}

- (void)prepareRequestMessage
{
    
}

- (void)parseResponseMessage
{
    NSMutableArray *objects = [[NSMutableArray alloc] init];
    
    NSString *path = [[self class] objectPath];
    [self.responseMessage enumerateNodesForXPath:path withBlock:^(xmlNodePtr node) {
        id obj = [[[self class] objectClass] alloc];
        obj = [obj initWithNode:node context:self.context];
        [objects addObject:obj];
    }];
    
    self.responseObjects = [objects copy];
}

@end
