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