//
//  XZMocoaDefines.m
//  XZMocoa
//
//  Created by Xezun on 2021/11/5.
//

#import "XZMocoaDefines.h"

CGFloat const XZMocoaViewMinimumDimension = 0.0000001;
CGSize  const XZMocoaViewMinimumSize      = (CGSize){XZMocoaViewMinimumDimension, XZMocoaViewMinimumDimension};

CGFloat const XZMocoaTableViewHeaderFooterHeight = XZMocoaViewMinimumDimension;
CGSize  const XZMocoaCollectionViewItemSize      = XZMocoaViewMinimumSize;

XZMocoaName const XZMocoaNameDefault = @"";
XZMocoaKind const XZMocoaKindDefault = @"";
XZMocoaKind const XZMocoaKindHeader  = @"header";
XZMocoaKind const XZMocoaKindFooter  = @"footer";
XZMocoaKind const XZMocoaKindSection = @"";
XZMocoaKind const XZMocoaKindCell    = @"";

XZMocoaName const XZMocoaNamePlaceholder = @"XZMocoaNamePlaceholder";
