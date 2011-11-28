//Copytright(c) 2011 Hongbo Yang (hongbo@yang.me). All rights reserved
//This file is part of YToolkit.
//
//YToolkit is free software: you can redistribute it and/or modify
//it under the terms of the GNU Lesser General Public License as 
//published by the Free Software Foundation, either version 3 of 
//the License, or (at your option) any later version.
//
//YToolkit is distributed in the hope that it will be useful,
//but WITHOUT ANY WARRANTY; without even the implied warranty of
//MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//GNU Lesser General Public License for more details.
//
//You should have received a copy of the GNU Lesser General Public 
//License along with YToolkit.  If not, see <http://www.gnu.org/licenses/>.
//



#import "YHTTPURLStringTests.h"
#import "NSString+YHTTPURLString.h"
#import "NSDictionary+YHTTPURLDictionary.h"
#import "ymacros.h"

@implementation YHTTPURLStringTests

- (void)testQueryStringByAddingParameters {
    NSDictionary * org = [NSDictionary dictionaryWithObjectsAndKeys:
                          [NSSet setWithObjects:@"",@"",@"3", nil], @"k1", 
                          @"v2", @"k2",
                          @"v3", @"k3",
                          @" ", @"k4",nil];
    NSDictionary * shouldbe = org;
    
    NSString * resultString = [org queryString];
    NSDictionary * result = [resultString decodedUrlencodedParameters];
    
    STAssertEqualObjects(result, shouldbe, @"resultString:%@" YSOURCE_IS(org), resultString);
}

- (void)testDecodedUrlencodedParameters {
    NSString * org = @"k1&k1&k1=3&k2=v2&k3=v3&k4=%20";
    NSDictionary * shouldbe = [NSDictionary dictionaryWithObjectsAndKeys:
                               [NSCountedSet setWithObjects:@"",@"",@"3", nil], @"k1", 
                               @"v2", @"k2",
                               @"v3", @"k3",
                               @" ", @"k4",nil];
    NSDictionary * result = [org decodedUrlencodedParameters];
    STAssertEqualObjects(result, shouldbe, YSOURCE_IS(org));
}

- (void)testEscapedString {
    NSString * str, *shouldbe, *result;

    str = @"a 3";
    result = [str escapedString];
    shouldbe = @"a%203";
    STAssertEqualObjects(result, shouldbe, YSOURCE_IS(str));

}

- (void)testUnescapedString {
    NSString * str, *shouldbe, *result;
    
    str = @"a%203";
    result = [str unescapeString];
    shouldbe = @"a 3";
    STAssertEqualObjects(result, shouldbe, YSOURCE_IS(str));
    
}
- (void)testEscapedStringWithWhitespace {
    NSString * str, *shouldbe, *result;
    
    str = @"a 3+3";
    result = [str escapedStringWithoutWhitespace];
    shouldbe = @"a 3%2B3";
    STAssertEqualObjects(result, shouldbe, YSOURCE_IS(str));
}
- (void)testUrlencodedString {
    NSString * str, *shouldbe, *result;
    
    str = @"a 3+3";
    result = [str urlencodedString];
    shouldbe = @"a+3%2B3";
    STAssertEqualObjects(result, shouldbe, YSOURCE_IS(str));
}

- (void)testUrldecodedString {
    NSString * str, *shouldbe, *result;
    
    str = @"a+3%2B3";
    result = [str urldecodedString];
    shouldbe = @"a 3+3";
    STAssertEqualObjects(result, shouldbe, YSOURCE_IS(str));
}

