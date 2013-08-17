//
//Copyright (c) 2013, Hongbo Yang (hongbo@yang.me)
//
//Permission is hereby granted, free of charge, to any person obtaining a copy
//of this software and associated documentation files (the "Software"), to deal
//in the Software without restriction, including without limitation the rights
//to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//copies of the Software, and to permit persons to whom the Software is
//furnished to do so, subject to the following conditions:
//
//The above copyright notice and this permission notice shall be included in
//all copies or substantial portions of the Software.
//
//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//THE SOFTWARE.


#import "NSString+YHTTPURLString.h"
#import "NSDictionary+YHTTPURLDictionary.h"
#import "NSMutableDictionary+YDuplicatableDictionary.h"

#define YIS_INSTANCE_OF(_x, _class) ([_x isKindOfClass:[_class class]])

@implementation NSString (YHTTPURLString)

- (NSString *)URLStringByAddingParameters:(NSDictionary *)parameters {
    NSString * newUrlString = [parameters queryString];
    if ([newUrlString length] > 0) {
        NSArray * songUrlParams = [self componentsSeparatedByString:@"?"];
        if ([songUrlParams count] > 1) {
            newUrlString = [self stringByAppendingFormat:@"&%@", newUrlString];
        }
        else {
            newUrlString = [self stringByAppendingFormat:@"?%@", newUrlString];
        }
        
        return newUrlString;
    }
    
    return self;
}

- (NSDictionary *)decodedUrlencodedParameters 
{
    NSMutableDictionary * responseDictionary = [NSMutableDictionary dictionaryWithCapacity:4];
    NSArray * parameters = [self componentsSeparatedByString:@"&"];
    for (NSString * parameter in parameters) {
        NSArray * keyvalue = [parameter componentsSeparatedByString:@"="];
        NSString * key = [keyvalue objectAtIndex:0];
        NSString * value = ([keyvalue count] > 1)?[keyvalue objectAtIndex:1]:@"";
        NSString * decodedKey = [key urldecodedString];
        NSString * decodedValue = [value urldecodedString];
        
        [responseDictionary addDuplicatableObject:decodedValue forKey:decodedKey];
    }
    return responseDictionary;
}

- (NSDictionary *)queryParameters 
{
    NSString * query = [self query];
    return [query decodedUrlencodedParameters];
}

//#define ESCAPE_CHARACTERS ":/?#[]@!$ &'()*+,;=\"<>%{}|\\^~`"
#define ESCAPE_CHARACTERS ":/?#[]@!$ &'()*+,;=\"<>%{}|\\^`"   //RFC3986, '~' is an unreserved character ,should not be escaped

- (NSString*)escapedString {
    NSString *newString = [NSMakeCollectable(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)self, NULL, CFSTR(ESCAPE_CHARACTERS), kCFStringEncodingUTF8)) autorelease];
	return newString?newString:@"";
}

- (NSString *)unescapeString {
    NSString *newString = [NSMakeCollectable(CFURLCreateStringByReplacingPercentEscapesUsingEncoding(kCFAllocatorDefault, (CFStringRef)self, CFSTR(""), kCFStringEncodingUTF8)) autorelease];
    return newString?newString:@"";
}

- (NSString *)escapedStringWithoutWhitespace {
    NSString *newString = [NSMakeCollectable(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)self, CFSTR(" "), CFSTR(ESCAPE_CHARACTERS), kCFStringEncodingUTF8)) autorelease];
	return newString?newString:@"";
}

