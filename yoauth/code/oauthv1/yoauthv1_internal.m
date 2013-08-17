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


#import "yoauthv1_internal.h"
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonHMAC.h>
#import <Security/Security.h>

#import "NSString+YHTTPURLString.h"
#import "NSMutableDictionary+YDuplicatableDictionary.h"
#import "NSData+YBase64String.h"
#import "yoauth_utilities.h"
#import "ymacros.h"
#import "yoauthv1.h"

#define YOAuthv1SignatureMethodPlainTextName @"PLAINTEXT"
#define YOAuthv1SignatureMethodHMAC_SHA1Name  @"HMAC-SHA1"
#define YOAuthv1SignatureMethodRSA_SHA1Name  @"RSA-SHA1"

static NSString const * YOAuthv1SignatureMethods[3] = {
    YOAuthv1SignatureMethodPlainTextName,
    YOAuthv1SignatureMethodHMAC_SHA1Name,
    YOAuthv1SignatureMethodRSA_SHA1Name
};


NSString * YOAuthv1GetSignature(YOAuthv1SignatureMethod signatureMethod,
                                NSString * requestMethod, 
                                NSString * url,
                                NSString * consumerKey,
                                NSString * consumerSecret,
                                NSData   * pkcs12PrivateKey,
                                NSString * token,
                                NSString * tokenSecret,
                                NSNumber * timestamp,
                                NSString * nonce,
                                NSDictionary * postParameters,
                                NSString * verifier,
                                NSString * callback) //must be raw/decoded paramerters
{
    if (nil == requestMethod || nil == url) {
        return nil;
    }
    
    NSString * signatureBaseString = nil;
    
    if(YOAuthv1SignatureMethodPlainText != signatureMethod) {
        signatureBaseString = YOAuthv1GetSignatureBaseString(signatureMethod,
                                                             requestMethod,
                                                             url,
                                                             consumerKey,
                                                             token, 
                                                             timestamp,
                                                             nonce,
                                                             postParameters,
                                                             verifier,
                                                             callback);
    }
    
    if (YOAuthv1SignatureMethodRSA_SHA1 == signatureMethod) {
        NSString * signature = nil;
        if (nil == pkcs12PrivateKey) {
            return nil;
        }
        CFArrayRef items = NULL;
        SecPKCS12Import((CFDataRef)pkcs12PrivateKey, NULL, &items);
        if (NULL == items) {
            return nil;
        }
        
        for (NSDictionary * item in (NSArray*)items) {
            SecIdentityRef identity = (SecIdentityRef)[item objectForKey:(NSString *)kSecImportItemIdentity];
            if (identity) {
                SecKeyRef privateKey = NULL;
                SecIdentityCopyPrivateKey(identity, &privateKey);
                if (privateKey) {
                    size_t blockSize = SecKeyGetBlockSize(privateKey);
                    uint8_t * sig = malloc(blockSize * sizeof(uint8_t));
                    NSData * data = [signatureBaseString dataUsingEncoding:NSUTF8StringEncoding];
                    if (sig) {
                        OSStatus st = SecKeyRawSign(privateKey, kSecPaddingPKCS1SHA1, 
                                                    [data bytes], 
                                                    [data length],
                                                    sig,
                                                    &blockSize);
                        if (errSecSuccess) {
                            NSData * data = [NSData dataWithBytesNoCopy:sig length:blockSize freeWhenDone:NO];
                            signature = [data base64String];
                        }
                        else {
                            YLOG(@"SecKeyRawSign failed:%ld", st);
                        }
                        free(sig);
                        sig = NULL;
                    }
                    CFRelease(privateKey);
                    privateKey = NULL;
                }
            }
        }
        CFRelease(items);
        items = NULL;
        return signature;
    }
    else if (YOAuthv1SignatureMethodHMAC_SHA1 == signatureMethod) {
        if (nil == consumerSecret) {
            consumerSecret = @"";
        }
        if (nil == tokenSecret) {
            tokenSecret = @"";
        }
        NSString * secret = [NSString stringWithFormat:@"%@&%@", 
                             [consumerSecret yoauthv1EscapedString], 
                             [tokenSecret yoauthv1EscapedString]];
        unsigned char hhmac[CC_SHA1_DIGEST_LENGTH] = {0};
        
        assert(signatureBaseString);
        NSData * data = [signatureBaseString dataUsingEncoding:NSUTF8StringEncoding];
        NSData * secretData = [secret dataUsingEncoding:NSUTF8StringEncoding];
        CCHmac(kCCHmacAlgSHA1, [secretData bytes], [secretData length], 
               [data bytes],
               [data length], hhmac);
        NSData * digestData = [NSData dataWithBytesNoCopy:hhmac length:sizeof(hhmac) freeWhenDone:NO];
        NSString * signature = [digestData base64String];

        return signature;
        
    }
    else if (YOAuthv1SignatureMethodPlainText == signatureMethod) {
        if (nil == consumerSecret) {
            consumerSecret = @"";
        }
        if (nil == tokenSecret) {
            tokenSecret = @"";
        }
        NSString * secret = [NSString stringWithFormat:@"%@&%@", 
                             [consumerSecret yoauthv1EscapedString], 
                             [tokenSecret yoauthv1EscapedString]];
        return secret;
    }
    return nil;
}

