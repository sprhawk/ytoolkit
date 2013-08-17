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
