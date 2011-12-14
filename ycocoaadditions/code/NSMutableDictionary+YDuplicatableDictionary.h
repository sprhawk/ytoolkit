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


#import <Foundation/Foundation.h>

@interface NSMutableDictionary (YDuplicatableDictionary)
- (void)addDuplicatableEntriesFromDictionary:(NSDictionary *)otherDictionary;
- (void)addDuplicatableObject:(id)object forKey:(id)key;
- (void)addDuplicatableObjectsAndKeys:(id)firstObject, ... NS_REQUIRES_NIL_TERMINATION;
- (void)removeDuplicableObject:(id)object forKey:(id)key;
#if NS_BLOCKS_AVAILABLE
- (void)enumerateDuplicableKeysAndObjectsUsingBlock:(void (^)(id, id, BOOL *))block ;
#endif

@end