NSDictionary * YOAuthv1GetParameters(YOAuthv1SignatureMethod signatureMethod,
                                     NSString * requestMethod, 
                                     NSString * consumerKey,
                                     NSString * token,
                                     NSNumber * timestamp,
                                     NSString * nonce,
                                     NSString * verifier,
                                     NSString * callback)
{
    NSMutableDictionary * oauthParameters = [NSMutableDictionary dictionaryWithCapacity:6];
    assert(signatureMethod < 3);
    [oauthParameters setObject:YOAuthv1SignatureMethods[signatureMethod] forKey:YOAuthv1OAuthSignatureMethodKey];
    if (consumerKey) { // consumerKey may be omitted?
        [oauthParameters setObject:consumerKey forKey:YOAuthv1OAuthConsumerKeyKey];
    }
    
    if (token) {
        [oauthParameters setObject:token forKey:YOAuthv1OAuthTokenKey];
    }
    
    if (timestamp) {
        [oauthParameters setObject:[NSString stringWithFormat:@"%d", [timestamp integerValue]] forKey:YOAuthv1OAuthTimestampKey];
    }
    
    if (nonce) {
        [oauthParameters setObject:nonce forKey:YOAuthv1OAuthNonceKey];
    }
    
    if (verifier) {
        [oauthParameters setObject:verifier forKey:YOAuthv1OAuthVerifierKey];
    }
    
    if (callback) {
        [oauthParameters setObject:callback forKey:YOAuthv1OAuthCallbackKey];
    }
    
    [oauthParameters setObject:@"1.0" forKey:@"oauth_version"];  
    
    return oauthParameters;
}


NSString * YOAuthv1GetURLBaseString(NSString * url)
{
    /*
     3.4.1.2.  Base String URI
     
     The scheme, authority, and path of the request resource URI [RFC3986]
     are included by constructing an "http" or "https" URI representing
     the request resource (without the query or fragment) as follows:
     
     1.  The scheme and host MUST be in lowercase.
     
     2.  The host and port values MUST match the content of the HTTP
     request "Host" header field.
     
     3.  The port MUST be included if it is not the default port for the
     scheme, and MUST be excluded if it is the default.  Specifically,
     the port MUST be excluded when making an HTTP request [RFC2616]
     to port 80 or when making an HTTPS request [RFC2818] to port 443.
     All other non-default port numbers MUST be included.
     
     For example, the HTTP request:
     
     GET /r%20v/X?id=123 HTTP/1.1
     Host: EXAMPLE.COM:80
     
     is represented by the base string URI: "http://example.com/r%20v/X".
     
     In another example, the HTTPS request:
     
     GET /?q=1 HTTP/1.1
     Host: www.example.net:8080
     
     is represented by the base string URI:
     "https://www.example.net:8080/".
     
     */
    
    /*construsting a new string is to ensure the base string URI is conforms to the OAuth 1.0 spec
     eg, url = @"api.douban.com?key=value", then base string should be @"http://api.douban.com/"
     */
    
    NSMutableString * baseString = [NSMutableString stringWithCapacity:32];
    [baseString setString:@""];
    
    NSString * scheme = [[url scheme] lowercaseString];
    if (nil == scheme) {
        scheme = @"http";
    }
    NSString * host = [[url host] lowercaseString];
    NSNumber * port = [url port];
    NSString * portString = @"";
    if (port) {
        if (([scheme isEqualToString:@"http"] && [port integerValue] != 80)
            || ([scheme isEqualToString:@"https"] && [port integerValue] != 443)) {
            portString = [NSString stringWithFormat:@":%d", [port integerValue]]; 
        }
    }
    NSString * relativeString = [url relativeString];
    [baseString appendFormat:@"%@://%@%@/%@", scheme, host, portString, relativeString];
    
    return baseString;
}


