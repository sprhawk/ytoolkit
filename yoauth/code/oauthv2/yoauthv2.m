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


#import "yoauthv2.h"
#import "NSString+YHTTPURLString.h"
#import "NSDictionary+YHTTPURLDictionary.h"
#import "yoauth_utilities.h"
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonHMAC.h>
#import "NSData+YBase64String.h"
#import "ymacros.h"

NSString * const YOAuthv2ResponseType = @"response_type";
NSString * const YOAuthv2AuthorizationCode = @"code";
NSString * const YOAuthv2ImplictGrant = @"token";

NSString * const YOAuthv2ClientId = @"client_id";
NSString * const YOAuthv2ClientSecret = @"client_secret";
NSString * const YOAuthv2RedirectURI = @"redirect_uri";
NSString * const YOAuthv2Scope = @"scope";
NSString * const YOAuthv2State = @"state";

NSString * const YOAuthv2GrantType = @"grant_type";
NSString * const YOAuthv2GrantTypeAuthorizationCode = @"authorization_code";
NSString * const YOAuthv2GrantTypeResourceOwnerPasswordCredentials = @"password";
NSString * const YOAuthv2ResourceOwnerUsername = @"username";
NSString * const YOAuthv2ResourceOwnerPassword = @"password";
NSString * const YOAuthv2GrantTypeClientCredentials = @"client_credentials";
NSString * const YOAuthv2GrantTypeRefreshToken = @"refresh_token";

NSString * const YOAuthv2AccessToken = @"access_token";
NSString * const YOAuthv2TokenType = @"token_type";
NSString * const YOAuthv2ExpiresIn = @"expires_in";
NSString * const YOAuthv2RefreshToken = @"refresh_token";

NSString * const YOAuthv2MacAlgorithmHmacSha1 = @"hmac-sha1";
NSString * const YOAuthv2MacAlgorithmHmacSha256 = @"hmac-sha256";

NSDictionary * YOAuthv2GetAccessTokenRequestParametersForAuthorizationCode(NSString *code, 
                                                                NSString *redirect_uri)
{
    if (nil == code) {
        return nil;
    }
    NSMutableDictionary * parameters = [NSMutableDictionary dictionaryWithCapacity:5];
    [parameters setObject:YOAuthv2GrantTypeAuthorizationCode forKey:YOAuthv2GrantType];
    [parameters setObject:code forKey:YOAuthv2AuthorizationCode];
    if (redirect_uri) {
        [parameters setObject:redirect_uri forKey:YOAuthv2RedirectURI];
    }
    
    return parameters;
}

NSDictionary * YOAuthv2GetAccessTokenRequestParametersForResourceOwnerPasswordCredentials(NSString *username, 
                                                                               NSString *password,
                                                                               NSString *scope)
{
    if (nil == username || nil == password) {
        return nil;
    }
    NSMutableDictionary * parameters = [NSMutableDictionary dictionaryWithCapacity:5];
    [parameters setObject:YOAuthv2GrantTypeResourceOwnerPasswordCredentials forKey:YOAuthv2GrantType];
    [parameters setObject:username forKey:YOAuthv2AuthorizationCode];
    if (scope) {
        [parameters setObject:scope forKey:YOAuthv2Scope];
    }
    
    return parameters;
}

NSDictionary * YOAuthv2GetAccessTokenRequestParametersForClientCredentials(NSString *scope)
{
    NSMutableDictionary * parameters = [NSMutableDictionary dictionaryWithCapacity:2];
    [parameters setObject:YOAuthv2GrantTypeClientCredentials forKey:YOAuthv2GrantType];
    if (scope) {
        [parameters setObject:scope forKey:YOAuthv2Scope];
    }
    
    return parameters;
}

NSDictionary * YOAuthv2GetAccessTokenRequestParametersForRefreshToken(NSString *refresh_token,
                                                    NSString *scope)
{
    NSMutableDictionary * parameters = [NSMutableDictionary dictionaryWithCapacity:2];
    [parameters setObject:YOAuthv2GrantTypeRefreshToken forKey:YOAuthv2GrantType];
    if (scope) {
        [parameters setObject:scope forKey:YOAuthv2Scope];
    }
    
    return parameters;
}

