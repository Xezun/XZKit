//
//  XZAuthorizationManager.m
//  XZKit
//
//  Created by mlibai on 2016/11/8.
//  Copyright © 2016年 mlibai. All rights reserved.
//

#import "XZAuthorizationManager.h"

#import <CoreLocation/CoreLocation.h>
#import <Photos/Photos.h>
#import <AssetsLibrary/AssetsLibrary.h>
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_10_0
#import <Speech/Speech.h>
#endif
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_9_0
#import <Contacts/Contacts.h>
#endif
#import <EventKit/EventKit.h> // calendar
#import <MediaPlayer/MediaPlayer.h>
#import <HealthKit/HealthKit.h>

typedef void (^_XZAuthorizationRequestCompletion)(XZAuthorizationStatus status);

static void xz_dispatch_on_main_thread(void (^ _Nonnull)());



static void xz_authorization_request(XZAuthorizationManager *manager, XZAuthorizationType type, _XZAuthorizationRequestCompletion completion);

@interface XZAuthorizationManager ()

@property (nonatomic, strong) XZLocationHelper *locationHelper;

@end


@implementation XZAuthorizationManager

+ (instancetype)manager {
    return [(XZAuthorizationManager *)[self alloc] init];
}

/**
 这个方法返回的是权限的真实的授权状态。
 */
+ (XZAuthorizationStatus)authorizationStatus:(XZAuthorizationType)authorizationType {
    return XZAuthorizationStatusForType(authorizationType);
}

- (XZAuthorizationStatus)authorizationStatus:(XZAuthorizationType)authorizationType {
    return XZAuthorizationStatusForType(authorizationType);
}

- (void)XZ_requestAuthorization:(XZAuthorizationType)authorizations flag:(XZAuthorizationType)flag completion:(XZAuthorizationRequestCompletion)completion {
    if ((flag & authorizations) == flag) {
        xz_authorization_request(self, flag, ^(XZAuthorizationStatus status) {
            switch (status) {
                case XZAuthorizationStatusAuthorized:
                    [self XZ_requestAuthorization:authorizations flag:(flag << 1) completion:completion];
                    break;
                default:
                    if (completion != nil) {
                        xz_dispatch_on_main_thread(^{
                            completion(status, flag);
                        });
                    }
                    break;
            }
        });
    } else if (flag < XZAuthorizationTypeUnknown) {
        [self XZ_requestAuthorization:authorizations flag:(flag << 1) completion:completion];
    } else if (completion != nil) {
        xz_dispatch_on_main_thread(^{
            completion(XZAuthorizationStatusAuthorized, authorizations);
        });
    }
}

- (void)requestAuthorization:(XZAuthorizationType)authorization completion:(XZAuthorizationRequestCompletion)completion {
    return [self XZ_requestAuthorization:authorization flag:1 completion:completion];
}

#pragma mark - getters & setters 

- (XZLocationHelper *)locationHelper {
    if (_locationHelper != nil) {
        return _locationHelper;
    }
    _locationHelper = [[XZLocationHelper alloc] init];
    return _locationHelper;
}

@end






#pragma mark - private functions

static void xz_dispatch_on_main_thread(void (^block)()) {
    if ([NSThread isMainThread]) {
        block();
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            block();
        });
    }
}

//  权限检测
static XZAuthorizationStatus PhotosAuthorizationStatus();
static XZAuthorizationStatus CameraAuthorizationStatus();
static XZAuthorizationStatus LocationServicesAlwaysAuthorizationStatus();
static XZAuthorizationStatus LocationServicesWhenInUseAuthorizationStatus();
static XZAuthorizationStatus MicrophoneAuthorizationStatus();
static XZAuthorizationStatus SpeechRecognitionAuthorizationStatus();
static XZAuthorizationStatus ContactsAuthorizationStatus();
static XZAuthorizationStatus CalendarsAuthorizationStatus();
static XZAuthorizationStatus RemindersAuthorizationStatus();
static XZAuthorizationStatus MediaLibraryAuthorizationStatus();

