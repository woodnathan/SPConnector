//
//  WNSortTransformer.m
//
//  Copyright (c) 2013 Nathan Wood (http://www.woodnathan.com/)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "SPSortTransformer.h"

@interface SPSortTransformer ()

+ (xmlNodePtr)fieldRefElementWithName:(NSString *)name;

@end

@implementation SPSortTransformer

+ (xmlNodePtr)transformSortDescriptorsIntoOrderElement:(NSArray *)descriptors
{
    return [self transformSortDescriptorsIntoOrderElement:descriptors mapping:nil];
}

+ (xmlNodePtr)transformSortDescriptorsIntoOrderElement:(NSArray *)descriptors fields:(NSArray *)fields
{
    NSMutableDictionary *mapping = [[NSMutableDictionary alloc] initWithCapacity:fields.count];
    for (NSObject *field in fields)
        [mapping setObject:[fields valueForKey:@"name"] forKey:[fields valueForKey:@"displayName"]];
    return [self transformSortDescriptorsIntoOrderElement:descriptors mapping:mapping];
}

+ (xmlNodePtr)transformSortDescriptorsIntoOrderElement:(NSArray *)descriptors mapping:(NSDictionary *)mapping
{
    if (descriptors == nil || descriptors.count == 0)
        return NULL;
    
    mapping = [mapping copy];
    
    xmlNodePtr rootOrderByElement = xmlNewNode(NULL, (const xmlChar *)"OrderBy");
    
    for (NSSortDescriptor *descriptor in descriptors)
    {
        NSString *fieldName = [mapping objectForKey:descriptor.key] ?: descriptor.key;
        xmlNodePtr field = [self fieldRefElementWithName:fieldName];
        
        const char *asc = descriptor.ascending ? "True" : "False";
        xmlNewProp(field, (xmlChar *)"Ascending", (xmlChar *)asc);
        
        xmlAddChild(rootOrderByElement, field);
    }
    
    return rootOrderByElement;
}

#pragma mark - Helper methods

+ (xmlNodePtr)fieldRefElementWithName:(NSString *)name
{
    xmlNodePtr fieldRefElement = xmlNewNode(NULL, (const xmlChar *)"FieldRef");
    
    xmlNewProp(fieldRefElement, (xmlChar *)"Name", (xmlChar *)[name UTF8String]);
    
    return fieldRefElement;
}

@end