- (NSString *)urlencodedString {
#ifdef ESCAPE_WHITESPACE
    return [self escapedString];
#else
    NSString *newString = [self escapedStringWithoutWhitespace];
    newString = [newString stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    return newString;
#endif
}

- (NSString *)urldecodedString {
    NSString * newString = [self stringByReplacingOccurrencesOfString:@"+" withString:@" "];
    return [newString unescapeString];
}

- (NSUInteger)indexOfFirstNonWhitespace
{
    static unichar whitespace = 0x20;
    static unichar tab = 0x09;
    //static unichar newline = 0x0a;
    //static unichar newline1 = 0x0d;
    //static unichar nextline = 0x85;
    const NSUInteger len = [self length];
    CFStringInlineBuffer buffer;
    CFRange range = CFRangeMake(0, len);
    CFStringInitInlineBuffer((CFStringRef)self, &buffer, range);
    NSUInteger idx = 0;
    
    for (; idx < len; idx ++) {
        const unichar c = CFStringGetCharacterFromInlineBuffer(&buffer, idx);
        if (c != whitespace && c != tab) {
            return idx;
        }
    }
    return NSNotFound;
}

/*
 for "http://www.douban.com", will get Range(0, 4) & "http"
 for "www.douban.com", will get Range(NotFound, 0) & nil
 for "://www.douban.com", will get Range(0, 0) & nil
 for  Empty or all whitespaces string, eg, "      ", will get Range(NSNotFound, 0), & nil
 for empyt scheme, eg, "    ://" will get Range(0, 4), & @"    "
 Not identified and invalid URL will get http.
 Custom scheme will get as specified, eg, "fake://fake.info" will get Range(0, 4), & "fake".
 URL validation should be perfomed by programmer
 */
- (NSRange)schemeRange 
{
    NSRange range ;
    NSRange searchRng;
    
    searchRng.location = 0;
    searchRng.length = [self length];
    
    //find the :// part, if not exist, just return http
    
    /*
     no reuse same struct var, because , llvm-gcc in XCode 4.2 (build 4d199) may compile out wrong instructions
     sequence for armv6 release build..., that cause the reused struct variable gets wrong result.
     */
    
    range = [self rangeOfString:@"://" options:0 range:searchRng];
    
    if (NSNotFound == range.location) {
        return NSMakeRange(NSNotFound, 0);
    }
    
    //for "://www.douban.com", will get NSRange(0, 0), since it will let hostRange to find the correct start position
    if (range.location == searchRng.location) {
        return NSMakeRange(0, 0);
    }
    
    NSRange schemeRange;
    schemeRange.location = searchRng.location;
    schemeRange.length = range.location - searchRng.location;
    
    return schemeRange;
}

- (NSString *)scheme 
{
    NSString * scheme = nil;
    NSRange schemeRange;
    schemeRange = [self schemeRange];
    if (NSNotFound != schemeRange.location) {
        scheme = [self substringWithRange:schemeRange];
    }
    return scheme;
}
/*
 for "   " will get Range(NSNotFound, 0) and nil.
 for "http://     /" will get Range(7, 5);
 URL validation should be perfomed by programmer
 */

- (NSRange)hostRange
{
    NSRange range;
    NSRange searchRng;
    
    searchRng.location = 0;
    searchRng.length = [self length];
    
    range = [self rangeOfString:@"://" options:0 range:searchRng];
    
    // if found ://, start new search just behind
    if (NSNotFound != range.location) {
        searchRng.location = range.location + range.length;
        searchRng.length = [self length] - searchRng.location;
    }
    // http://www.douban.com/, or http://www.douban.com:80/, or http://www.douban.com?key=value, or http://www.douban.com
    range = [self rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@":/?#"] options:0 range:searchRng];
    
    //extract host from URL
    if (NSNotFound != range.location) {
        searchRng.length = range.location - searchRng.location;
        
    }
    return searchRng;
    // this may return "   " for "http://     /"
    // this will not alter the length, so latter function can use this range as a anchor reference
    
    
}

- (NSString *)host 
{
    NSString * host = nil;
    NSRange rng = [self hostRange];
    if (NSNotFound != rng.location) {
        host = [self substringWithRange:rng];
    }
    return host;
}

/*
 for "http://www.douban.com" get Range(NSNotFound, 0) and nil
 for "http://www.douban.com:80" get Range(22, 2) and 80
 for "http://www.douban.com:xx/" get Range(22, 2) and 0
 for "http://www.douban.com:" get Range(22, 0) and 0
 for "http://www.douban.com:/" get Range(22, 0) and 0
 for "http://www.douban.com:  /" get Range(22, 2) and 0
 for "http://www.douban.com:8A/" get Range(22, 2) and 8
 for "http://www.douban.com:8 /" get Range(22, 2) and 8
 for "http://www.douban.com:80?key=value" get Range(22, 2) and 80
 for ":/" gets Range(1, 0) and 0
 
 port number for invalid port string is according NSString -(NSInteger)integerValue;
 */
- (NSRange)portRange {
    NSRange hostRange = [self hostRange];
    if (NSNotFound == hostRange.location) {
        hostRange.location = 0;
        hostRange.length = 0;
    }
    NSRange searchRange;
    searchRange.location = hostRange.location + hostRange.length;
    if (searchRange.location < [self length]) {
        const unichar c = [self characterAtIndex:searchRange.location];
        if ((unichar)':' == c) {
            searchRange.location ++;
            searchRange.length = [self length] - searchRange.location;
            
            NSRange range = [self rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"?/"] 
                                                  options:0
                                                    range:searchRange];
            if (NSNotFound == range.location) {
                return searchRange;
            }
            else {
                NSRange portRange;
                portRange.location = searchRange.location;
                portRange.length = range.location - portRange.location;
                return portRange;
            }
        }
    }
    return NSMakeRange(NSNotFound, 0);
}

- (NSNumber *)port 
{
    NSNumber * port = nil;
    NSRange rng = [self portRange];
    if (NSNotFound != rng.location) {
        NSString * portString = [self substringWithRange:rng];
        port = [NSNumber numberWithInteger:[portString integerValue]];
    }
    return port;
}

