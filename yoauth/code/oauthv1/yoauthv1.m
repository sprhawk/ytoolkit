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


