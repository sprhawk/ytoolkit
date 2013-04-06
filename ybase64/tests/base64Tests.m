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


#import "base64Tests.h"
#import "ybase64.h"

@implementation base64Tests

// All code under test must be linked into the Unit Test bundle
- (void)testBase64Encode1
{
//    STAssertTrue((1 + 1) == 2, @"Compiler isn't feeling well today :-(");
    strcpy(message, "\x1\xa");
    l = ybase64_encode(message, 1, NULL, sizeof(encoded));
    STAssertTrue(5 == l, @"\"1\" should be encoded to 4 characters plus \\0");
    
    l = ybase64_encode(message, 1, encoded, sizeof(encoded));
    STAssertTrue(0 == strcmp(encoded, "AQ=="), @"'1' should be encoded \"AQ==\", result:%s", encoded);
    
    strcpy(message, "1\xa");
    len = strlen(message);
    l = ybase64_encode(message, len, encoded, sizeof(encoded));
    STAssertTrue(5 == l, @"\"1\" should be encoded to 4 characters plus \\0");
    l = ybase64_encode(message, len, encoded, sizeof(encoded));
    STAssertTrue(0 == strcmp(encoded, "MQo="), @"'1' should be encoded \"MQo=\", result:%s", encoded);
}

- (void)testBase64Encode2
{
    strcpy(message, "abcdefghijklmnopqrstuvwxyz\xa");
    len = strlen(message);
    l = ybase64_encode(message, len, encoded, sizeof(encoded));
    STAssertTrue(37 == l, @"\"abcdefghijklmnopqrstuvwxyz\\xa\" should be encoded to 37 characters plus \\0");
    
    l = ybase64_encode(message, len, encoded, sizeof(encoded));
    STAssertTrue(0 == strcmp(encoded, "YWJjZGVmZ2hpamtsbW5vcHFyc3R1dnd4eXoK"), @"\"abcdefghijklmnopqrstuvwxyz\\xa\" should be encoded \"YWJjZGVmZ2hpamtsbW5vcHFyc3R1dnd4eXoK\", result:%s", encoded);

}

- (void)testBase64Decode1
{
    strcpy(encoded, "AQ==");
    len = strlen(encoded);
    l = ybase64_decode(encoded, len, NULL, 0);
    STAssertTrue(1 == l, @"\"AQ==\" should be decode as 1, result len:%d", l);
    
    l = ybase64_decode(encoded, len, message, sizeof(message));
    STAssertTrue( 1 == message[0], @"\"AQ==\" should be decode as 1, result:0x%X", message[0]);
}

- (void)testBase64Decode2
{
    strcpy(encoded, "YWJjZGVmZ2hpamtsbW5vcHFyc3R1dnd4eXoK");
    len = strlen(encoded);
    l = ybase64_decode(encoded, len, NULL, 0);
    STAssertTrue(27 == l, @"\"YWJjZGVmZ2hpamtsbW5vcHFyc3R1dnd4eXoK\" should be decode as \"abcdefghijklmnopqrstuvwxyz\\xa\", result len:%d", l);
    
    l = ybase64_decode(encoded, len, message, sizeof(message));
    STAssertTrue( 0 == memcmp(message, "abcdefghijklmnopqrstuvwxyz\xa", 27), @"\"YWJjZGVmZ2hpamtsbW5vcHFyc3R1dnd4eXoK\" should be decode as \"abcdefghijklmnopqrstuvwxyz\\xa\", result:%s", message);
    
    strcpy(encoded, "a2tra2s=");
    len = strlen(encoded);
    l = ybase64_decode(encoded, len, NULL, 0);
    STAssertTrue(5 == l, @"\"a2tra2s=\" should be decode as \"kkkkk\", result len:%d", l);
    
    memset(message, 0, sizeof(message));
    l = ybase64_decode(encoded, len, message, sizeof(message));
    STAssertTrue( 0 == memcmp(message, "kkkkk", 5), @"\"a2tra2s=\" should be decode as \"kkkkk\", result:%s", message);
    
}

@end