- (void)testScheme {
    NSString * url, *scheme, *shouldbe;
    NSRange schemeRange, shouldbeRange;
    
    url = @"http://www.douban.com";
    schemeRange = [url schemeRange];
    shouldbeRange = NSMakeRange(0, 4);
    STAssertEquals(schemeRange, shouldbeRange, YSHOULD_BE_BUT_RESULT(url, NSStringFromRange(shouldbeRange), NSStringFromRange(schemeRange)));
    shouldbe = @"http";
    scheme = [url scheme];
    STAssertEqualObjects(scheme, shouldbe, YSOURCE_IS(url));
    
    url = @"    http://www.douban.com";
    schemeRange = [url schemeRange];
    shouldbeRange = NSMakeRange(0, 8);
    STAssertEquals(schemeRange, shouldbeRange, YSHOULD_BE_BUT_RESULT(url, NSStringFromRange(shouldbeRange), NSStringFromRange(schemeRange)));
    shouldbe = @"    http";
    scheme = [url scheme];
    STAssertEqualObjects(scheme, shouldbe, YSOURCE_IS(url));
    
    url = @"    https://www.douban.com";
    schemeRange = [url schemeRange];
    shouldbeRange = NSMakeRange(0, 9);
    STAssertEquals(schemeRange, shouldbeRange, YSHOULD_BE_BUT_RESULT(url, NSStringFromRange(shouldbeRange), NSStringFromRange(schemeRange)));
    shouldbe = @"    https";
    scheme = [url scheme];
    STAssertEqualObjects(scheme, shouldbe, YSOURCE_IS(url));
    
    url = @"    fake://www.douban.com";
    schemeRange = [url schemeRange];
    shouldbeRange = NSMakeRange(0, 8);
    STAssertEquals(schemeRange, shouldbeRange, YSHOULD_BE_BUT_RESULT(url, NSStringFromRange(shouldbeRange), NSStringFromRange(schemeRange)));
    shouldbe = @"    fake";
    scheme = [url scheme];
    STAssertEqualObjects(scheme, shouldbe, YSOURCE_IS(url));
    
    url = @"    fa ke://www.douban.com";
    schemeRange = [url schemeRange];
    shouldbeRange = NSMakeRange(0, 9);
    STAssertEquals(schemeRange, shouldbeRange, YSHOULD_BE_BUT_RESULT(url, NSStringFromRange(shouldbeRange), NSStringFromRange(schemeRange)));
    shouldbe = @"    fa ke";
    scheme = [url scheme];
    STAssertEqualObjects(scheme, shouldbe, YSOURCE_IS(url));
    

    
    //this is invalid URL, cannot be parsed correctly(think fake is the host) just return default HTTP
    //the URL should be validated before use
    //
    url = @"    fake:/jkljl";
    schemeRange = [url schemeRange];
    shouldbeRange = NSMakeRange(NSNotFound, 0);
    STAssertEquals(schemeRange, shouldbeRange, YSHOULD_BE_BUT_RESULT(url, NSStringFromRange(shouldbeRange), NSStringFromRange(schemeRange)));
    shouldbe = nil;
    scheme = [url scheme];
    STAssertEqualObjects(scheme, shouldbe, YSOURCE_IS(url));
    
    url = @"    ";
    schemeRange = [url schemeRange];
    shouldbeRange = NSMakeRange(NSNotFound, 0);
    STAssertEquals(schemeRange, shouldbeRange, YSHOULD_BE_BUT_RESULT(url, NSStringFromRange(shouldbeRange), NSStringFromRange(schemeRange)));
    shouldbe = nil;
    scheme = [url scheme];
    STAssertEqualObjects(scheme, shouldbe, YSOURCE_IS(url));
    
    url = @"    ://www.douban.com";
    schemeRange = [url schemeRange];
    shouldbeRange = NSMakeRange(0, 4);
    STAssertEquals(schemeRange, shouldbeRange, YSHOULD_BE_BUT_RESULT(url, NSStringFromRange(shouldbeRange), NSStringFromRange(schemeRange)));
    shouldbe = @"    ";
    scheme = [url scheme];
    STAssertEqualObjects(scheme, shouldbe, YSOURCE_IS(url));

    url = @"://www.douban.com";
    schemeRange = [url schemeRange];
    shouldbeRange = NSMakeRange(0, 0);
    STAssertEquals(schemeRange, shouldbeRange, YSHOULD_BE_BUT_RESULT(url, NSStringFromRange(shouldbeRange), NSStringFromRange(schemeRange)));
    shouldbe = @"";
    scheme = [url scheme];
    STAssertEqualObjects(scheme, shouldbe, YSOURCE_IS(url));

    url = @"    ht:tp:///";
    schemeRange = [url schemeRange];
    shouldbeRange = NSMakeRange(0, 9);
    STAssertEquals(schemeRange, shouldbeRange, YSHOULD_BE_BUT_RESULT(url, NSStringFromRange(shouldbeRange), NSStringFromRange(schemeRange)));
    shouldbe = @"    ht:tp";
    scheme = [url scheme];
    STAssertEqualObjects(scheme, shouldbe, YSOURCE_IS(url));

}

