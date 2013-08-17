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


#ifndef ybase64_h
#define ybase64_h

#include "ydefines.h"

//typedef void (*ybase64_write_callback)(const void * data, 
//                                 const size_t len, 
//                                 const void * context);
//
//typedef size_t (*ybase64_read_callback)(const void * data, 
//                                        const size_t max, 
//                                        const size_t to_read
//                                        const void * context);

//version: 0.9
#define YBASE64_VERSION_MAJOR 0
#define YBASE64_VERSION_MINOR 9

YEXTERN size_t ybase64_encode( IN const void * from, 
                              IN const size_t from_len,
                              OUT void * to, 
                              IN const size_t to_len);
YEXTERN void * ybase64_encode_alloc( IN const void * from, 
                              IN const size_t from_len,
                                    OUT size_t *to_len);
YEXTERN size_t ybase64_decode( IN const char * from, //input must be an Base64 encoded text
                              IN const size_t strlen,  // must be a string length, (minus \0)
                              OUT void * to, 
                              IN const size_t to_len);
YEXTERN void * ybase64_decode_alloc( IN const void * from, 
                                    IN const size_t from_len,
                                    OUT size_t *to_len);
YEXTERN void ybase64_free(IN void * p);
#endif
