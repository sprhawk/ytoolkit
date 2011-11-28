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

#import "ydefines.h"

YEXTERN NSString * const YOAuthv2ErrorKey;                                  //error
YEXTERN NSString * const YOAuthv2ErrorInvalidRequest;                       //invalid_request
YEXTERN NSString * const YOAuthv2ErrorInvalidClient;                        //invalid_client
YEXTERN NSString * const YOAuthv2ErrorInvalidGrant;                         //invalid_grant
YEXTERN NSString * const YOAuthv2ErrorUnauthorizedClient;                   //unauthorized_client
YEXTERN NSString * const YOAuthv2ErrorAccessDenied;                         //access_denied
YEXTERN NSString * const YOAuthv2ErrorUnsupportedResponseType;              //unsupported_response_type
YEXTERN NSString * const YOAuthv2ErrorInvalidScope;                         //invalid_scope
YEXTERN NSString * const YOAuthv2ErrorServerError;                          //server_error
YEXTERN NSString * const YOAuthv2ErrorTemporarilyUnavailable;               //temporarily_unavailable

YEXTERN NSString * const YOAuthv2ErrorDescriptionKey;                       //error_description
YEXTERN NSString * const YOAuthv2ErrorURIKey;                               //error_uri

YEXTERN NSString * const YOAuthv2ErrorDomain;

typedef enum YOAuthv2ErrorTypeCode {
    YOAuthv2ErrorTypeCodeInvalidRequest,
    YOAuthv2ErrorTypeCodeInvalidClient,
    YOAuthv2ErrorTypeCodeInvalidGrant,
    YOAuthv2ErrorTypeCodeUnauthorizedClient,
    YOAuthv2ErrorTypeCodeAccessDenied,
    YOAuthv2ErrorTypeCodeUnsupportedResponseType,
    YOAuthv2ErrorTypeCodeInvalidScope,
    YOAuthv2ErrorTypeCodeServerError,
    YOAuthv2ErrorTypeCodeTemporarilyUnavailable,
    YOAuthv2ErrorTypeCodeMax
}YOAuthv2ErrorTypeCode;

@interface NSError (YOAuthv2)
+ (NSError *)errorByCheckingOAuthv2RedirectURI:(NSString *)redirect_uri;
+ (NSError *)errorByCheckingOAuthv2RedirectURIParameters:(NSDictionary *)parameters;
@end
