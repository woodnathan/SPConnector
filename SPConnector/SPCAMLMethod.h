//
//  SPCAMLMethod.h
//  SPTest
//
//  Created by Nathan Wood on 8/02/13.
//  Copyright (c) 2013 Nathan Wood. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <libxml/tree.h>

typedef enum {
    SPCAMLMethodCommandUnspecified = -1,
    SPCAMLMethodCommandCreate = 0,
    SPCAMLMethodCommandUpdate,
    SPCAMLMethodCommandDelete
} SPCAMLMethodCommand;

@interface SPCAMLMethod : NSObject

@property (nonatomic, copy) NSString *methodID;
@property (nonatomic, assign) SPCAMLMethodCommand command;

- (void)setValue:(id)value forField:(NSString *)field;
- (id)valueForField:(NSString *)field;

- (xmlNodePtr)serialize;

@end
