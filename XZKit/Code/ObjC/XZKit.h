//
//  XZKit.h
//  XZKit
//
//  Created by 徐臻 on 2025/7/10.
//

#import <Foundation/Foundation.h>

//! Project version number for XZKit.
FOUNDATION_EXPORT double XZKitVersionNumber;

//! Project version string for XZKit.
FOUNDATION_EXPORT const unsigned char XZKitVersionString[];

#if __has_include(<XZKit/XZKit.h>)

#import <XZKit/XZLog.h>
#import <XZKit/XZDefines.h>
#import <XZKit/XZExtensions.h>

#import <XZKit/XZURLQuery.h>
#import <XZKit/XZGeometry.h>
#import <XZKit/XZImage.h>
#import <XZKit/XZObjcDescriptor.h>

#import <XZKit/XZJSON.h>
#import <XZKit/XZLocale.h>
#import <XZKit/XZDataCryptor.h>
#import <XZKit/XZDataDigester.h>
#import <XZKit/XZKeychain.h>

#import <XZKit/XZML.h>
#import <XZKit/XZMocoa.h>
#import <XZKit/XZToast.h>
#import <XZKit/XZRefresh.h>

#import <XZKit/XZPageView.h>
#import <XZKit/XZPageControl.h>
#import <XZKit/XZSegmentedControl.h>

#else

#import "XZLog.h"
#import "XZDefines.h"
#import "XZExtensions.h"

#import "XZURLQuery.h"
#import "XZGeometry.h"
#import "XZImage.h"
#import "XZObjcDescriptor.h"

#import "XZJSON.h"
#import "XZLocale.h"
#import "XZDataCryptor.h"
#import "XZDataDigester.h"
#import "XZKeychain.h"

#import "XZML.h"
#import "XZMocoa.h"
#import "XZToast.h"
#import "XZRefresh.h"

#import "XZPageView.h"
#import "XZPageControl.h"
#import "XZSegmentedControl.h"

#endif
