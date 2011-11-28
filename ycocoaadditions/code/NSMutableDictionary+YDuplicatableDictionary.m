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
        [self addDuplicatableObject:firstObject key:key];
        
        while ((eachObject = va_arg(argumentList, id))) {
            key = va_arg(argumentList, id);
            if (key) {
                [self addDuplicatableObject:eachObject key:key];
            }
            else {
                break;
            }
        }
        va_end(argumentList);
    }

}

- (void)addDuplicatableObject:(id)object key:(id)key 
{
    if (nil == object || nil == key) {
        @throw NSInvalidArgumentException;
    }
    if (key) {
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
}
- (void)addDuplicatableEntriesFromDictionary:(NSDictionary *)otherDictionary {
    for (id key in otherDictionary) {
        id value = [otherDictionary objectForKey:key];
        [self addDuplicatableObject:value key:key];
    }
}
@end
