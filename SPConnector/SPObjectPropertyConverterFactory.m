//
//  SPObjectPropertyConverterBase.m
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

#import "SPObjectPropertyConverterFactory.h"

NSString *const SPObjectDefaultPropertyConverterKey = @"kDefault";


@interface SPObjectPropertyConverterFactory ()

+ (NSMutableDictionary *)converters;

@end


@implementation SPObjectPropertyConverterFactory

+ (NSMutableDictionary *)converters
{
    static __DISPATCH_ONCE__ NSMutableDictionary *_converters = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _converters = [[NSMutableDictionary alloc] init];
    });
    return _converters;
}

+ (BOOL)registerConverter:(id <SPObjectPropertyConverter>)converter forType:(NSString *)type
{
    if (converter != nil && [converter conformsToProtocol:@protocol(SPObjectPropertyConverter)])
    {
        [[self converters] setObject:converter forKey:type];
        return YES;
    }
    return NO;
}

+ (id <SPObjectPropertyConverter>)converterForType:(NSString *)type
{
    id propConverter = nil;
    if (type == nil || (propConverter = [[self converters] objectForKey:type]) == nil)
        propConverter = [[self converters] objectForKey:SPObjectDefaultPropertyConverterKey];
    
    return propConverter;
}

@end
