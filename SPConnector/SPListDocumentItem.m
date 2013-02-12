//
//  SPListDocumentItem.m
//  SPTest
//
//  Created by Nathan Wood on 12/02/13.
//  Copyright (c) 2013 Nathan Wood. All rights reserved.
//

#import "SPListDocumentItem.h"
#import "SPGetListItems.h"
#import "SPListItemMapping.h"

@implementation SPListDocumentItem

@dynamic baseName;
@dynamic filename;
@dynamic URLString;

+ (void)load
{
    SPListItemMapping *mapping = [[SPListItemMapping alloc] init];
    [mapping mapKeyPath:@"baseName" toAttribute:@"ows_BaseName"];
    [mapping mapKeyPath:@"filename" toAttribute:@"ows_LinkFilename"];
    [mapping mapKeyPath:@"URLString" toAttribute:@"ows_EncodedAbsUrl"];
    
    [SPObjectMappingFactory registerObjectMapping:mapping forClass:self];
    
    [SPGetListItems registerClass:self forContentType:@"Document"];
}

@end
