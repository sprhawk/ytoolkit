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
#include "ydefines.h"

typedef enum YOAuthv1SignatureMethod {
    YOAuthv1SignatureMethodPlainText,
    YOAuthv1SignatureMethodHMAC_SHA1,
    YOAuthv1SignatureMethodRSA_SHA1,
}YOAuthv1SignatureMethod;

YEXTERN NSString * const YOAuthv1OAuthCallbackKey;
YEXTERN NSString * const YOAuthv1OAuthCallbackConfirmedKey;
YEXTERN NSString * const YOAuthv1OAuthVerifierKey;
YEXTERN NSString * const YOAuthv1OAuthTokenKey;
YEXTERN NSString * const YOAuthv1OAuthTokenSecretKey;

YEXTERN NSString * const YOAuthv1OAuthSignatureMethodKey;
YEXTERN NSString * const YOAuthv1OAuthSignatureKey;
YEXTERN NSString * const YOAuthv1OAuthConsumerKeyKey;
YEXTERN NSString * const YOAuthv1OAuthTimestampKey;
YEXTERN NSString * const YOAuthv1OAuthNonceKey;

YEXTERN NSDictionary * YOAuthv1GetSignedProtocolParameters( IN YOAuthv1SignatureMethod signatureMethod,
                                                            IN NSString * requestMethod, 
                                                            IN NSString * url,
                                                            IN NSString * consumerKey,
                                                            IN NSString * consumerSecret,
                                                            IN NSData   * pkcs12PrivateKey,
                                                            IN NSString * token,
                                                            IN NSString * tokenSecret,
                                                            IN NSNumber * timestamp,
                                                            IN NSString * nonce,
                                                            IN NSDictionary * parameters,
                                                           IN NSString * verifier,
                                                           IN NSString * callback);//for post parameters or additional parameters such as verifier or callback

// "old version of oauth.py (Douban is using) requires an 'OAuth realm=' format pattern
// So, the realm should be specified (even @"")
YEXTERN NSString * YOAuthv1GetAuthorizationHeader( IN YOAuthv1SignatureMethod signatureMethod,
                                                   IN NSString * requestMethod, 
                                                   IN NSString * url,
                                                   IN NSString * consumerKey,
                                                   IN NSString * consumerSecret,
                                                   IN NSData   * pkcs12PrivateKey,
                                                   IN NSString * token,
                                                   IN NSString * tokenSecret,
                                                   IN NSNumber * timestamp,
                                                   IN NSString * nonce,
                                                   IN NSString * realm,
                                                  IN NSDictionary * parameters,
                                                  IN NSString * verifier,
                                                  IN NSString * callback);


// combined all the request parameters in url and postParameters 
// along with oauth protocol parameters
YEXTERN NSDictionary * YOAuthv1GetSignedRequestParameters( IN YOAuthv1SignatureMethod signatureMethod,
                                                           IN NSString * requestMethod, 
                                                           IN NSString * url,
                                                           IN NSString * consumerKey,
                                                           IN NSString * consumerSecret,
                                                           IN NSData   * pkcs12PrivateKey,
                                                           IN NSString * token,
                                                           IN NSString * tokenSecret,
                                                           IN NSNumber * timestamp,
                                                           IN NSString * nonce,
                                                          IN NSDictionary * parameters,
                                                          IN NSString * verifier,
                                                          IN NSString * callback);

// Only combined postParameters with oauth protocol parameters if you want to post content 
// to a URL with query parameters.
// The oauth signature is still generated with all parameters(in url and post body)
// eg, POST http://api.doubn.com/note?id=11111
// post body: title=test&body=testtest
// This function will return {'title':'test', 'body':'testtest'},
// The signature will still combined with: body=testtest&id=11111&title=test
YEXTERN NSDictionary * YOAuthv1GetSignedPostRequestParameters( IN YOAuthv1SignatureMethod signatureMethod,
                                                               IN NSString * requestMethod, 
                                                               IN NSString * url,
                                                               IN NSString * consumerKey,
                                                               IN NSString * consumerSecret,
                                                               IN NSData   * pkcs12PrivateKey,
                                                               IN NSString * token,
                                                               IN NSString * tokenSecret,
                                                               IN NSNumber * timestamp,
                                                               IN NSString * nonce,
                                                              IN NSDictionary * parameters,
                                                              IN NSString * verifier,
                                                              IN NSString * callback);


