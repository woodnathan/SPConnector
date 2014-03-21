//
//  SPObject.m
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

#import "SPObject.h"
#import <libxml/tree.h>
#import <objc/runtime.h>
#import "SPContext.h"
#import "SPObjectPropertyConverterFactory.h"

typedef enum {
    SPObjectPropertyTypeDefault = 0
} SPObjectPropertyType;

static const char *property_getType(objc_property_t property)
{
    const char *attributes = property_getAttributes(property);
    char buffer[1 + strlen(attributes)];
    strcpy(buffer, attributes);
    char *state = buffer, *attribute;
    while ((attribute = strsep(&state, ",")) != NULL) {
        if (attribute[0] == 'T' && attribute[1] != '@') {
            return (const char *)[[NSData dataWithBytes:(attribute + 1) length:strlen(attribute) - 1] bytes];
        }
        else if (attribute[0] == 'T' && attribute[1] == '@' && strlen(attribute) == 2) {
            return "id";
        }
        else if (attribute[0] == 'T' && attribute[1] == '@') {
            return (const char *)[[NSData dataWithBytes:(attribute + 3) length:strlen(attribute) - 4] bytes];
        }
    }
    return "";
}

@interface SPObject () {
  @private
    xmlNodePtr _xmlNode;
  @protected
    NSDictionary *_attributes;
    NSSet *_attributeKeys;
}

@property (nonatomic, readonly) NSMutableDictionary *backingStore;

@property (nonatomic, readonly) NSSet *attributeKeys;

@property (nonatomic, readonly) id <SPObjectMapping> objectMapping;

- (id)primitiveValueForKey:(NSString *)key;

- (void)contextWillBeDeallocated:(NSNotification *)notification;

@end


@implementation SPObject

@synthesize context = _context;
@synthesize backingStore = _backingStore;
@synthesize objectMapping = _objectMapping;

- (id)initWithNode:(xmlNodePtr)node context:(SPContext *)context
{
    self = [super init];
    if (self)
    {
        if (self->_xmlNode != NULL)
            // Recursively copy the node with properties and namespaces
            self->_xmlNode = xmlCopyNode((xmlNodePtr)node, 2);
        
        if (context != nil)
        {
            self->_context = context;
            
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(contextWillBeDeallocated:)
                                                         name:SPContextWillBeDeallocated
                                                       object:context];
        }
    }
    return self;
}

- (void)dealloc
{
    if (self->_xmlNode != NULL)
        xmlFreeNode(self->_xmlNode);
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)contextWillBeDeallocated:(NSNotification *)notification
{
    if (notification.object == _context)
        _context = nil;
}

- (NSMutableDictionary *)backingStore
{
    if (self->_backingStore == nil)
        self->_backingStore = [[NSMutableDictionary alloc] init];
    return self->_backingStore;
}

- (id <SPObjectMapping>)objectMapping
{
    if (self->_objectMapping == nil)
        self->_objectMapping = [SPObjectMappingFactory objectMappingForClass:[self class]];
    return self->_objectMapping;
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

NSString *fastGetter(id self, SEL _cmd)
{
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
        NSSet *attributeKeys = self.attributeKeys;
        NSString *actualKey = key;
        if ([attributeKeys containsObject:actualKey] == NO)
        {
            actualKey = [self.objectMapping attributeForKeyPath:key];
            if ([attributeKeys containsObject:actualKey] == NO)
            {
                actualKey = [NSString stringWithFormat:@"ows_%@", key];
            }
        }
        retVal = [self.attributes objectForKey:actualKey];
        
        objc_property_t prop = class_getProperty([self class], [key UTF8String]);
        if (prop == nil)
            return retVal;
        NSString *type = [NSString stringWithUTF8String:property_getType(prop)];
        id <SPObjectPropertyConverter> converter = [SPObjectPropertyConverterFactory converterForType:type];
        
        if (retVal == nil)
            return [converter valueForNil];
        
        NSRange range = [retVal rangeOfString:@"#;"];
        if (range.location != NSNotFound)
            retVal = [retVal substringFromIndex:(range.location + range.length)];
        
        retVal = [converter valueForString:retVal];
        
        [self.backingStore setObject:retVal forKey:key];
        
        SEL cmd = NSSelectorFromString(key);
        if (class_getInstanceMethod([self class], cmd) == NULL)
            class_addMethod([self class], cmd, (IMP)fastGetter, "@@:");
    }
    
    return retVal;
}

- (id)primitiveValueForKey:(NSString *)key
{
    return [self.attributes valueForKey:key];
}

#pragma mark Attributes

- (NSDictionary *)attributes
{
    if (self->_attributes == nil)
    {
        NSMutableDictionary *attrs = [[NSMutableDictionary alloc] init];
        
        xmlNodePtr node = self->_xmlNode;
        if (node != NULL)
        {
            xmlAttrPtr attr = node->properties;
            NSString *key = nil;
            NSString *value = nil;
            while (attr)
            {
                const xmlChar *attrKey = attr->name;
                xmlChar *attrValue = xmlGetProp(node, attrKey);
                value = [NSString stringWithUTF8String:(const char *)attrValue];
                xmlFree(attrValue);
                
                key = [NSString stringWithUTF8String:(const char *)attrKey];
                
                [attrs setObject:value forKey:key];
                
                attr = attr->next;
            }
            
            // Done with the node, dispose of it now
            xmlFree(node), self->_xmlNode = NULL;
        }
        
        self->_attributes = [attrs copy];
    }
    return self->_attributes;
}

- (NSSet *)attributeKeys
{
    if (self->_attributeKeys == nil)
    {
        NSArray *allKeys = [self.attributes allKeys];
        self->_attributeKeys = [NSSet setWithArray:allKeys];
    }
    return self->_attributeKeys;
}

- (NSDictionary *)dumpAttributes
{
    NSMutableDictionary *props = [[NSMutableDictionary alloc] init];
    for (xmlAttrPtr attr = _xmlNode->properties; attr != NULL; attr = attr->next)
    {
        NSString *key = [[NSString alloc] initWithUTF8String:(const char *)attr->name];
        char *content = (char *)xmlNodeGetContent((xmlNodePtr)attr);
        NSString *value = [[NSString alloc] initWithUTF8String:content];
        xmlFree(content);
        
        [props setObject:value forKey:key];
    }
    return [props copy];
}

#pragma mark NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.attributes forKey:NSStringFromSelector(@selector(attributes))];
    [aCoder encodeObject:self.objectMapping forKey:NSStringFromSelector(@selector(objectMapping))];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [self initWithNode:NULL context:nil];
    if (self)
    {
        self->_attributes = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(attributes))];
        self->_objectMapping = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(objectMapping))];
    }
    return self;
}

@end
