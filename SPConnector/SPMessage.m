//
//  SPMessage.m
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

#import "SPMessage.h"
#import <libxml/xpath.h>
#import <libxml/xpathInternals.h>

xmlChar * const SPMessageNamespaceURISchemaInstance = (xmlChar *)"http://www.w3.org/2001/XMLSchema-instance";
xmlChar * const SPMessageNamespaceURISchema         = (xmlChar *)"http://www.w3.org/2001/XMLSchema";
xmlChar * const SPMessageNamespaceURISOAP11         = (xmlChar *)"http://schemas.xmlsoap.org/soap/envelope/";
xmlChar * const SPMessageNamespaceURISOAP12         = (xmlChar *)"http://www.w3.org/2003/05/soap-envelope";
xmlChar * const SPMessageNamespaceURISharePointSOAP = (xmlChar *)"http://schemas.microsoft.com/sharepoint/soap/";
xmlChar * const SPMessageNamespaceRowset            = (xmlChar *)"urn:schemas-microsoft-com:rowset";
xmlChar * const SPMessageNamespaceRowsetSchema      = (xmlChar *)"#RowsetSchema";


static NSMutableString *xmlErrorMessage = nil;
static void xmlErrorFunc(void *ctx, const char *msg, ...)
{
    if (xmlErrorMessage == nil)
        xmlErrorMessage = [[NSMutableString alloc] init];
    
    NSString *fmt = [[NSString alloc] initWithCString:msg encoding:NSUTF8StringEncoding];
    va_list args;
    va_start(args, msg);
    NSString *str = [[NSString alloc] initWithFormat:fmt arguments:args];
    va_end(args);
    
    [xmlErrorMessage appendString:str];
}


@interface SPMessage () {
    xmlDocPtr _xmlDoc;
@protected
    xmlNodePtr _methodNode;
}

+ (xmlNodePtr)newSOAPEnvelopeNodeWithVersion:(SPSOAPVersion)version;

- (void)enumerateNodesForXPath:(NSString *)path namespace:(void (^)(xmlXPathContextPtr ctx))namespace withBlock:(void (^)(xmlNodePtr node, BOOL *stop))block;

@end


@implementation SPMessage

@synthesize version = _version;

- (id)initWithMethod:(NSString *)method
{
    return [self initWithMethod:method version:SPSOAPVersion12];
}

- (id)initWithMethod:(NSString *)method version:(SPSOAPVersion)version
{
    self = [super init];
    if (self)
    {
        self->_version = version;
        
        _xmlDoc = xmlNewDoc(NULL);
        
        xmlNodePtr envelope = [[self class] newSOAPEnvelopeNodeWithVersion:version];
        xmlDocSetRootElement(_xmlDoc, envelope);
        
        _methodNode = xmlNewNode(NULL, (xmlChar *)[method UTF8String]);
        xmlNewNs(_methodNode, (xmlChar*)SPMessageNamespaceURISharePointSOAP, NULL);
        xmlAddChild(xmlGetLastChild(envelope), _methodNode);
    }
    return self;
}

- (id)initWithData:(NSData *)data error:(NSError **)error
{
    self = [super init];
    if (self)
    {
        xmlSetGenericErrorFunc(NULL, xmlErrorFunc);
        
        _xmlDoc = xmlReadMemory((const char *)[data bytes], (int)[data length], NULL, NULL, XML_PARSE_NOCDATA | XML_PARSE_NOBLANKS | XML_PARSE_RECOVER);
        
        if (_xmlDoc == NULL && error)
        {
            NSString *reason = [xmlErrorMessage copy];
            [xmlErrorMessage setString:@""];
            NSDictionary *userInfo = nil;
            if (reason != nil)
                userInfo = @{ NSLocalizedFailureReasonErrorKey : reason };
            *error = [NSError errorWithDomain:@"com.woodnathan.SPConnector"
                                         code:-1
                                     userInfo:userInfo];
        }
        else
        {
            SPSOAPVersion version = SPSOAPVersion12;
            xmlNsPtr *namespaceList = xmlGetNsList(_xmlDoc, xmlDocGetRootElement(_xmlDoc));
            if (namespaceList != NULL)
            {
                for (int i = 0; namespaceList[i] != NULL; i++)
                {
                    xmlNsPtr ns = namespaceList[i];
                    if (ns->href == NULL)
                        continue;
                    
                    if (xmlStrcmp(ns->href, SPMessageNamespaceURISOAP12))
                    {
                        break;
                    }
                    else
                        if (xmlStrcmp(ns->href, SPMessageNamespaceURISOAP11))
                        {
                            version = SPSOAPVersion11;
                            break;
                        }
                }
                
                xmlFree(namespaceList);
            }
            
            self->_version = version;
        }
    }
    return self;
}

