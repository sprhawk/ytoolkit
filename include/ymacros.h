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
#define YINVALIDATE_TIMER(_x) if(_x){[(_x) invalidate];_x=nil;}

#define YDECL_NOTIFICATION(notification) extern NSString* const notification;
#define YIMPL_NOTIFICATION(notification) NSString* const notification = @#notification;

#define YLOCALIZED(macro) NSLocalizedString(@#macro, @#macro)

#define YLOG(xx, ...)  NSLog(@"%s(%d): " xx, __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)

#ifdef _DEBUG
#define YDEBUGLOG YLOG
#else
#define YDEBUGLOG(xx, ...) ((void)0)
#endif

// for SenTests
#define YSHOULD_BE_BUT_RESULT(original, shouldbe, result) \
                @"process %@ result should be %@, but result is %@", original, shouldbe, result

#define YSOURCE_IS(__xx__) @"source is %@", __xx__

#endif
