//
//  SPMessage.h
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
#import <libxml/tree.h>
#import "SPContext.h"

@interface SPMessage : NSObject

- (id)initWithMethod:(NSString *)method; // Default is SOAP v1.2
- (id)initWithMethod:(NSString *)method version:(SPSOAPVersion)version;
- (id)initWithData:(NSData *)data error:(NSError **)error;

- (NSData *)XMLData;

@property (nonatomic, readonly) SPSOAPVersion version;

@property (nonatomic, readonly) xmlDocPtr XMLDocument;
@property (nonatomic, readonly) xmlNodePtr rootElement;
@property (nonatomic, readonly) xmlNodePtr methodElement;

- (void)addMethodElementChild:(xmlNodePtr)child;
- (xmlNodePtr)addMethodElementWithName:(NSString *)name value:(NSString *)value;

- (void)enumerateNodesForXPath:(NSString *)path withBlock:(void (^)(xmlNodePtr node, BOOL *stop))block;
- (void)enumerateRowNodesForXPath:(NSString *)path withBlock:(void (^)(xmlNodePtr node, BOOL *stop))block;

@end
