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
