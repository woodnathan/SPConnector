//
//  SPListEventItem.h
//  SPTest
//
//  Created by Nathan Wood on 12/02/13.
//  Copyright (c) 2013 Nathan Wood. All rights reserved.
//

#import "SPListItem.h"

@interface SPListEventItem : SPListItem

@property (nonatomic, readonly) NSDate *startDate;
@property (nonatomic, readonly) NSDate *endDate;

@property (nonatomic, readonly) NSString *location;

@end
