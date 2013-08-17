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

#import "NSString+YBase64.h"
#import "ybase64.h"

@implementation NSString (YBase64)
- (NSString *)base64string
{
    const char * string = [self cStringUsingEncoding:NSUTF8StringEncoding];
    size_t len = strlen(string);
    size_t size = ybase64_encode(string, len, NULL, 0);
    char * newstring = (char *)malloc(size + 1);
    memset(newstring, 0, size + 1);
    len = ybase64_encode(string, len, newstring, size);
    NSString * nsstr = [NSString stringWithCString:newstring encoding:NSUTF8StringEncoding];
    free(newstring);
    newstring = NULL;
    return nsstr;
}
@end