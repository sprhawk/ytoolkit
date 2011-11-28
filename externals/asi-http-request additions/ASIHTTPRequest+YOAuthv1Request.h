//Copyright 2011 Hongbo YANG (hongbo@yang.me). All rights reserved.
//
//Redistribution and use in source and binary forms, with or without modification, are
//permitted provided that the following conditions are met:
//
//1. Redistributions of source code must retain the above copyright notice, this list of
//conditions and the following disclaimer.
//
//2. Redistributions in binary form must reproduce the above copyright notice, this list
//of conditions and the following disclaimer in the documentation and/or other materials
//provided with the distribution.
//
//THIS SOFTWARE IS PROVIDED BY Hongbo YANG ''AS IS'' AND ANY EXPRESS OR IMPLIED
//WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
//FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL Hongbo YANG OR
//CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
//CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
//SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
//ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
//NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
//ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
//The views and conclusions contained in the software and documentation are those of the
//authors and should not be interpreted as representing official policies, either expressed
//or implied, of Hongbo YANG.

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
