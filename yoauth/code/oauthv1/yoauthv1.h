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
// The oauth signature is still be generated with all parameters(in url and post body)
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