NSString * YOAuthv2GetAuthorizationMACHeader(NSString * mac_identifier,
                                             NSString * mac_key,
                                             NSString * mac_algorithm,
                                             NSTimeInterval age,
                                             NSString * unique_string,
                                             NSString * requestMethod,
                                             NSString * host, //because this host should be the 
                                                                 //HOST in HTTP header, may be 
                                                                 //slightly different among 
                                                                 //libraries? So have better to
                                                                 //get host from the specific 
                                                                 //request instance
                                             NSString * url,
                                             NSString * body,
                                             NSString * extension,
                                             NSString * bodyhash,//custom hash, if exists, will use this instead of internal calculation
                                             NSString * mac)//custom hash, if exists, will use this instead of internal calculation
{
    if (nil == mac_identifier 
        || nil == url
        || (nil == mac_key && nil == mac_algorithm && nil == mac)) {
        return nil;
    }
    NSMutableString * header = [NSMutableString stringWithCapacity:64];
    [header appendFormat:@"MAC id=\"%@\"",mac_identifier];
    
    [header setString:@""];
    if (nil == unique_string) {
        unique_string = YGetUUID();
    }
    NSString * nonce = [NSString stringWithFormat:@"%.0f:%@", age, unique_string];
    [header appendFormat:@", nonce=\"%@\"", nonce];
    if (extension) {
        [header appendFormat:@", ext=\"%@\"", extension];
    }

    if (nil == mac) {
        NSMutableString * requestString = [NSMutableString stringWithCapacity:64];
        [requestString setString:@""];
        [requestString appendFormat:@"%@\n", nonce];
        [requestString appendFormat:@"%@\n", [requestMethod uppercaseString]];
        [requestString appendFormat:@"%@\n", [url requestURI]];
        if (nil == host) {
            host = [url host];
        }

        [requestString appendFormat:@"%@\n", [host lowercaseString]];
        
        NSNumber * port = [url port];
        if (nil == port) {
            NSString * scheme = [[url scheme] lowercaseString];
            if (nil == scheme || [scheme isEqualToString:@"http"]) {
                port = [NSNumber numberWithInteger:80];
            }
            else if([scheme isEqualToString:@"https:"]) {
                port = [NSNumber numberWithInteger:443];
            }
            else {// not recognized scheme
                return nil;
            }
        }
        [requestString appendFormat:@"%d\n", [port integerValue]];
        
        if ([mac_algorithm isEqualToString:YOAuthv2MacAlgorithmHmacSha1]) {
            unsigned char hhmac[CC_SHA1_DIGEST_LENGTH] = {0};
            if (nil == bodyhash && body) {
                NSData * data = [body dataUsingEncoding:NSUTF8StringEncoding];
                CC_SHA1([data bytes], [data length], hhmac);
                data = [[NSData alloc] initWithBytesNoCopy:hhmac length:sizeof(hhmac) freeWhenDone:NO];
                bodyhash = [data base64String];
                YRELEASE_SAFELY(data);
            }

            [requestString appendFormat:@"%@\n", bodyhash?bodyhash:@""];
            [requestString appendFormat:@"%@\n", extension?extension:@""];

            memset(hhmac, 0, sizeof(hhmac));
            NSData * data = [requestString dataUsingEncoding:NSUTF8StringEncoding];
            NSData * mac_key_data = [mac_key dataUsingEncoding:NSUTF8StringEncoding];
            CCHmac(kCCHmacAlgSHA1, [mac_key_data bytes], [mac_key_data length], 
                   [data bytes],
                   [data length], hhmac);
            NSData * digestData = [NSData dataWithBytesNoCopy:hhmac length:sizeof(hhmac) freeWhenDone:NO];
            mac = [digestData base64String];
        }
        else if ([mac_algorithm isEqualToString:YOAuthv2MacAlgorithmHmacSha256]) {
            unsigned char hhmac[CC_SHA256_DIGEST_LENGTH] = {0};
            if (nil == bodyhash && body) {
                NSData * data = [body dataUsingEncoding:NSUTF8StringEncoding];
                CC_SHA256([data bytes], [data length], hhmac);
                data = [[NSData alloc] initWithBytesNoCopy:hhmac length:sizeof(hhmac) freeWhenDone:NO];
                bodyhash = [data base64String];
                YRELEASE_SAFELY(data);
            }
            
            [requestString appendFormat:@"%@\n", bodyhash?bodyhash:@""];
            [requestString appendFormat:@"%@\n", extension?extension:@""];
            
            memset(hhmac, 0, sizeof(hhmac));
            NSData * data = [requestString dataUsingEncoding:NSUTF8StringEncoding];
            NSData * mac_key_data = [mac_key dataUsingEncoding:NSUTF8StringEncoding];
            CCHmac(kCCHmacAlgSHA256, [mac_key_data bytes], [mac_key_data length], 
                   [data bytes],
                   [data length], hhmac);
            NSData * digestData = [NSData dataWithBytesNoCopy:hhmac length:sizeof(hhmac) freeWhenDone:NO];
            mac = [digestData base64String];
        }
    }
    
    [header appendFormat:@", mac=\"%@\"", mac];
    if (bodyhash) {
        [header appendFormat:@", bodyhash=\"%@\"", bodyhash];
    }
    
    return header;
}

@implementation NSString (YOAuthv2)
- (NSString *)requestAuthorizationCodeUrlStringByAddingClientId:(NSString *)client_id
                                                    redirectURI:(NSString *)redirect_uri
                                                          scope:(NSString *)scope
                                                          state:(NSString *)state
{
    if (nil == client_id) {
        return nil;
    }
    NSMutableDictionary * parameters = [NSMutableDictionary dictionaryWithCapacity:5];
    [parameters setObject:YOAuthv2AuthorizationCode forKey:YOAuthv2ResponseType];
    [parameters setObject:client_id forKey:YOAuthv2ClientId];
    if (redirect_uri) {
        [parameters setObject:redirect_uri forKey:YOAuthv2RedirectURI];
    }
    if (scope) {
        [parameters setObject:scope forKey:YOAuthv2Scope];
    }
    if (state) {
        [parameters setObject:state forKey:YOAuthv2State];
    }
    
    return [self URLStringByAddingParameters:parameters];
}


- (NSString *)requestImplicitGrantUrlStringByAddingClientId:(NSString *)client_id
                                                redirectURI:(NSString *)redirect_uri
                                                      scope:(NSString *)scope
                                                      state:(NSString *)state
{
    if (nil == client_id) {
        return nil;
    }
    NSMutableDictionary * parameters = [NSMutableDictionary dictionaryWithCapacity:5];
    [parameters setObject:YOAuthv2ImplictGrant forKey:YOAuthv2ResponseType];
    [parameters setObject:client_id forKey:YOAuthv2ClientId];
    if (redirect_uri) {
        [parameters setObject:redirect_uri forKey:YOAuthv2RedirectURI];
    }
    if (scope) {
        [parameters setObject:scope forKey:YOAuthv2Scope];
    }
    if (state) {
        [parameters setObject:state forKey:YOAuthv2State];
    }
    
    return [self URLStringByAddingParameters:parameters];
}


@end
