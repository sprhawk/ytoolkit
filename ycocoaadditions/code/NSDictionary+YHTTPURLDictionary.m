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
