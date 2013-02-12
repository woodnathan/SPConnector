//
//  SPCAMLBatch.h
//  SPTest
//
//  Created by Nathan Wood on 8/02/13.
//  Copyright (c) 2013 Nathan Wood. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <libxml/tree.h>

@class SPCAMLMethod;

typedef enum {
    SPCAMLBatchOnErrorContinue,
    SPCAMLBatchOnErrorReturn
} SPCAMLBatchOnError;

@interface SPCAMLBatch : NSObject

@property (nonatomic, assign) int listVersion;
@property (nonatomic, assign) SPCAMLBatchOnError onError;
@property (nonatomic, copy) NSString *viewName;

@property (nonatomic, readonly) NSMutableArray *methods;
- (void)addMethod:(SPCAMLMethod *)method;

- (SPCAMLMethod *)createWithFields:(NSDictionary *)fields;

- (xmlNodePtr)serialize;

@end
