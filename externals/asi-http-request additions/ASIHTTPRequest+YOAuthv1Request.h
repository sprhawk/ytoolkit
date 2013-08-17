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

#import "ASIHTTPRequest.h"
#import <ytoolkit/yoauthv1.h>
// Note 1: Not support to sign a post data when YES == streamPostDataFromDisk.
//          "Are you sure to sign a huge post data with OAuth?"
// Note 2: "old version of oauth.py (which Douban is using currently) requires an 'OAuth realm=' format pattern
//          So, the realm MUST be specified (even @"")

@interface ASIHTTPRequest (YOAuthv1Request)
//easist way (use Authorization / HMAC-SHA1
- (void)prepareOAuthv1RequestUsingConsumerKey:(NSString *)consumerKey 
                            consumerSecretKey:(NSString *)consumerSecretKey
                                        token:(NSString *)token
                                  tokenSecret:(NSString *)tokenSecret
                                        realm:(NSString *)realm;


//Explictly use AuthorizationHeader to send oauth parameters
- (void)prepareOAuthv1AuthorizationHeaderUsingConsumerKey:(NSString *)consumerKey 
                                        consumerSecretKey:(NSString *)consumerSecretKey
                                                    token:(NSString *)token
                                              tokenSecret:(NSString *)tokenSecret
                                                    realm:(NSString *)realm;

- (void)prepareOAuthv1AuthorizationHeaderUsingConsumerKey:(NSString *)consumerKey 
                                        consumerSecretKey:(NSString *)consumerSecretKey
                                                    token:(NSString *)token
                                              tokenSecret:(NSString *)tokenSecret
                                          signatureMethod:(YOAuthv1SignatureMethod)method
                                                    realm:(NSString *)realm
                                                 verifier:(NSString *)verifier
                                                 callback:(NSString *)callback;

//Explictly use post body to send oauth parameters 
- (void)prepareOAuthv1FormRequestUsingConsumerKey:(NSString *)consumerKey 
                                consumerSecretKey:(NSString *)consumerSecretKey
                                            token:(NSString *)token
                                      tokenSecret:(NSString *)tokenSecret NOTTESTED;
// Only combined postParameters with oauth protocol parameters if you want to post content 
// to a URL with query parameters.
// The oauth signature is still be generated with all parameters(in url and post body)
// eg, POST http://api.douban.com/note?id=11111
// post body: title=test&body=testtest
// This function will return {'title':'test', 'body':'testtest'},
// The signature will still combined with: body=testtest&id=11111&title=test
- (void)prepareOAuthv1FormRequestUsingConsumerKey:(NSString *)consumerKey 
                                consumerSecretKey:(NSString *)consumerSecretKey
                                            token:(NSString *)token
                                      tokenSecret:(NSString *)tokenSecret
                                  signatureMethod:(YOAuthv1SignatureMethod)method
                                         verifier:(NSString *)verifier
                                         callback:(NSString *)callback NOTTESTED;

//Explictly use URI query string to send oauth parameters
- (void)prepareOAuthv1QueryURIUsingConsumerKey:(NSString *)consumerKey 
                             consumerSecretKey:(NSString *)consumerSecretKey
                                         token:(NSString *)token
                                   tokenSecret:(NSString *)tokenSecret;

- (void)prepareOAuthv1QueryURIUsingConsumerKey:(NSString *)consumerKey 
                             consumerSecretKey:(NSString *)consumerSecretKey
                                         token:(NSString *)token
                                   tokenSecret:(NSString *)tokenSecret
                               signatureMethod:(YOAuthv1SignatureMethod)method
                                      verifier:(NSString *)verifier
                                      callback:(NSString *)callback;

@end