NSString * YOAuthv1GetSignatureBaseString(YOAuthv1SignatureMethod signatureMethod,
                                          NSString * requestMethod, 
                                          NSString * url,
                                          NSString * consumerKey, 
                                          NSString * token,
                                          NSNumber * timestamp,
                                          NSString * nonce,
                                          NSDictionary * postParameters,
                                          NSString * verifier,
                                          NSString * callback) //must be raw/decoded paramerters
{
    if (nil == requestMethod || nil == url) {
        return nil;
    }
    
    /*
     3.4.1.1.  String Construction
     
     The signature base string is constructed by concatenating together,
     in order, the following HTTP request elements:
     
     1.  The HTTP request method in uppercase.  For example: "HEAD",
     "GET", "POST", etc.  If the request uses a custom HTTP method, it
     MUST be encoded (Section 3.6).
     
     2.  An "&" character (ASCII code 38).
     
     3.  The base string URI from Section 3.4.1.2, after being encoded
     (Section 3.6).
     
     4.  An "&" character (ASCII code 38).
     
     5.  The request parameters as normalized in Section 3.4.1.3.2, after
     being encoded (Section 3.6).
     
     For example, the HTTP request:
     
     POST /request?b5=%3D%253D&a3=a&c%40=&a2=r%20b HTTP/1.1
     Host: example.com
     Content-Type: application/x-www-form-urlencoded
     Authorization: OAuth realm="Example",
     oauth_consumer_key="9djdj82h48djs9d2",
     oauth_token="kkk9d7dh3k39sjv7",
     oauth_signature_method="HMAC-SHA1",
     oauth_timestamp="137131201",
     oauth_nonce="7d8f3e4a",
     oauth_signature="bYT5CMsGcbgUdFHObYMEfcx6bsw%3D"
     
     c2&a3=2+q
     
     is represented by the following signature base string (line breaks
     are for display purposes only):
     
     POST&http%3A%2F%2Fexample.com%2Frequest&a2%3Dr%2520b%26a3%3D2%2520q
     %26a3%3Da%26b5%3D%253D%25253D%26c%2540%3D%26c2%3D%26oauth_consumer_
     key%3D9djdj82h48djs9d2%26oauth_nonce%3D7d8f3e4a%26oauth_signature_m
     ethod%3DHMAC-SHA1%26oauth_timestamp%3D137131201%26oauth_token%3Dkkk
     9d7dh3k39sjv7
     
     */
    NSString * str = nil;
    NSMutableString * signatureBaseString = [NSMutableString stringWithCapacity:32];
    str = [[requestMethod uppercaseString] yoauthv1EscapedString];
    [signatureBaseString setString:str];
    str = YOAuthv1GetURLBaseString(url);
    str = [str yoauthv1EscapedString];
    [signatureBaseString appendFormat:@"&%@", str];
    
    /*
     3.4.1.3.2.  Parameters Normalization
     
     The parameters collected in Section 3.4.1.3 are normalized into a
     single string as follows:
     
     1.  First, the name and value of each parameter are encoded
     (Section 3.6).
     
     2.  The parameters are sorted by name, using ascending byte value
     ordering.  If two or more parameters share the same name, they
     are sorted by their value.
     
     3.  The name of each parameter is concatenated to its corresponding
     value using an "=" character (ASCII code 61) as a separator, even
     if the value is empty.
     
     4.  The sorted name/value pairs are concatenated together into a
     single string by using an "&" character (ASCII code 38) as
     separator.
     */
    
    NSMutableDictionary * oauthParameters = [[NSMutableDictionary alloc] initWithCapacity:8];
    NSDictionary * parameters = [url queryParameters];
    if (parameters) {
        [oauthParameters addDuplicatableEntriesFromDictionary:[parameters oauthv1EscapedParameters]];
    }
    if (postParameters) {
        [oauthParameters addDuplicatableEntriesFromDictionary:[postParameters oauthv1EscapedParameters]];
    }
    
    parameters = YOAuthv1GetParameters(signatureMethod,
                                       requestMethod,
                                       consumerKey,
                                       token, 
                                       timestamp,
                                       nonce,
                                       verifier,
                                       callback);
    // Not using addDuplicatableEntriesFromDictionary 
    // to elimated duplicated oauth protocol parameters
    // (if existed unexpectedly)
    // if there is oauth_verifier or oauth_callback key ,they will be overrided
    [oauthParameters addEntriesFromDictionary:[parameters oauthv1EscapedParameters]];
    
    str = [oauthParameters oauthv1ConcatenatedSignatureParametersString];
    [signatureBaseString appendFormat:@"&%@", [str yoauthv1EscapedString]];
    
    YRELEASE_SAFELY(oauthParameters);
    
    return signatureBaseString;
}

