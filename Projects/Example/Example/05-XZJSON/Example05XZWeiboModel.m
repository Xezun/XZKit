//
//  Example05XZWeiboModel.m
//  Example
//
//  Created by 徐臻 on 2025/2/28.
//

#import "Example05XZWeiboModel.h"

static NSDateFormatter *dateFormatter(void) {
    static NSDateFormatter *formatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSDateFormatter alloc] init];
        formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
        formatter.dateFormat = @"EEE MMM dd HH:mm:ss Z yyyy";
    });
    return formatter;
}

@implementation Example05XZWeiboPictureMetadata

+ (NSDictionary *)mappingJSONCodingKeys {
    return @{
        @"cutType" : @"cut_type"
    };
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        [XZJSON model:self decodeWithCoder:coder];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [XZJSON model:self encodeWithCoder:coder];
}

- (BOOL)isEqual:(id)object {
    return [XZJSON model:self isEqualToModel:object comparator:nil];
}

- (id)copyWithZone:(NSZone *)zone {
    return [XZJSON model:self copy:^BOOL(id  _Nonnull newModel, NSString * _Nonnull key) {
        return NO;
    }];
}

@end

@implementation Example05XZWeiboPicture

+ (NSDictionary *)mappingJSONCodingKeys {
    return @{
        @"picID" : @"pic_id",
        @"keepSize" : @"keep_size",
        @"photoTag" : @"photo_tag",
        @"objectID" : @"object_id",
        @"middlePlus" : @"middleplus"
    };
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        [XZJSON model:self decodeWithCoder:coder];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [XZJSON model:self encodeWithCoder:coder];
}

- (BOOL)isEqual:(id)object {
    return [XZJSON model:self isEqualToModel:object comparator:nil];
}

- (id)copyWithZone:(NSZone *)zone {
    return [XZJSON model:self copy:^BOOL(id  _Nonnull newModel, NSString * _Nonnull key) {
        return NO;
    }];
}
@end

@implementation Example05XZWeiboURL
+ (NSDictionary *)mappingJSONCodingKeys {
    return @{
        @"oriURL" : @"ori_url",
        @"urlTitle" : @"url_title",
        @"urlTypePic" : @"url_type_pic",
        @"urlType" : @"url_type",
        @"shortURL" : @"short_url",
        @"actionLog" : @"actionlog",
        @"pageID" : @"page_id",
        @"storageType" : @"storage_type"
    };
}


- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        [XZJSON model:self decodeWithCoder:coder];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [XZJSON model:self encodeWithCoder:coder];
}

- (BOOL)isEqual:(id)object {
    return [XZJSON model:self isEqualToModel:object comparator:nil];
}

- (id)copyWithZone:(NSZone *)zone {
    return [XZJSON model:self copy:^BOOL(id  _Nonnull newModel, NSString * _Nonnull key) {
        return NO;
    }];
}
@end

