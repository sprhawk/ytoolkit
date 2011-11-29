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

#ifndef oauth_timing_h
#define oauth_timing_h
#include <sys/time.h>

//CAUTION with Side Effect of Macros!!!!!

#define YTIMING_WITH_GETTIMEOFDAY_START() \
                    struct timeval t0,t1; \
                    gettimeofday(&t0, NULL); 

#define YTIMING_WITH_GETTIMEOFDAY_END() \
                    gettimeofday(&t1, NULL); \
                    double timing = (t1.tv_sec - t0.tv_sec) * 1000.0f + (t1.tv_usec - t0.tv_usec)*1.0f / 1000.0f; 

#define YTIMING_WITH_MACH_ABSOLUTE_TIME_INIT() \
                    mach_timebase_info_data_t timebaseInfo;\
                    mach_timebase_info(&timebaseInfo);

#define YTIMING_WITH_MACH_ABSOLUTE_TIME_START() \
                    uint64_t start, elapsed, elapsedNano;\
                    start = mach_absolute_time();

#define YTIMING_WITH_MACH_ABSOLUTE_TIME_END() \
                    elapsed = mach_absolute_time() - start;\
                    elapsedNano = elapsed * timebaseInfo.numer / timebaseInfo.denom; \
                    double timing = elapsedNano * 1.0 / 1000.0f / 1000.0f;


#define YTIMING( __times__, __XXX__, __info__, ...) \
{\
    if(__times__ > 0) { \
        YLOG(@"------------" __info__ "\ntiming results (%d rounds):\n", ##__VA_ARGS__, __times__); \
        double mean_timing = 0; \
        for (int i = 0; i < __times__; i ++ ) {\
            YTIMING_WITH_GETTIMEOFDAY_START() \
\
            __XXX__ \
\
            YTIMING_WITH_GETTIMEOFDAY_END() \
            YLOG(@"round %d: %f ms\n", i, timing); \
            mean_timing += timing; \
        } \
        mean_timing /= __times__; \
        YLOG(@"------------mean time:%f ms\n\n", mean_timing); \
    }\
}

#endif
