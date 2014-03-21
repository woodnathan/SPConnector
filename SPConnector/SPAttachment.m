//
//  SPAttachment.m
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

#import "SPAttachment.h"
#import <libxml/tree.h>

@interface SPAttachment ()

@property (nonatomic, copy, readwrite) NSString *URLString;

@end


@implementation SPAttachment

@synthesize parent = _parent, URLString = _URLString;

- (id)initWithNode:(xmlNodePtr)node context:(SPContext *)context
{
    self = [super initWithNode:node context:context];
    if (self)
    {
        xmlChar *content = xmlNodeGetContent(node);
        self.URLString = [[[NSString alloc] initWithUTF8String:(const char *)content] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        free(content);
    }
    return self;
}

#pragma mark NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    
    [aCoder encodeObject:self.URLString forKey:NSStringFromSelector(@selector(URLString))];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        self.URLString = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(URLString))];
    }
    return self;
}

@end