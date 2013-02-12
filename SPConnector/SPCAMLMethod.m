//
//  SPCAMLMethod.m
//  SPTest
//
//  Created by Nathan Wood on 8/02/13.
//  Copyright (c) 2013 Nathan Wood. All rights reserved.
//

#import "SPCAMLMethod.h"

@interface SPCAMLMethod ()

+ (NSString *)UUIDString;

@property (nonatomic, readonly) NSMutableDictionary *fieldDictionary;

- (void)configureMethodProperties:(xmlNodePtr)methodNode;

@end

@implementation SPCAMLMethod

@synthesize methodID = _methodID;
@synthesize command = _command;
@synthesize fieldDictionary = _fieldDictionary;

+ (NSString *)UUIDString
{
    CFUUIDRef uuidRef = CFUUIDCreate(kCFAllocatorDefault);
    NSString *uuidStr = CFBridgingRelease(CFUUIDCreateString(kCFAllocatorDefault, uuidRef));
    CFRelease(uuidRef);
    return uuidStr;
}

- (NSMutableDictionary *)fieldDictionary
{
    if (self->_fieldDictionary == nil)
        self->_fieldDictionary = [[NSMutableDictionary alloc] init];
    return self->_fieldDictionary;
}

- (void)setValue:(id)value forField:(NSString *)field
{
    [self.fieldDictionary setObject:value forKey:field];
}

- (id)valueForField:(NSString *)field
{
    return [self.fieldDictionary objectForKey:field];
}

- (xmlNodePtr)serialize
{
    xmlNodePtr methodNode = xmlNewNode(NULL, (const xmlChar *)"Method");
    
    [self configureMethodProperties:methodNode];
    
    [self.fieldDictionary enumerateKeysAndObjectsUsingBlock:^(NSString *field, id value, BOOL *stop) {
        xmlNodePtr fieldNode = xmlNewNode(NULL, (const xmlChar *)"Field");
        
        xmlNewProp(fieldNode, (const xmlChar *)"Name", (const xmlChar *)[field UTF8String]);
        
        xmlNodeSetContent(fieldNode, (const xmlChar *)[[value description] UTF8String]);
        
        xmlAddChild(methodNode, fieldNode);
    }];
    
    return methodNode;
}

- (void)configureMethodProperties:(xmlNodePtr)methodNode
{
    if (self.methodID == nil)
        self.methodID = [[self class] UUIDString];
    
    xmlSetProp(methodNode, (const xmlChar *)"ID", (const xmlChar *)[self.methodID UTF8String]);
    
    
    const char *cmdValue = NULL;
    switch (self.command) {
        case SPCAMLMethodCommandCreate:
            cmdValue = "New";
            break;
        case SPCAMLMethodCommandUpdate:
            cmdValue = "Update";
            break;
        case SPCAMLMethodCommandDelete:
            cmdValue = "Delete";
            break;
        case SPCAMLMethodCommandUnspecified:
        default:
            break;
    }
    
    if (cmdValue != NULL)
        xmlSetProp(methodNode, (const xmlChar *)"Cmd", (const xmlChar *)cmdValue);
}

@end
