YToolkit for Cocoa
===========

What it includes
----------------

At the moment , the YToolkit includes a **base64 lib** (implemented in C, with NSData/NSString catetories), a handy **cocoa categories** lib, an  **oauth 1.0 & 2.0** lib (implemented in C function but using Cocoa object arguments, with **NSMutableURLRequest & [ASIHTTPRequest] categories**).

Besides, a demo for YToolkit is available from [ytoolkitdemo][] (which is including demos for signing in & retrieving basic data from **[Twitter]**, **[Facebook]**, **[Douban]**, **[Sina Weibo]**, **[QQ Weibo]**, etc).

[Twitter]: http://www.twitter.com
[Facebook]: http://www.facebook.com
[Douban]: http://www.douban.com
[Sina Weibo]: http://www.weibo.com
[QQ Weibo]: http://t.qq.com/

[ytoolkitdemo]: https://github.com/sprhawk/ytoolkitdemo

[ASIHTTPRequest]: https://github.com/pokeb/asi-http-request/tree


Why implementing again? 
-----------------------

* I have used some [OAuth] implementation for iOS, such as [OAuthConsumer], [OAuthCore], each of them has its pros and cons.
  > About one year and a half ago I started to learn iPhone development, I wanted to make a client for [douban.com][]. Then I tried [OAuthConsumer], after some hard work, I got [OAuthConsumer] working.
However, [OAuthConsumer] process network handling internally, with NSURLConnection. If I want to use the ASIHTTPRequest, it just can't help. Besides, [OAuthConsumer] simply handles error according to  OATicket object is nil or non-nil ( it assumes returned format is form-url-encoded), programmers cannot get the real reason why it can't work.
  > Then I turned to use [OAuthCore]. It is simply a C function, which generates a OAuth 1.0 Authorization Header, one can integrate it with any HTTP handling libs. But [OAuthCore] only generate OAuth 1.0 spec Authorization without an optional realm value, which may be required by a OAuth provider. 

So, I decide to re-implement it: **OAuth 1.0** and **2.0 (draft 22)**, following the spec as strictly as I could. 

* A base64 implementation is just for fun at the beginning. When I finished the code, I had a profiling among with NSData+Base64 (along with [OAuthCore]),  [josefsson's base64] (which is now a GNU CoreUtils implementation) and [libb64]. The NSData+Base64 is the slowest, and my implementation is the fastest (On Macbook pro and an iPod 3G). Although on a Mac, my implementation is not much faster than  [josefsson's base64] and [libb64], but on an iPod, it is faster enough (both on a Mac and iPod, tested for a nearly 1.5MB png file). (You can check the [benchmark] result)

[OAuth]: http://oauth.net/
[douban.com]: www.douban.com
[OAuthConsumer]: https://github.com/jdg/oauthconsumer
[OAuthCore]: https://github.com/atebits/OAuthCore
[josefsson's base64]: http://josefsson.org/base64/
[libb64]: http://libb64.sourceforge.net/
[benchmark]: https://github.com/sprhawk/ytoolkit/blob/master/BENCHMARK

What can I do with it?
--------------------

* The ytoolkit generates ybase64.a,  ybase64additions.a, yoauth.a, yoauthadditions.a, and ytoolkit.framework (statically linked faked framework.  Thanks to the [ios-Universal-Framework] project).  You can either use the lib(s) alone, or the framework. Just add ytoolkit project as a dependencies of your project, and link the libs. All required headers will be generated under {BUILT_PRODUCTS_DIR}/usr/local/include, you should add this path into your header search path (See how [ytoolkitdemo] does)

[ios-Universal-Framework]: https://github.com/kstenerud/iOS-Universal-Framework

* You can use its base64 lib, core is an pure C implementation, with NSString/NSData categories, which is handy under Cocoa foundation.
Just as:

```objective-c
    NSString * base64encoded = [data base64String];
```

or

```objective-c
    NSData * base64decode = [base64encodedString base64ToData];
```

* You can use some [cocoa additions], such as:
    * Parsing a URL string into component: scheme, host, relative, query, fragment. (similar functionalities than NSURL supplies is not working sometimes.
    * Handling escaped/unscaped URLs
    * Generating a URL's query from a dictionary's key/value pair, or get the parameters from a URL's query string
    * Adding duplicated key/value paires: when a key is existed, the addition will add a NSCountedSet object to contains the values

* You can use OAuth 1.0 and 2.0 (draft 22) lib or their Cocoa additions
  * If you are using NSMutableURLRequest of ASIHTTPRequest, just use the related additions
  * If you are using other request lib, just use yoauth lib to generate an oauth authorization header (OAuth 1.0) or an oauth parameters (OAuth 2.0), and set them as spec accordingly.
  * Just see the [ytoolkitdemo] for usage example of most popular sites

[cocoa additions]: https://github.com/sprhawk/ytoolkit/tree/master/ycocoaadditions/code

License
--------------------

The core of ytoolkit is distributed under [LGPL v3.0], you can freely link ytoolkit against any part of your program.

Except that, the ASIHTTPRequest additions are under FreeBSD license, you can use it without any restrictions ( Because this ASIHTTPRequest may be compiled into your project)

[LGPL v3.0]: http://www.gnu.org/licenses/lgpl.html

Hope this is useful for you.
===============


