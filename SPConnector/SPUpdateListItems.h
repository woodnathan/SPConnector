//
//  SPUpdateListItems.h
//  SPTest
//
//  Created by Nathan Wood on 12/02/13.
//  Copyright (c) 2013 Nathan Wood. All rights reserved.
//

#import "SPListMethod.h"
#import "SPCAMLBatch.h"

@interface SPUpdateListItems : SPListMethod

@property (nonatomic, readonly) SPCAMLBatch *batch;

@end