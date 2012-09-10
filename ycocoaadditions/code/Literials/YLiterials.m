//
//  Literials.m
//  ytoolkit
//
//  Created by YANG HONGBO on 2012-9-10.
//  Copyright (c) 2012年 Douban Inc. All rights reserved.
//

#import "YLiterials.h"

#if !defined(__IPHONE_6_0) || __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_6_0

@implementation NSArray (Literials)
- (id)objectAtIndexedSubscript:(NSUInteger)index
{
  return [self objectAtIndex:index];
}
@end

@implementation NSMutableArray (Literials)
- (void)setObject:(id)object atIndexedSubscript:(NSUInteger)index
{
  [self replaceObjectAtIndex:index withObject:object];
}
@end


@implementation NSDictionary (Literials)
- (id)objectForKeyedSubscript:(id)key
{
  return [self objectForKey:key];
}
@end

@implementation NSMutableDictionary (Literials)
- (void)setObject:(id)obj forKeyedSubscript:(id <NSCopying>)key
{
  [self setObject:obj forKey:key];
}
@end

#endif