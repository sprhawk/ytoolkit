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


#import "NSDictionary+YHTTPURLDictionary.h"
#import "NSString+YHTTPURLString.h"
#import "ymacros.h"

@implementation NSDictionary (YHTTPURLDictionary)
- (NSString *)queryString {
    NSMutableArray * parameterStrings = [NSMutableArray arrayWithCapacity:[self count]];
    for (NSString * key in self) { 
        id value = [self valueForKey:key];
        if (YIS_INSTANCE_OF(value, NSString)) {
            NSString * s = (NSString *)value;
            NSString * parameter;
            if ([s length] > 0) {//may be only a value, but no name/key
                parameter = [NSString stringWithFormat:@"%@=%@", 
                             [key urlencodedString], [s urlencodedString]];
            }
            else {
                parameter = [key urlencodedString];
            }
            [parameterStrings addObject:parameter];
        }
        else if (YIS_INSTANCE_OF(value, NSNumber)) {
            NSNumber * v = (NSNumber *)value;
            NSString * parameter = [NSString stringWithFormat:@"%@=%@",
                                    [key urlencodedString], [[v stringValue] urlencodedString]];
            [parameterStrings addObject:parameter];
        }
        else if (YIS_INSTANCE_OF(value, NSSet)) {
            NSArray * set = (NSArray *)value;
            NSString * encodedKey = [key urlencodedString];
            for (NSString * s in set) {
                NSString * parameter;
                if ([s length] > 0) {//may be only a value, but no name/key
                    parameter = [NSString stringWithFormat:@"%@=%@", 
                                 encodedKey, [s urlencodedString]];
                }
                else {
                    parameter = encodedKey;
                }
                [parameterStrings addObject:parameter];
            }
        }
    }
    if ([parameterStrings count]) {
        return [parameterStrings componentsJoinedByString:@"&"];
    }
    else {
        return @"";
    }
}
@end