XZAuthorizationStatus XZAuthorizationStatusForType(XZAuthorizationType authorizationType) {
    switch (authorizationType) {
        case XZAuthorizationTypeNone:
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        case XZAuthorizationTypeNetworking:
#pragma clang diagnostic pop
            return XZAuthorizationStatusAuthorized;
            
        case XZAuthorizationTypePhotos:
            return PhotosAuthorizationStatus();
            
        case XZAuthorizationTypeCamera:
            return CameraAuthorizationStatus();
            
        case XZAuthorizationTypeLocationServicesAlways:
            return LocationServicesAlwaysAuthorizationStatus();
            
        case XZAuthorizationTypeLocationServicesWhenInUse:
            return LocationServicesWhenInUseAuthorizationStatus();
            
        case XZAuthorizationTypeMicrophone:
            return MicrophoneAuthorizationStatus();
            
        case XZAuthorizationTypeSpeechRecognition:
            return SpeechRecognitionAuthorizationStatus();
            
        case XZAuthorizationTypeContacts:
            return ContactsAuthorizationStatus();
            
        case XZAuthorizationTypeCalendars:
            return CalendarsAuthorizationStatus();
            
        case XZAuthorizationTypeReminders:
            return RemindersAuthorizationStatus();
            
        case XZAuthorizationTypeMediaLibrary:
            return MediaLibraryAuthorizationStatus();
            
        case XZAuthorizationTypeUnknown:
            return XZAuthorizationStatusRestricted;
    }
    return XZAuthorizationStatusRestricted;
}


static XZAuthorizationStatus PhotosAuthorizationStatus() {
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_8_0
    if ([UIDevice currentDevice].systemVersion.floatValue >= 8.0) {
#endif
        switch ([PHPhotoLibrary authorizationStatus]) {
            case PHAuthorizationStatusDenied:
                return XZAuthorizationStatusDenied;
            case PHAuthorizationStatusAuthorized:
                return XZAuthorizationStatusAuthorized;
            case PHAuthorizationStatusRestricted:
                return XZAuthorizationStatusRestricted;
            case PHAuthorizationStatusNotDetermined:
                return XZAuthorizationStatusNotDetermined;
        }
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_8_0
    } else {
        switch ([ALAssetsLibrary authorizationStatus]) {
            case ALAuthorizationStatusDenied:
                return XZAuthorizationStatusDenied;
            case ALAuthorizationStatusAuthorized:
                return XZAuthorizationStatusAuthorized;
            case ALAuthorizationStatusRestricted:
                return XZAuthorizationStatusRestricted;
            case ALAuthorizationStatusNotDetermined:
                return XZAuthorizationStatusNotDetermined;
        }
    }
#endif
}

static XZAuthorizationStatus CameraAuthorizationStatus() {
    switch ([AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo]) {
        case AVAuthorizationStatusDenied:
            return XZAuthorizationStatusDenied;
        case AVAuthorizationStatusAuthorized:
            return XZAuthorizationStatusAuthorized;
        case AVAuthorizationStatusRestricted:
            return XZAuthorizationStatusRestricted;
        case AVAuthorizationStatusNotDetermined:
            return XZAuthorizationStatusNotDetermined;
    }
}

static XZAuthorizationStatus LocationServicesAlwaysAuthorizationStatus() {
    switch ([CLLocationManager authorizationStatus]) {
        case kCLAuthorizationStatusDenied:
            return XZAuthorizationStatusDenied;
        case kCLAuthorizationStatusRestricted:
            return XZAuthorizationStatusRestricted;
        case kCLAuthorizationStatusNotDetermined:
            return XZAuthorizationStatusNotDetermined;
        case kCLAuthorizationStatusAuthorizedAlways: // kCLAuthorizationStatusAuthorized
            return XZAuthorizationStatusAuthorized;
        case kCLAuthorizationStatusAuthorizedWhenInUse:
            return XZAuthorizationStatusDenied;
    }
}

