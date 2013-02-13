//
//  SPGetListItems.m
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

#import "SPGetListItems.h"
#import "SPMessage.h"
#import "SPListItem.h"


NSString * const SPListItemDefaultContentTypeClassKey = @"kDefaultListItem";


@interface SPGetListItems ()

+ (NSMutableDictionary *)contentTypeClassMappings;

@property (nonatomic, strong) NSMutableSet *viewFieldSet;

@end


@implementation SPGetListItems

@synthesize viewFieldSet = _viewFieldSet;
@synthesize parentFileRef = _parentFileRef;

+ (NSMutableDictionary *)contentTypeClassMappings
{
    static __DISPATCH_ONCE__ NSMutableDictionary *contentTypeMappings = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        contentTypeMappings = [[NSMutableDictionary alloc] init];
        
        [contentTypeMappings setObject:[SPListItem class] forKey:SPListItemDefaultContentTypeClassKey];
    });
    
    return contentTypeMappings;
}

+ (void)registerClass:(Class)objectClass forContentType:(NSString *)contentType
{
    [[self contentTypeClassMappings] setObject:objectClass forKey:contentType];
}

+ (Class)objectClassForContentType:(NSString *)contentType
{
    if (contentType == nil)
        contentType = SPListItemDefaultContentTypeClassKey;
    
    Class objectClass = [[self contentTypeClassMappings] objectForKey:contentType];
    if (objectClass == Nil)
        objectClass = [[self contentTypeClassMappings] objectForKey:SPListItemDefaultContentTypeClassKey];
    
    return objectClass;
}

+ (NSString *)method
{
    return @"GetListItems";
}

+ (NSString *)objectPath
{
    return @"//rs:data/z:row";
}

+ (Class)objectClass
{
    return [SPListItem class];
}

- (void)prepareRequestMessage
{
    [super prepareRequestMessage];
    
    xmlNodePtr viewFieldsElement = xmlNewNode(NULL, (xmlChar *)"ViewFields");
    xmlNewProp(viewFieldsElement, (xmlChar *)"Properties", (xmlChar *)"True");
    xmlNodePtr vfElement = xmlNewNode(NULL, (xmlChar *)"viewFields");
    xmlAddChild(vfElement, viewFieldsElement);
    [self.requestMessage addMethodElementChild:vfElement];
    
    // Add the minimum required fields, but only
    // if we're going to get specified fields
    if (self->_viewFieldSet)
    {
        [self addViewField:@"Title"];
        [self addViewField:@"ContentType"];
    }
    
    [self.viewFieldSet enumerateObjectsUsingBlock:^(NSString *fieldName, BOOL *stop) {
        xmlNodePtr field = xmlNewNode(NULL, (xmlChar *)"FieldRef");
        xmlNewProp(field, (xmlChar *)"Name", (xmlChar *)[fieldName UTF8String]);
        xmlAddChild(viewFieldsElement, field);
    }];
    
    NSPredicate *predicate = self.predicate;
    if (self.parentFileRef)
    {
        NSPredicate *parentRefPred = [NSPredicate predicateWithFormat:@"FileDirRef = %@", self.parentFileRef];
        
        if (predicate)
        {
            NSArray *subpredicates = [NSArray arrayWithObjects:predicate, parentRefPred, nil];
            predicate = [[NSCompoundPredicate alloc] initWithType:NSAndPredicateType subpredicates:subpredicates];
        }
        else
        {
            predicate = parentRefPred;
        }
    }
    self.predicate = predicate;
}

- (void)parseResponseMessage
{
    NSMutableArray *objects = [[NSMutableArray alloc] init];
    
    NSString *path = [[self class] objectPath];
    [self.responseMessage enumerateRowNodesForXPath:path withBlock:^(xmlNodePtr node, BOOL *stop) {
        xmlAttrPtr contentTypeAttr = xmlHasProp(node, (const xmlChar *)"ows_ContentType");
        NSString *contentType = nil;
        if (contentTypeAttr != NULL)
        {
            char *attrContent = (char *)xmlNodeGetContent((xmlNodePtr)contentTypeAttr);
            contentType = [[NSString alloc] initWithUTF8String:attrContent];
            xmlFree(attrContent);
        }
        
        Class objectClass = [[self class] objectClassForContentType:contentType];
        
        id obj = [objectClass alloc];
        obj = [obj initWithNode:node context:self.context];
        [obj setListName:self.listName];
        [objects addObject:obj];
    }];
    
    self->_responseObjects = [objects copy];
}

#pragma mark - View Field

- (NSArray *)viewFields
{
    return [self.viewFieldSet allObjects];
}

- (NSMutableSet *)viewFieldSet
{
    if (self->_viewFieldSet == nil)
        self->_viewFieldSet = [[NSMutableSet alloc] init];
    return self->_viewFieldSet;
}

- (void)addViewField:(NSString *)field
{
    [self.viewFieldSet addObject:field];
}

- (void)addViewFields:(NSArray *)fields
{
    [self.viewFieldSet addObjectsFromArray:fields];
}

- (void)setViewFields:(NSArray *)viewFields
{
    self->_viewFieldSet = [[NSMutableSet alloc] initWithArray:viewFields];
}

@end
