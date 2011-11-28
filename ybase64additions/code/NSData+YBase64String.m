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


#import "NSData+YBase64String.h"
#import "ybase64.h"

@implementation NSData (YBase64String)
- (NSString *)base64String
{
    size_t len = ybase64_encode(self.bytes, self.length, NULL, 0);
    void * stringData = malloc(len);
    len = ybase64_encode(self.bytes, self.length, stringData, len);
    NSString * s = [NSString stringWithUTF8String:stringData];
    free(stringData);
    return s;
}
@end
