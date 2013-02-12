//
//  SPPredicateTransformer.m
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

#import "SPPredicateTransformer.h"

typedef enum {
  WNPredicateLogicalTestDefinition
} WNPredicateDefinition;

@interface SPPredicateTransformer ()

+ (xmlNodePtr)transformPredicate:(NSPredicate *)predicate mapping:(NSDictionary *)mapping;
+ (xmlNodePtr)transformCompoundPredicate:(NSCompoundPredicate *)predicate mapping:(NSDictionary *)mapping;
+ (xmlNodePtr)transformComparisonPredicate:(NSComparisonPredicate *)predicate mapping:(NSDictionary *)mapping;

+ (xmlNodePtr)comparisonNodeWithType:(NSPredicateOperatorType)type definition:(WNPredicateDefinition *)definition;
+ (xmlNodePtr)logicalTestNodeWithType:(NSPredicateOperatorType)type;
+ (xmlNodePtr)fieldRefElementWithName:(NSString *)name;
+ (xmlNodePtr)valueElementWithConstant:(id)constant;

static inline xmlNodePtr xmlNewElement(const char *name);

@end


@implementation SPPredicateTransformer

+ (xmlNodePtr)transformPredicateIntoWhereElement:(NSPredicate *)predicate
{
    return [self transformPredicateIntoWhereElement:predicate mapping:nil];
}

+ (xmlNodePtr)transformPredicateIntoWhereElement:(NSPredicate *)predicate fields:(NSArray *)fields
{
    NSMutableDictionary *mapping = [[NSMutableDictionary alloc] initWithCapacity:fields.count];
    for (NSObject *field in fields)
        [mapping setObject:[fields valueForKey:@"name"] forKey:[fields valueForKey:@"displayName"]];
    return [self transformPredicateIntoWhereElement:predicate mapping:mapping];
}

+ (xmlNodePtr)transformPredicateIntoWhereElement:(NSPredicate *)predicate mapping:(NSDictionary *)mapping
{
    mapping = [mapping copy];
    
    xmlNodePtr rootQueryElement = xmlNewElement("Where");
    
    xmlNodePtr immediateChild = [self transformPredicate:predicate mapping:mapping];
    if (immediateChild == NULL)
    {
        xmlFreeNode(rootQueryElement);
        return NULL;
    }
    
    xmlAddChild(rootQueryElement, immediateChild);
    
    return rootQueryElement;
}

#pragma mark - Recursion methods

+ (xmlNodePtr)transformPredicate:(NSPredicate *)predicate mapping:(NSDictionary *)mapping
{
    xmlNodePtr node = NULL;
    
    if ([predicate isKindOfClass:[NSCompoundPredicate class]])
        node = [self transformCompoundPredicate:(NSCompoundPredicate *)predicate mapping:mapping];
    else
        if ([predicate isKindOfClass:[NSComparisonPredicate class]])
            node = [self transformComparisonPredicate:(NSComparisonPredicate *)predicate mapping:mapping];
    
    return node;
}

+ (xmlNodePtr)transformCompoundPredicate:(NSCompoundPredicate *)predicate mapping:(NSDictionary *)mapping
{
    NSCompoundPredicateType type = predicate.compoundPredicateType;
    NSArray *subpredicates = predicate.subpredicates;
    
    char *compoundElementName = NULL;
    switch (type) {
        case NSAndPredicateType:
            compoundElementName = "And";
            break;
        case NSOrPredicateType:
            compoundElementName = "Or";
            break;
        default:
            break;
    }
    
    if (compoundElementName == NULL)
        return NULL;
    
    xmlNodePtr compoundNode = xmlNewElement(compoundElementName);
    
    for (NSPredicate *predicate in subpredicates)
    {
        xmlNodePtr childNode = [self transformPredicate:predicate mapping:mapping];
        
        if (childNode)
            xmlAddChild(compoundNode, childNode);
    }
    
    return compoundNode;
}

