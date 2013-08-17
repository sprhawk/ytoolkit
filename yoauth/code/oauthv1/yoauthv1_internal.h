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
#import "yoauthv1.h"

YEXTERN NSString * YOAuthv1GetURLBaseString(IN NSString * url);
YEXTERN NSString * YOAuthv1GetSignatureBaseString( IN YOAuthv1SignatureMethod signatureMethod,
                                                   IN NSString * requestMethod, 
                                                   IN NSString * url,
                                                   IN NSString * consumerKey, 
                                                   IN NSString * token,
                                                   IN NSNumber * timestamp,
                                                   IN NSString * nonce,
                                                  IN NSDictionary * parameters,
                                                  IN NSString * verifier,
                                                  IN NSString * callback);
YEXTERN NSString * YOAuthv1GetSignature( IN YOAuthv1SignatureMethod signatureMethod,
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

YEXTERN NSDictionary * YOAuthv1GetParameters( IN YOAuthv1SignatureMethod signatureMethod,
                                              IN NSString * requestMethod, 
                                              IN NSString * consumerKey,
                                              IN NSString * token,
                                              IN NSNumber * timestamp,
                                             IN NSString * nonce,
                                             IN NSString * verifier,
                                             IN NSString * callback);


@interface NSString (OAuthv1String)
- (NSString *)yoauthv1EscapedString;
@end

@interface NSDictionary (OAuthv1Dictionary)
- (NSDictionary *)oauthv1EscapedParameters;
- (NSString *)oauthv1ConcatenatedSignatureParametersString;
@end