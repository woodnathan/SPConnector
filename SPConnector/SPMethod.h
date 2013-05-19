//
//  SPMethod.h
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
#import "SPCAMLQueryOptions.h"

@class SPContext, SPMessage;

@interface SPMethod : NSOperation {
@protected
    NSArray *_responseObjects;
}

+ (NSString *)method;
+ (NSString *)endpoint;
+ (NSString *)objectPath;
+ (Class)objectClass;
+ (NSString *)SOAPAction;

- (id)initWithContext:(SPContext *)context;

@property (nonatomic, weak, readonly) SPContext *context;

@property (nonatomic, strong, readonly) SPMessage *requestMessage;
@property (nonatomic, strong, readonly) SPMessage *responseMessage;

@property (nonatomic, readonly) SPCAMLQueryOptions *queryOptions;
@property (nonatomic, copy) NSPredicate *predicate;
@property (nonatomic, copy) NSArray *sortDescriptors;
@property (nonatomic, copy) NSString *dateRangeOverlapValue;

@property (nonatomic, strong, readonly) NSArray *responseObjects;

@property (nonatomic, strong, readonly) NSError *error;

- (void)prepareRequestMessage;
- (void)parseResponseMessage;

@end