- (void)dealloc
{
    xmlFreeDoc(_xmlDoc);
    _methodNode = NULL;
    _xmlDoc = NULL;
}

+ (xmlNodePtr)newSOAPEnvelopeNodeWithVersion:(SPSOAPVersion)version
{
    xmlNsPtr soapNS = NULL;
    xmlNodePtr envelope = NULL, body = NULL;
    
    switch (version) {
        case SPSOAPVersion11:
            soapNS = xmlNewNs(NULL, SPMessageNamespaceURISOAP11, (xmlChar*)"soap");
            break;
        case SPSOAPVersion12:
        default:
            soapNS = xmlNewNs(NULL, SPMessageNamespaceURISOAP12, (xmlChar*)"soap12");
            break;
    }
    
    envelope = xmlNewNode(soapNS, (xmlChar*)"Envelope");
    body = xmlNewNode(soapNS, (xmlChar*)"Body");
    
    xmlNewNs(envelope, (xmlChar*)SPMessageNamespaceURISchema, (xmlChar*)"xsd");
    xmlNewNs(envelope, (xmlChar*)SPMessageNamespaceURISchemaInstance, (xmlChar*)"xsi");
    
    switch (version) {
        case SPSOAPVersion11:
            xmlNewNs(envelope, SPMessageNamespaceURISOAP11, (xmlChar*)"soap");
            break;
        case SPSOAPVersion12:
        default:
            xmlNewNs(envelope, SPMessageNamespaceURISOAP12, (xmlChar*)"soap12");
            break;
    }
    
    xmlAddChild(envelope, body);
    
    return envelope;
}

- (xmlDocPtr)XMLDocument
{
    return _xmlDoc;
}

- (xmlNodePtr)rootElement
{
    return xmlDocGetRootElement(_xmlDoc);
}

- (xmlNodePtr)methodElement
{
    return _methodNode;
}

- (NSData *)XMLData
{
    if (_xmlDoc)
    {
        xmlChar *buffer = NULL;
        int bufferSize = 0;
        
        xmlDocDumpMemory(_xmlDoc, &buffer, &bufferSize);
        
        if (buffer)
        {
            NSData *data = [[NSData alloc] initWithBytes:buffer length:bufferSize];
            xmlFree(buffer);
            return data;
        }
    }
    return nil;
}

- (void)addMethodElementChild:(xmlNodePtr)child
{
    xmlAddChild(self.methodElement, child);
}

- (xmlNodePtr)addMethodElementWithName:(NSString *)name value:(NSString *)value
{
    xmlNodePtr element = xmlNewNode(NULL, (xmlChar *)[name UTF8String]);
    
    if (value != nil)
        xmlNodeSetContent(element, (xmlChar *)[value UTF8String]);
    
    [self addMethodElementChild:element];
    
    return element;
}

- (void)enumerateNodesForXPath:(NSString *)path namespace:(void (^)(xmlXPathContextPtr ctx))namespace withBlock:(void (^)(xmlNodePtr node, BOOL *stop))block
{
    xmlXPathContextPtr ctx = xmlXPathNewContext(_xmlDoc);
    
    if (namespace)
        namespace(ctx);
    
    xmlChar *xpath = (xmlChar *)[path UTF8String];
    xmlXPathObjectPtr obj = xmlXPathEvalExpression(xpath, ctx);
    
    if (obj && xmlXPathNodeSetIsEmpty(obj->nodesetval) == NO)
    {
        BOOL stop = NO;
        for (int i = 0; i < xmlXPathNodeSetGetLength(obj->nodesetval); i++)
        {
            xmlNodePtr currNode = obj->nodesetval->nodeTab[i];
            
            if (block)
                block(currNode, &stop);
            
            if (stop)
                break;
        }
    }
    
    xmlXPathFreeObject(obj);
    xmlXPathFreeContext(ctx);
}

- (void)enumerateNodesForXPath:(NSString *)path withBlock:(void (^)(xmlNodePtr node, BOOL *stop))block
{
    [self enumerateNodesForXPath:path
                       namespace:^(xmlXPathContextPtr ctx) {
                           xmlXPathRegisterNs(ctx, (xmlChar*)"soap", SPMessageNamespaceURISharePointSOAP);
                       }
                       withBlock:block];
}

- (void)enumerateRowNodesForXPath:(NSString *)path withBlock:(void (^)(xmlNodePtr node, BOOL *stop))block
{
    [self enumerateNodesForXPath:path
                       namespace:^(xmlXPathContextPtr ctx) {
                           xmlXPathRegisterNs(ctx, (xmlChar*)"z", SPMessageNamespaceRowsetSchema);
                           xmlXPathRegisterNs(ctx, (xmlChar*)"rs", SPMessageNamespaceRowset);
                       }
                       withBlock:block];
}

@end
