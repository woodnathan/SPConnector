//
//  SPListMethod.m
//  SPTest
//
//  Created by Nathan Wood on 15/01/13.
//  Copyright (c) 2013 Nathan Wood. All rights reserved.
//

#import "SPListMethod.h"
#import "SPMessage.h"

@implementation SPListMethod

@synthesize listName = _listName;

- (void)prepareRequestMessage
{
    [self.requestMessage addMethodElementWithName:@"listName" value:self.listName];
}

@end
