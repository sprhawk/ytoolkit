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


#import <Foundation/Foundation.h>
#import "ydefines.h"

#import "NSError+YOAuthv2.h"

YEXTERN NSString * const YOAuthv2ResponseType;                              //response_type
YEXTERN NSString * const YOAuthv2AuthorizationCode;                         //code
YEXTERN NSString * const YOAuthv2ImplictGrant;                              //token

YEXTERN NSString * const YOAuthv2ClientId;                                  //client_id
YEXTERN NSString * const YOAuthv2ClientSecret;                              //client_secret
YEXTERN NSString * const YOAuthv2RedirectURI;                               //redirect_uri
YEXTERN NSString * const YOAuthv2Scope;                                     //scope
YEXTERN NSString * const YOAuthv2State;                                     //state

YEXTERN NSString * const YOAuthv2GrantType;                                 //grant_type
YEXTERN NSString * const YOAuthv2GrantTypeAuthorizationCode;                //authorization_code
YEXTERN NSString * const YOAuthv2GrantTypeResourceOwnerPasswordCredentials; //password
YEXTERN NSString * const YOAuthv2ResourceOwnerUsername;                     //username
YEXTERN NSString * const YOAuthv2ResourceOwnerPassword;                     //password
YEXTERN NSString * const YOAuthv2GrantTypeClientCredentials;                //client_credentials
YEXTERN NSString * const YOAuthv2GrantTypeRefreshToken;                     //refresh_token

YEXTERN NSString * const YOAuthv2AccessToken;                               //access_token
YEXTERN NSString * const YOAuthv2TokenType;                                 //token_type
YEXTERN NSString * const YOAuthv2ExpiresIn;                                 //expires_in
YEXTERN NSString * const YOAuthv2RefreshToken;                              //refresh_token

YEXTERN NSString * const YOAuthv2MacAlgorithmHmacSha1 ;                     //hmac-sha1
YEXTERN NSString * const YOAuthv2MacAlgorithmHmacSha256 ;                   //hmac-sha256


YEXTERN NSDictionary * YOAuthv2GetAccessTokenRequestParametersForAuthorizationCode( IN NSString *code, 
                                                                                   IN NSString *redirect_uri)  ;
YEXTERN NSDictionary * YOAuthv2GetAccessTokenRequestParametersForResourceOwnerPasswordCredentials( IN NSString *username, 
                                                                                                  IN NSString *password,
                                                                                                  IN NSString *scope) ;
YEXTERN NSDictionary * YOAuthv2GetAccessTokenRequestParametersForClientCredentials( IN NSString *scope) NOTTESTED ;
YEXTERN NSDictionary * YOAuthv2GetAccessTokenRequestParametersForRefreshToken( IN NSString *refresh_token,
                                                                              IN NSString *scope) NOTTESTED ;

YEXTERN NSString * YOAuthv2GetAuthorizationMACHeader( IN NSString * mac_identifier,
                                                               IN NSString * mac_key,
                                                               IN NSString * mac_algorithm,
                                                               IN NSTimeInterval age,
                                                               IN NSString * unique_string,
                                                               IN NSString * requestMethod,
                                                               IN NSString * host, //because this host should be the 
                                                                                   //HOST in HTTP header, may be 
                                                                                   //slightly different among 
                                                                                   //libraries? So have better to
                                                                                   //get host from the specific 
                                                                                   //request instance
                                                               IN NSString * url,
                                                               IN NSString * body,
                                                               IN NSString * extension,
                                                               IN NSString * bodyhash,//custom hash, if exists, will use this instead of internal calculation
                                                               IN NSString * mac) NOTTESTED ;//custom hash, if exists, will use this instead of internal calculation

@interface NSString (YOAuthv2)
- (NSString *)requestAuthorizationCodeUrlStringByAddingClientId:(NSString *)client_id
                                                    redirectURI:(NSString *)redirect_uri
                                                          scope:(NSString *)scope
                                                          state:(NSString *)state ;


- (NSString *)requestImplicitGrantUrlStringByAddingClientId:(NSString *)client_id
                                                redirectURI:(NSString *)redirect_uri
                                                      scope:(NSString *)scope
                                                      state:(NSString *)state ;

@end


