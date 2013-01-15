//
//  SPGetListItems.m
//
//  Copyright (c) 2012 Nathan Wood (http://www.woodnathan.com/)
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


#define kPrepareResponseCapacity 0


@interface SPGetListItems ()

@property (nonatomic, strong) NSMutableSet *viewFieldSet;

@end


@implementation SPGetListItems

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
    
    [self.viewFieldSet enumerateObjectsUsingBlock:^(NSString *fieldName, BOOL *stop) {
        xmlNodePtr field = xmlNewNode(NULL, (xmlChar *)"FieldRef");
        xmlNewProp(field, (xmlChar *)"Name", (xmlChar *)[fieldName UTF8String]);
        xmlAddChild(viewFieldsElement, field);
    }];
    
    /* queryOptions/QueryOptions */
    {
        xmlNodePtr queryOptsRootElement = xmlNewNode(NULL, (xmlChar *)"queryOptions");
        xmlNodePtr queryOptsElement = xmlNewNode(NULL, (xmlChar *)"QueryOptions");
        xmlNodePtr utcDateElement = xmlNewNode(NULL, (xmlChar *)"DateInUTC");
        xmlNodeSetContent(utcDateElement, (xmlChar *)"True");
        xmlAddChild(queryOptsElement, utcDateElement);
        xmlAddChild(queryOptsRootElement, queryOptsElement);
        [self.requestMessage addMethodElementChild:queryOptsRootElement];
    }
    
    if (self.parentFileRef)
    {
        xmlNodePtr queryRootElement = xmlNewNode(NULL, (xmlChar *)"query");
        xmlNodePtr queryElement = xmlNewNode(NULL, (xmlChar *)"Query");
        xmlNodePtr whereElement = xmlNewNode(NULL, (xmlChar *)"Where");
        xmlNodePtr eqElement = xmlNewNode(NULL, (xmlChar *)"Eq");
        
        xmlNodePtr field = xmlNewNode(NULL, (xmlChar *)"FieldRef");
        xmlNewProp(field, (xmlChar *)"Name", (xmlChar *)"FileDirRef");
        xmlNodePtr value = xmlNewNode(NULL, (xmlChar *)"Value");
        xmlNewProp(value, (xmlChar *)"Type", (xmlChar *)"Text");
        xmlNodeSetContent(value, (xmlChar *)[self.parentFileRef UTF8String]);
        
        xmlAddChild(eqElement, field);
        xmlAddChild(eqElement, value);
        
        xmlAddChild(whereElement, eqElement);
        xmlAddChild(queryElement, whereElement);
        xmlAddChild(queryRootElement, queryElement);
        [self.requestMessage addMethodElementChild:queryRootElement];
    }
}

- (void)parseResponseMessage
{
#if kPrepareResponseCapacity
    __block NSUInteger itemCount = 0;
    [self.responseMessage enumerateRowNodesForXPath:@"//rs:data" withBlock:^(xmlNodePtr node, BOOL *stop) {
        xmlAttr *countAttr = xmlHasProp(node, (const xmlChar *)"ItemCount");
        if (countAttr)
        {
            char *countContent = (char *)xmlNodeGetContent((xmlNodePtr)countAttr);
            itemCount = atoi(countContent);
            xmlFree(countContent);
            
            *stop = YES;
        }
    }];
    
    NSMutableArray *objects = [[NSMutableArray alloc] initWithCapacity:itemCount];
#else
    NSMutableArray *objects = [[NSMutableArray alloc] init];
#endif
    
    NSString *path = [[self class] objectPath];
    [self.responseMessage enumerateRowNodesForXPath:path withBlock:^(xmlNodePtr node, BOOL *stop) {
        id obj = [[[self class] objectClass] alloc];
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
    if (_viewFieldSet == nil)
        _viewFieldSet = [[NSMutableSet alloc] initWithObjects:@"Title", @"LinkFilename",
                         @"EncodedAbsUrl", @"ContentType", @"FileRef", @"FileDirRef", @"MetaInfo", nil];
    return _viewFieldSet;
}

- (void)addViewField:(NSString *)field
{
    [self.viewFieldSet addObject:field];
}

- (void)setViewFields:(NSArray *)viewFields
{
    _viewFieldSet = [[NSMutableSet alloc] initWithArray:viewFields];
}

@end
