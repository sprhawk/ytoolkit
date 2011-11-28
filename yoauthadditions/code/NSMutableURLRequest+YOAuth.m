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

#import "NSMutableURLRequest+YOAuth.h"

#import "NSString+YHTTPURLString.h"
#import "NSDictionary+YHTTPURLDictionary.h"
#import "YOAuthv1.h"
#import "ymacros.h"


@implementation NSMutableURLRequest (YOAuth)

- (NSDictionary *)postParametersForOAuthv1 {
    NSDictionary * postParameters = nil;
    NSString * contentType = [self valueForHTTPHeaderField:@"Content-Type"];
    
    if(nil == [self HTTPBodyStream] && [contentType hasPrefix:@"application/x-www-form-urlencoded"]) {
        NSString * encodedQuery = [[[NSString alloc] initWithData:self.HTTPBody
                                                         encoding:NSUTF8StringEncoding] 
                                   autorelease];
        postParameters = [encodedQuery queryParameters];
    }
    return postParameters;
}

- (void)prepareOAuthv1RequestUsingConsumerKey:(NSString *)consumerKey 
                            consumerSecretKey:(NSString *)consumerSecretKey
                                        token:(NSString *)token
                                  tokenSecret:(NSString *)tokenSecret
                                        realm:(NSString *)realm
{
    [self prepareOAuthv1RequestUsingConsumerKey:consumerKey
                              consumerSecretKey:consumerSecretKey
                                          token:token
                                    tokenSecret:tokenSecret
                                          realm:realm
                                       verifier:nil
                                       callback:nil];
}

- (void)prepareOAuthv1AuthorizationHeaderUsingConsumerKey:(NSString *)consumerKey 
                                        consumerSecretKey:(NSString *)consumerSecretKey
                                                    token:(NSString *)token
                                              tokenSecret:(NSString *)tokenSecret
                                          signatureMethod:(YOAuthv1SignatureMethod)method
                                                    realm:(NSString *)realm
                                                 verifier:(NSString *)verifier
                                                 callback:(NSString *)callback
{
    NSDictionary * postParameters = [self postParametersForOAuthv1];
    NSString *header = YOAuthv1GetAuthorizationHeader(method,
                                                      self.HTTPMethod,
                                                      [[self URL] absoluteString],
                                                      consumerKey, 
                                                      consumerSecretKey,
                                                      nil,
                                                      token, 
                                                      tokenSecret, 
                                                      nil, 
                                                      nil,
                                                      realm,
                                                      postParameters,
                                                      verifier,
                                                      callback);
    [self addValue:header forHTTPHeaderField:@"Authorization"];
}


- (void)prepareOAuthv1FormRequestUsingConsumerKey:(NSString *)consumerKey 
                                consumerSecretKey:(NSString *)consumerSecretKey
                                            token:(NSString *)token
                                      tokenSecret:(NSString *)tokenSecret
                                  signatureMethod:(YOAuthv1SignatureMethod)method
                                         verifier:(NSString *)verifier
                                         callback:(NSString *)callback

