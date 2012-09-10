//
//  Literials.h
//  ytoolkit
//
//  Created by YANG HONGBO on 2012-9-10.
//  Copyright (c) 2012年 Douban Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#if !defined(__IPHONE_6_0) || __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_6_0

@interface NSArray (Literials)
- (id)objectAtIndexedSubscript:(NSUInteger)index;
@end

@interface NSMutableArray (Literials)
- (void)setObject:(id)object atIndexedSubscript:(NSUInteger)index;
@end


@interface NSDictionary (Literials)
- (id)objectForKeyedSubscript:(id)key;
@end

@interface NSMutableDictionary (Literials)
- (void)setObject:(id)obj forKeyedSubscript:(id <NSCopying>)key ;
@end


#endif
