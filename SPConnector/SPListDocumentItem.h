//
//  SPListDocumentItem.h
//  SPTest
//
//  Created by Nathan Wood on 12/02/13.
//  Copyright (c) 2013 Nathan Wood. All rights reserved.
//

#import "SPListItem.h"

@interface SPListDocumentItem : SPListItem

@property (nonatomic, readonly) NSString *baseName;
@property (nonatomic, readonly) NSString *filename;
@property (nonatomic, readonly) NSString *URLString;

@end
