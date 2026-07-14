//
//  XZKit.h
//  XZKit
//
//  Created by Xezun on 2025/7/10.
//

#import <Foundation/Foundation.h>

//! Project version number for XZKit.
FOUNDATION_EXPORT double XZKitVersionNumber;

//! Project version string for XZKit.
FOUNDATION_EXPORT const unsigned char XZKitVersionString[];

#if COCOAPODS

#import <XZKit/XZKit-umbrella.h>

#else

#if __has_include(<XZKit/XZLog.h>)
#import <XZKit/XZLog.h>
#elif __has_include("XZLog.h")
#import "XZLog.h"
#endif
#if __has_include(<XZKit/XZObjc.h>)
#import <XZKit/XZObjc.h>
#elif __has_include("XZObjc.h")
#import "XZObjc.h"
#endif
#if __has_include(<XZKit/XZDefines.h>)
#import <XZKit/XZDefines.h>
#elif __has_include("XZDefines.h")
#import "XZDefines.h"
#endif
#if __has_include(<XZKit/XZExtensions.h>)
#import <XZKit/XZExtensions.h>
#elif __has_include("XZExtensions.h")
#import "XZExtensions.h"
#endif

#if __has_include(<XZKit/XZURL.h>)
#import <XZKit/XZURL.h>
#elif __has_include("XZURL.h")
#import "XZURL.h"
#endif
#if __has_include(<XZKit/XZGeometry.h>)
#import <XZKit/XZGeometry.h>
#elif __has_include("XZGeometry.h")
#import "XZGeometry.h"
#endif
#if __has_include(<XZKit/XZImage.h>)
#import <XZKit/XZImage.h>
#elif __has_include("XZImage.h")
#import "XZImage.h"
#endif

#if __has_include(<XZKit/XZJSON.h>)
#import <XZKit/XZJSON.h>
#elif __has_include("XZJSON.h")
#import "XZJSON.h"
#endif
#if __has_include(<XZKit/XZLocale.h>)
#import <XZKit/XZLocale.h>
#elif __has_include("XZLocale.h")
#import "XZLocale.h"
#endif
#if __has_include(<XZKit/XZDataCryptor.h>)
#import <XZKit/XZDataCryptor.h>
#elif __has_include("XZDataCryptor.h")
#import "XZDataCryptor.h"
#endif
#if __has_include(<XZKit/XZDataDigester.h>)
#import <XZKit/XZDataDigester.h>
#elif __has_include("XZDataDigester.h")
#import "XZDataDigester.h"
#endif
#if __has_include(<XZKit/XZKeychain.h>)
#import <XZKit/XZKeychain.h>
#elif __has_include("XZKeychain.h")
#import "XZKeychain.h"
#endif

#if __has_include(<XZKit/XZML.h>)
#import <XZKit/XZML.h>
#elif __has_include("XZML.h")
#import "XZML.h"
#endif
#if __has_include(<XZKit/XZMocoa.h>)
#import <XZKit/XZMocoa.h>
#elif __has_include("XZMocoa.h")
#import "XZMocoa.h"
#endif
#if __has_include(<XZKit/XZToast.h>)
#import <XZKit/XZToast.h>
#elif __has_include("XZToast.h")
#import "XZToast.h"
#endif
#if __has_include(<XZKit/XZRefresh.h>)
#import <XZKit/XZRefresh.h>
#elif __has_include("XZRefresh.h")
#import "XZRefresh.h"
#endif

#if __has_include(<XZKit/XZPageView.h>)
#import <XZKit/XZPageView.h>
#elif __has_include("XZPageView.h")
#import "XZPageView.h"
#endif
#if __has_include(<XZKit/XZPageControl.h>)
#import <XZKit/XZPageControl.h>
#elif __has_include("XZPageControl.h")
#import "XZPageControl.h"
#endif
#if __has_include(<XZKit/XZSegmentedControl.h>)
#import <XZKit/XZSegmentedControl.h>
#elif __has_include("XZSegmentedControl.h")
#import "XZSegmentedControl.h"
#endif

#endif
