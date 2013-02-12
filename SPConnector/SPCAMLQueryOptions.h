//
//  SPCAMLQueryOptions.h
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

#import <Foundation/Foundation.h>
#import <libxml/tree.h>

typedef enum {
    WNCAMLQueryOptionsViewScopeNone = 0,
    WNCAMLQueryOptionsViewScopeRecursive,
    WNCAMLQueryOptionsViewScopeRecursiveAll,
    WNCAMLQueryOptionsViewScopeFilesOnly
} WNCAMLQueryOptionsViewScope;

@interface SPCAMLQueryOptions : NSObject <NSCopying>

- (xmlNodePtr)queryOptionsNode;

@property (nonatomic, assign) BOOL dateInUTC;
@property (nonatomic, assign) BOOL expandRecurrence;
@property (nonatomic, copy) NSString *folder;
@property (nonatomic, copy) NSString *listItemCollectionPositionNext; // Paging
@property (nonatomic, assign) BOOL includeMandatoryColumns;
// TODO: @property (nonatomic, assign) int meetingInstanceID;
@property (nonatomic, assign) WNCAMLQueryOptionsViewScope viewAttributes;
// TODO: RecurrencePatternXMLVersion
@property (nonatomic, assign) BOOL includePermissions;
@property (nonatomic, assign) BOOL expandUserField;
@property (nonatomic, assign) BOOL recurrenceOrderBy;
@property (nonatomic, assign) BOOL includeAttachmentURLs;
@property (nonatomic, assign) BOOL includeAttachmentVersion;
@property (nonatomic, assign) BOOL removeInvalidXMLCharacters;
// TODO: OptimizeFor
@property (nonatomic, copy) NSString *extraIDs;
@property (nonatomic, assign) BOOL optimizeLookups;
@property (nonatomic, assign) BOOL includeFragmentChanges;

@property (nonatomic, readonly) NSDictionary *customOptions;
- (void)addCustomOption:(NSString *)name value:(NSString *)value;
- (void)removeCustomOption:(NSString *)name;

@end