- testHost {
    NSString * url, *host, *shouldbe;
    NSRange hostRange, shouldbeRange;
    
    shouldbe = @"www.douban.com";
    
    url = @"    http://www.douban.com";
    shouldbeRange = NSMakeRange(11, 14);
    hostRange = [url hostRange];
    STAssertEquals(hostRange, shouldbeRange, YSHOULD_BE_BUT_RESULT(url, NSStringFromRange(shouldbeRange), NSStringFromRange(hostRange)));
    host = [url host];
    STAssertEqualObjects(host, shouldbe, YSOURCE_IS(url));
    
    url = @"    http://www.douban.com:80";
    shouldbeRange = NSMakeRange(11, 14);
    hostRange = [url hostRange];
    STAssertEquals(hostRange, shouldbeRange, YSHOULD_BE_BUT_RESULT(url, NSStringFromRange(shouldbeRange), NSStringFromRange(hostRange)));
    host = [url host];
    STAssertEqualObjects(host, shouldbe, YSOURCE_IS(url));
    
    url = @"    http://www.douban.com/groups";
    shouldbeRange = NSMakeRange(11, 14);
    hostRange = [url hostRange];
    STAssertEquals(hostRange, shouldbeRange, YSHOULD_BE_BUT_RESULT(url, NSStringFromRange(shouldbeRange), NSStringFromRange(hostRange)));
    host = [url host];
    STAssertEqualObjects(host, shouldbe, YSOURCE_IS(url));
    
    url = @"    http://www.douban.com/groups";
    shouldbeRange = NSMakeRange(11, 14);
    hostRange = [url hostRange];
    STAssertEquals(hostRange, shouldbeRange, YSHOULD_BE_BUT_RESULT(url, NSStringFromRange(shouldbeRange), NSStringFromRange(hostRange)));
    host = [url host];
    STAssertEqualObjects(host, shouldbe, YSOURCE_IS(url));
    
    url = @"    http://www.douban.com/groups?key=value";
    shouldbeRange = NSMakeRange(11, 14);
    hostRange = [url hostRange];
    STAssertEquals(hostRange, shouldbeRange, YSHOULD_BE_BUT_RESULT(url, NSStringFromRange(shouldbeRange), NSStringFromRange(hostRange)));
    host = [url host];
    STAssertEqualObjects(host, shouldbe, YSOURCE_IS(url));
    
    url = @"    www.douban.com";
    shouldbeRange = NSMakeRange(0, [url length]);
    hostRange = [url hostRange];
    STAssertEquals(hostRange, shouldbeRange, YSHOULD_BE_BUT_RESULT(url, NSStringFromRange(shouldbeRange), NSStringFromRange(hostRange)));
    host = [url host];
    shouldbe = @"    www.douban.com";
    STAssertEqualObjects(host, shouldbe, YSOURCE_IS(url));
    
    url = @"     www.douban.com     ";
    shouldbeRange = NSMakeRange(0, [url length]);
    hostRange = [url hostRange];
    STAssertEquals(hostRange, shouldbeRange, YSHOULD_BE_BUT_RESULT(url, NSStringFromRange(shouldbeRange), NSStringFromRange(hostRange)));
    host = [url host];
    shouldbe = url;
    STAssertEqualObjects(host, shouldbe, YSOURCE_IS(url));
    
    url = @"  http://    www.douban.com     ";
    shouldbeRange = NSMakeRange(9, 23);
    hostRange = [url hostRange];
    STAssertEquals(hostRange, shouldbeRange, YSHOULD_BE_BUT_RESULT(url, NSStringFromRange(shouldbeRange), NSStringFromRange(hostRange)));
    host = [url host];
    shouldbe = @"    www.douban.com     ";
    STAssertEqualObjects(host, shouldbe, YSOURCE_IS(url));
    
    
    url = @"    ";
    shouldbeRange = NSMakeRange(0, 4);
    hostRange = [url hostRange];
    STAssertEquals(hostRange, shouldbeRange, YSHOULD_BE_BUT_RESULT(url, NSStringFromRange(shouldbeRange), NSStringFromRange(hostRange)));
    host = [url host];
    shouldbe = url;
    STAssertEqualObjects(host, shouldbe, YSOURCE_IS(url));
    
    url = @"    http://    ";
    shouldbeRange = NSMakeRange(11, 4);
    hostRange = [url hostRange];
    STAssertEquals(hostRange, shouldbeRange, YSHOULD_BE_BUT_RESULT(url, NSStringFromRange(shouldbeRange), NSStringFromRange(hostRange)));
    host = [url host];
    shouldbe = @"    ";
    STAssertEqualObjects(host, shouldbe, YSOURCE_IS(url));

    url = @"    http://    /";
    shouldbeRange = NSMakeRange(11, 4);
    hostRange = [url hostRange];
    STAssertEquals(hostRange, shouldbeRange, YSHOULD_BE_BUT_RESULT(url, NSStringFromRange(shouldbeRange), NSStringFromRange(hostRange)));
    host = [url host];
    shouldbe = @"    ";
    STAssertEqualObjects(host, shouldbe, YSOURCE_IS(url));

    url = @"    http:///";
    shouldbeRange = NSMakeRange(11, 0);
    hostRange = [url hostRange];
    STAssertEquals(hostRange, shouldbeRange, YSHOULD_BE_BUT_RESULT(url, NSStringFromRange(shouldbeRange), NSStringFromRange(hostRange)));
    host = [url host];
    shouldbe = @"";
    STAssertEqualObjects(host, shouldbe, YSOURCE_IS(url));

    url = @"    http://";
    shouldbeRange = NSMakeRange(11, 0);
    hostRange = [url hostRange];
    STAssertEquals(hostRange, shouldbeRange, YSHOULD_BE_BUT_RESULT(url, NSStringFromRange(shouldbeRange), NSStringFromRange(hostRange)));
    host = [url host];
    shouldbe = @"";
    STAssertEqualObjects(host, shouldbe, YSOURCE_IS(url));

    
    url = @"    ht:tp:///";
    shouldbeRange = NSMakeRange(11, 0);
    hostRange = [url hostRange];
    STAssertEquals(hostRange, shouldbeRange, YSHOULD_BE_BUT_RESULT(url, NSStringFromRange(shouldbeRange), NSStringFromRange(hostRange)));
    host = [url host];
    shouldbe = @"";
    STAssertEqualObjects(host, shouldbe, YSOURCE_IS(url));
}

