//
//  SPList+Operations.m
//  SPTest
//
//  Created by Nathan Wood on 15/01/13.
//  Copyright (c) 2013 Nathan Wood. All rights reserved.
//

#import "SPList.h"
#import "SPContext.h"

@implementation SPList (Operations)

- (void)loadItems:(void (^)(NSArray *items))completion
{
    [self.context getList:self.listName
                    items:^(NSArray *items) {
                        self.items = items;
                        
                        if (completion)
                            completion(items);
                    }];
}

- (void)loadViews:(void (^)(NSArray *views))completion
{
    [self.context getList:self.listName
                    views:^(NSArray *views) {
                        self.views = views;
                        
                        if (completion)
                            completion(views);
                    }];
}

@end