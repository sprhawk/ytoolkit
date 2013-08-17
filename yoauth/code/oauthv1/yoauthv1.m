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


#import <CoreFoundation/CoreFoundation.h>
#import "ymacros.h"
#import "yoauthv1.h"
#import "NSString+YHTTPURLString.h"
#import "yoauthv1_internal.h"
#import "NSData+YBase64String.h"
#import "NSMutableDictionary+YDuplicatableDictionary.h"
#import "yoauth_utilities.h"
/*
 RFC 5849   OAuth 1.0
 http://tools.ietf.org/html/rfc5849
 Section 3.4 Signature
 
 */

NSString * const YOAuthv1OAuthCallbackKey = @"oauth_callback";
NSString * const YOAuthv1OAuthVerifierKey = @"oauth_verifier";
NSString * const YOAuthv1OAuthCallbackConfirmedKey = @"oauth_callback_confirmed";
NSString * const YOAuthv1OAuthTokenKey = @"oauth_token";
NSString * const YOAuthv1OAuthTokenSecretKey = @"oauth_token_secret";
NSString * const YOAuthv1OAuthSignatureKey = @"oauth_signature";
NSString * const YOAuthv1OAuthSignatureMethodKey = @"oauth_signature_method";
NSString * const YOAuthv1OAuthConsumerKeyKey = @"oauth_consumer_key";
NSString * const YOAuthv1OAuthTimestampKey = @"oauth_timestamp";
NSString * const YOAuthv1OAuthNonceKey = @"oauth_nonce";

NSDictionary * YOAuthv1GetSignedProtocolParameters(YOAuthv1SignatureMethod signatureMethod,
                                                   NSString * requestMethod, 
                                                   NSString * url,
                                                   NSString * consumerKey,
                                                   NSString * consumerSecret,
                                                   NSData   * pkcs12PrivateKey,
                                                   NSString * token,
                                                   NSString * tokenSecret,
                                                   NSNumber * timestamp,
                                                   NSString * nonce,
                                                   NSDictionary * parameters,
                                                   IN NSString * verifier,
                                                   IN NSString * callback)
{
    if (nil == timestamp && YOAuthv1SignatureMethodPlainText != signatureMethod) {
        NSTimeInterval ts = [[NSDate date] timeIntervalSince1970];
        timestamp = [NSNumber numberWithFloat:ts];
    }
    
    if (nil == nonce && YOAuthv1SignatureMethodPlainText != signatureMethod) {
        nonce = YGetUUID();
    }
    
    id oauthParameters = YOAuthv1GetParameters(signatureMethod,
                                               requestMethod,
                                               consumerKey,
                                               token,
                                               timestamp,
                                               nonce,
                                               verifier,
                                               callback);
    
    if (!YIS_INSTANCE_OF(oauthParameters, NSMutableDictionary)) {
        oauthParameters = [[oauthParameters mutableCopy] autorelease];
    }
    
    NSString * signature = YOAuthv1GetSignature(signatureMethod,
                                                requestMethod,
                                                url,
                                                consumerKey,
                                                consumerSecret,
                                                pkcs12PrivateKey,
                                                token,
                                                tokenSecret,
                                                timestamp,
                                                nonce,
                                                parameters,
                                                verifier,
                                                callback);
    if (signature) {
        [oauthParameters setObject:signature forKey:YOAuthv1OAuthSignatureKey];
    }
    
    return oauthParameters;
}


NSDictionary * YOAuthv1GetSignedPostRequestParameters(YOAuthv1SignatureMethod signatureMethod,
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
                                                      NSString * callback)
{
    NSDictionary * oauthParameters = YOAuthv1GetSignedProtocolParameters(signatureMethod,
                                                                         requestMethod,
                                                                         url,
                                                                         consumerKey,
                                                                         consumerSecret,
                                                                         pkcs12PrivateKey,
                                                                         token,
                                                                         tokenSecret,
                                                                         timestamp,
                                                                         nonce,
                                                                         postParameters,
                                                                         verifier,
                                                                         callback);
    
    NSMutableDictionary * requestParameters = [NSMutableDictionary dictionaryWithCapacity:
                                               [postParameters count]
                                               + [oauthParameters count]];
    
    [requestParameters addEntriesFromDictionary:postParameters];
    // Not using addDuplicatableEntriesFromDictionary 
    // to elimated duplicated oauth protocol parameters
    // (if existed unexpectedly)
    // if there are oauth_verifier or oauth_callback key ,they will be overrided
    [requestParameters addEntriesFromDictionary:oauthParameters];
    
    return requestParameters;
}

