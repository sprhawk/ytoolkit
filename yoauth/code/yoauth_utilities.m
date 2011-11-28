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


#import "yoauth_utilities.h"
#import "ybase64additions.h"

NSString * YGetUUID(void) 
{
    CFUUIDRef uuid = CFUUIDCreate(NULL);
    if (uuid) {
        CFStringRef string = CFUUIDCreateString(NULL, uuid);
        CFRelease(uuid);
        return [((NSString *)string) autorelease];
    }
    return nil;
}

NSString * YGetAuthenticateBasicSchemeHeader(NSString * username, NSString * password)
{
    NSString * pair = [NSString stringWithFormat:@"%@:%@", username?username:@"", password?password:@""];
    NSData * pairData = [pair dataUsingEncoding:NSUTF8StringEncoding];
    NSString * base64 = [pairData base64String];
    return [NSString stringWithFormat:@"Basic %@", base64];
}