static XZAuthorizationStatus LocationServicesWhenInUseAuthorizationStatus() {
    switch ([CLLocationManager authorizationStatus]) {
        case kCLAuthorizationStatusDenied:
            return XZAuthorizationStatusDenied;
        case kCLAuthorizationStatusRestricted:
            return XZAuthorizationStatusRestricted;
        case kCLAuthorizationStatusNotDetermined:
            return XZAuthorizationStatusNotDetermined;
        case kCLAuthorizationStatusAuthorizedAlways: // kCLAuthorizationStatusAuthorized
        case kCLAuthorizationStatusAuthorizedWhenInUse:
            return XZAuthorizationStatusAuthorized;
    }
}

static XZAuthorizationStatus MicrophoneAuthorizationStatus() {
    switch ([AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio]) {
        case AVAuthorizationStatusDenied:
            return XZAuthorizationStatusDenied;
        case AVAuthorizationStatusAuthorized:
            return XZAuthorizationStatusAuthorized;
        case AVAuthorizationStatusRestricted:
            return XZAuthorizationStatusRestricted;
        case AVAuthorizationStatusNotDetermined:
            return XZAuthorizationStatusNotDetermined;
    }
}

static XZAuthorizationStatus SpeechRecognitionAuthorizationStatus() {
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_10_0
    NSLog(@"适配版本小于10.0，语音识别 权限检测不可用");
    return XZAuthorizationStatusRestricted;
#else
    switch ([SFSpeechRecognizer authorizationStatus]) {
        case SFSpeechRecognizerAuthorizationStatusDenied:
            return XZAuthorizationStatusDenied;
        case SFSpeechRecognizerAuthorizationStatusAuthorized:
            return XZAuthorizationStatusAuthorized;
        case SFSpeechRecognizerAuthorizationStatusRestricted:
            return XZAuthorizationStatusRestricted;
        case SFSpeechRecognizerAuthorizationStatusNotDetermined:
            return XZAuthorizationStatusNotDetermined;
    }
#endif
}

static XZAuthorizationStatus ContactsAuthorizationStatus() {
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_9_0
    NSLog(@"适配版本小于9.0，通讯录 权限检测不可用");
    return XZAuthorizationStatusRestricted;
#else
    switch ([CNContactStore authorizationStatusForEntityType:(CNEntityTypeContacts)]) {
        case CNAuthorizationStatusDenied:
            return XZAuthorizationStatusDenied;
        case CNAuthorizationStatusAuthorized:
            return XZAuthorizationStatusAuthorized;
        case CNAuthorizationStatusRestricted:
            return XZAuthorizationStatusRestricted;
        case CNAuthorizationStatusNotDetermined:
            return XZAuthorizationStatusNotDetermined;
    }
#endif
}

static XZAuthorizationStatus CalendarsAuthorizationStatus() {
    switch ([EKEventStore authorizationStatusForEntityType:(EKEntityTypeEvent)]) {
        case EKAuthorizationStatusDenied:
            return XZAuthorizationStatusDenied;
        case EKAuthorizationStatusAuthorized:
            return XZAuthorizationStatusAuthorized;
        case EKAuthorizationStatusRestricted:
            return XZAuthorizationStatusRestricted;
        case EKAuthorizationStatusNotDetermined:
            return XZAuthorizationStatusNotDetermined;
    }
}

static XZAuthorizationStatus RemindersAuthorizationStatus() {
    switch ([EKEventStore authorizationStatusForEntityType:(EKEntityTypeReminder)]) {
        case EKAuthorizationStatusDenied:
            return XZAuthorizationStatusDenied;
        case EKAuthorizationStatusAuthorized:
            return XZAuthorizationStatusAuthorized;
        case EKAuthorizationStatusRestricted:
            return XZAuthorizationStatusRestricted;
        case EKAuthorizationStatusNotDetermined:
            return XZAuthorizationStatusNotDetermined;
    }
}