- (void)testPort 
{
    NSString * url;
    NSNumber *port, *shouldbe;
    NSRange portRange, shouldbeRange;
    url = @"    http://www.douban.com:80";
    shouldbeRange = NSMakeRange(26, 2);
    portRange = [url portRange];
    STAssertEquals(portRange, shouldbeRange, YSHOULD_BE_BUT_RESULT(url, NSStringFromRange(shouldbeRange), NSStringFromRange(portRange)));
    port = [url port];
    shouldbe = [NSNumber numberWithInteger:[@"80" integerValue]];
    STAssertEqualObjects(port, shouldbe, YSOURCE_IS(url));

    url = @"http://www.douban.com";
    shouldbeRange = NSMakeRange(NSNotFound, 0);
    portRange = [url portRange];
    STAssertEquals(portRange, shouldbeRange, YSHOULD_BE_BUT_RESULT(url, NSStringFromRange(shouldbeRange), NSStringFromRange(portRange)));
    port = [url port];
    shouldbe = nil;
    STAssertEqualObjects(port, shouldbe, YSOURCE_IS(url));

    url = @"http://www.douban.com:80  /";
    shouldbeRange = NSMakeRange(22, 4);
    portRange = [url portRange];
    STAssertEquals(portRange, shouldbeRange, YSHOULD_BE_BUT_RESULT(url, NSStringFromRange(shouldbeRange), NSStringFromRange(portRange)));
    port = [url port];
    shouldbe = [NSNumber numberWithInteger:[@"80  " integerValue]];
    STAssertEqualObjects(port, shouldbe, YSOURCE_IS(url));

    url = @"http://www.douban.com:8a/";
    shouldbeRange = NSMakeRange(22, 2);
    portRange = [url portRange];
    STAssertEquals(portRange, shouldbeRange, YSHOULD_BE_BUT_RESULT(url, NSStringFromRange(shouldbeRange), NSStringFromRange(portRange)));
    port = [url port];
    shouldbe = [NSNumber numberWithInteger:[@"8a" integerValue]];
    STAssertEqualObjects(port, shouldbe, YSOURCE_IS(url));
    
    url = @"http://www.douban.com:a8/";
    shouldbeRange = NSMakeRange(22, 2);
    portRange = [url portRange];
    STAssertEquals(portRange, shouldbeRange, YSHOULD_BE_BUT_RESULT(url, NSStringFromRange(shouldbeRange), NSStringFromRange(portRange)));
    port = [url port];
    shouldbe = [NSNumber numberWithInteger:[@"a8" integerValue]];
    STAssertEqualObjects(port, shouldbe, YSOURCE_IS(url));

    url = @"http://www.douban.com:8   /";
    shouldbeRange = NSMakeRange(22, 4);
    portRange = [url portRange];
    STAssertEquals(portRange, shouldbeRange, YSHOULD_BE_BUT_RESULT(url, NSStringFromRange(shouldbeRange), NSStringFromRange(portRange)));
    port = [url port];
    shouldbe = [NSNumber numberWithInteger:[@"8   " integerValue]];
    STAssertEqualObjects(port, shouldbe, YSOURCE_IS(url));

    
    url = @"    fake:/jkljl";
    shouldbeRange = NSMakeRange(9, 0);
    portRange = [url portRange];
    STAssertEquals(portRange, shouldbeRange, YSHOULD_BE_BUT_RESULT(url, NSStringFromRange(shouldbeRange), NSStringFromRange(portRange)));
    port = [url port];
    shouldbe = [NSNumber numberWithInteger:[@"" integerValue]];
    STAssertEqualObjects(port, shouldbe, YSOURCE_IS(url));
    
    url = @"www.douban.com:";
    shouldbeRange = NSMakeRange(15, 0);
    portRange = [url portRange];
    STAssertEquals(portRange, shouldbeRange, YSHOULD_BE_BUT_RESULT(url, NSStringFromRange(shouldbeRange), NSStringFromRange(portRange)));
    port = [url port];
    shouldbe = [NSNumber numberWithInteger:[@"" integerValue]];
    STAssertEqualObjects(port, shouldbe, YSOURCE_IS(url));

    url = @"www.douban.com:/";
    shouldbeRange = NSMakeRange(15, 0);
    portRange = [url portRange];
    STAssertEquals(portRange, shouldbeRange, YSHOULD_BE_BUT_RESULT(url, NSStringFromRange(shouldbeRange), NSStringFromRange(portRange)));
    port = [url port];
    shouldbe = [NSNumber numberWithInteger:[@"" integerValue]];
    STAssertEqualObjects(port, shouldbe, YSOURCE_IS(url));

    url = @":/";
    shouldbeRange = NSMakeRange(1, 0);
    portRange = [url portRange];
    STAssertEquals(portRange, shouldbeRange, YSHOULD_BE_BUT_RESULT(url, NSStringFromRange(shouldbeRange), NSStringFromRange(portRange)));
    port = [url port];
    shouldbe = [NSNumber numberWithInteger:[@"" integerValue]];
    STAssertEqualObjects(port, shouldbe, YSOURCE_IS(url));
    
    url = @"http://:";
    shouldbeRange = NSMakeRange(8, 0);
    portRange = [url portRange];
    STAssertEquals(portRange, shouldbeRange, YSHOULD_BE_BUT_RESULT(url, NSStringFromRange(shouldbeRange), NSStringFromRange(portRange)));
    port = [url port];
    shouldbe = [NSNumber numberWithInteger:[@"" integerValue]];
    STAssertEqualObjects(port, shouldbe, YSOURCE_IS(url));

    url = @"www.douban.com/group:80/";
    shouldbeRange = NSMakeRange(NSNotFound, 0);
    portRange = [url portRange];
    STAssertEquals(portRange, shouldbeRange, YSHOULD_BE_BUT_RESULT(url, NSStringFromRange(shouldbeRange), NSStringFromRange(portRange)));
    port = [url port];
    shouldbe = nil;
    STAssertEqualObjects(port, shouldbe, YSOURCE_IS(url));
}

