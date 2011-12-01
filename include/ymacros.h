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

#define YRELEASE_SAFELY(_x) if(_x){[(_x) release];_x=nil;}
#define YIS_INSTANCE_OF(_x, _class) ([_x isKindOfClass:[_class class]])
#define INVALIDATE_TIMER(_x) if(_x){[(_x) invalidate];_x=nil;}
#define INVALIDATE_RELEASE_TIMER(_x) if(_x){[(_x) invalidate];[(_x) release];_x=nil;}

#define YLOG(xx, ...)  NSLog(@"%s(%d): " xx, __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)

#ifdef _DEBUG
#define YDEBUGLOG YLOG
#else
#define YDEBUGLOG ((void)0)
#endif

// for SenTests
#define YSHOULD_BE_BUT_RESULT(original, shouldbe, result) \
                @"process %@ result should be %@, but result is %@", original, shouldbe, result

#define YSOURCE_IS(__xx__) @"source is %@", __xx__

#endif