static XZAuthorizationStatus MediaLibraryAuthorizationStatus() {
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_9_3
    NSLog(@"适配版本小于9.3，媒体库 权限检测不可用");
    return XZAuthorizationStatusRestricted;
#else
    switch ([MPMediaLibrary authorizationStatus]) {
        case MPMediaLibraryAuthorizationStatusDenied:
            return XZAuthorizationStatusDenied;
        case MPMediaLibraryAuthorizationStatusAuthorized:
            return XZAuthorizationStatusAuthorized;
        case MPMediaLibraryAuthorizationStatusRestricted:
            return XZAuthorizationStatusRestricted;
        case MPMediaLibraryAuthorizationStatusNotDetermined:
            return XZAuthorizationStatusNotDetermined;
    }
#endif
}



// 申请
static void PhotosAuthorizationRequest(XZAuthorizationManager *manager, _XZAuthorizationRequestCompletion completion);
static void CameraAuthorizationRequest(XZAuthorizationManager *manager, _XZAuthorizationRequestCompletion completion);
static void LocationServicesAlwaysAuthorizationRequest(XZAuthorizationManager *manager, _XZAuthorizationRequestCompletion completion);
static void LocationServicesWhenInUseAuthorizationRequest(XZAuthorizationManager *manager, _XZAuthorizationRequestCompletion completion);
static void MicrophoneAuthorizationRequest(XZAuthorizationManager *manager, _XZAuthorizationRequestCompletion completion);
static void SpeechRecognitionAuthorizationRequest(XZAuthorizationManager *manager, _XZAuthorizationRequestCompletion completion);
static void ContactsAuthorizationRequest(XZAuthorizationManager *manager, _XZAuthorizationRequestCompletion completion);
static void CalendarsAuthorizationRequest(XZAuthorizationManager *manager, _XZAuthorizationRequestCompletion completion);
static void RemindersAuthorizationRequest(XZAuthorizationManager *manager, _XZAuthorizationRequestCompletion completion);
static void MediaLibraryAuthorizationRequest(XZAuthorizationManager *manager, _XZAuthorizationRequestCompletion completion);


static void xz_authorization_request(XZAuthorizationManager *manager, XZAuthorizationType type, _XZAuthorizationRequestCompletion completion) {
    XZAuthorizationStatus status = XZAuthorizationStatusForType(type);
    switch (status) {
        case XZAuthorizationStatusNotDetermined:
            switch (type) {
                case XZAuthorizationTypeNone:
#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Wdeprecated-declarations"
                case XZAuthorizationTypeNetworking:
#pragma clang diagnostic pop
                    completion(XZAuthorizationStatusAuthorized);
                    break;
                    
                case XZAuthorizationTypePhotos:
                    PhotosAuthorizationRequest(manager, completion);
                    break;
                    
                case XZAuthorizationTypeCamera:
                    CameraAuthorizationRequest(manager, completion);
                    break;
                    
                case XZAuthorizationTypeLocationServicesAlways:
                    LocationServicesAlwaysAuthorizationRequest(manager, completion);
                    break;
                    
                case XZAuthorizationTypeLocationServicesWhenInUse:
                    LocationServicesWhenInUseAuthorizationRequest(manager, completion);
                    break;
                
                case XZAuthorizationTypeMicrophone:
                    MicrophoneAuthorizationRequest(manager, completion);
                    break;
                
                case XZAuthorizationTypeSpeechRecognition:
                    SpeechRecognitionAuthorizationRequest(manager, completion);
                    break;
                
                case XZAuthorizationTypeContacts:
                    ContactsAuthorizationRequest(manager, completion);
                    break;
                
                case XZAuthorizationTypeCalendars:
                    CalendarsAuthorizationRequest(manager, completion);
                    break;
                
                case XZAuthorizationTypeReminders:
                    RemindersAuthorizationRequest(manager, completion);
                    break;
                
                case XZAuthorizationTypeMediaLibrary:
                    MediaLibraryAuthorizationRequest(manager, completion);
                    break;
                
                case XZAuthorizationTypeUnknown:
                default:
                    completion(XZAuthorizationStatusRestricted);
                    break;
            }
            break;
        default:
            completion(status);
            break;
    }
}

