//
//  SPCAMLQueryOptions.m
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

#import "SPCAMLQueryOptions.h"


@interface SPCAMLQueryOptions () {
@private
    xmlNodePtr _xmlNode;
    BOOL _validNode;
    NSMutableDictionary *_customOptions;
}

@property (nonatomic, strong) NSRecursiveLock *lock;

@property (nonatomic, readonly) NSMutableDictionary *internalCustomOptions;

- (void)invalidateNode;
- (xmlNodePtr)generateQueryOptionsElement;

xmlNodePtr xmlNewBooleanNodeOnParent(xmlNodePtr parent, const char *name, BOOL value);
xmlNodePtr xmlNewNodeOnParent(xmlNodePtr parent, const char *name, const char *attr, xmlChar *content);
inline xmlChar *stringValueForBoolean(BOOL boolean);
inline xmlChar *stringValueForString(NSString *string);
inline xmlChar *stringValueForViewScope(WNCAMLQueryOptionsViewScope scope);

@end


@implementation SPCAMLQueryOptions

@synthesize dateInUTC = _dateInUTC;
@synthesize expandRecurrence = _expandRecurrence;
@synthesize folder = _folder;
@synthesize listItemCollectionPositionNext = _listItemCollectionPositionNext;
@synthesize includeMandatoryColumns = _includeMandatoryColumns;
@synthesize viewAttributes = _viewAttributes;
@synthesize includePermissions = _includePermissions;
@synthesize expandUserField = _expandUserField;
@synthesize recurrenceOrderBy = _recurrenceOrderBy;
@synthesize includeAttachmentURLs = _includeAttachmentURLs;
@synthesize includeAttachmentVersion = _includeAttachmentVersion;
@synthesize removeInvalidXMLCharacters = _removeInvalidXMLCharacters;
@synthesize extraIDs = _extraIDs;
@synthesize optimizeLookups = _optimizeLookups;
@synthesize includeFragmentChanges = _includeFragmentChanges;
@synthesize customOptions = _customOptions;
@synthesize lock = _lock;

- (id)init
{
    self = [super init];
    if (self)
    {
        self.lock = [[NSRecursiveLock alloc] init];
    }
    return self;
}

- (void)dealloc
{
    if (self->_xmlNode != NULL)
    {
        xmlFreeNode(self->_xmlNode);
        self->_xmlNode = NULL;
    }
}

- (id)copyWithZone:(NSZone *)zone
{
    SPCAMLQueryOptions *copy = [[[self class] alloc] init];
    copy->_dateInUTC = self->_dateInUTC;
    copy->_folder = [self->_folder copy];
    return copy;
}

- (NSDictionary *)customOptions
{
    return self.internalCustomOptions;
}
- (NSMutableDictionary *)internalCustomOptions
{
    if (self->_customOptions == nil)
        self->_customOptions = [[NSMutableDictionary alloc] init];
    
    return self->_customOptions;
}
- (void)addCustomOption:(NSString *)name value:(NSString *)value
{
    [self.internalCustomOptions setObject:value forKey:name];
}
- (void)removeCustomOption:(NSString *)name
{
    [self.internalCustomOptions removeObjectForKey:name];
}

- (xmlNodePtr)queryOptionsNode
{
    [self.lock lock];
    if (self->_xmlNode == NULL || self->_validNode == NO)
    {
        if (self->_xmlNode != NULL)
        {
            xmlFreeNode(self->_xmlNode);
            self->_xmlNode = NULL;
        }
        
        self->_xmlNode = [self generateQueryOptionsElement];
        self->_validNode = YES;
    }
    
    xmlNodePtr node = xmlCopyNode(self->_xmlNode, 1);
    [self.lock unlock];
    
    return node;
}

- (void)invalidateNode
{
    [self.lock lock];
    self->_validNode = NO;
    [self.lock unlock];
}

