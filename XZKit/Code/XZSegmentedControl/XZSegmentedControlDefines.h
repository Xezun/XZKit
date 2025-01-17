//
//  XZSegmentedControlDefines.h
//  XZSegmentedControl
//
//  Created by Xezun on 2024/7/18.
//

#import <UIKit/UIKit.h>

#if XZ_FRAMEWORK
#define XZ_SEGMENTEDCONTROL_READONLY
#else
#define XZ_SEGMENTEDCONTROL_READONLY readonly
#endif

#ifndef XZLog
#if XZ_DEBUG
#define XZLog(format, ...) NSLog(format, ##__VA_ARGS__)
#else
#define XZLog(...)
#endif
#endif
