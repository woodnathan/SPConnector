//
//  SPGetWebCollection.m
//  SPConnector
//
//  Created by Nathan Wood on 4/11/12.
//  Copyright (c) 2012 Nathan Wood. All rights reserved.
//

#import "SPGetWebCollection.h"

@implementation SPGetWebCollection

+ (NSString *)method
{
    return @"GetWebCollection";
}

+ (NSString *)objectPath
{
    return @"//soap:Webs/soap:Web";
}

+ (Class)objectClass
{
    return [SPWeb class];
}

@end
