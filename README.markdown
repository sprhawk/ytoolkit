YToolkit for Cocoa
===========
What's new
----------
2012-10-10
Added a binary ytoolkit.framework, which contains armv6, armv7 and armv7s arch lib
https://github.com/downloads/sprhawk/ytoolkit/ytoolkit.framework.zip

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
However, [OAuthConsumer] handles network with NSURLConnection internally. If I want to use the ASIHTTPRequest, it just can't help. Besides, [OAuthConsumer] simply handles error according to  OATicket object is nil or non-nil ( it assumes returned format is form-url-encoded), programmers cannot get the real reason why it can't work.

  > Then I turned to use [OAuthCore]. It is simply a C function, which generates a OAuth 1.0 Authorization Header, one can integrate it with any HTTP handling libs. But [OAuthCore] only generate OAuth 1.0 spec Authorization without an optional realm value, which may be required by a OAuth provider. 

    So, I decide to re-implement it: **OAuth 1.0** and **2.0 (draft 22)**, following the spec as strictly as I could. 

* A base64 implementation is just for fun at the beginning. When I finished the code, I had a profiling among NSData+Base64 (along with [OAuthCore]),  [josefsson's base64] (which is now a GNU CoreUtils implementation) and [libb64]. The NSData+Base64 is the slowest, and my implementation is the fastest (On Macbook pro and an iPod 3G). Although on a Mac, my implementation is not much faster than  [josefsson's base64] and [libb64], on an iPod, it is faster enough (both on a Mac and iPod, tested for a nearly 1.5MB png file). (You can check the [benchmark] result, or run the benchmark yourself in [ytoolkitdemo])

[OAuth]: http://oauth.net/
[douban.com]: www.douban.com
[OAuthConsumer]: https://github.com/jdg/oauthconsumer
[OAuthCore]: https://github.com/atebits/OAuthCore
[josefsson's base64]: http://josefsson.org/base64/
[libb64]: http://libb64.sourceforge.net/
[benchmark]: https://github.com/sprhawk/ytoolkit/blob/master/BENCHMARK

What can I do with it?
--------------------

* The ytoolkit generates ybase64.a,  ybase64additions.a, yoauth.a, yoauthadditions.a, and ytoolkit.framework (statically linked faked framework.  Thanks to the [ios-Universal-Framework] project).  You can either use the lib(s) , or the framework alone. Just add ytoolkit project as a dependencies of your project, and link the libs. All required headers will be generated under {BUILT_PRODUCTS_DIR}/usr/local/include, you should add this path into your header search path (See how [ytoolkitdemo] does). If you want to use the framework, just link against it, all required headers are just bundled in it.
  add 

  > -ObjC
  > -all_load

    linker flags into your project

[ios-Universal-Framework]: https://github.com/kstenerud/iOS-Universal-Framework

* You can only use its base64 lib, the core is a pure C implementation, with NSString/NSData categories, which is handy under Cocoa foundation.
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
  * With NSMutableURLRequest:

>  ```Objective-c
>    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://www.douban.com/service/auth/request_token"]];
>    
>    // "old version of oauth.py (Douban is using) requires an 'OAuth realm=' format pattern
>    // So, the realm should be specified (even @"")
>    [request prepareOAuthv1RequestUsingConsumerKey:kDoubanConsumerKey
>                                 consumerSecretKey:kDoubanConsumerSecretKey
>                                             token:nil
>                                       tokenSecret:nil
>                                             realm:kDoubanRealm
>                                          verifier:nil
>                                          callback:nil];
>    [NSURLConnection connectionWithRequest:request delegate:self];
>  ``` 

  * With [ASIHTTPRequest]:

>  ```Objective-c
>    NSURL * url = [NSURL URLWithString:@"http://api.douban.com/people/%40me/miniblog?alt=json"];
>    ASIHTTPRequest * request = [ASIHTTPRequest requestWithURL:url];
>    request.delegate = self;
>    [request prepareOAuthv1RequestUsingConsumerKey:kDoubanConsumerKey
>                                 consumerSecretKey:kDoubanConsumerSecretKey
>                                             token:self.accesstoken
>                                       tokenSecret:self.tokensecret
>                                             realm:kDoubanRealm];
>    [request startAsynchronous];
>  ```

  * Just see the [ytoolkitdemo] for usage example of most popular sites

[cocoa additions]: https://github.com/sprhawk/ytoolkit/tree/master/ycocoaadditions/code

  * new Objective-C literials which was available only in iOS6, the literials category could add the new feature to iOS below iOS SDK 6, so you can use:

>  ```Objective-C
>     NSArray * a = @[obj1, obj2, obj3];
>     id obj = a[0]; // this literial need a new method which is only available under iOS 6, the literial category added the missing methods to array/dictionary.
>  ```

License
--------------------

The core of ytoolkit is distributed under [LGPL v3.0], you can freely link ytoolkit against any part of your program.

Except that, the ASIHTTPRequest additions are under BSD license, you can use it without any restrictions ( Because this ASIHTTPRequest may be compiled into your project)

[LGPL v3.0]: http://www.gnu.org/licenses/lgpl.html

Hope this is useful for you.
===============

这里面有什么？
------------

一个快速的base64编码（纯C，及NSData/NSString的category），可以看项目页面的README和代码库里的benchmark，或者在ytoolkitdemo里跑profile

一个cocoa附加库（包括词典到URL query，URL query到词典，URL分解为scheme, host, relative path, query, fragment，包括一个可以放置重复key-value的DuplicatableDictionary），

一个完善的OAuthv1库（C函数实现，但使用cocoa对象作参数）及相对应的NSMutableURLRequest和ASIHTTPRequest的扩展，

一个OAuthv2库(结构同OAuthv1，但是由于OAuthv2比较简单，所以并没有什么代码）及OAuthv2 HTTP-MAC的扩展的实现（由于没有相应的服务器，所以没有测试）

[ytoolkitdemo]里包含了下列服务的登录和获取数据的demo：

Twitter(OAuthv1),

Facebook(OAuthv2),

豆瓣 (OAuthv1),

新浪微博(OAuth及OAuth 2都跑通了)

QQ微博(OAuthv1)

demo地址是
https://github.com/sprhawk/ytoolkitdemo


ytoolkit核心库是LGPLv3，ASIHTTPRequest的扩展未编译进核心库，使用BSD发布。ytoolkitdemo使用BSD发布。

