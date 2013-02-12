//
//  SPUpdateListItems.m
//  SPTest
//
//  Created by Nathan Wood on 12/02/13.
//  Copyright (c) 2013 Nathan Wood. All rights reserved.
//

#import "SPUpdateListItems.h"
#import "SPMessage.h"

@implementation SPUpdateListItems

@synthesize batch = _batch;

+ (NSString *)method
{
    return @"UpdateListItems";
}

+ (NSString *)objectPath
{
    return @"//rs:data/z:row";
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
#warning Implement in future
//    [super parseResponseMessage];
//    NSLog(@"%@", [[NSString alloc] initWithData:self.responseMessage.XMLData encoding:NSUTF8StringEncoding]);
}

@end
