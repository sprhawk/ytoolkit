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


#import "yoauthTests.h"
#import "yoauthv1_internal.h"
#import "ymacros.h"
#import "NSString+YHTTPURLString.h"

@implementation OAuthv1Teset

- (void)testSignatureBaseString {
    
    NSString * url, *shouldbe, *result;
    url = @"http://EXAMPLE.COM:80/r%20v/X?id=123";
    result = YOAuthv1GetURLBaseString(url);
    shouldbe = @"http://example.com/r%20v/X";
    STAssertEqualObjects(result, shouldbe, YSOURCE_IS(url));
    
    url = @"https://www.example.net:8080/?q=1";
    result = YOAuthv1GetURLBaseString(url);
    shouldbe = @"https://www.example.net:8080/";
    STAssertEqualObjects(result, shouldbe, YSOURCE_IS(url));

}

- (void)testOAuthv1EscapedString {
    
    NSString * org, *shouldbe, *result;
    org = @"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~";
    result = [org yoauthv1EscapedString];
    shouldbe = org;
    STAssertEqualObjects(result, shouldbe, YSOURCE_IS(org));

    //ascii ordered, 
    org = @ " !\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~";
    result = [org yoauthv1EscapedString];
    shouldbe = @"%20%21%22%23%24%25%26%27%28%29%2A%2B%2C-.%2F0123456789%3A%3B%3C%3D%3E%3F%40ABCDEFGHIJKLMNOPQRSTUVWXYZ%5B%5C%5D%5E_%60abcdefghijklmnopqrstuvwxyz%7B%7C%7D~";
    STAssertEqualObjects(result, shouldbe, YSOURCE_IS(org));
}

- (void)testOAuthv1ConcatenatedSignatureParametersString {
    NSDictionary * parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                 @"=%3D", @"b5", 
                                 @"", @"c@",
                                 @"r b", @"a2",
                                 @"9djdj82h48djs9d2", @"oauth_consumer_key",
                                 @"kkk9d7dh3k39sjv7", @"oauth_token",
                                 @"HMAC-SHA1", @"oauth_signature_method",
                                 @"137131201", @"oauth_timestamp",
                                 @"7d8f3e4a", @"oauth_nonce", 
                                 @"", @"c2",
                                 [NSSet setWithObjects:@"2 q", @"a", nil], @"a3", nil];
    parameters = [parameters oauthv1EscapedParameters];
    NSString * result = [parameters oauthv1ConcatenatedSignatureParametersString];
    NSString * shouldbe = @"a2=r%20b&a3=2%20q&a3=a&b5=%3D%253D&c%40=&c2=&oauth_consumer_key=9djdj82h48djs9d2&oauth_nonce=7d8f3e4a&oauth_signature_method=HMAC-SHA1&oauth_timestamp=137131201&oauth_token=kkk9d7dh3k39sjv7";
    STAssertEqualObjects(result, shouldbe, @"");
}

- (void)testOAuthv1SignatureString {
    NSString * url, *shouldbe, *result;
    url = @"http://EXAMPLE.COM:80/request?b5=%3D%253D&a3=a&c%40=&a2=r%20b";
    shouldbe = @"POST&http%3A%2F%2Fexample.com%2Frequest&a2%3Dr%2520b%26a3%3D2%2520q%26a3%3Da%26b5%3D%253D%25253D%26c%2540%3D%26c2%3D%26oauth_consumer_key%3D9djdj82h48djs9d2%26oauth_nonce%3D7d8f3e4a%26oauth_signature_method%3DHMAC-SHA1%26oauth_timestamp%3D137131201%26oauth_token%3Dkkk9d7dh3k39sjv7%26oauth_version%3D1.0";
    NSDictionary * parameters = [NSDictionary dictionaryWithObjectsAndKeys:@"", @"c2", @"2 q", @"a3", nil];
    result = YOAuthv1GetSignatureBaseString(YOAuthv1SignatureMethodHMAC_SHA1, @"POST", url, @"9djdj82h48djs9d2", @"kkk9d7dh3k39sjv7", [NSNumber numberWithInteger:137131201], @"7d8f3e4a", parameters, nil, nil);
    STAssertEqualObjects(result, shouldbe, YSOURCE_IS(url));
    
    shouldbe = nil;
    result = YOAuthv1GetSignatureBaseString(YOAuthv1SignatureMethodHMAC_SHA1, nil, @"", @"", @"", nil, @"", parameters, nil, nil);
    STAssertEqualObjects(result, shouldbe, @"");
    
    shouldbe = nil;
    result = YOAuthv1GetSignatureBaseString(YOAuthv1SignatureMethodHMAC_SHA1, @"", nil, @"", @"", nil, @"", parameters, nil, nil);
    STAssertEqualObjects(result, shouldbe, @"");
    
}



@end
