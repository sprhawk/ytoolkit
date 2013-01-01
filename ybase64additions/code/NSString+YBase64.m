//
//  NSString+YBase64.m
//  ytoolkit
//
//  Created by YANG HONGBO on 2012-12-29.
//  Copyright (c) 2012年 Douban Inc. All rights reserved.
//

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