static void PhotosAuthorizationRequest(XZAuthorizationManager *manager, _XZAuthorizationRequestCompletion completion) {
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_8_0
    if ([UIDevice currentDevice].systemVersion.floatValue >= 8.0) {
#endif
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            xz_authorization_request(manager, XZAuthorizationTypePhotos, completion);
        }];
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_8_0
    } else {
        completion(XZAuthorizationStatusAuthorized);
    }
#endif
}

static void CameraAuthorizationRequest(XZAuthorizationManager *manager, _XZAuthorizationRequestCompletion completion) {
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
        xz_authorization_request(manager, XZAuthorizationTypeCamera, completion);
    }];
}

static void LocationServicesAlwaysAuthorizationRequest(XZAuthorizationManager *manager, _XZAuthorizationRequestCompletion completion) {
    [manager.locationHelper requestAlwaysAuthorization:^(CLAuthorizationStatus status) {
        xz_authorization_request(manager, XZAuthorizationTypeLocationServicesAlways, completion);
    }];
}

static void LocationServicesWhenInUseAuthorizationRequest(XZAuthorizationManager *manager, _XZAuthorizationRequestCompletion completion) {
    [manager.locationHelper requestWhenInUseAuthorization:^(CLAuthorizationStatus status) {
        xz_authorization_request(manager, XZAuthorizationTypeLocationServicesWhenInUse, completion);
    }];
}

static void MicrophoneAuthorizationRequest(XZAuthorizationManager *manager, _XZAuthorizationRequestCompletion completion) {
#if TARGET_IPHONE_SIMULATOR
    NSLog(@"正在模拟器中运行，麦克风授权直接返回 已授权。");
    completion(XZAuthorizationStatusAuthorized);
#else
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
        xz_authorization_request(manager, XZAuthorizationTypeMicrophone, completion);
    }];
#endif
}

static void SpeechRecognitionAuthorizationRequest(XZAuthorizationManager *manager, _XZAuthorizationRequestCompletion completion) {
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_10_0
    completion(XZAuthorizationStatusRestricted);
#else
    [SFSpeechRecognizer requestAuthorization:^(SFSpeechRecognizerAuthorizationStatus status) {
        xz_authorization_request(manager, XZAuthorizationTypeSpeechRecognition, completion);
    }];
#endif
}

static void ContactsAuthorizationRequest(XZAuthorizationManager *manager, _XZAuthorizationRequestCompletion completion) {
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_9_0
    completion(XZAuthorizationStatusRestricted);
#else
    [[[CNContactStore alloc] init] requestAccessForEntityType:(CNEntityTypeContacts) completionHandler:^(BOOL granted, NSError * _Nullable error) {
        xz_authorization_request(manager, XZAuthorizationTypeContacts, completion);
    }];
#endif
}

static void CalendarsAuthorizationRequest(XZAuthorizationManager *manager, _XZAuthorizationRequestCompletion completion) {
    EKEventStore *__block store = [[EKEventStore alloc] init];
    [store requestAccessToEntityType:(EKEntityTypeEvent) completion:^(BOOL granted, NSError * _Nullable error) {
        xz_authorization_request(manager, XZAuthorizationTypeCalendars, completion);
        store = nil;
    }];
}

static void RemindersAuthorizationRequest(XZAuthorizationManager *manager, _XZAuthorizationRequestCompletion completion) {
    EKEventStore *__block store = [[EKEventStore alloc] init];
    [store requestAccessToEntityType:(EKEntityTypeReminder) completion:^(BOOL granted, NSError * _Nullable error) {
        xz_authorization_request(manager, XZAuthorizationTypeReminders, completion);
        store = nil;
    }];
}

static void MediaLibraryAuthorizationRequest(XZAuthorizationManager *manager, _XZAuthorizationRequestCompletion completion) {
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_9_3
    completion(XZAuthorizationStatusRestricted);
#else
    [MPMediaLibrary requestAuthorization:^(MPMediaLibraryAuthorizationStatus status) {
        xz_authorization_request(manager, XZAuthorizationTypeMediaLibrary, completion);
    }];
#endif
}