- (void)testRelativeString
{
    NSString * url, *relString, *shouldbe;
    NSRange relRange, shouldbeRange;
    
    
    url = @"    http://www.douban.com/group/12345";
    shouldbeRange = NSMakeRange(26, 11);
    relRange = [url relativeRange];
    STAssertEquals(relRange, shouldbeRange, YSHOULD_BE_BUT_RESULT(url, NSStringFromRange(shouldbeRange), NSStringFromRange(relRange)));
    shouldbe = @"group/12345";
    relString = [url relativeString];
    STAssertEqualObjects(relString, shouldbe, YSOURCE_IS(url));

    url = @"http://www.douban.com/group/12345?key=value";
    shouldbeRange = NSMakeRange(22, 11);
    relRange = [url relativeRange];
    STAssertEquals(relRange, shouldbeRange, YSHOULD_BE_BUT_RESULT(url, NSStringFromRange(shouldbeRange), NSStringFromRange(relRange)));
    shouldbe = @"group/12345";
    relString = [url relativeString];
    STAssertEqualObjects(relString, shouldbe, YSOURCE_IS(url));
    
    url = @"http://www.douban.com/group/12345/";
    shouldbeRange = NSMakeRange(22, 12);
    relRange = [url relativeRange];
    STAssertEquals(relRange, shouldbeRange, YSHOULD_BE_BUT_RESULT(url, NSStringFromRange(shouldbeRange), NSStringFromRange(relRange)));
    shouldbe = @"group/12345/";
    relString = [url relativeString];
    STAssertEqualObjects(relString, shouldbe, YSOURCE_IS(url));
    
    url = @"http://www.douban.com/group/12345/?key=value";
    shouldbeRange = NSMakeRange(22, 12);
    relRange = [url relativeRange];
    STAssertEquals(relRange, shouldbeRange, YSHOULD_BE_BUT_RESULT(url, NSStringFromRange(shouldbeRange), NSStringFromRange(relRange)));
    shouldbe = @"group/12345/";
    relString = [url relativeString];
    STAssertEqualObjects(relString, shouldbe, YSOURCE_IS(url));
    
    url = @"http://www.douban.com:/group/12345/?key=value";
    shouldbeRange = NSMakeRange(23, 12);
    relRange = [url relativeRange];
    STAssertEquals(relRange, shouldbeRange, YSHOULD_BE_BUT_RESULT(url, NSStringFromRange(shouldbeRange), NSStringFromRange(relRange)));
    shouldbe = @"group/12345/";
    relString = [url relativeString];
    STAssertEqualObjects(relString, shouldbe, YSOURCE_IS(url));
    
    url = @"http://www.douban.com:/";
    shouldbeRange = NSMakeRange(23, 0);
    relRange = [url relativeRange];
    STAssertEquals(relRange, shouldbeRange, YSHOULD_BE_BUT_RESULT(url, NSStringFromRange(shouldbeRange), NSStringFromRange(relRange)));
    shouldbe = @"";
    relString = [url relativeString];
    STAssertEqualObjects(relString, shouldbe, YSOURCE_IS(url));
    
    url = @"http://www.douban.com:";
    shouldbeRange = NSMakeRange(22, 0);
    relRange = [url relativeRange];
    STAssertEquals(relRange, shouldbeRange, YSHOULD_BE_BUT_RESULT(url, NSStringFromRange(shouldbeRange), NSStringFromRange(relRange)));
    shouldbe = @"";
    relString = [url relativeString];
    STAssertEqualObjects(relString, shouldbe, YSOURCE_IS(url));
    
}


