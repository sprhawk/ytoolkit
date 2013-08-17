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
        else if ([value isEqual:object]){
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
