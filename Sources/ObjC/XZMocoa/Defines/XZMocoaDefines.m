//
//  XZMocoaDefines.m
//  XZMocoa
//
//  Created by Xezun on 2021/11/5.
//

#import "XZMocoaDefines.h"

CGFloat const XZMocoaMinimumViewDimension = 0.0000001;
CGSize  const XZMocoaMinimumViewSize      = (CGSize){XZMocoaMinimumViewDimension, XZMocoaMinimumViewDimension};

CGFloat const XZMocoaTableViewHeaderFooterHeight = XZMocoaMinimumViewDimension;
CGSize  const XZMocoaCollectionViewItemSize      = XZMocoaMinimumViewSize;

XZMocoaName const XZMocoaNameDefault = @"";
XZMocoaKind const XZMocoaKindDefault = @"";
XZMocoaKind const XZMocoaKindHeader  = @"header";
XZMocoaKind const XZMocoaKindFooter  = @"footer";
XZMocoaKind const XZMocoaKindSection = @"";
XZMocoaKind const XZMocoaKindCell    = @"";

XZMocoaName const XZMocoaNameList        = @"list";
XZMocoaName const XZMocoaNamePlaceholder = @"XZMocoaNamePlaceholder";