+ (xmlNodePtr)transformComparisonPredicate:(NSComparisonPredicate *)predicate mapping:(NSDictionary *)mapping
{
    NSPredicateOperatorType type = predicate.predicateOperatorType;
    NSExpression *leftExp = predicate.leftExpression;
    NSExpression *rightExp = predicate.rightExpression;
    
    WNPredicateDefinition definition = WNPredicateLogicalTestDefinition;
    
    xmlNodePtr comparisonNode = [self comparisonNodeWithType:type definition:&definition];
    if (comparisonNode == NULL)
        return NULL;
    
    NSString *fieldName = [mapping objectForKey:leftExp.keyPath] ?: leftExp.keyPath;
    
    if (rightExp.constantValue)
    {
        switch (definition) {
            case WNPredicateLogicalTestDefinition:
                xmlAddChild(comparisonNode, [self fieldRefElementWithName:fieldName]);
                xmlAddChild(comparisonNode, [self valueElementWithConstant:rightExp.constantValue]);
                break;
            default:
                break;
        }
    }
    else
    {
        switch (type) {
            case NSEqualToPredicateOperatorType:
                comparisonNode = xmlNewElement("IsNull");
                break;
            case NSNotEqualToPredicateOperatorType:
                comparisonNode = xmlNewElement("IsNotNull");
                break;
            default:
                comparisonNode = NULL;
                break;
        }
        
        xmlAddChild(comparisonNode, [self fieldRefElementWithName:fieldName]);
    }
    
    return comparisonNode;
}

#pragma mark - Helper methods

+ (xmlNodePtr)comparisonNodeWithType:(NSPredicateOperatorType)type definition:(WNPredicateDefinition *)definition
{
    xmlNodePtr comparisonNode = NULL;
    WNPredicateDefinition comparisionDefinition = WNPredicateLogicalTestDefinition;
    
    switch (type) {
        case NSEqualToPredicateOperatorType:
        case NSNotEqualToPredicateOperatorType:
        case NSLessThanPredicateOperatorType:
        case NSLessThanOrEqualToPredicateOperatorType:
        case NSGreaterThanPredicateOperatorType:
        case NSGreaterThanOrEqualToPredicateOperatorType:
        case NSBeginsWithPredicateOperatorType:
        case NSContainsPredicateOperatorType:
            comparisonNode = [self logicalTestNodeWithType:type];
            break;
        default:
            break;
    }
    
    if (definition)
        *definition = comparisionDefinition;
    
    return comparisonNode;
}

+ (xmlNodePtr)logicalTestNodeWithType:(NSPredicateOperatorType)type
{
    xmlNodePtr comparisonNode = NULL;
    
    const char *operatorName = NULL;
    switch (type)
    {
        case NSEqualToPredicateOperatorType:
            operatorName = "Eq";
            break;
        case NSNotEqualToPredicateOperatorType:
            operatorName = "Neq";
            break;
        case NSLessThanPredicateOperatorType:
            operatorName = "Lt";
            break;
        case NSLessThanOrEqualToPredicateOperatorType:
            operatorName = "Leq";
            break;
        case NSGreaterThanPredicateOperatorType:
            operatorName = "Gt";
            break;
        case NSGreaterThanOrEqualToPredicateOperatorType:
            operatorName = "Geq";
            break;
        case NSBeginsWithPredicateOperatorType:
            operatorName = "BeginsWith";
            break;
        case NSContainsPredicateOperatorType:
            operatorName = "Contains";
        default:
            break;
    }
    
    if (operatorName != NULL)
        return xmlNewElement(operatorName);
    
    return comparisonNode;
}

+ (xmlNodePtr)fieldRefElementWithName:(NSString *)name
{
    xmlNodePtr fieldRefElement = xmlNewElement("FieldRef");
    
    xmlNewProp(fieldRefElement, (xmlChar *)"Name", (xmlChar *)[name UTF8String]);
    
    return fieldRefElement;
}

+ (xmlNodePtr)valueElementWithConstant:(id)constant
{
    xmlNodePtr valueElement = xmlNewElement("Value");
    
    NSString *content = nil;
    if ([constant isKindOfClass:[NSString class]])
        content = (NSString *)constant;
    else
        if ([constant isKindOfClass:[NSNumber class]])
            content = [(NSNumber *)constant stringValue];
    
    xmlNodeSetContent(valueElement, (xmlChar *)[content UTF8String]);
    
    return valueElement;
}

#pragma mark - C helper methods

static inline xmlNodePtr xmlNewElement(const char *name)
{
    return xmlNewNode(NULL, (const xmlChar *)name);
}

@end