@implementation NSString (YOAuthv1String)
/*
 3.6.  Percent Encoding
 
 Existing percent-encoding methods do not guarantee a consistent
 construction of the signature base string.  The following percent-
 encoding method is not defined to replace the existing encoding
 methods defined by [RFC3986] and [W3C.REC-html40-19980424].  It is
 used only in the construction of the signature base string and the
 "Authorization" header field.
 
 This specification defines the following method for percent-encoding
 strings:
 
 1.  Text values are first encoded as UTF-8 octets per [RFC3629] if
 they are not already.  This does not include binary values that
 are not intended for human consumption.
 
 2.  The values are then escaped using the [RFC3986] percent-encoding
 (%XX) mechanism as follows:
 
 *  Characters in the unreserved character set as defined by
 [RFC3986], Section 2.3 (ALPHA, DIGIT, "-", ".", "_", "~") MUST
 NOT be encoded.
 
 *  All other characters MUST be encoded.
 
 *  The two hexadecimal characters used to represent encoded
 characters MUST be uppercase.
 
 This method is different from the encoding scheme used by the
 "application/x-www-form-urlencoded" content-type (for example, it
 encodes space characters as "%20" and not using the "+" character).
 It MAY be different from the percent-encoding functions provided by
 web-development frameworks (e.g., encode different characters, use
 lowercase hexadecimal characters).
 */
- (NSString *)yoauthv1EscapedString 
{
    //    NSString * const nonescapedCharacters = (NSString *)CFSTR("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~");
    //this table is not support EBCDIC encoded system
#define _ 0
    static unsigned char nonescaped_map[256] =
    {// 0 1 2 3   4 5 6 7   8 9 A B   C D E f
        _,_,_,_,  _,_,_,_,  _,_,_,_,  _,_,_,_,// 0
        _,_,_,_,  _,_,_,_,  _,_,_,_,  _,_,_,_,// 1
        _,_,_,_,  _,_,_,_,  _,_,_,_,  _,1,1,_,// 2
        1,1,1,1,  1,1,1,1,  1,1,_,_,  _,_,_,_,// 3
        _,1,1,1,  1,1,1,1,  1,1,1,1,  1,1,1,1,// 4
        1,1,1,1,  1,1,1,1,  1,1,1,_,  _,_,_,1,// 5
        _,1,1,1,  1,1,1,1,  1,1,1,1,  1,1,1,1,// 6
        1,1,1,1,  1,1,1,1,  1,1,1,_,  _,_,1,_,// 7
        _,_,_,_,  _,_,_,_,  _,_,_,_,  _,_,_,_,// 8
        _,_,_,_,  _,_,_,_,  _,_,_,_,  _,_,_,_,// 9
        _,_,_,_,  _,_,_,_,  _,_,_,_,  _,_,_,_,// A
        _,_,_,_,  _,_,_,_,  _,_,_,_,  _,_,_,_,// B
        _,_,_,_,  _,_,_,_,  _,_,_,_,  _,_,_,_,// C
        _,_,_,_,  _,_,_,_,  _,_,_,_,  _,_,_,_,// D
        _,_,_,_,  _,_,_,_,  _,_,_,_,  _,_,_,_,// E
        _,_,_,_,  _,_,_,_,  _,_,_,_,  _,_,_,_,// F
    };
    
    NSMutableString * escapedString = [NSMutableString string];
    const char * cstring = [self cStringUsingEncoding:NSUTF8StringEncoding];
    if (cstring) {
        NSUInteger i = 0;
        
        unsigned char c = (unsigned char)*(cstring);
        while (c) {
            int nonescaped = nonescaped_map[c];
            if (nonescaped) {
                [escapedString appendFormat:@"%c", c];
            }
            else {
                [escapedString appendFormat:@"%%%2X", c];
            }
            i ++;
            c = (unsigned char)*(cstring + i);
        }
    }
    
    return escapedString;
}

