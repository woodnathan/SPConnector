//
//  SPUpdateListItems.m
//  SPTest
//
//  Created by Nathan Wood on 12/02/13.
//  Copyright (c) 2013 Nathan Wood. All rights reserved.
//

#import "SPUpdateListItems.h"
#import "SPMessage.h"
#import "SPListItem.h"

@implementation SPUpdateListItems

@synthesize batch = _batch;

+ (NSString *)method
{
    return @"UpdateListItems";
}

+ (NSString *)objectPath
{
    return @"//z:row";
}

+ (Class)objectClass
{
    return [SPListItem class];
}

- (SPCAMLBatch *)batch
{
    if (self->_batch == nil)
        self->_batch = [[SPCAMLBatch alloc] init];
    return self->_batch;
}

- (void)prepareRequestMessage
{
    [super prepareRequestMessage];
    
    xmlNodePtr updatesElement = xmlNewNode(NULL, (const xmlChar *)"updates");
    xmlAddChild(updatesElement, [self.batch serialize]);
    [self.requestMessage addMethodElementChild:updatesElement];
}

- (void)parseResponseMessage
{
    NSMutableArray *objects = [[NSMutableArray alloc] init];
    
    NSString *path = [[self class] objectPath];
    [self.responseMessage enumerateRowNodesForXPath:path withBlock:^(xmlNodePtr node, BOOL *stop) {
        id obj = [[[self class] objectClass] alloc];
        obj = [obj initWithNode:node context:self.context];
        [objects addObject:obj];
    }];
    
    self->_responseObjects = [objects copy];
}

@end
