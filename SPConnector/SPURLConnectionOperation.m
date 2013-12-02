//
//  SPURLConnectionOperation.m
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

#import "SPURLConnectionOperation.h"

@interface SPURLConnectionOperation () <NSURLConnectionDelegate, NSURLConnectionDataDelegate> {
    BOOL _isExecuting;
    BOOL _isFinished;
    BOOL _isCancelled;
}

+ (NSThread *)networkRequestThread;
+ (void)networkRequestThreadEntryPoint:(id)object;

@property (nonatomic, strong) NSURLConnection *connection;

@property (nonatomic, strong, readwrite) NSURLResponse *response;
@property (nonatomic, strong, readwrite) NSError *error;
@property (nonatomic, strong, readwrite) NSData *responseData;

- (void)finish;

- (void)operationDidStart;
- (void)cancelConnection;

@end

@implementation SPURLConnectionOperation

@synthesize runLoopModes = _runLoopModes;
@synthesize request = _request;
@synthesize response = _response;
@synthesize error = _error;
@synthesize outputStream = _outputStream;
@synthesize responseData = _responseData;
@synthesize authenticationChallengeBlock = _authenticationChallengeBlock;
@synthesize connection = _connection;

- (id)initWithRequest:(NSURLRequest *)request
{
    self = [super init];
    if (self)
    {
        if (request == nil)
            return (self = nil);
        
        self.request = request;
        
        self.runLoopModes = [NSSet setWithObject:NSRunLoopCommonModes];
        
        self.outputStream = [NSOutputStream outputStreamToMemory];
    }
    return self;
}

#pragma mark - Operation Properties

- (BOOL)isConcurrent
{
    return YES;
}

- (BOOL)isExecuting
{
    return self->_isExecuting;
}

- (BOOL)isFinished
{
    return self->_isFinished;
}

- (BOOL)isCancelled
{
    return self->_isCancelled;
}

- (void)finish
{
    [self willChangeValueForKey:@"isExecuting"];
    [self willChangeValueForKey:@"isFinished"];
    self->_isExecuting = NO;
    self->_isFinished = YES;
    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];
}

#pragma mark - Operation

- (void)start
{
    [self willChangeValueForKey:@"isExecuting"];
    self->_isExecuting = YES;
    [self didChangeValueForKey:@"isExecuting"];
    
    [self performSelector:@selector(operationDidStart)
                 onThread:[[self class] networkRequestThread]
               withObject:nil
            waitUntilDone:NO
                    modes:[self.runLoopModes allObjects]];
}

- (void)operationDidStart
{
    if ([self isCancelled])
    {
        [self finish];
    }
    else
    {
        NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:self.request
                                                                      delegate:self
                                                              startImmediately:NO];
        NSOutputStream *outputStream = self.outputStream;
        
        NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
        for (NSString *runLoopMode in self.runLoopModes)
        {
            [connection scheduleInRunLoop:runLoop forMode:runLoopMode];
            [outputStream scheduleInRunLoop:runLoop forMode:runLoopMode];
        }
        
        self.connection = connection;
        [connection start];
    }
}

- (void)cancel
{
    [self willChangeValueForKey:@"isCancelled"];
    self->_isCancelled = YES;
    [self didChangeValueForKey:@"isCancelled"];
    
    [self performSelector:@selector(cancelConnection)
                 onThread:[[self class] networkRequestThread]
               withObject:nil
            waitUntilDone:NO
                    modes:[self.runLoopModes allObjects]];
}

- (void)cancelConnection
{
    NSURLConnection *connection = self.connection;
    if (connection != nil)
    {
        [connection cancel];
        
        NSURL *failingURL = [self.request URL];
        NSDictionary *userInfo = nil;
        if (failingURL != nil)
            userInfo = @{ NSURLErrorFailingURLErrorKey : failingURL };
        
        NSError *error = [NSError errorWithDomain:NSURLErrorDomain
                                             code:NSURLErrorCancelled
                                         userInfo:userInfo];
        [self connection:connection didFailWithError:error];
    }
}

#pragma mark - Connection

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    self.response = response;
    
    [self.outputStream open];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    NSOutputStream *outputStream = self.outputStream;
    if ([outputStream hasSpaceAvailable])
    {
        const uint8_t *dataBuffer = (uint8_t *)data.bytes;
        NSUInteger length = data.length;
        [outputStream write:dataBuffer maxLength:length];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    self.responseData = [self.outputStream propertyForKey:NSStreamDataWrittenToMemoryStreamKey];
    
    [self.outputStream close];
    
    [self finish];
    
    self.connection = nil;
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    self.error = error;
    
    [self.outputStream close];
    
    [self finish];
    
    self.connection = nil;
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    SPAuthenticationChallengeBlock block = self.authenticationChallengeBlock;
    if (block)
        block(connection, challenge);
}

#pragma mark - Threading

+ (NSThread *)networkRequestThread
{
    static NSThread *_networkRequestThread = nil;
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate, ^{
        _networkRequestThread = [[NSThread alloc] initWithTarget:self selector:@selector(networkRequestThreadEntryPoint:) object:nil];
        _networkRequestThread.name = @"SPURLConnection";
        [_networkRequestThread start];
    });
    
    return _networkRequestThread;
}

+ (void)networkRequestThreadEntryPoint:(id)object
{
    @autoreleasepool
    {
        while ([[NSThread currentThread] isCancelled] == NO)
        {
            [[NSRunLoop currentRunLoop] run];
        }
    }
}

@end