@implementation Example05XZWeiboUser
+ (NSDictionary *)mappingJSONCodingKeys {
    return @{
        @"userID" : @"id",
        @"idString" : @"idstr",
        @"genderString" : @"gender",
        @"biFollowersCount" : @"bi_followers_count",
        @"profileImageURL" : @"profile_image_url",
        @"uclass" : @"class",
        @"verifiedContactEmail" : @"verified_contact_email",
        @"statusesCount" : @"statuses_count",
        @"geoEnabled" : @"geo_enabled",
        @"followMe" : @"follow_me",
        @"coverImagePhone" : @"cover_image_phone",
        @"desc" : @"description",
        @"followersCount" : @"followers_count",
        @"verifiedContactMobile" : @"verified_contact_mobile",
        @"avatarLarge" : @"avatar_large",
        @"verifiedTrade" : @"verified_trade",
        @"profileURL" : @"profile_url",
        @"coverImage" : @"cover_image",
        @"onlineStatus"  : @"online_status",
        @"badgeTop" : @"badge_top",
        @"verifiedContactName" : @"verified_contact_name",
        @"screenName" : @"screen_name",
        @"verifiedSourceURL" : @"verified_source_url",
        @"pagefriendsCount" : @"pagefriends_count",
        @"verifiedReason" : @"verified_reason",
        @"friendsCount" : @"friends_count",
        @"blockApp" : @"block_app",
        @"hasAbilityTag" : @"has_ability_tag",
        @"avatarHD" : @"avatar_hd",
        @"creditScore" : @"credit_score",
        @"createdAt" : @"created_at",
        @"blockWord" : @"block_word",
        @"allowAllActMsg" : @"allow_all_act_msg",
        @"verifiedState" : @"verified_state",
        @"verifiedReasonModified" : @"verified_reason_modified",
        @"allowAllComment" : @"allow_all_comment",
        @"verifiedLevel" : @"verified_level",
        @"verifiedReasonURL" : @"verified_reason_url",
        @"favouritesCount" : @"favourites_count",
        @"verifiedType" : @"verified_type",
        @"verifiedSource" : @"verified_source",
        @"userAbility" : @"user_ability"
    };
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        [XZJSON model:self decodeWithCoder:coder];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [XZJSON model:self encodeWithCoder:coder];
}

- (BOOL)isEqual:(id)object {
    return [XZJSON model:self isEqualToModel:object comparator:nil];
}

- (id)copyWithZone:(NSZone *)zone {
    return [XZJSON model:self copy:^BOOL(id  _Nonnull newModel, NSString * _Nonnull key) {
        return NO;
    }];
}

- (BOOL)JSONDecodeValue:(id)value forKey:(NSString *)key {
    if ([key isEqualToString:@"createdAt"]) {
        if ([value isKindOfClass:NSString.class]) {
            self.createdAt = [dateFormatter() dateFromString:value];
        }
        return YES;
    }
    return NO;
}

@end

@implementation Example05XZWeiboStatus

+ (NSDictionary<NSString *,id> *)mappingJSONCodingKeys {
    return @{
        @"statusID" : @"id",
        @"createdAt" : @"created_at",
        @"attitudesStatus" : @"attitudes_status",
        @"inReplyToScreenName" : @"in_reply_to_screen_name",
        @"sourceType" : @"source_type",
        @"commentsCount" : @"comments_count",
        @"recomState" : @"recom_state",
        @"urlStruct" : @"url_struct",
        @"sourceAllowClick" : @"source_allowclick",
        @"bizFeature" : @"biz_feature",
        @"mblogTypeName" : @"mblogtypename",
        @"mblogType" : @"mblogtype",
        @"inReplyToStatusId" : @"in_reply_to_status_id",
        @"picIds" : @"pic_ids",
        @"repostsCount" : @"reposts_count",
        @"attitudesCount" : @"attitudes_count",
        @"darwinTags" : @"darwin_tags",
        @"userType" : @"userType",
        @"picInfos" : @"pic_infos",
        @"inReplyToUserId" : @"in_reply_to_user_id"
    };
}

+ (NSDictionary<NSString *,id> *)mappingJSONCodingClasses {
    return @{
        @"picIds" : [NSString class],
        @"picInfos" : [Example05XZWeiboPicture class],
        @"urlStruct" : [Example05XZWeiboURL class]
    };
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        [XZJSON model:self decodeWithCoder:coder];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [XZJSON model:self encodeWithCoder:coder];
}

- (BOOL)isEqual:(id)object {
    return [XZJSON model:self isEqualToModel:object comparator:nil];
}

- (id)copyWithZone:(NSZone *)zone {
    return [XZJSON model:self copy:^BOOL(id  _Nonnull newModel, NSString * _Nonnull key) {
        return NO;
    }];
}

- (BOOL)JSONDecodeValue:(id)value forKey:(NSString *)key {
    if ([key isEqualToString:@"createdAt"]) {
        if ([value isKindOfClass:NSString.class]) {
            self.createdAt = [dateFormatter() dateFromString:value];
        }
        return YES;
    }
    return NO;
}

@end
