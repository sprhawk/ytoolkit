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
      [self buildPostBody];
        NSString * contentType = [formdataRequest.requestHeaders objectForKey:@"Content-Type"];
        
        //Not supported streamPostDataFromDisk, are you sure to sign a huge post data with OAuth?
        if (![formdataRequest shouldStreamPostDataFromDisk]
            && [contentType hasPrefix:@"application/x-www-form-urlencoded"]) {
            NSString * encodedQuery = [[[NSString alloc] initWithData:self.postBody 
                                                             encoding:NSUTF8StringEncoding] 
                                       autorelease];
            postParameters = [encodedQuery decodedUrlencodedParameters];
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
