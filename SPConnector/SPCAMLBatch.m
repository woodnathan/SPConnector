//
//  SPCAMLBatch.m
//  SPTest
//
//  Created by Nathan Wood on 8/02/13.
//  Copyright (c) 2013 Nathan Wood. All rights reserved.
//

#import "SPCAMLBatch.h"
#import "SPCAMLMethod.h"

@interface SPCAMLBatch ()

- (void)configureBatchProperties:(xmlNodePtr)batchNode;

@end

@implementation SPCAMLBatch

@synthesize listVersion = _listVersion, onError = _onError, viewName = _viewName;
@synthesize methods = _methods;

- (NSMutableArray *)methods
{
    if (self->_methods == nil)
        self->_methods = [[NSMutableArray alloc] init];
    
    return self->_methods;
}

- (void)addMethod:(SPCAMLMethod *)method
{
    [self.methods addObject:method];
}

- (SPCAMLMethod *)createWithFields:(NSDictionary *)fields
{
    SPCAMLMethod *method = [[SPCAMLMethod alloc] init];
    method.command = SPCAMLMethodCommandCreate;
    
    [fields enumerateKeysAndObjectsUsingBlock:^(NSString *field, id obj, BOOL *stop) {
        [method setValue:obj forField:field];
    }];
    
    [self addMethod:method];
    
    return method;
}

#pragma mark - Serialization

- (xmlNodePtr)serialize
{
    xmlNodePtr batchNode = xmlNewNode(NULL, (const xmlChar *)"Batch");
    
    [self configureBatchProperties:batchNode];
    
    for (SPCAMLMethod *method in self->_methods)
    {
        xmlNodePtr methodNode = [method serialize];
        
        xmlAddChild(batchNode, methodNode);
    }
    
    return batchNode;
}

- (void)configureBatchProperties:(xmlNodePtr)batchNode
{
    const char *onErrorStr = (self.onError == SPCAMLBatchOnErrorContinue) ? "Continue" : "Return";
    xmlSetProp(batchNode, (const xmlChar *)"OnError", (const xmlChar *)onErrorStr);
    
    if (self.listVersion > 0)
    {
        NSString *versionStr = [NSString stringWithFormat:@"%i", self.listVersion];
        xmlSetProp(batchNode, (const xmlChar *)"ListVersion", (const xmlChar *)[versionStr UTF8String]);
    }
    
    NSString *viewName = self.viewName;
    if (viewName != nil)
    {
        xmlSetProp(batchNode, (const xmlChar *)"ViewName", (const xmlChar *)[viewName UTF8String]);
    }
}

@end