- (xmlNodePtr)generateQueryOptionsElement
{
    xmlNodePtr queryOptsElement = xmlNewNode(NULL, (const xmlChar *)"QueryOptions");
    
    xmlNewBooleanNodeOnParent(queryOptsElement, "DateInUTC", self.dateInUTC);
    xmlNewBooleanNodeOnParent(queryOptsElement, "ExpandRecurrence", self.expandRecurrence);
    if (self.folder)
        xmlNewNodeOnParent(queryOptsElement, "Folder", NULL, stringValueForString(self.folder));
    if (self.listItemCollectionPositionNext)
        xmlNewNodeOnParent(queryOptsElement, "Paging", "ListItemCollectionPositionNext", stringValueForString(self.listItemCollectionPositionNext));
    xmlNewBooleanNodeOnParent(queryOptsElement, "IncludeMandatoryColumns", self.includeMandatoryColumns);
//    TODO: meetingInstanceID
    if (self.viewAttributes != WNCAMLQueryOptionsViewScopeNone)
        xmlNewNodeOnParent(queryOptsElement, "ViewAttributes", "Scope", stringValueForViewScope(self.viewAttributes));
//    TODO: RecurrencePatternXMLVersion
    xmlNewBooleanNodeOnParent(queryOptsElement, "IncludePermissions", self.includePermissions);
    xmlNewBooleanNodeOnParent(queryOptsElement, "ExpandUserField", self.expandUserField);
    xmlNewBooleanNodeOnParent(queryOptsElement, "IncludeAttachmentUrls", self.includeAttachmentURLs);
    xmlNewBooleanNodeOnParent(queryOptsElement, "IncludeAttachmentVersion", self.includeAttachmentVersion);
    xmlNewBooleanNodeOnParent(queryOptsElement, "RemoveInvalidXmlCharacters", self.removeInvalidXMLCharacters);
//    TODO: OptimizeFor
    xmlNewNodeOnParent(queryOptsElement, "ExtraIds", NULL, stringValueForString(self.extraIDs));
    xmlNewBooleanNodeOnParent(queryOptsElement, "OptimizeLookups", self.optimizeLookups);
    xmlNewBooleanNodeOnParent(queryOptsElement, "IncludeFragmentChanges", self.includeFragmentChanges);
    
    [self->_customOptions enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *obj, BOOL *stop) {
        xmlNewNodeOnParent(queryOptsElement, [key UTF8String], NULL, (xmlChar *)[obj UTF8String]);
    }];
    
    return queryOptsElement;
}

#pragma mark - C methods

xmlNodePtr xmlNewBooleanNodeOnParent(xmlNodePtr parent, const char *name, BOOL value)
{
    return xmlNewNodeOnParent(parent, name, NULL, stringValueForBoolean(value));
}

xmlNodePtr xmlNewNodeOnParent(xmlNodePtr parent, const char *name, const char *attr, xmlChar *content)
{
    if (parent == NULL)
        return NULL;
    
    xmlNodePtr node = xmlNewNode(NULL, (xmlChar *)name);
    
    if (attr)
        xmlNewProp(node, (xmlChar *)attr, content);
    else
        xmlNodeSetContent(node, content);
    
    xmlAddChild(parent, node);
    
    return node;
}

xmlChar *stringValueForBoolean(BOOL boolean)
{
    return (xmlChar *)(boolean ? "True" : "False");
}

xmlChar *stringValueForString(NSString *string)
{
    return (xmlChar *)[string UTF8String];
}

xmlChar *stringValueForViewScope(WNCAMLQueryOptionsViewScope scope)
{
    switch (scope) {
        case WNCAMLQueryOptionsViewScopeRecursive:
            return (xmlChar *)"Recursive";
        case WNCAMLQueryOptionsViewScopeRecursiveAll:
            return (xmlChar *)"RecursiveAll";
        case WNCAMLQueryOptionsViewScopeFilesOnly:
            return (xmlChar *)"FilesOnly";
        case WNCAMLQueryOptionsViewScopeNone:
        default:
            break;
    }
    return (xmlChar *)"";
}

@end
