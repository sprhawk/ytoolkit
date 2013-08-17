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


#ifndef oauth_macros_h
#define oauth_macros_h

#ifndef __has_feature
#define __has_feature(x) 0
#endif

#if __has_feature(objc_arc)
  #define HAS_OBJC_ARC 1
#else
  #define HAS_OBJC_ARC 0
#endif

#define NON_OBJC_ARC !HAS_OBJC_ARC

#if HAS_OBJC_ARC
  #if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_5_0
    #define YASSIGN_WEAK assign
    #define YUNSAFE_UNRETAINED __unsafe_unretained
  #else
    #define YWEAK weak
    #define YUNSAFE_UNRETAINED 
  #endif

  #define YRETAIN_STRONG strong
  #define YBRIDGE  __bridge
  #define YRELEASE_SAFELY(_x) if(_x){_x=nil;}

#else 
  #define YBRIDGE
  #define YRETAIN_STRONG retain
  #define YASSIGN_WEAK assign
  #define YINVALIDATE_RELEASE_TIMER(_x) if(_x){[(_x) invalidate];[(_x) release];_x=nil;}
  #define YRELEASE_SAFELY(_x) if(_x){[(_x) release];_x=nil;}
  #define YUNSAFE_UNRETAINED 
#endif


#define YIS_INSTANCE_OF(_x, _class) ([_x isKindOfClass:[_class class]])
#define YIF_OBJECT_FOR_KEY_IS_INSTANCE_OF(OBJ, DICT, KEY, CLS) OBJ = [DICT objectForKey:KEY]; if(YIS_INSTANCE_OF(OBJ, CLS))

#define YINVALIDATE_TIMER(_x) if(_x){[(_x) invalidate];_x=nil;}

#define YDECL_NOTIFICATION(notification) extern NSString* const notification;
#define YIMPL_NOTIFICATION(notification) NSString* const notification = @#notification;

#define YLOCALIZED(macro) NSLocalizedString(@#macro, @#macro)

#define YLOG(xx, ...)  NSLog(@"%s(%d): " xx, __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)

#if defined(_DEBUG) || defined(DEBUG)
#define YDEBUGLOG YLOG
#else
#define YDEBUGLOG(xx, ...) ((void)0)
#endif

//from web/designer's hex color value to % value
#define YHEX_TO_FLOAT(x) ((float)0x##x * 1.0f / 255.0f)

// for SenTests
#define YSHOULD_BE_BUT_RESULT(original, shouldbe, result) \
                @"process %@ result should be %@, but result is %@", original, shouldbe, result

#define YSOURCE_IS(__xx__) @"source is %@", __xx__

#endif
