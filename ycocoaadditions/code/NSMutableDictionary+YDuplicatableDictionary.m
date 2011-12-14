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


#import "NSMutableDictionary+YDuplicatableDictionary.h"
#import "ymacros.h"

@implementation NSMutableDictionary (YDuplicatableDictionary)

- (void)addDuplicatableObjectsAndKeys:(id)firstObject, ... 
{
    id eachObject;
    va_list argumentList;
    if (firstObject) 
    {
        va_start(argumentList, firstObject); // Start scanning for arguments after firstObject.
        id key = va_arg(argumentList, id);
        if (nil == key) {
            @throw NSInvalidArgumentException;
            return;
        }
        [self addDuplicatableObject:firstObject forKey:key];
        
        while ((eachObject = va_arg(argumentList, id))) {
            key = va_arg(argumentList, id);
            if (key) {
                [self addDuplicatableObject:eachObject forKey:key];
            }
            else {
                break;
            }
        }
        va_end(argumentList);
    }

}

- (void)addDuplicatableObject:(id)object forKey:(id)key 
{
    if (nil == object || nil == key) {
        @throw NSInvalidArgumentException;
    }
    id value = [self objectForKey:key];
    if (nil == value) {
        [self setObject:object forKey:key];
    }
    else {
        if (YIS_INSTANCE_OF(value, NSCountedSet)) {
            [value addObject:object];
        }
        else if (YIS_INSTANCE_OF(value, NSSet)) {
            NSCountedSet * set = [NSCountedSet setWithSet:value];
            [set addObject:object];
            [self setObject:set forKey:key];
        }
        else {
            NSCountedSet * set = [NSCountedSet setWithCapacity:2];
            [set addObject:value];
            [set addObject:object];
            [self setObject:set forKey:key];
        }
    }
}
- (void)addDuplicatableEntriesFromDictionary:(NSDictionary *)otherDictionary {
    if (nil == otherDictionary) {
        @throw NSInvalidArgumentException;
    }
    for (id key in otherDictionary) {
        id value = [otherDictionary objectForKey:key];
        [self addDuplicatableObject:value forKey:key];
    }
}

- (void)removeDuplicableObject:(id)object forKey:(id)key
{
    if (nil == object || nil == key) {
        @throw NSInvalidArgumentException;
    }
    
    id value = [self objectForKey:key];
    if (nil == value) {
        return ;
    }
    else {
        if (YIS_INSTANCE_OF(value, NSCountedSet)) {
            NSCountedSet * set = (NSCountedSet *)value;
            [set removeObject:object];
        }
        else if (YIS_INSTANCE_OF(value, NSSet)) {
            NSCountedSet * set = [NSCountedSet setWithSet:value];
            [set removeObject:object];
            [self setObject:set forKey:key];
        }
        else {
            [self removeObjectForKey:key];
        }
    }
}

#if NS_BLOCKS_AVAILABLE
- (void)enumerateDuplicableKeysAndObjectsUsingBlock:(void (^)(id, id, BOOL *))block 
{
    [self enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL * stop){
        if (YIS_INSTANCE_OF(obj, NSSet)) {
            for (id subObj in obj) {
                block(key, subObj, stop);
            }
        }
        else {
            block(key, obj, stop);
        }
    }];
}
#endif
@end
