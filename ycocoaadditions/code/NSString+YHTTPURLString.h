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
#import "ydefines.h"

@interface NSString (YHTTPURLString)
- (NSString *)URLStringByAddingParameters:(NSDictionary *)parameters ;
- (NSDictionary *)decodedUrlencodedParameters;
- (NSDictionary *)queryParameters ;

- (NSString *)escapedString ;
- (NSString *)unescapeString ;
- (NSString *)escapedStringWithoutWhitespace;
- (NSString *)urlencodedString;
- (NSString *)urldecodedString;
//Just decompose the string, not intend to validate the format of the URL
- (NSRange)schemeRange;
- (NSString *)scheme;

- (NSRange)hostRange;
- (NSString *)host;

- (NSRange)portRange;
- (NSNumber *)port;

- (NSRange)relativeRange;
- (NSString *)relativeString;

- (NSRange)queryRange;
- (NSString *)query;

//fragment is not in Unit Test
- (NSRange)fragmentRange ;
- (NSString *)fragment ;

//absolutePath is not in Unit Test
// NO absolutePathRange, because the absolute may be not exactly a part of the URL string, eg, @"/"
//- (NSRange)absolutePathRange;
- (NSString *)absolutePath NOTTESTED;

//requestURI is not in Unit Test
- (NSString *)requestURI NOTTESTED;

@end