@end

@implementation NSDictionary (OAuthv1Dictionary)

- (NSDictionary *)oauthv1EscapedParameters {
    //re-encode using OAuth 1.0 percent encoding
    NSMutableDictionary * newParameters = [[NSMutableDictionary alloc] initWithCapacity:[self count]];
    
    for (NSString * key in self) {
        id value = [self objectForKey:key];
        NSString * encodedKey = [key yoauthv1EscapedString];
        
        if (YIS_INSTANCE_OF(value, NSString)) {
            [newParameters addDuplicatableObject:[value yoauthv1EscapedString] forKey:encodedKey];
        }
        else if (YIS_INSTANCE_OF(value, NSSet)) {
            for (id item in value) {
                if (YIS_INSTANCE_OF(item, NSString)) {
                    [newParameters addDuplicatableObject:[item yoauthv1EscapedString] forKey:encodedKey];
                }
            }
        }
    }
    NSDictionary * parameters = [[newParameters copy] autorelease];
    YRELEASE_SAFELY(newParameters);
    return parameters;
}

/*
 3.4.1.3.2.  Parameters Normalization
 
 The parameters collected in Section 3.4.1.3 are normalized into a
 single string as follows:
 
 1.  First, the name and value of each parameter are encoded
 (Section 3.6).
 
 2.  The parameters are sorted by name, using ascending byte value
 ordering.  If two or more parameters share the same name, they
 are sorted by their value.
 
 3.  The name of each parameter is concatenated to its corresponding
 value using an "=" character (ASCII code 61) as a separator, even
 if the value is empty.
 
 4.  The sorted name/value pairs are concatenated together into a
 single string by using an "&" character (ASCII code 38) as
 separator.
 */


//all keys/values must be oauthv1 encoded, because keys must be encoded before sorting
- (NSString *)oauthv1ConcatenatedSignatureParametersString {
    NSMutableArray * sortedParameters = [NSMutableArray arrayWithCapacity:[self count]];
    NSArray * sortedKeys = [[self allKeys] sortedArrayUsingSelector:@selector(compare:)];
    for (NSString * key in sortedKeys) {
        id value = [self objectForKey:key];
        if (YIS_INSTANCE_OF(value, NSString)) {
            NSString * str = [NSString stringWithFormat:@"%@=%@", key, (NSString *)value];
            [sortedParameters addObject:str];
        }
        else if (YIS_INSTANCE_OF(value, NSSet)) {
            NSSortDescriptor * desc = [[[NSSortDescriptor alloc] initWithKey:@"self" ascending:YES selector:@selector(compare:)] autorelease];
            NSArray * sortDescriptors = [NSArray arrayWithObjects:desc ,nil];
            NSArray * values = [value sortedArrayUsingDescriptors:sortDescriptors];
            for (id item in values) {
                NSString * str = [NSString stringWithFormat:@"%@=%@", key, (NSString *)item];
                [sortedParameters addObject:str];
            }
        }
    }
    
    return [sortedParameters componentsJoinedByString:@"&"];
}
@end
