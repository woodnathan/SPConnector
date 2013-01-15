//
//  SPObject.m
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

#import "SPObject.h"
#import <libxml/tree.h>
#import <objc/runtime.h>
#import "SPContext.h"

@interface SPObject () {
    xmlNodePtr _xmlNode;
    NSMutableDictionary *_backingStore;
}

@property (nonatomic, readonly) NSMutableDictionary *backingStore;

- (id)primitiveValueForKey:(NSString *)key;

+ (NSDate *)dateFromString:(NSString *)string;

- (void)contextWillBeDeallocated:(NSNotification *)notification;

@end


@implementation SPObject

- (id)initWithNode:(xmlNodePtr)node context:(SPContext *)context
{
    self = [super init];
    if (self)
    {
        // Recursively copy the node with properties and namespaces
        _xmlNode = xmlCopyNode((xmlNodePtr)node, 2);
        if (_xmlNode == NULL)
            return nil;
        
        _context = context;
        
        if (context)
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(contextWillBeDeallocated:)
                                                         name:SPContextWillBeDeallocated
                                                       object:context];
    }
    return self;
}

- (void)dealloc
{
    xmlFreeNode(_xmlNode);
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)contextWillBeDeallocated:(NSNotification *)notification
{
    if (notification.object == _context)
        _context = nil;
}

+ (NSDictionary *)propertyToAttributeMap
{
    return nil;
}
+ (NSArray *)dateProperties
{
    return nil;
}

+ (NSDate *)dateFromString:(NSString *)string
{
    static __DISPATCH_ONCE__ NSDateFormatter *formatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    });
    
    return [formatter dateFromString:string];
}

- (NSMutableDictionary *)backingStore
{
    if (_backingStore == nil)
        _backingStore = [[NSMutableDictionary alloc] init];
    return _backingStore;
}

- (void)forwardInvocation:(NSInvocation *)anInvocation
{
    NSString *key = NSStringFromSelector(anInvocation.selector);
    
    [anInvocation setSelector:@selector(valueForKey:)];
    [anInvocation setArgument:&key atIndex:2];
    
    [anInvocation invokeWithTarget:self];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
{
    NSMethodSignature *ret = [[self class] instanceMethodSignatureForSelector:aSelector];
    
    if (ret == nil)
        ret = [[self class] instanceMethodSignatureForSelector:@selector(valueForKey:)];
    
    return ret;
}

NSString *fastGetter(id self, SEL _cmd) {
    NSString *key = NSStringFromSelector(_cmd);
    id val = [[self backingStore] objectForKey:key];
    if (val == nil)
        val = [self valueForUndefinedKey:key];
    return val;
}

- (id)valueForUndefinedKey:(NSString *)key
{
    id retVal = nil;
    
    if ((retVal = [self.backingStore objectForKey:key]) == nil)
    {
        if ((retVal = [self primitiveValueForKey:key]) == nil)
        {
            id mappedKey = [[[self class] propertyToAttributeMap] objectForKey:key];
            
            if ((retVal = [self primitiveValueForKey:mappedKey]) == nil)
            {
                id owsKey = [NSString stringWithFormat:@"ows_%@", key];
                
                if ((retVal = [self primitiveValueForKey:owsKey]) == nil)
                {
                    return nil;
                }
            }
        }
        
        NSRange range = [retVal rangeOfString:@"#;"];
        if (range.location != NSNotFound)
            retVal = [retVal substringFromIndex:(range.location + range.length)];
        
        if ([[[self class] dateProperties] containsObject:key])
            retVal = [[self class] dateFromString:retVal];
        
        [self.backingStore setObject:retVal forKey:key];
        
        SEL cmd = NSSelectorFromString(key);
        if (class_getInstanceMethod([self class], cmd) == NULL)
            class_addMethod([self class], cmd, (IMP)fastGetter, "@@:");
    }
    
    return retVal;
}

- (id)primitiveValueForKey:(NSString *)key
{
    xmlAttrPtr attr = xmlHasProp(_xmlNode, (xmlChar *)[key UTF8String]);
    
    if (attr)
    {
        char *content = (char *)xmlNodeGetContent((xmlNodePtr)attr);
        id value = [[NSString alloc] initWithCString:content encoding:NSUTF8StringEncoding];
        xmlFree(content);
        
        return value;
    }
    
    return nil;
}

- (NSDictionary *)dumpProperties
{
    NSMutableDictionary *props = [[NSMutableDictionary alloc] init];
    for (xmlAttrPtr attr = _xmlNode->properties; attr != NULL; attr = attr->next)
    {
        NSString *key = [[NSString alloc] initWithUTF8String:(const char *)attr->name];
        char *content = (char *)xmlNodeGetContent((xmlNodePtr)attr);
        NSString *value = [[NSString alloc] initWithCString:content encoding:NSUTF8StringEncoding];
        xmlFree(content);
        
        [props setObject:value forKey:key];
    }
    return [props copy];
}

@end
