//
//Copyright (c) 2011, Hongbo Yang (hongbo@yang.me)
//All rights reserved.
//
//Redistribution and use in source and binary forms, with or without modification, are permitted 
//provided that the following conditions are met:
//
//Redistributions of source code must retain the above copyright notice, this list of conditions 
//and 
//the following disclaimer.
//
//Redistributions in binary form must reproduce the above copyright notice, this list of conditions
//and the following disclaimer in the documentation and/or other materials provided with the 
//distribution.
//
//Neither the name of the Hongbo Yang nor the names of its contributors may be used to endorse or 
//promote products derived from this software without specific prior written permission.
//
//THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR
//IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND 
//FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR 
//CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL 
//DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, 
//DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER 
//IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT 
//OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


#import "ASIHTTPRequest+YOAuthv1Request.h"
#import "ASIFormDataRequest.h"
#import <ytoolkit/NSString+YHTTPURLString.h>
#import <ytoolkit/NSDictionary+YHTTPURLDictionary.h>
#import <ytoolkit/yoauthv1.h>
#import <ytoolkit/ymacros.h>

@implementation ASIHTTPRequest (YOAuthv1Request)

- (NSDictionary *)postParametersForOAuthv1 {
    NSDictionary * postParameters = nil;
    if (YIS_INSTANCE_OF(self, ASIFormDataRequest)) {
        ASIFormDataRequest * formdataRequest = (ASIFormDataRequest *)self;
        NSString * contentType = [formdataRequest.requestHeaders objectForKey:@"Content-Type"];
        
        //Not supported streamPostDataFromDisk, are you sure to sign a huge post data with OAuth?
        if (![formdataRequest shouldStreamPostDataFromDisk]
            && [contentType hasPrefix:@"application/x-www-form-urlencoded"]) {
            NSString * encodedQuery = [[[NSString alloc] initWithData:self.postBody 
                                                             encoding:NSUTF8StringEncoding] 
                                       autorelease];
            postParameters = [encodedQuery queryParameters];
        }
    }
    return postParameters;
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
                                                      self.requestMethod,
                                                      self.url.absoluteString,
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
    [self addRequestHeader:@"Authorization" value:header];
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
                                                                       self.requestMethod,
                                                                       self.url.absoluteString,
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
        if (self.postBody) {
            // the contentType is not "application/x-www-form-urlencoded"
            @throw NSInvalidArgumentException;
            return;
        }
    }
    
    NSString * body = [parameters queryString];
    //Because ASIHTTPRequest's bodyData is MutableData, so set it accordingly.
    //But if the postdata is changed after the oauthv1 parameters added, the 
    //Signature will be changed
    NSMutableData * data = [[[body dataUsingEncoding:NSUTF8StringEncoding] mutableCopy]autorelease];
    [self setPostBody:data];
}

- (void)prepareOAuthv1QueryURIUsingConsumerKey:(NSString *)consumerKey 
                             consumerSecretKey:(NSString *)consumerSecretKey
                                         token:(NSString *)token
                                   tokenSecret:(NSString *)tokenSecret
                               signatureMethod:(YOAuthv1SignatureMethod)method
                                      verifier:(NSString *)verifier
                                      callback:(NSString *)callback
{
    NSString * urlString = self.url.absoluteString;
    NSDictionary * parameters = YOAuthv1GetSignedRequestParameters(method,
                                                                   self.requestMethod,
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
    self.url = newURL;    
}

- (void)prepareOAuthv1QueryURIUsingConsumerKey:(NSString *)consumerKey 
                             consumerSecretKey:(NSString *)consumerSecretKey
                                         token:(NSString *)token
                                   tokenSecret:(NSString *)tokenSecret
{
    [self prepareOAuthv1QueryURIUsingConsumerKey:consumerKey
                               consumerSecretKey:consumerSecretKey
                                           token:token 
                                     tokenSecret:tokenSecret
                                 signatureMethod:YOAuthv1SignatureMethodHMAC_SHA1
                                        verifier:nil 
                                        callback:nil];
}

- (void)prepareOAuthv1FormRequestUsingConsumerKey:(NSString *)consumerKey 
                                consumerSecretKey:(NSString *)consumerSecretKey
                                            token:(NSString *)token
                                      tokenSecret:(NSString *)tokenSecret
{
    [self prepareOAuthv1FormRequestUsingConsumerKey:consumerKey
                                  consumerSecretKey:consumerSecretKey
                                              token:token 
                                        tokenSecret:tokenSecret
                                    signatureMethod:YOAuthv1SignatureMethodHMAC_SHA1
                                           verifier:nil
                                           callback:nil];
}

- (void)prepareOAuthv1AuthorizationHeaderUsingConsumerKey:(NSString *)consumerKey 
                                        consumerSecretKey:(NSString *)consumerSecretKey
                                                    token:(NSString *)token
                                              tokenSecret:(NSString *)tokenSecret
                                                    realm:(NSString *)realm
{
    [self prepareOAuthv1AuthorizationHeaderUsingConsumerKey:consumerKey
                                          consumerSecretKey:consumerSecretKey
                                                      token:token 
                                                tokenSecret:tokenSecret
                                            signatureMethod:YOAuthv1SignatureMethodHMAC_SHA1
                                                      realm:realm
                                                   verifier:nil 
                                                   callback:nil];
}

- (void)prepareOAuthv1RequestUsingConsumerKey:(NSString *)consumerKey 
                            consumerSecretKey:(NSString *)consumerSecretKey
                                        token:(NSString *)token
                                  tokenSecret:(NSString *)tokenSecret
                                        realm:(NSString *)realm
{
    [self prepareOAuthv1AuthorizationHeaderUsingConsumerKey:consumerKey
                                          consumerSecretKey:consumerSecretKey
                                                      token:token 
                                                tokenSecret:tokenSecret
                                                      realm:realm];
}


@end
