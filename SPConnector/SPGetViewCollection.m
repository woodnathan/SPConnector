//
//  SPGetViewCollection.m
//  SPTest
//
//  Created by Nathan Wood on 15/01/13.
//  Copyright (c) 2013 Nathan Wood. All rights reserved.
//

#import "SPGetViewCollection.h"
#import "SPMessage.h"

@implementation SPGetViewCollection

+ (NSString *)method
{
    return @"GetViewCollection";
}

+ (NSString *)objectPath
{
    return @"//soap:Views/soap:View";
}

+ (Class)objectClass
{
    return [SPView class];
}

- (void)prepareRequestMessage
{
    [self.requestMessage addMethodElementWithName:@"listName" value:self.listName];
}

- (void)parseResponseMessage
{
    [super parseResponseMessage];
}

@end
