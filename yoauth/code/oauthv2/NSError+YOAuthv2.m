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

#import "NSError+YOAuthv2.h"

#import "NSString+YHTTPURLString.h"

NSString * const YOAuthv2ErrorKey = @"error";
NSString * const YOAuthv2ErrorInvalidRequest = @"invalid_request";
NSString * const YOAuthv2ErrorInvalidClient = @"invalid_client";
NSString * const YOAuthv2ErrorInvalidGrant = @"invalid_grant";
NSString * const YOAuthv2ErrorUnauthorizedClient = @"unauthorized_client";
NSString * const YOAuthv2ErrorAccessDenied = @"access_denied";
NSString * const YOAuthv2ErrorUnsupportedResponseType = @"unsupported_response_type";
NSString * const YOAuthv2ErrorInvalidScope = @"invalid_scope";
NSString * const YOAuthv2ErrorServerError = @"server_error";
NSString * const YOAuthv2ErrorTemporarilyUnavailable = @"temporarily_unavailable";

NSString * const YOAuthv2ErrorDescriptionKey = @"error_description";
NSString * const YOAuthv2ErrorURIKey = @"error_uri";

NSString * const YOAuthv2ErrorDomain = @"YToolkitOAuthv2ErrorDomain";

static NSString * const  kYOAuthv2ErrorLocalizedTable = @"ErrorLocalizedString";
static NSBundle * __YToolkitBundle = nil;
static NSUInteger __YOAuthv2ErrorHashCodeMap[YOAuthv2ErrorTypeCodeMax] = {0};

@implementation NSError (YOAuthv2)
+ (void)load {
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    __YOAuthv2ErrorHashCodeMap[YOAuthv2ErrorTypeCodeInvalidRequest] = [YOAuthv2ErrorInvalidRequest hash];
    __YOAuthv2ErrorHashCodeMap[YOAuthv2ErrorTypeCodeInvalidClient] = [YOAuthv2ErrorInvalidClient hash];
    __YOAuthv2ErrorHashCodeMap[YOAuthv2ErrorTypeCodeInvalidGrant] = [YOAuthv2ErrorInvalidGrant hash];
    __YOAuthv2ErrorHashCodeMap[YOAuthv2ErrorTypeCodeUnauthorizedClient] = [YOAuthv2ErrorUnauthorizedClient hash];
    __YOAuthv2ErrorHashCodeMap[YOAuthv2ErrorTypeCodeAccessDenied] = [YOAuthv2ErrorAccessDenied hash];
    __YOAuthv2ErrorHashCodeMap[YOAuthv2ErrorTypeCodeUnsupportedResponseType] = [YOAuthv2ErrorUnsupportedResponseType hash];
    __YOAuthv2ErrorHashCodeMap[YOAuthv2ErrorTypeCodeInvalidScope] = [YOAuthv2ErrorInvalidScope hash];
    __YOAuthv2ErrorHashCodeMap[YOAuthv2ErrorTypeCodeServerError] = [YOAuthv2ErrorServerError hash];
    __YOAuthv2ErrorHashCodeMap[YOAuthv2ErrorTypeCodeTemporarilyUnavailable] = [YOAuthv2ErrorTemporarilyUnavailable hash];
    NSString * bundlePath = [[NSBundle mainBundle] pathForResource:@"ytoolkit" ofType:@"bundle"];
    if (bundlePath) {
        __YToolkitBundle = [[NSBundle bundleWithPath:bundlePath] retain];
    }
    [pool release];
}

+ (NSError *)errorByCheckingOAuthv2RedirectURIParameters:(NSDictionary *)parameters
{
    NSString * errorType = [parameters objectForKey:YOAuthv2ErrorKey];
    if (errorType) {
        NSUInteger errorHash = [errorType hash];
        NSInteger errorCode = 0;
        for (; errorCode < YOAuthv2ErrorTypeCodeMax ; errorCode ++) {
            if (errorHash == __YOAuthv2ErrorHashCodeMap[errorCode]) {
                break;
            }
        }
        NSString * errorName = NSLocalizedStringFromTableInBundle(errorType, 
                                                                  kYOAuthv2ErrorLocalizedTable, 
                                                                  __YToolkitBundle, 
                                                                  errorType);
        NSMutableDictionary * userInfo = [NSMutableDictionary dictionaryWithCapacity:3];
      if (nil == errorName) {
        errorName = @"Unknown";
      }
        [userInfo setObject:errorName forKey:NSLocalizedDescriptionKey];
        [userInfo addEntriesFromDictionary:parameters];
        return [[self class] errorWithDomain:YOAuthv2ErrorDomain
                                        code:errorCode
                                    userInfo:userInfo];
    }
    
    
    return nil;
}
+ (NSError *)errorByCheckingOAuthv2RedirectURI:(NSString *)redirect_uri
{
    NSDictionary * parameters = [redirect_uri queryParameters];
    return [[self class] errorByCheckingOAuthv2RedirectURIParameters:parameters];
}
@end