NSDictionary * YOAuthv1GetSignedRequestParameters(YOAuthv1SignatureMethod signatureMethod,
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
                                                  NSString * callback)
{
    NSDictionary * oauthParameters = YOAuthv1GetSignedProtocolParameters(signatureMethod,
                                                                         requestMethod,
                                                                         url,
                                                                         consumerKey,
                                                                         consumerSecret,
                                                                         pkcs12PrivateKey,
                                                                         token,
                                                                         tokenSecret,
                                                                         timestamp,
                                                                         nonce,
                                                                         postParameters,
                                                                         verifier,
                                                                         callback);
    NSDictionary * urlParameters = [url queryParameters];
    NSMutableDictionary * requestParameters = [NSMutableDictionary dictionaryWithCapacity:
                                               [postParameters count]
                                               + [oauthParameters count]
                                               + [urlParameters count]];
    
    [requestParameters addEntriesFromDictionary:urlParameters];
    [requestParameters addDuplicatableEntriesFromDictionary:postParameters];
    
    // Not using addDuplicatableEntriesFromDictionary 
    // to elimated duplicated oauth protocol parameters
    // (if existed unexpectedly)
    [requestParameters addEntriesFromDictionary:oauthParameters];
    
    return requestParameters;
}

NSString * YOAuthv1GetAuthorizationHeader(YOAuthv1SignatureMethod signatureMethod,
                                          NSString * requestMethod, 
                                          NSString * url,
                                          NSString * consumerKey,
                                          NSString * consumerSecret,
                                          NSData   * pkcs12PrivateKey,
                                          NSString * token,
                                          NSString * tokenSecret,
                                          NSNumber * timestamp,
                                          NSString * nonce,
                                          NSString * realm,
                                          NSDictionary * postParameters,
                                          NSString * verifier,
                                          NSString * callback)
{
    
     
    NSMutableString * authorizationHeader = [NSMutableString stringWithCapacity:256];
    [authorizationHeader setString:@"OAuth "];
    
    
    if (realm) {
        [authorizationHeader appendFormat:@"realm=\"%@\", ", realm];
    }
    NSDictionary * oauthParameters = YOAuthv1GetSignedProtocolParameters(signatureMethod,
                                                                         requestMethod,
                                                                         url,
                                                                         consumerKey,
                                                                         consumerSecret,
                                                                         pkcs12PrivateKey,
                                                                         token,
                                                                         tokenSecret,
                                                                         timestamp,
                                                                         nonce,
                                                                         postParameters,
                                                                         verifier,
                                                                         callback);
    
    NSMutableArray * parameters = [[NSMutableArray alloc] initWithCapacity:[oauthParameters count]];
    for (NSString * key in oauthParameters) {
        id value = [oauthParameters objectForKey:key];
        // if the value of a key (eg, consumer key) is omitted, but the protocol requires it,
        // parameters should contain a [NSNull null] object. However, currently, this object
        // is not needed/implemented
        if ([NSNull null] == value) {
            value = @"";
        }
        if (YIS_INSTANCE_OF(value, NSString)) {
            NSString * p = [NSString stringWithFormat:@"%@=\"%@\"", [key yoauthv1EscapedString], [value yoauthv1EscapedString]];
            [parameters addObject:p];
        }
        else if(YIS_INSTANCE_OF(value, NSNumber)) {
            NSString * p = [NSString stringWithFormat:@"%@=\"%d\"", [key yoauthv1EscapedString], [value integerValue]];
            [parameters addObject:p];
        }
    }
    [authorizationHeader appendString:[parameters componentsJoinedByString:@", "]];
    YRELEASE_SAFELY(parameters);
    return authorizationHeader;
}