{
    NSDictionary * postParameters = [self postParametersForOAuthv1];
    
    NSDictionary * parameters = YOAuthv1GetSignedPostRequestParameters(method,
                                                                       self.HTTPMethod,
                                                                       [[self URL] absoluteString],
                                                                       consumerKey, 
                                                                       consumerSecretKey,
                                                                       nil,
                                                                       token, 
                                                                       tokenSecret, 
                                                                       nil, 
                                                                       nil, 
                                                                       postParameters,
                                                                       verifier,
                                                                       callback);
    //maybe ContentType != "application/x-www-form-urlencoded", or there is not any parameters
    if (nil == postParameters) {
        if (self.HTTPBody) {
            // the contentType is not "application/x-www-form-urlencoded"
            @throw NSInvalidArgumentException;
            return;
        }
    }
    
    NSString * body = [parameters queryString];
    [self setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
}

- (void)prepareOAuthv1QueryURIUsingConsumerKey:(NSString *)consumerKey 
                             consumerSecretKey:(NSString *)consumerSecretKey
                                         token:(NSString *)token
                                   tokenSecret:(NSString *)tokenSecret
                               signatureMethod:(YOAuthv1SignatureMethod)method
                                      verifier:(NSString *)verifier
                                      callback:(NSString *)callback

{
    NSString * urlString = [[self URL] absoluteString];
    NSDictionary * parameters = YOAuthv1GetSignedRequestParameters(method,
                                                                   [self HTTPMethod],
                                                                   urlString,
                                                                   consumerKey, 
                                                                   consumerSecretKey,
                                                                   nil,
                                                                   token, 
                                                                   tokenSecret, 
                                                                   nil, 
                                                                   nil,
                                                                   nil,
                                                                   verifier,
                                                                   callback);
    NSString * newString = [urlString URLStringByAddingParameters:parameters];
    NSURL * newURL = [NSURL URLWithString:newString];
    self.URL = newURL;    
}

- (void)prepareOAuthv1FormRequestUsingConsumerKey:(NSString *)consumerKey 
                                consumerSecretKey:(NSString *)consumerSecretKey
                                            token:(NSString *)token
                                      tokenSecret:(NSString *)tokenSecret
                                         verifier:(NSString *)verifier
                                         callback:(NSString *)callback

{
    [self prepareOAuthv1FormRequestUsingConsumerKey:consumerKey
                                  consumerSecretKey:consumerSecretKey
                                              token:token 
                                        tokenSecret:tokenSecret
                                    signatureMethod:YOAuthv1SignatureMethodHMAC_SHA1
                                           verifier:verifier 
                                           callback:callback];
}

- (void)prepareOAuthv1QueryURIUsingConsumerKey:(NSString *)consumerKey 
                             consumerSecretKey:(NSString *)consumerSecretKey
                                         token:(NSString *)token
                                   tokenSecret:(NSString *)tokenSecret
                                      verifier:(NSString *)verifier
                                      callback:(NSString *)callback

{
    [self prepareOAuthv1QueryURIUsingConsumerKey:consumerKey
                               consumerSecretKey:consumerSecretKey
                                           token:token 
                                     tokenSecret:tokenSecret
                                 signatureMethod:YOAuthv1SignatureMethodHMAC_SHA1
                                        verifier:verifier 
                                        callback:callback];
}



- (void)prepareOAuthv1RequestUsingConsumerKey:(NSString *)consumerKey 
                            consumerSecretKey:(NSString *)consumerSecretKey
                                        token:(NSString *)token
                                  tokenSecret:(NSString *)tokenSecret
                                        realm:(NSString *)realm
                                     verifier:(NSString *)verifier
                                     callback:(NSString *)callback

{
    [self prepareOAuthv1AuthorizationHeaderUsingConsumerKey:consumerKey
                                          consumerSecretKey:consumerSecretKey
                                                      token:token 
                                                tokenSecret:tokenSecret
                                                      realm:realm
                                                   verifier:verifier 
                                                   callback:callback];
}

- (void)prepareOAuthv1AuthorizationHeaderUsingConsumerKey:(NSString *)consumerKey 
                                        consumerSecretKey:(NSString *)consumerSecretKey
                                                    token:(NSString *)token
                                              tokenSecret:(NSString *)tokenSecret
                                                    realm:(NSString *)realm
                                                 verifier:(NSString *)verifier
                                                 callback:(NSString *)callback

{
    [self prepareOAuthv1AuthorizationHeaderUsingConsumerKey:consumerKey
                                          consumerSecretKey:consumerSecretKey
                                                      token:token 
                                                tokenSecret:tokenSecret
                                            signatureMethod:YOAuthv1SignatureMethodHMAC_SHA1
                                                      realm:realm
                                                   verifier:verifier 
                                                   callback:callback];
}

@end
