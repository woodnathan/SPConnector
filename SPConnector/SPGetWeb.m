//
//  SPGetWeb.m
//  SPTest
//
//  Created by Nathan Wood on 9/01/13.
//  Copyright (c) 2013 Nathan Wood. All rights reserved.
//

#import "SPGetWeb.h"
#import "SPMessage.h"

@implementation SPGetWeb

@synthesize webURL = _webURL;

+ (NSString *)method
{
    return @"GetWeb";
}

+ (NSString *)objectPath
{
    return @"//soap:GetWebResult/soap:Web";
}

+ (Class)objectClass
{
    return [SPWeb class];
}

- (void)prepareRequestMessage
{
    [self.requestMessage addMethodElementWithName:@"webUrl" value:self.webURL];
}

@end