/*
 for "http://www.douban.com/group/12345" will get Range(22, 11) and "group/12345"
 for "http://www.douban.com/group/12345?key=value" will get Range(22, 11) and "group/12345"
 for "http://www.douban.com/group/12345/" will get Range(22, 12) and "group/12345/"
 for "http://www.douban.com/group/12345/?key=value" will get Range(22, 12) and "group/12345/"
 for "http://www.douban.com:/group/12345/?key=value" will get Range(23, 12) and "group/12345/"
 for "http://www.douban.com:/" will get Range(23, 0) and ""
 for "http://www.douban.com:" will get Range(22, 0) and ""
 */
- (NSRange)relativeRange
{
    NSRange searchRange;
    NSRange range = [self portRange];
    if (NSNotFound == range.location) {
        range = [self hostRange]; //never returns (NSNotFound, 0)
    }
    searchRange.location = range.location + range.length;
    searchRange.length = [self length] - searchRange.location;
    
    //search for first '/'
    range =[self rangeOfString:@"/" options:0 range:searchRange];
    if (NSNotFound == range.location) {
        range.location = searchRange.location + searchRange.length;
        range.length = 0;
        return range;
    }
    searchRange.location = range.location + range.length;
    searchRange.length = [self length] - searchRange.location;
    
    range = [self rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"?#"] 
                                  options:0
                                    range:searchRange];
    if (NSNotFound == range.location) {
        return searchRange;
    }
    
    searchRange.length = range.location - searchRange.location;
    return searchRange;
}

- (NSString *)relativeString
{
    NSString * relativeString = nil;
    NSRange range = [self relativeRange]; // should not be NSNotFound
    relativeString = [self substringWithRange:range];
    
    return relativeString;
}

/*
 for "http://www.douban.com/group/12345" will get Range(NSNotFound, 0) and nil
 for "http://www.douban.com/group/12345?key=value" will get Range(34, 9) and "key=value"
 for "http://www.douban.com/group/12345/" will get Range(NSNotFound, 0) and nil
 for "http://www.douban.com/group/12345/?key=value" will get Range(35, 9) and "key=value"
 for "http://www.douban.com:/group/12345/?key=value" will get Range(36, 9) and "key=value"
 for "http://www.douban.com:/" will get Range(NSNotFound, 0) and nil
 for "http://www.douban.com:/group/12345/?key=value:invalid/form/?bad" will get Range(36, 27) and "key=value:invalid/form/?bad"
 */
- (NSRange)queryRange {
    NSRange range;
    range = [self rangeOfString:@"?"
                        options:0
                          range:NSMakeRange(0, self.length)];
    if (NSNotFound != range.location) {
        if (range.location + range.length < self.length) {
            NSRange searchRange;
            searchRange.location = range.location + 1;
            searchRange.length = self.length - searchRange.location;
            range = [self rangeOfString:@"#" options:0 range:searchRange];
            if (NSNotFound == range.location) {
                return searchRange;
            }
            else if (range.location > searchRange.location) {
                NSRange queryRange;
                queryRange.location = searchRange.location;
                queryRange.length = range.location - searchRange.location;
                return queryRange;
            }

        }
    }
    return NSMakeRange(NSNotFound, 0);
}
- (NSString *)query
{
    NSString * query = nil;
    NSRange range = [self queryRange];
    if (NSNotFound != range.location) {
        query = [self substringWithRange:range];
    }
    return query;
}

- (NSRange)fragmentRange {
    NSRange range;
    range = [self rangeOfString:@"#"
                        options:0
                          range:NSMakeRange(0, self.length)];
    if (NSNotFound != range.location && range.location + range.length < self.length) {
        NSRange fragmentRange;
        fragmentRange.location = range.location + 1;
        fragmentRange.length = self.length - fragmentRange.location;
        return fragmentRange;
    }
    return NSMakeRange(NSNotFound, 0);
}

- (NSString *)fragment
{
    NSString * fragment = nil;
    NSRange fragmentRange = [self fragmentRange];
    if (NSNotFound != fragmentRange.location) {
        fragment = [self substringWithRange:fragmentRange];
    }
    return fragment;
}

- (NSString *)absolutePath 
{
    NSString * relative = [self relativeString];
    if (nil == relative) {
        return @"/";
    }
    
    return [@"/" stringByAppendingString:relative];
}

- (NSString *)requestURI {
    NSString * absolutePath = [self absolutePath];
    NSString * query = [self query];
    NSString * fragment = [self fragment];
    
    NSString * queryCompoent = query?[@"?" stringByAppendingString:query]:nil;
    NSString * fragmentCompoent = fragment?[@"#" stringByAppendingString:fragment]:nil;
    return [NSString stringWithFormat:@"%@%@%@", absolutePath, queryCompoent?queryCompoent:@"", fragmentCompoent?fragmentCompoent:@""];
}

- (NSArray *)emailParts
{
    NSArray * emailParts = [self componentsSeparatedByString:@"@"];
    if (2 != [emailParts count]) {
        return nil;
    }
    
    // may be user@anydomain , will not test the number of the parts of the domain.
    return emailParts;
}

@end
