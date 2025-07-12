//
//  Example05XZGHUser.m
//  Example
//
//  Created by 徐臻 on 2025/2/28.
//

#import "Example05XZGHUser.h"

static NSDateFormatter *dateFormatter(void) {
    static NSDateFormatter *formatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSDateFormatter alloc] init];
        formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
        formatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ssZ";
    });
    return formatter;
}

@implementation Example05XZGHUser
+ (NSDictionary<NSString *,id> *)mappingJSONCodingKeys {
    return @{
        @"userID" : @"id",
        @"avatarURL" : @"avatar_url",
        @"gravatarID" : @"gravatar_id",
        @"htmlURL" : @"html_url",
        @"followersURL" : @"followers_url",
        @"followingURL" : @"following_url",
        @"gistsURL" : @"gists_url",
        @"starredURL" : @"starred_url",
        @"subscriptionsURL" : @"subscriptions_url",
        @"organizationsURL" : @"organizations_url",
        @"reposURL" : @"repos_url",
        @"eventsURL" : @"events_url",
        @"receivedEventsURL" : @"received_events_url",
        @"siteAdmin" : @"site_admin",
        @"publicRepos" : @"public_repos",
        @"publicGists" : @"public_gists",
        @"createdAt" : @"created_at",
        @"updatedAt" : @"updated_at",
    };
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [XZJSON model:self encodeWithCoder:aCoder];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        [XZJSON model:self decodeWithCoder:aDecoder];
    }
    return self;
}

- (BOOL)JSONDecodeValue:(id)value forKey:(NSString *)key {
    if ([key isEqualToString:@"updatedAt"]) {
        if ([value isKindOfClass:NSString.class]) {
            self.updatedAt = [dateFormatter() dateFromString:value];
        }
        return YES;
    }
    if ([key isEqualToString:@"test"]) {
        return YES;
    }
    return NO;
}

@end
