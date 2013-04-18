//
//  YHelper.m
//  ytoolkit
//
//  Created by YANG HONGBO on 2013-4-18.
//  Copyright (c) 2013年 Douban Inc. All rights reserved.
//

#import "YHelper.h"
#import <sys/xattr.h>

BOOL YAddSkipBackupAttributeToItemAtURL(NSURL *URL)
{
    if ([[NSFileManager defaultManager] fileExistsAtPath: [URL path]]) {
        //from iOS 5.0, iDevice can be backed up to iCloud. However, many cached files except under
        //  Caches directory which should not be backed up are synchronized to iCloud.(iOS 5.0开始
        //  iCloud，但并未考虑一些只需要本地缓存并不需要被iCloud同步的数据)
        //from iOS 5.0.1, Apple added a "com.apple.MobileBackup" attribute to file, which will
        //  instruct iCloud will not back up the file. Besides, a new App Store Review Guidelines
        //  announced that any cached files created by app should add that attribute. Otherwise,
        //  the app will be rejected. (iOS 5.0.1增加了com.apple.MobileBackup属性，指示不需要被iCloud同步。)
        //from iOS 5.1, another similar attribute (NSURLIsExcludedFromBackupKey) to file was added.
        //  (iOS 5.1新增加了同样功能的属性）
        
        //reference to http://developer.apple.com/library/ios/#qa/qa1719/_index.html
        
        if ((void*)&NSURLIsExcludedFromBackupKey) {
            
            NSError *error = nil;
            BOOL success = [URL setResourceValue: [NSNumber numberWithBool: YES]
                                          forKey: NSURLIsExcludedFromBackupKey error: &error];
            if(!success){
                NSLog(@"Error excluding %@ from backup %@", [URL lastPathComponent], error);
            }
            return success;
        }
        else {
            const char* filePath = [[URL path] fileSystemRepresentation];
            
            const char* attrName = "com.apple.MobileBackup";
            u_int8_t attrValue = 1;
            
            int result = setxattr(filePath, attrName, &attrValue, sizeof(attrValue), 0, 0);
            return result == 0;
        }
    }
    return NO;
}