- (void)testQueryString
{
    NSString * url, *queryString, *shouldbe;
    NSRange queryRange, shouldbeRange;
    
    
    url = @"    http://www.douban.com/group/12345";
    shouldbeRange = NSMakeRange(NSNotFound, 0);
    queryRange = [url queryRange];
    STAssertEquals(queryRange, shouldbeRange, YSHOULD_BE_BUT_RESULT(url, NSStringFromRange(shouldbeRange), NSStringFromRange(queryRange)));
    shouldbe = nil;
    queryString = [url query];
    STAssertEqualObjects(queryString, shouldbe, YSOURCE_IS(url));
    
    url = @"http://www.douban.com/group/12345?key=value";
    shouldbeRange = NSMakeRange(34, 9);
    queryRange = [url queryRange];
    STAssertEquals(queryRange, shouldbeRange, YSHOULD_BE_BUT_RESULT(url, NSStringFromRange(shouldbeRange), NSStringFromRange(queryRange)));
    shouldbe = @"key=value";
    queryString = [url query];
    STAssertEqualObjects(queryString, shouldbe, YSOURCE_IS(url));
    
    url = @"http://www.douban.com/group/12345/";
    shouldbeRange = NSMakeRange(NSNotFound, 0);
    queryRange = [url queryRange];
    STAssertEquals(queryRange, shouldbeRange, YSHOULD_BE_BUT_RESULT(url, NSStringFromRange(shouldbeRange), NSStringFromRange(queryRange)));
    shouldbe = nil;
    queryString = [url query];
    STAssertEqualObjects(queryString, shouldbe, YSOURCE_IS(url));
    
    url = @"http://www.douban.com/group/12345/?key=value";
    shouldbeRange = NSMakeRange(35, 9);
    queryRange = [url queryRange];
    STAssertEquals(queryRange, shouldbeRange, YSHOULD_BE_BUT_RESULT(url, NSStringFromRange(shouldbeRange), NSStringFromRange(queryRange)));
    shouldbe = @"key=value";
    queryString = [url query];
    STAssertEqualObjects(queryString, shouldbe, YSOURCE_IS(url));
     
    url = @"http://www.douban.com:/group/12345/?key=value";
    shouldbeRange = NSMakeRange(36, 9);
    queryRange = [url queryRange];
    STAssertEquals(queryRange, shouldbeRange, YSHOULD_BE_BUT_RESULT(url, NSStringFromRange(shouldbeRange), NSStringFromRange(queryRange)));
    shouldbe = @"key=value";
    queryString = [url query];
    STAssertEqualObjects(queryString, shouldbe, YSOURCE_IS(url));
   
    url = @"http://www.douban.com:/";
    shouldbeRange = NSMakeRange(NSNotFound, 0);
    queryRange = [url queryRange];
    STAssertEquals(queryRange, shouldbeRange, YSHOULD_BE_BUT_RESULT(url, NSStringFromRange(shouldbeRange), NSStringFromRange(queryRange)));
    shouldbe = nil;
    queryString = [url query];
    STAssertEqualObjects(queryString, shouldbe, YSOURCE_IS(url));
   
    url = @"http://www.douban.com:";
    shouldbeRange = NSMakeRange(NSNotFound, 0);
    queryRange = [url queryRange];
    STAssertEquals(queryRange, shouldbeRange, YSHOULD_BE_BUT_RESULT(url, NSStringFromRange(shouldbeRange), NSStringFromRange(queryRange)));
    shouldbe = nil;
    queryString = [url query];
    STAssertEqualObjects(queryString, shouldbe, YSOURCE_IS(url));
   
    url = @"http://www.douban.com:/group/12345/?key=value:invalid/form/?bad";
    shouldbeRange = NSMakeRange(36, 27);
    queryRange = [url queryRange];
    STAssertEquals(queryRange, shouldbeRange, YSHOULD_BE_BUT_RESULT(url, NSStringFromRange(shouldbeRange), NSStringFromRange(queryRange)));
    shouldbe = @"key=value:invalid/form/?bad";
    queryString = [url query];
    STAssertEqualObjects(queryString, shouldbe, YSOURCE_IS(url));
}

@end
