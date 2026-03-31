//
//  XZJSONCopying.m
//  XZKit
//
//  Created by 徐臻 on 2026/2/1.
//

#import "XZJSONCopying.h"
#import "XZJSONClass.h"
#import "XZJSONEncoder.h"
#import "XZJSONDecoder.h"
#import "XZLog.h"

@protocol XZJSONMutableColletion <NSObject>
- (void)addObject:(id)anObject;
@end

@interface NSMutableArray (XZJSONMutableColletion) <XZJSONMutableColletion>
@end
@interface NSMutableSet (XZJSONMutableColletion) <XZJSONMutableColletion>
@end
@interface NSCountedSet (XZJSONMutableColletion) <XZJSONMutableColletion>
@end
@interface NSMutableOrderedSet (XZJSONMutableColletion) <XZJSONMutableColletion>
@end

id XZJSONObjectCopying(id sourceModel, id targetModel) {
    if (!sourceModel || sourceModel == targetModel || sourceModel == (id)kCFNull) {
        return targetModel;
    }
    
    XZJSONClass * const SourceJSONClass = [XZJSONClass classForClass:object_getClass(sourceModel)];
    if (SourceJSONClass == nil) {
        return targetModel;
    }
    
    switch (SourceJSONClass->_cocoaClass) {
        case XZJSONCocoaClassUnknown: {
            NSMutableDictionary *dictionaryM = [NSMutableDictionary dictionaryWithCapacity:SourceJSONClass->_numberOfProperties];
            XZJSONModelEncodeIntoDictionary(sourceModel, SourceJSONClass, dictionaryM);
            
            XZJSONClass *TargetJSONClass = nil;
            if (targetModel == nil) {
                TargetJSONClass = SourceJSONClass;
                targetModel = [SourceJSONClass->_raw.raw new];
            } else {
                TargetJSONClass = [XZJSONClass classForClass:object_getClass(targetModel)];
            }

            if (TargetJSONClass) {
                XZJSONModelDecodeFromDictionary(targetModel, TargetJSONClass, dictionaryM);
                return targetModel;
            }
            
            XZLog(@"[XZJSON][NSCopying] 目标对象 %@ 不支持复制", targetModel);
            return targetModel;
        }
        case XZJSONCocoaClassNSString: {
            if (targetModel == nil) {
                return [(id<NSCopying>)sourceModel copyWithZone:nil];
            }
            if ([targetModel isKindOfClass:NSMutableString.class]) {
                [(NSMutableString *)targetModel setString:sourceModel];
                return targetModel;
            }
            XZLog(@"[XZJSON][NSCopying] 目标对象 %@ 不支持复制", targetModel);
            return targetModel;
        }
        case XZJSONCocoaClassNSMutableString: {
            if (targetModel == nil) {
                return [(id<NSCopying>)sourceModel copyWithZone:nil];
            }
            if ([targetModel isKindOfClass:NSMutableString.class]) {
                [(NSMutableString *)targetModel setString:sourceModel];
                return targetModel;
            }
            XZLog(@"[XZJSON][NSCopying] 目标对象 %@ 不支持复制", targetModel);
            return targetModel;
        }
        case XZJSONCocoaClassNSValue: {
            if (targetModel == nil) {
                return [(id<NSCopying>)sourceModel copyWithZone:nil];
            }
            XZLog(@"[XZJSON][NSCopying] 目标对象 %@ 不支持复制", targetModel);
            return targetModel;
        }
        case XZJSONCocoaClassNSNumber: {
            if (targetModel == nil) {
                return [(id<NSCopying>)sourceModel copyWithZone:nil];
            }
            XZLog(@"[XZJSON][NSCopying] 目标对象 %@ 不支持复制", targetModel);
            return targetModel;
        }
        case XZJSONCocoaClassNSDecimalNumber: {
            if (targetModel == nil) {
                return [NSDecimalNumber decimalNumberWithDecimal:((NSDecimalNumber *)sourceModel).decimalValue];
            }
            XZLog(@"[XZJSON][NSCopying] 目标对象 %@ 不支持复制", targetModel);
            return targetModel;
        }
        case XZJSONCocoaClassNSData: {
            if (targetModel == nil) {
                return [(id<NSCopying>)sourceModel copyWithZone:nil];
            }
            if ([targetModel isKindOfClass:NSMutableData.class]) {
                [(NSMutableData *)targetModel setData:sourceModel];
                return targetModel;
            }
            XZLog(@"[XZJSON][NSCopying] 目标对象 %@ 不支持复制", targetModel);
            return targetModel;
        }
        case XZJSONCocoaClassNSMutableData: {
            if (targetModel == nil) {
                return [(id<NSCopying>)sourceModel copyWithZone:nil];
            }
            if ([targetModel isKindOfClass:NSMutableData.class]) {
                [(NSMutableData *)targetModel setData:sourceModel];
                return targetModel;
            }
            XZLog(@"[XZJSON][NSCopying] 目标对象 %@ 不支持复制", targetModel);
            return targetModel;
        }
        case XZJSONCocoaClassNSDate: {
            if (targetModel == nil) {
                return [(id<NSCopying>)sourceModel copyWithZone:nil];
            }
            XZLog(@"[XZJSON][NSCopying] 目标对象 %@ 不支持复制", targetModel);
            return targetModel;
        }
        case XZJSONCocoaClassNSURL: {
            if (targetModel == nil) {
                return [(id<NSCopying>)sourceModel copyWithZone:nil];
            }
            XZLog(@"[XZJSON][NSCopying] 目标对象 %@ 不支持复制", targetModel);
            return targetModel;
        }
        case XZJSONCocoaClassNSArray:
        case XZJSONCocoaClassNSMutableArray: {
            NSMutableArray * arrayM = nil;
            if (targetModel == nil) {
                arrayM = [NSMutableArray arrayWithCapacity:((NSArray *)sourceModel).count];
            } else if ([targetModel isKindOfClass:NSMutableArray.class]) {
                arrayM = targetModel;
            }
            if (arrayM) {
                NSInteger const count = ((NSArray *)sourceModel).count;
                for (NSInteger index = 0; index < count; index++) {
                    id const oldObject = ((NSArray *)sourceModel)[index];
                    id const newObject = XZJSONObjectCopying(oldObject, nil);
                    arrayM[index] = newObject ?: oldObject;
                }
                return arrayM;
            }
            if ([targetModel conformsToProtocol:@protocol(XZJSONMutableColletion)]) {
                for (id const oldObject in (NSArray *)sourceModel) {
                    id const newObject = XZJSONObjectCopying(oldObject, nil);
                    [(id<XZJSONMutableColletion>)targetModel addObject:(newObject ?: oldObject)];
                }
                return targetModel;
            }
            XZLog(@"[XZJSON][NSCopying] 目标对象 %@ 不支持复制", targetModel);
            return targetModel;
        }
        case XZJSONCocoaClassNSSet:
        case XZJSONCocoaClassNSMutableSet: {
            id<XZJSONMutableColletion> collectionM = nil;
            if (targetModel == nil) {
                collectionM = [NSMutableSet setWithCapacity:((NSSet *)sourceModel).count];
            } else if ([targetModel conformsToProtocol:@protocol(XZJSONMutableColletion)]) {
                collectionM = targetModel;
            }
            if (collectionM) {
                for (id oldObject in (NSSet *)sourceModel) {
                    id newObject = XZJSONObjectCopying(oldObject, nil);
                    [collectionM addObject:(newObject ?: oldObject)];
                }
                return collectionM;
            }
            XZLog(@"[XZJSON][NSCopying] 目标对象 %@ 不支持复制", targetModel);
            return targetModel;
        }
        case XZJSONCocoaClassNSCountedSet: {
            id<XZJSONMutableColletion> collectionM = nil;
            if (targetModel == nil) {
                collectionM = [NSCountedSet setWithCapacity:((NSSet *)sourceModel).count];
            } else if ([targetModel conformsToProtocol:@protocol(XZJSONMutableColletion)]) {
                collectionM = targetModel;
            }
            if (collectionM) {
                for (id oldObject in (NSSet *)sourceModel) {
                    id newObject = XZJSONObjectCopying(oldObject, nil);
                    [collectionM addObject:(newObject ?: oldObject)];
                }
                return collectionM;
            }
            XZLog(@"[XZJSON][NSCopying] 目标对象 %@ 不支持复制", targetModel);
            return targetModel;
        }
        case XZJSONCocoaClassNSOrderedSet:
        case XZJSONCocoaClassNSMutableOrderedSet: {
            id<XZJSONMutableColletion> collectionM = nil;
            if (targetModel == nil) {
                collectionM = [NSMutableOrderedSet orderedSetWithCapacity:((NSSet *)sourceModel).count];
            } else if ([targetModel conformsToProtocol:@protocol(XZJSONMutableColletion)]) {
                collectionM = targetModel;
            }
            if (collectionM) {
                for (id oldObject in (NSSet *)sourceModel) {
                    id newObject = XZJSONObjectCopying(oldObject, nil);
                    [collectionM addObject:(newObject ?: oldObject)];
                }
                return collectionM;
            }
            XZLog(@"[XZJSON][NSCopying] 目标对象 %@ 不支持复制", targetModel);
            return targetModel;
        }
        case XZJSONCocoaClassNSDictionary: {
            NSMutableDictionary *dictionaryM = nil;
            if (targetModel == nil) {
                dictionaryM = [NSMutableDictionary dictionaryWithCapacity:((NSDictionary *)sourceModel).count];
            } else if ([targetModel isKindOfClass:NSMutableDictionary.class]) {
                dictionaryM = targetModel;
            }
            if (dictionaryM) {
                [(NSDictionary *)sourceModel enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                    dictionaryM[key] = XZJSONObjectCopying(obj, nil) ?: obj;
                }];
                return dictionaryM;
            }
            XZLog(@"[XZJSON][NSCopying] 目标对象 %@ 不支持复制", targetModel);
            return targetModel;
        }
        case XZJSONCocoaClassNSMutableDictionary: {
            NSMutableDictionary *dictionaryM = nil;
            if (targetModel == nil) {
                dictionaryM = [NSMutableDictionary dictionaryWithCapacity:((NSDictionary *)sourceModel).count];
            } else if ([targetModel isKindOfClass:NSMutableDictionary.class]) {
                dictionaryM = targetModel;
            }
            if (dictionaryM) {
                [(NSDictionary *)sourceModel enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                    dictionaryM[key] = XZJSONObjectCopying(obj, nil) ?: obj;
                }];
                return dictionaryM;
            }
            XZLog(@"[XZJSON][NSCopying] 目标对象 %@ 不支持复制", targetModel);
            return targetModel;
        }
    }
}


@implementation NSMutableArray (XZJSONMutableColletion)
@end
@implementation NSMutableSet (XZJSONMutableColletion)
@end
@implementation NSCountedSet (XZJSONMutableColletion)
@end
@implementation NSMutableOrderedSet (XZJSONMutableColletion)
@end
