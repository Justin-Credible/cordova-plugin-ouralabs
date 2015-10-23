//
//  Ouralabs
//
//  Copyright (c) 2015 Ouralabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCrypto.h>
#import <UIKit/UIKit.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import <arpa/inet.h>
#import <sys/utsname.h>
#import <pthread.h>
#import <zlib.h>
#import <objc/runtime.h>

#import "Ouralabs.h"

#define now()         ([[NSDate date] timeIntervalSince1970])
#define valOrBlank(x) (x ? x : @"")
#define valOr(x, y)   (x ? x : y)

#define addObserver(name, block) ([[NSNotificationCenter defaultCenter] addObserverForName:name object:nil queue:sOperationQueue usingBlock:block])
#define removeObserver(ref)      ([[NSNotificationCenter defaultCenter] removeObserver:ref])

#define lock()   ([sLock lock])
#define unlock() ([sLock unlock])

#define LTRACE  OULogLevelTrace
#define LDEBUG  OULogLevelDebug
#define LINFO   OULogLevelInfo
#define LWARN   OULogLevelWarn
#define LERROR  OULogLevelError
#define LFATAL  OULogLevelFatal

#pragma mark - Trace C Methods

void __attribute__((overloadable)) OULogTrace(NSString *tag, NSString *message, ...) {
    va_list args;
    va_start(args, message);
    [Ouralabs log:OULogLevelTrace tag:tag message:message args:args];
    va_end(args);
}

void __attribute__((overloadable)) OULogTrace(NSString *tag, NSString *message, NSDictionary *kvp) {
    [Ouralabs log:OULogLevelTrace tag:tag message:message kvp:kvp];
}

void __attribute__((overloadable)) OULogTrace(NSString *tag, NSString *message, NSException *exception) {
    [Ouralabs log:OULogLevelTrace tag:tag message:message exception:exception];
}

void __attribute__((overloadable)) OULogTrace(NSString *tag, NSString *message, NSError *error) {
    [Ouralabs log:OULogLevelTrace tag:tag message:message error:error];
}

#pragma mark - Debug C Methods

void __attribute__((overloadable)) OULogDebug(NSString *tag, NSString *message, ...) {
    va_list args;
    va_start(args, message);
    [Ouralabs log:OULogLevelDebug tag:tag message:message args:args];
    va_end(args);
}

void __attribute__((overloadable)) OULogDebug(NSString *tag, NSString *message, NSDictionary *kvp) {
    [Ouralabs log:OULogLevelDebug tag:tag message:message kvp:kvp];
}

void __attribute__((overloadable)) OULogDebug(NSString *tag, NSString *message, NSException *exception) {
    [Ouralabs log:OULogLevelDebug tag:tag message:message exception:exception];
}

void __attribute__((overloadable)) OULogDebug(NSString *tag, NSString *message, NSError *error) {
    [Ouralabs log:OULogLevelDebug tag:tag message:message error:error];
}

#pragma mark - Info C Methods

void __attribute__((overloadable)) OULogInfo(NSString *tag, NSString *message, ...) {
    va_list args;
    va_start(args, message);
    [Ouralabs log:OULogLevelInfo tag:tag message:message args:args];
    va_end(args);
}

void __attribute__((overloadable)) OULogInfo(NSString *tag, NSString *message, NSDictionary *kvp) {
    [Ouralabs log:OULogLevelInfo tag:tag message:message kvp:kvp];
}

void __attribute__((overloadable)) OULogInfo(NSString *tag, NSString *message, NSException *exception) {
    [Ouralabs log:OULogLevelInfo tag:tag message:message exception:exception];
}

void __attribute__((overloadable)) OULogInfo(NSString *tag, NSString *message, NSError *error) {
    [Ouralabs log:OULogLevelInfo tag:tag message:message error:error];
}

#pragma mark - Warn C Methods

void __attribute__((overloadable)) OULogWarn(NSString *tag, NSString *message, ...) {
    va_list args;
    va_start(args, message);
    [Ouralabs log:OULogLevelWarn tag:tag message:message args:args];
    va_end(args);
}

void __attribute__((overloadable)) OULogWarn(NSString *tag, NSString *message, NSDictionary *kvp) {
    [Ouralabs log:OULogLevelWarn tag:tag message:message kvp:kvp];
}

void __attribute__((overloadable)) OULogWarn(NSString *tag, NSString *message, NSException *exception) {
    [Ouralabs log:OULogLevelWarn tag:tag message:message exception:exception];
}

void __attribute__((overloadable)) OULogWarn(NSString *tag, NSString *message, NSError *error) {
    [Ouralabs log:OULogLevelWarn tag:tag message:message error:error];
}

#pragma mark - Error C Methods

void __attribute__((overloadable)) OULogError(NSString *tag, NSString *message, ...) {
    va_list args;
    va_start(args, message);
    [Ouralabs log:OULogLevelError tag:tag message:message args:args];
    va_end(args);
}

void __attribute__((overloadable)) OULogError(NSString *tag, NSString *message, NSDictionary *kvp) {
    [Ouralabs log:OULogLevelError tag:tag message:message kvp:kvp];
}

void __attribute__((overloadable)) OULogError(NSString *tag, NSString *message, NSException *exception) {
    [Ouralabs log:OULogLevelError tag:tag message:message exception:exception];
}

void __attribute__((overloadable)) OULogError(NSString *tag, NSString *message, NSError *error) {
    [Ouralabs log:OULogLevelError tag:tag message:message error:error];
}

#pragma mark - Fatal C Methods

void __attribute__((overloadable)) OULogFatal(NSString *tag, NSString *message, ...) {
    va_list args;
    va_start(args, message);
    [Ouralabs log:OULogLevelFatal tag:tag message:message args:args];
    va_end(args);
}

void __attribute__((overloadable)) OULogFatal(NSString *tag, NSString *message, NSDictionary *kvp) {
    [Ouralabs log:OULogLevelFatal tag:tag message:message kvp:kvp];
}

void __attribute__((overloadable)) OULogFatal(NSString *tag, NSString *message, NSException *exception) {
    [Ouralabs log:OULogLevelFatal tag:tag message:message exception:exception];
}

void __attribute__((overloadable)) OULogFatal(NSString *tag, NSString *message, NSError *error) {
    [Ouralabs log:OULogLevelFatal tag:tag message:message error:error];
}

#pragma mark - Log Methods

void __attribute__((overloadable)) OULog(OULogLevel level, NSString *tag, NSString *message, ...) {
    va_list args;
    va_start(args, message);
    [Ouralabs log:level tag:tag message:message args:args];
    va_end(args);
}

void __attribute__((overloadable)) OULog(OULogLevel level, NSString *tag, NSString *message, NSException *exception) {
    [Ouralabs log:level tag:tag message:message exception:exception];
}

void __attribute__((overloadable)) OULog(OULogLevel level, NSString *tag, NSString *message, NSError *error) {
    [Ouralabs log:level tag:tag message:message error:error];
}

void __attribute__((overloadable)) OULog(OULogLevel level, NSString *tag, NSString *message, NSDictionary *kvp) {
    [Ouralabs log:level tag:tag message:message kvp:kvp];
}

#pragma mark - Internal Log Methods

void __attribute__((overloadable)) OULogInner(OULogLevel level, NSString *tag, NSString *message, ...) {
    if ([Ouralabs getLoggerLogsAllowed]) {
        va_list args;
        va_start(args, message);
        [Ouralabs log:level tag:tag message:message args:args];
        va_end(args);
    }
}

void __attribute__((overloadable)) OULogInner(OULogLevel level, NSString *tag, NSString *message, NSException *exception) {
    if ([Ouralabs getLoggerLogsAllowed]) {
        [Ouralabs log:level tag:tag message:message exception:exception];
    }
}

void __attribute__((overloadable)) OULogInner(OULogLevel level, NSString *tag, NSString *message, NSError *error) {
    if ([Ouralabs getLoggerLogsAllowed]) {
        [Ouralabs log:level tag:tag message:message error:error];
    }
}

void __attribute__((overloadable)) OULogInner(OULogLevel level, NSString *tag, NSString *message, NSDictionary *kvp) {
    if ([Ouralabs getLoggerLogsAllowed]) {
        [Ouralabs log:level tag:tag message:message kvp:kvp];
    }
}

#pragma mark - Constants

NSString *const OUAttr1 = @"attr_1";
NSString *const OUAttr2 = @"attr_2";
NSString *const OUAttr3 = @"attr_3";

static NSString *const TAG = @"Ouralabs";

static NSString *const VERSION = @"2.7.0";

static const char *LOG_LEVELS[] = {"TRACE", "DEBUG", "INFO", "WARN", "ERROR", "FATAL"};
static const char *LOG_LEVEL_INDICATORS[] = {"T", "D", "I", "W", "E", "F"};

static NSString *const SETTING_API_SCHEME                = @"api_scheme";
static NSString *const SETTING_API_HOST                  = @"api_host";
static NSString *const SETTING_API_TIMEOUT               = @"api_timeout";
static NSString *const SETTING_LOG_LEVEL                 = @"log_level";
static NSString *const SETTING_MAX_FILE_SIZE             = @"max_file_size";
static NSString *const SETTING_MAX_SIZE                  = @"max_size";
static NSString *const SETTING_UPLOAD_INTERVAL_LIVE_TAIL = @"upload_interval_live_tail";
static NSString *const SETTING_UPLOAD_INTERVAL_WIFI      = @"upload_interval_wifi";
static NSString *const SETTING_UPLOAD_INTERVAL_WWAN      = @"upload_interval_wwan";
static NSString *const SETTING_EXPIRATION                = @"expiration";
static NSString *const SETTING_LIVE_TAIL                 = @"live_tail";
static NSString *const SETTING_CERTIFICATE               = @"certificate";
static NSString *const SETTING_DISK_ONLY                 = @"disk_only";
static NSString *const SETTING_BUFFERED                  = @"buffered";
static NSString *const SETTING_LOGGER_LOGS_ALLOWED       = @"logger_logs_allowed";
static NSString *const SETTING_LOG_LIFECYCLE             = @"log_lifecycle";
static NSString *const SETTING_UNCAUGHT_EXCEPTIONS       = @"uncaught_exceptions";
static NSString *const _SETTING_ATTR_1                   = @"_attr_1";
static NSString *const _SETTING_ATTR_2                   = @"_attr_2";
static NSString *const _SETTING_ATTR_3                   = @"_attr_3";
static NSString *const _SETTING_OPT_IN                   = @"_opt_in";
static NSString *const _SETTING_SIMULATOR_VENDOR_ID      = @"_simulator_vendor_id";

#pragma mark - Exception Handler

static NSUncaughtExceptionHandler *original_exception_handler;

void uncaught_exception_handler(NSException *ex) {
    if (ex) {
        OULogFatal(@"Runtime", ex.reason, ex);
    }
    
    if (original_exception_handler) {
        OULogInner(LDEBUG, TAG, @"Forwarding uncaught exception");
        original_exception_handler(ex);
    }
}

#pragma mark - OUDouble

@implementation OUDouble

- (id)initWithDouble:(double)doubleValue scale:(NSInteger)scale {
    if (self = [super init]) {
        _doubleValue = doubleValue;
        _scale = scale;
    }
    return self;
}   

+ (OUDouble *)doubleWithDouble:(double)value scale:(NSInteger)scale {
    return [[OUDouble alloc] initWithDouble:value scale:scale];
}

- (NSString *)stringValue {
    NSMutableString *format = [[NSMutableString alloc] initWithString:@"%."];
    [format appendString:[@(self.scale) stringValue]];
    [format appendString:@"f"];

    return [NSString stringWithFormat:format, [self doubleValue]];
}

@end

#pragma mark - OULogEntry

@interface OULogEntry()
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
- (OULogEntry *)initWithLocation:(CLLocation *)location
                          thread:(NSString *)thread
                            time:(NSTimeInterval)time
                           level:(NSInteger)level
                             tag:(NSString *)tag
                         message:(NSString *)message
                      appVersion:(NSString *)appVersion;
- (NSString *)fullMessage;
@end

@implementation OULogEntry

- (OULogEntry *)initWithLocation:(CLLocation *)location
                          thread:(NSString *)thread
                            time:(NSTimeInterval)time
                           level:(NSInteger)level
                             tag:(NSString *)tag
                         message:(NSString *)message
                      appVersion:(NSString *)appVersion {
    if (self = [super init]) {
        _location = location;
        _thread = thread && thread.length > 0 ? [thread stringByReplacingOccurrencesOfString:@" " withString:@"_"] : @"(null)";
        _time = time;
        _level = level;
        _tag = tag && tag.length > 0 ? tag : @"(null)";
        _message = valOrBlank(message);
        _appVersion = appVersion;
    }
    return self;
}

- (NSString *)fullMessage {
    NSMutableString *str = [NSMutableString new];
    [str appendString:self.appVersion];
    [str appendString:@" "];
    [str appendFormat:@"%.6f", self.location ? self.location.coordinate.latitude : 0.0];
    [str appendString:@","];
    [str appendFormat:@"%.6f", self.location ? self.location.coordinate.longitude : 0.0];
    [str appendString:@" "];
    [str appendFormat:@"%.3f", self.time];
    [str appendString:@" - "];
    [str appendString:self.thread];
    [str appendString:@" ["];
    [str appendString:self.tag];
    [str appendString:@"] "];
    [str appendString:[NSString stringWithCString:LOG_LEVELS[self.level] encoding:NSUTF8StringEncoding]];
    [str appendString:@" "];
    [str appendString:self.message];
    return str;
}

@end

#pragma mark - OUProxyViewController

@implementation UIViewController (OUProxyViewController)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        
        for (NSString *selector in @[@"viewWillAppear:", @"viewWillDisappear:", @"didReceiveMemoryWarning"]) {
            SEL oSel = NSSelectorFromString(selector);
            SEL sSel = NSSelectorFromString([NSString stringWithFormat:@"OU_%@", selector]);
            
            Method oMethod = class_getInstanceMethod(class, oSel);
            Method sMethod = class_getInstanceMethod(class, sSel);
            
            BOOL didAddMethod = class_addMethod(class,
                                                oSel,
                                                method_getImplementation(sMethod),
                                                method_getTypeEncoding(sMethod));
            
            if (didAddMethod) {
                class_replaceMethod(class, sSel, method_getImplementation(oMethod), method_getTypeEncoding(oMethod));
            } else {
                method_exchangeImplementations(oMethod, sMethod);
            }
        }
    });
}

- (void)OU_viewWillAppear:(BOOL)animated {
    [self OU_viewWillAppear:animated];
    
    if ([Ouralabs getLogLifecycle]) {
        OULogInfo(NSStringFromClass([self class]), @"viewWillAppear.", @{@"animated" : @(animated)});
    }
}

- (void)OU_viewWillDisappear:(BOOL)animated {
    [self OU_viewWillDisappear:animated];
    
    if ([Ouralabs getLogLifecycle]) {
        OULogInfo(NSStringFromClass([self class]), @"viewWillDisappear.", @{@"animated" : @(animated)});
    }
}

- (void)OU_didReceiveMemoryWarning {
    [self OU_didReceiveMemoryWarning];
    
    if ([Ouralabs getLogLifecycle]) {
        OULogInfo(NSStringFromClass([self class]), @"didReceiveMemoryWarning.");
    }
}

@end

#pragma mark - Ouralabs

@implementation Ouralabs

static NSRecursiveLock          *sLock;
static NSData                   *sNewLine;

static NSOperationQueue         *sOperationQueue;
static SCNetworkReachabilityRef  sReachabilityRef;
static BOOL                      sInitialized;
static NSString                 *sChannelKey;
static NSNumber                 *sLogLevel;
static NSNumber                 *sLiveTail;
static NSNumber                 *sDiskOnly;
static NSNumber                 *sBuffered;
static NSMutableArray           *sQueue;
static NSMutableDictionary      *sSettings;
static NSString                 *sAppVersion;
static NSString                 *sNameID;
static NSString                 *sVendorID;
static NSMutableDictionary      *sAttributes;
static CLLocation               *sLocation;
static BOOL                      sDisableTimedOperations;
static NSNumber                 *sLoggerLogsAllowed;
static OUSettingsChangedBlock    sSettingsChangedBlock;
static OULogBlock                sLogBlock;
static dispatch_queue_t          sLogBlockDispatchQueue;
static NSNumber                 *sLogLifecycle;
static NSNumber                 *sUncaughtExceptions;

static NSString *sApplicationName;
static pid_t     sPid;

static NSData *sAESKey;
static NSData *sEncryptedAESKey;

static BOOL sLifecycleHooked;

static NSArray *sNotifications;
static void (^sObserver)(NSNotification *);

static NSString          *sLibraryFile;
static NSString          *sFile;
static unsigned long long sFileSize;
static NSMutableArray    *sFiles;
static NSFileHandle      *sFileHandle;
static NSFileManager     *sFileManager;
static NSDateFormatter   *sDateFormatter;

typedef void (^OUResponse) (NSInteger statusCode, NSDictionary *dict, NSError *error);

static dispatch_block_t sSettingsBlock;
static dispatch_block_t sUploadBlock;
static dispatch_block_t sQueueBlock;

static NSTimer *sSettingsTimer;
static NSTimer *sUploadTimer;

#pragma mark - Static Init

+ (void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sNewLine = [@"\n" dataUsingEncoding:NSUTF8StringEncoding];
        
        sOperationQueue = [[NSOperationQueue alloc] init];
        sOperationQueue.name = @"com.ouralabs";
        sOperationQueue.maxConcurrentOperationCount = 1;
        
        sLock        = [NSRecursiveLock new];
        sQueue       = [NSMutableArray new];
        sFileManager = [NSFileManager defaultManager];
        sLibraryFile = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        
        sDateFormatter = [[NSDateFormatter alloc] init];
        sDateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss.SSS";
        
        sApplicationName = valOrBlank([[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"]);
        sPid = getpid();
        original_exception_handler = NSGetUncaughtExceptionHandler();
        
        sSettings    = [NSMutableDictionary dictionaryWithDictionary:
                        @{SETTING_API_SCHEME                : @"https",
                          SETTING_API_HOST                  : @"www.ouralabs.com",
                          SETTING_API_TIMEOUT               : @(120),
                          SETTING_LOG_LEVEL                 : @(OULogLevelWarn),
                          SETTING_MAX_FILE_SIZE             : @(1024 * 512),
                          SETTING_MAX_SIZE                  : @(1024 * 1024 * 20),
                          SETTING_DISK_ONLY                 : @(YES),
                          SETTING_BUFFERED                  : @(NO),
                          SETTING_UPLOAD_INTERVAL_LIVE_TAIL : @(5),
                          SETTING_UPLOAD_INTERVAL_WIFI      : @(60 * 5),
                          SETTING_UPLOAD_INTERVAL_WWAN      : @(60 * 60),
                          SETTING_EXPIRATION                : @(60 * 60),
                          SETTING_LIVE_TAIL                 : @(NO),
                          SETTING_CERTIFICATE               : @"",
                          SETTING_LOGGER_LOGS_ALLOWED       : @(NO),
                          SETTING_LOG_LIFECYCLE             : @(YES),
                          SETTING_UNCAUGHT_EXCEPTIONS       : @(NO)}];
        
        sNotifications = @[UIApplicationDidEnterBackgroundNotification,
                           UIApplicationWillEnterForegroundNotification,
                           UIApplicationDidFinishLaunchingNotification,
                           UIApplicationDidBecomeActiveNotification,
                           UIApplicationWillResignActiveNotification,
                           UIApplicationDidReceiveMemoryWarningNotification,
                           UIApplicationWillTerminateNotification,
                           UIApplicationSignificantTimeChangeNotification,
                           UIApplicationWillChangeStatusBarOrientationNotification,
                           UIApplicationDidChangeStatusBarOrientationNotification,
                           UIApplicationWillChangeStatusBarFrameNotification,
                           UIApplicationDidChangeStatusBarFrameNotification,
                           UIApplicationBackgroundRefreshStatusDidChangeNotification,
                           UIApplicationLaunchOptionsRemoteNotificationKey,
                           UIApplicationLaunchOptionsLocalNotificationKey,
                           UIContentSizeCategoryDidChangeNotification,
                           UIApplicationUserDidTakeScreenshotNotification,
                           UIDeviceOrientationDidChangeNotification,
                           NSHTTPCookieManagerAcceptPolicyChangedNotification,
                           NSHTTPCookieManagerCookiesChangedNotification];
        
        struct sockaddr_in zeroaddr;
        bzero(&zeroaddr, sizeof(zeroaddr));
        zeroaddr.sin_len = sizeof(zeroaddr);
        zeroaddr.sin_family = AF_INET;
        sReachabilityRef = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, (const struct sockaddr*) &zeroaddr);
        
        sObserver = ^(NSNotification *note) {
            OULogInfo(TAG, [NSString stringWithFormat:@"%@.", note.name], note.userInfo);
        };
        
        sSettingsBlock = ^{
            if ([self isConnected]) {
                NSTimeInterval start = now();
                
                NSString *base = [NSString stringWithFormat:@"api/v1/channels/%@/settings?", sChannelKey];
                
                base = [self appendQueryParams:base dict:[self device]];
                
                [self makeRequest:base body:nil response:^(NSInteger statusCode, NSDictionary *dict, NSError *error) {
                    NSTimeInterval delta = now() - start;
                    
                    if (statusCode == 200) {
                        lock();
                        for (NSString *key in [dict allKeys]) {
                            id val = dict[key];
                            
                            sSettings[key] = val;
                        }
                        [self updateFiles];
                        [self loadPublicKey];
                        unlock();
                        
                        [self saveSettings];
                        [self publishSettingsChanged];
                        [self toggleUncaughtExceptionHandler];
                    } else {
                        NSString *errorString = error ? error.description : dict[@"error"];
                        
                        OULogInner(LERROR, TAG, @"Could not retrieve settings.", @{@"time"   : OUDouble(delta, 3),
                                                                                   @"error"  : errorString,
                                                                                   @"status" : @(statusCode)});
                    }
                    
                }];
            } else {
                OULogInner(LWARN, TAG, @"Could not update settings. Not connected to the internet.");
            }
            
            if ([self getDisableTimedOperations]) return;
            
            NSTimeInterval nextDispatch = [self nextDispatch:[sSettings[SETTING_EXPIRATION] doubleValue]];
            
            if (sSettingsTimer) [sSettingsTimer invalidate];
            
            sSettingsTimer = [NSTimer timerWithTimeInterval:nextDispatch
                                                     target:self
                                                   selector:@selector(dispatchTimer:)
                                                   userInfo:sSettingsBlock
                                                    repeats:NO];
            [[NSRunLoop mainRunLoop] addTimer:sSettingsTimer forMode:NSRunLoopCommonModes];
        };
        
        sUploadBlock = ^{
            if ([self isConnected]) {
                NSMutableArray *files;
                
                NSString *base = [NSString stringWithFormat:@"api/v1/channels/%@/logs?", sChannelKey];
                
                NSString *workingDir = [self workingDirectory];
                
                lock();
                [self rollFile];
                
                files = [self sort:[self filter:[self listFiles:[self directory]]]];
                
                // copy files
                for (NSString *file in files) {
                    if ([[sFileManager attributesOfItemAtPath:file error:nil] fileSize] == 0) {
                        [self removeFile:file];
                    } else {
                        NSString *outPath = [[self workingDirectory] stringByAppendingPathComponent:[file lastPathComponent]];
                    
                        [self copyFile:file to:outPath];
                    }
                }
                unlock();
                
                files = [self listFiles:workingDir];
                
                for (NSString *file in files) {
                    NSTimeInterval start = now();
                    NSError *error;
                    NSString  *text = [NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:&error];
                    NSUInteger size = [text lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
                    
                    if (error) {
                        OULogInner(LERROR, TAG, @"Could not upload file.", error);
                    } else {
                        NSDictionary *dict = @{@"device" : [self device],
                                               @"text"   : text};
                        
                        NSData *json = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&error];
                        
                        if (error) {
                            OULogInner(LERROR, TAG, @"Could not build json.", error);
                            error = nil;
                        } else {
                            [self makeRequest:base body:json response:^(NSInteger statusCode, NSDictionary *dict, NSError *error) {
                                NSTimeInterval delta = now() - start;
                                NSString *original = [[self directory] stringByAppendingPathComponent:[file lastPathComponent]];
                                
                                if (statusCode == 201) {
                                    [self removeFile:original];
                                } else if (statusCode == 404) {
                                    OULogInner(LERROR, TAG, @"Invalid channel key.", @{@"time"   : OUDouble(delta, 3),
                                                                                       @"status" : @(statusCode)});
                                    
                                    [self removeFile:original];
                                } else {
                                    NSString *errorString = error ? error.description : dict[@"error"];
                                    
                                    OULogInner(LERROR, TAG, @"Could not upload logs.", @{@"time"   : OUDouble(delta, 3),
                                                                                         @"error"  : errorString,
                                                                                         @"status" : @(statusCode),
                                                                                         @"size"   : @(size)});
                                }
                                
                                [self removeFile:file];
                            }];
                        }
                    }
                }
            } else {
                OULogInner(LWARN, TAG, @"Could not upload logs. Not connected to internet.");
            }
            
            if ([self getDisableTimedOperations] && ![self getLiveTail]) return;
            
            NSTimeInterval nextDispatch;
            
            if ([self getLiveTail]) {
                nextDispatch = [self nextDispatch:[sSettings[SETTING_UPLOAD_INTERVAL_LIVE_TAIL] doubleValue]];
            } else {
                if ([self isWifi]) {
                    nextDispatch = [self nextDispatch:[sSettings[SETTING_UPLOAD_INTERVAL_WIFI] doubleValue]];
                } else {
                    nextDispatch = [self nextDispatch:[sSettings[SETTING_UPLOAD_INTERVAL_WWAN] doubleValue]];
                }
            }
            
            if (sUploadTimer) [sUploadTimer invalidate];
            
            sUploadTimer = [NSTimer timerWithTimeInterval:nextDispatch
                                                   target:self
                                                 selector:@selector(dispatchTimer:)
                                                 userInfo:sUploadBlock
                                                  repeats:NO];
            [[NSRunLoop mainRunLoop] addTimer:sUploadTimer forMode:NSRunLoopCommonModes];
        };
        
        sQueueBlock = ^{
            NSMutableArray *logs = [NSMutableArray new];
            
            lock();
            [logs addObjectsFromArray:sQueue];
            [sQueue removeAllObjects];
            unlock();
            
            for (OULogEntry *log in logs) {
                [self processLog:log];
            }
            
            lock();
            if (sQueue.count > 0) {
                [self dispatchBlock:sQueueBlock];
            }
            unlock();
        };
    });
}

#pragma mark - Init

+ (void)initWithKey:(NSString *)key {
    lock();
    
    if (sInitialized) {
        OULogWarn(TAG, @"Ouralabs already initialized.");
    } else if (!key || key.length == 0) {
        OULogError(TAG, @"Cannot init with null or empty channel key.");
    } else {
        sInitialized   = YES;
        sChannelKey    = key;
        sAESKey        = [self generateAESKey];
        
        [self loadSettings];
        
        sVendorID      = [self vendorID];
        sNameID        = [self sha256:[[UIDevice currentDevice] name]];
        
        [self updateFiles];
        [self toggleUncaughtExceptionHandler];
        
        OULogInner(LINFO, TAG, @"Initialized Ouralabs.");
        
        [self dispatchBlock:sSettingsBlock];
        [self dispatchBlock:sQueueBlock];
        [self dispatchBlock:sUploadBlock];
        
        [self publishSettingsChanged];
    }
    
    unlock();
}

#pragma mark - Public API

+ (void)setLiveTail:(NSNumber *)liveTail {
    OULogInner(LINFO, TAG, @"Set live tail.", @{@"liveTail" : valOr(liveTail, [NSNull null])});
    
    lock();
    sLiveTail = liveTail;
    [self publishSettingsChanged];
    unlock();
}

+ (void)setAppVersion:(NSString *)appVersion {
    OULogInner(LINFO, TAG, @"Set app version.", @{@"appVersion" : valOr(appVersion, [NSNull null])});
    
    lock();
    sAppVersion = appVersion;
    unlock();
}

+ (void)setLogLevel:(NSNumber *)logLevel {
    OULogInner(LINFO, TAG, @"Set log level.", @{@"logLevel" : valOr(logLevel, [NSNull null])});
    
    lock();
    sLogLevel = logLevel;
    
    if (sLogLevel) {
        NSInteger intValue = [sLogLevel integerValue];
        sLogLevel = @(MIN(OULogLevelFatal, MAX(OULogLevelTrace, intValue)));
    }
    
    [self publishSettingsChanged];
    unlock();
}

+ (void)setAttributes:(NSDictionary *)attributes {
    OULogInner(LINFO, TAG, @"Set attributes.", @{@"attributes" : valOr(attributes, [NSNull null])});
    
    lock();
    if (!sAttributes) sAttributes = [NSMutableDictionary new];
    if (!attributes) attributes = [NSMutableDictionary new];
    
    NSString *attr1 = valOrBlank(sAttributes[OUAttr1]);
    NSString *attr2 = valOrBlank(sAttributes[OUAttr2]);
    NSString *attr3 = valOrBlank(sAttributes[OUAttr3]);
    
    BOOL changed;
    
    changed = ![attr1 isEqualToString:attributes[OUAttr1]];
    changed = changed || ![attr2 isEqualToString:attributes[OUAttr2]];
    changed = changed || ![attr3 isEqualToString:attributes[OUAttr3]];
    
    sAttributes = [NSMutableDictionary dictionaryWithDictionary:attributes];
    
    if (changed) {
        [sSettingsTimer invalidate];
        [self dispatchBlock:sSettingsBlock];
    }
    
    unlock();
}

+ (void)setOptIn:(BOOL)optIn {
    OULogInner(LINFO, TAG, @"Set opt in.", @{@"optIn" : @(optIn)});
    
    lock();
    sSettings[_SETTING_OPT_IN] = @(optIn);
    [self saveSettings];
    unlock();
}

+ (void)setDiskOnly:(NSNumber *)diskOnly {
    OULogInner(LINFO, TAG, @"Set disk only.", @{@"diskOnly" : valOr(diskOnly, [NSNull null])});
    
    lock();
    sDiskOnly = diskOnly;
    unlock();
}

+ (void)setBuffered:(NSNumber *)buffered {
    OULogInner(LINFO, TAG, @"Set buffered.", @{@"buffered" : valOr(buffered, [NSNull null])});
    
    lock();
    sBuffered = buffered;
    unlock();
}

+ (void)setLocation:(CLLocation *)location {
    OULogInner(LINFO, TAG, @"Set location.", @{@"location" : valOr(location, [NSNull null])});
    
    lock();
    sLocation = location;
    unlock();
}

+ (void)setDisableTimedOperations:(BOOL)disable {
    OULogInner(LINFO, TAG, @"Set disable timed operations.", @{@"disable" : @(disable)});
    
    lock();
    sDisableTimedOperations = disable;
    unlock();
}

+ (void)setLoggerLogsAllowed:(NSNumber *)allowed {
    OULogInner(LINFO, TAG, @"Set logger logs allowed.", @{@"allowed" : valOr(allowed, [NSNull null])});
    
    lock();
    sLoggerLogsAllowed = allowed;
    unlock();
}

+ (void)setSettingsChangedBlock:(OUSettingsChangedBlock)settingsChangedBlock {
    OULogInner(LINFO, TAG, @"Set settings changed block.");
    
    lock();
    sSettingsChangedBlock = settingsChangedBlock;
    unlock();
}

+ (void)setLogLifecycle:(NSNumber *)enable {
    OULogInner(LINFO, TAG, @"Set log lifecycle.", @{@"enable" : valOr(enable, [NSNull null])});
    
    lock();
    sLogLifecycle = enable;
    
    [self toggleLogLifecycle];
    unlock();
}

+ (void)setLogUncaughtExceptions:(NSNumber *)enable {
    OULogInner(LINFO, TAG, @"Set log uncaught exceptions.", @{@"enable" : valOr(enable, [NSNull null])});
    
    lock();
    sUncaughtExceptions = enable;
    unlock();
    
    [self toggleUncaughtExceptionHandler];
}

+ (void)setLogBlock:(OULogBlock)logBlock {
    [self setLogBlock:logBlock queue:dispatch_get_main_queue()];
}

+ (void)setLogBlock:(OULogBlock)logBlock queue:(dispatch_queue_t)queue {
    OULogInner(LINFO, TAG, @"Set log block.");
    
    lock();
    sLogBlock = logBlock;
    sLogBlockDispatchQueue = queue;
    unlock();
}

+ (BOOL)getInitialized {
    lock();
    BOOL val = sInitialized;
    unlock();
    return val;
}

+ (BOOL)getLiveTail {
    lock();
    BOOL val;
    if (sLiveTail) {
        val = [sLiveTail boolValue];
    } else {
        val = [sSettings[SETTING_LIVE_TAIL] boolValue];
    }
    unlock();
    return val;
}

+ (OULogLevel)getLogLevel {
    lock();
    OULogLevel val;
    if (sLogLevel) {
        val = [sLogLevel integerValue];
    } else {
        val = [sSettings[SETTING_LOG_LEVEL] integerValue];
    }
    unlock();
    return val;
}

+ (BOOL)getOptIn {
    lock();
    BOOL val;
    if (sSettings[_SETTING_OPT_IN]) {
        val = [sSettings[_SETTING_OPT_IN] boolValue];
    } else {
        val = YES;
    }
    unlock();
    return val;
}

+ (BOOL)getDiskOnly {
    lock();
    BOOL val;
    if (sDiskOnly) {
        val = [sDiskOnly boolValue];
    } else {
        val = sSettings[SETTING_DISK_ONLY] ? [sSettings[SETTING_DISK_ONLY] boolValue] : YES;
    }
    unlock();
    return val;
}

+ (BOOL)getBuffered {
    lock();
    BOOL val;
    if (sBuffered) {
        val = [sBuffered boolValue];
    } else {
        val = sSettings[SETTING_BUFFERED] ? [sSettings[SETTING_BUFFERED] boolValue] : NO;
    }
    unlock();
    return val;
}

+ (NSString *)getAppVersion {
    lock();
    NSString *val;
    
    if (sAppVersion) {
        val = sAppVersion;
    } else {
        NSString *shortVersion = valOr([[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"], @"0.0.0");
        NSString *longVersion  = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
        
        if (longVersion && longVersion.length > 0) {
            sAppVersion = [NSString stringWithFormat:@"%@-%@", shortVersion, longVersion];
        } else {
            sAppVersion = shortVersion;
        }
        
        val = sAppVersion;
    }
    unlock();
    return val;
}

+ (NSString *)getVersion {
    return VERSION;
}

+ (NSDictionary *)getAttributes {
    lock();
    NSMutableDictionary *attrs = [NSMutableDictionary new];
    
    if (sAttributes) {
        [attrs addEntriesFromDictionary:sAttributes];
    }
    
    unlock();
    return attrs;
}

+ (CLLocation *)getLocation {
    lock();
    CLLocation *val = sLocation;
    unlock();
    return val;
}

+ (BOOL)getDisableTimedOperations {
    lock();
    BOOL val = sDisableTimedOperations;
    unlock();
    return val;
}

+ (BOOL)getLoggerLogsAllowed {
    lock();
    BOOL val;
    if (sLoggerLogsAllowed) {
        val = [sLoggerLogsAllowed boolValue];
    } else {
        val = sSettings[SETTING_LOGGER_LOGS_ALLOWED] ? [sSettings[SETTING_LOGGER_LOGS_ALLOWED] boolValue] : NO;
    }
    unlock();
    return val;
}

+ (OUSettingsChangedBlock)getSettingsChangedBlock {
    lock();
    OUSettingsChangedBlock block = sSettingsChangedBlock;
    unlock();
    return block;
}

+ (BOOL)getLogLifecycle {
    BOOL val;
    lock();
    if (sLogLifecycle) {
        val = [sLogLifecycle boolValue];
    } else {
        val = sSettings[SETTING_LOG_LIFECYCLE] ? [sSettings[SETTING_LOG_LIFECYCLE] boolValue] : NO;
    }
    unlock();
    return val;
}

+ (BOOL)getLogUncaughtExceptions {
    BOOL val;
    lock();
    if (sUncaughtExceptions) {
        val = [sUncaughtExceptions boolValue];
    } else {
        val = sSettings[SETTING_UNCAUGHT_EXCEPTIONS] ? [sSettings[SETTING_UNCAUGHT_EXCEPTIONS] boolValue] : NO;
    }
    unlock();
    return val;
}

+ (OULogBlock)getLogBlock {
    OULogBlock block;
    lock();
    block = sLogBlock;
    unlock();
    return block;
}

+ (void)update {
    lock();
    if (sInitialized) {
        OULogInner(LINFO, TAG, @"Forcing update");
        
        [sSettingsTimer invalidate];
        [sUploadTimer invalidate];
        
        [self dispatchBlock:sSettingsBlock];
        [self dispatchBlock:sUploadBlock];
    } else {
        OULogInner(LWARN, TAG, @"Attempted to update without initializing");
    }
    unlock();
}

+ (void)flush {
    lock();
    if (sInitialized) {
        OULogInner(LINFO, TAG, @"Forcing flush");
        
        [sUploadTimer invalidate];
        [self dispatchBlock:sUploadBlock];
    } else {
        OULogInner(LWARN, TAG, @"Attempted to flush without initializing");
    }
    unlock();
}

+ (void)log:(OULogLevel)level tag:(NSString *)tag message:(NSString *)message, ... {
    if (![self shouldLog:@(level)]) return;
    
    va_list args;
    va_start(args, message);
    [self log:level tag:tag message:message args:args];
    va_end(args);
}

+ (void)log:(OULogLevel)level tag:(NSString *)tag message:(NSString *)message args:(va_list)args {
    if (![self shouldLog:@(level)]) return;
    
    [self logInternal:@(level) tag:tag message:[[NSString alloc] initWithFormat:valOrBlank(message) arguments:args]];
}

+ (void)log:(OULogLevel)level tag:(NSString *)tag message:(NSString *)message exception:(NSException *)exception {
    if (![self shouldLog:@(level)]) return;
    
    [self logInternal:@(level) tag:tag message:[NSString stringWithFormat:@"%@\n%@", valOrBlank(message), (exception ? [exception callStackSymbols] : @"")]];
}

+ (void)log:(OULogLevel)level tag:(NSString *)tag message:(NSString *)message error:(NSError *)error {
    if (![self shouldLog:@(level)]) return;
    
    [self logInternal:@(level) tag:tag message:[NSString stringWithFormat:@"%@\n%@", valOrBlank(message), (error ? error.description : @"")]];
}

+ (void)log:(OULogLevel)level tag:(NSString *)tag message:(NSString *)message kvp:(NSDictionary *)kvp {
    if (![self shouldLog:@(level)]) return;
    
    [self logInternal:@(level) tag:tag message:[NSString stringWithFormat:@"%@ %@", valOrBlank(message), (kvp ? [self kvpToString:kvp] : @"")]];
}

#pragma mark - Internals

+ (void)logInternal:(NSNumber *)level tag:(NSString *)tag message:(NSString *)message {
    lock();

    OULogEntry *log = [[OULogEntry alloc] initWithLocation:[self getLocation]
                                                    thread:[self threadName]
                                                      time:now()
                                                     level:[level integerValue]
                                                       tag:tag
                                                   message:message
                                                appVersion:[self getAppVersion]];
    
    if ([self getBuffered] && level.integerValue < OULogLevelError) {
        [sQueue addObject:log];
        
        if (sQueue.count == 1) {
            [self dispatchBlock:sQueueBlock];
        }
    } else {
        [self processLog:log];
    }
    
    unlock();
}

+ (void)processLog:(OULogEntry *)log {
    if (![self getDiskOnly]) {
        printf("%s %s[%d:%s] %s/%s %s\n",
               [sDateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:log.time]].UTF8String,
               sApplicationName.UTF8String,
               sPid,
               log.thread.UTF8String,
               LOG_LEVEL_INDICATORS[log.level],
               log.tag.UTF8String,
               log.message.UTF8String);
    }

    lock();
    if (sLogBlock) {
        dispatch_async(sLogBlockDispatchQueue, ^{
            sLogBlock(log);
        });
    }
    
    if (sFileHandle && sEncryptedAESKey) {
        NSData *iv = [self generateAESIV];
        NSData *encrypted = [self AESEncrypt:[[log fullMessage] dataUsingEncoding:NSUTF8StringEncoding]
                                         key:sAESKey
                                          iv:iv];

        if (encrypted) {
            NSMutableData *merged = [NSMutableData new];
            [merged appendData:sEncryptedAESKey];
            [merged appendData:iv];
            [merged appendData:encrypted];
            
            NSData *base64 = [merged base64EncodedDataWithOptions:0];
            
            [sFileHandle writeData:base64];
            [sFileHandle writeData:sNewLine];
            
            sFileSize += base64.length + 1; // +1 for new line char
        }
        
        if (sFileSize >= [sSettings[SETTING_MAX_FILE_SIZE] integerValue]) [self rollFile];
    }
    unlock();
}

+ (BOOL)shouldLog:(NSNumber *)requestLevel {
    lock();
    BOOL val;
    if (!sInitialized) {
        val = NO;
    } else if (!sEncryptedAESKey) {
        val = NO;
    } else if (![self getOptIn]) {
        val = NO;
    } else {
        if (sLogLevel) {
            val = [requestLevel integerValue] >= [sLogLevel integerValue];
        } else {
            val = [requestLevel integerValue] >= [sSettings[SETTING_LOG_LEVEL] integerValue];
        }
    }
    unlock();
    return val;
}

+ (void)publishSettingsChanged {
    lock();
    OUSettingsChangedBlock block = [self getSettingsChangedBlock];
    if (block) {
        dispatch_async(dispatch_get_main_queue(), ^{
            block([self getLiveTail], [self getLogLevel]);
        });
    }
    unlock();
}

+ (NSString *)rootDirectory {
    NSString *directory = [sLibraryFile stringByAppendingPathComponent:@"ouralabs"];
    [self createDirectory:directory];
    return directory;
}

+ (NSString *)directory {
    NSString *directory = [[self rootDirectory] stringByAppendingPathComponent:sChannelKey];
    [self createDirectory:directory];
    return directory;
}

+ (NSString *)workingDirectory {
    NSString *directory = [[self directory] stringByAppendingPathComponent:@"working"];
    [self createDirectory:directory];
    return directory;
}

+ (NSString *)file {
    NSString *file = [[self directory] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.txt", sChannelKey]];
    
    if (![sFileManager fileExistsAtPath:file]) {
        [sFileManager createFileAtPath:file contents:nil attributes:nil];
    }
    
    return file;
}

+ (NSString *)rolledFile:(NSString *)file {
    NSString *parent = [file stringByDeletingLastPathComponent];
    
    NSString *extension = [file pathExtension];
    NSString *name = [[file lastPathComponent] stringByDeletingPathExtension];
    
    NSString *newName = [NSString stringWithFormat:@"%@.%lld.%@", name, (long long)(now() * 1000), extension];
    NSString *toFile = [parent stringByAppendingPathComponent:newName];
    
    return toFile;
}

+ (void)rollFile {
    NSString *rollTo = [self rolledFile:sFile];
    
    [self copyFile:sFile to:rollTo];
    [self removeFile:sFile];
    [self updateFiles];
    
    NSInteger total = 0, delCount = 0;
    
    for (NSInteger i = sFiles.count - 1; i >= 0; i--) {
        NSString *path = sFiles[i];
        
        total += [[sFileManager attributesOfItemAtPath:path error:nil] fileSize];
        
        if (total > [sSettings[SETTING_MAX_SIZE] integerValue]) {
            delCount++;
        }
    }
    
    for (NSInteger i = 0; i < delCount; i++) {
        NSString *path = sFiles[i];
        
        [self removeFile:path];
        [sFiles removeObject:path];
    }
}

+ (void)clearDir:(NSString *)file {
    BOOL isDir;
    
    [sFileManager fileExistsAtPath:file isDirectory:&isDir];
    
    if (isDir) {
        NSDirectoryEnumerator *enumerator = [sFileManager enumeratorAtPath:file];
        
        NSString *fname;
        while (fname = [enumerator nextObject]) {
            BOOL isChildDir;
            [sFileManager fileExistsAtPath:fname isDirectory:&isChildDir];
            
            if (isChildDir) {
                [self clearDir:fname];
            } else {
                [self removeFile:fname];
            }
        }
    }
}

+ (void)loadSettings {
    lock();
    NSMutableDictionary *dict = [NSMutableDictionary new];
    NSString *file = [[self directory] stringByAppendingPathComponent:@"settings.json"];
    
    if ([sFileManager fileExistsAtPath:file isDirectory:nil]) {
        [dict addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:file]];
    }
    
    for (NSString *key in [dict allKeys]) {
        id val = dict[key];
        
        if ([key hasPrefix:@"_attr"]) continue;
        
        sSettings[key] = val;
    }
    
    if (!sAttributes) sAttributes = [NSMutableDictionary new];
    
    if (dict[_SETTING_ATTR_1]) sAttributes[OUAttr1] = dict[_SETTING_ATTR_1];
    if (dict[_SETTING_ATTR_2]) sAttributes[OUAttr2] = dict[_SETTING_ATTR_2];
    if (dict[_SETTING_ATTR_3]) sAttributes[OUAttr3] = dict[_SETTING_ATTR_3];
    
    [self loadPublicKey];
    unlock();
}

+ (void)saveSettings {
    lock();
    if (sAttributes) {
        if (sAttributes[OUAttr1]) sSettings[_SETTING_ATTR_1] = sAttributes[OUAttr1];
        if (sAttributes[OUAttr2]) sSettings[_SETTING_ATTR_2] = sAttributes[OUAttr2];
        if (sAttributes[OUAttr3]) sSettings[_SETTING_ATTR_3] = sAttributes[OUAttr3];
    }
    
    NSString *file = [[self directory] stringByAppendingPathComponent:@"settings.json"];
    [sSettings writeToFile:file atomically:YES];
    unlock();
}

+ (NSDictionary *)device {
    UIDevice *device = [UIDevice currentDevice];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:@{@"platform"         : @"ios",
                                                                                @"platform_version" : valOrBlank([device systemVersion]),
                                                                                @"manufacturer"     : @"apple",
                                                                                @"model"            : valOrBlank([self model]),
                                                                                @"name_id"          : valOrBlank(sNameID),
                                                                                @"vendor_id"        : valOrBlank(sVendorID),
                                                                                @"app_identifier"   : valOr([[NSBundle mainBundle] bundleIdentifier], @"unknown"),
                                                                                @"app_version"      : valOrBlank([self getAppVersion]),
                                                                                @"opt_in"           : @([self getOptIn]),
                                                                                @"live_tail"        : valOr(sLiveTail, [NSNull null]),
                                                                                @"log_level"        : valOr(sLogLevel, [NSNull null])}];
    
    if (sAttributes) {
        if (sAttributes[OUAttr1]) dict[OUAttr1] = sAttributes[OUAttr1];
        if (sAttributes[OUAttr2]) dict[OUAttr2] = sAttributes[OUAttr2];
        if (sAttributes[OUAttr3]) dict[OUAttr3] = sAttributes[OUAttr3];
    }
    
    return dict;
}

+ (BOOL)isWifi {
    if ([self isConnected]) return NO;
    
    SCNetworkReachabilityFlags flags = 0;
    BOOL wifi = YES;
    
    if (SCNetworkReachabilityGetFlags(sReachabilityRef, &flags)) {
        wifi = !(flags & kSCNetworkReachabilityFlagsIsWWAN);
    }
    
    return wifi;
}

+ (BOOL)isConnected {
    SCNetworkReachabilityFlags flags = 0;
    BOOL connected = YES;
    
    if (!SCNetworkReachabilityGetFlags(sReachabilityRef, &flags)) {
        connected = NO;
    } else {
        if (!(flags & kSCNetworkReachabilityFlagsReachable)) {
            connected = NO;
        }
    }
    
    return connected;
}

+ (NSString *)vendorID {
    if ([[[UIDevice currentDevice] model] hasSuffix:@"Simulator"]) {
        NSString *vid = sSettings[_SETTING_SIMULATOR_VENDOR_ID];
        
        if (!vid) {
            vid = [[NSUUID UUID] UUIDString];
            sSettings[_SETTING_SIMULATOR_VENDOR_ID] = vid;
            
            [self saveSettings];
        }
        
        return vid;
    } else {
        return [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    }
}

+ (NSString *)sha256:(NSString *)clear {
    const char *str = [clear UTF8String];
    unsigned char result[CC_SHA256_DIGEST_LENGTH];
    
    CC_SHA256(str, (CC_LONG)strlen(str), result);
    
    NSMutableString *ret = [NSMutableString stringWithCapacity:CC_SHA256_DIGEST_LENGTH * 2];
    for (int i = 0; i < CC_SHA256_DIGEST_LENGTH; i++) {
        [ret appendFormat:@"%02x", result[i]];
    }
    return ret;
}

+ (NSTimeInterval)nextDispatch:(NSTimeInterval)val {
    long long interval     = (long long) val * 1000;
    long long offset       = [[[UIDevice currentDevice] name] hash] % interval;
    long long now          = (long long) (now() * 1000);
    long long current      = (now % 86400000) + offset;
    long long next         = ceil(((double) current / interval) * interval) - current;
    long long nextDispatch = next == 0 ? interval : next;
    
    return nextDispatch / 1000.0;
}

+ (void)updateFiles {
    if (sFileHandle) [sFileHandle closeFile];
    
    sFile     = [self file];
    sFileSize = [[sFileManager attributesOfItemAtPath:sFile error:nil] fileSize];
    
    [sFiles removeAllObjects];
    
    NSError *error;
    NSString *directory   = [self directory];
    NSArray *files        = [sFileManager contentsOfDirectoryAtPath:directory error:&error];
    NSMutableArray *paths = [NSMutableArray new];
    
    for (NSString *path in files) {
        [paths addObject:[directory stringByAppendingPathComponent:path]];
    }
    
    if (error) {
        OULogInner(LERROR, TAG, @"Could not update files.", error);
    } else {
        sFiles = [self sort:[self filter:paths]];
    }
    
    sFileHandle = [NSFileHandle fileHandleForWritingAtPath:sFile];
}

+ (NSMutableArray *)filter:(NSMutableArray *)array {
    NSMutableArray *removeList = [NSMutableArray new];
    
    for (NSString *path in array) {
        NSString *filename = [path lastPathComponent];
        
        if ([@"settings.json" isEqualToString:filename]) {
            [removeList addObject:path];
        } else if ([[[self workingDirectory] lastPathComponent] isEqualToString:filename]) {
            [removeList addObject:path];
        } else if ([[sFile lastPathComponent] isEqualToString:filename]) {
            [removeList addObject:path];
        }
    }
    
    [array removeObjectsInArray:removeList];
    return array;
}

+ (NSMutableArray *)sort:(NSMutableArray *)array {
    NSMutableArray *sortedArray = [NSMutableArray arrayWithArray:[array sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSString *path1         = (NSString *) obj1;
        NSString *path2         = (NSString *) obj2;
        
        return [path1 compare:path2];
    }]];
    
    return sortedArray;
}

+ (NSString *)appendQueryParams:(NSString *)base dict:(NSDictionary *)params {
    for (NSString *key in [params allKeys]) {
        id val = params[key];
        NSString *value;
        
        if ([val isKindOfClass:[NSString class]]) {
            value = (NSString *)val;
        } else if ([val isKindOfClass:[NSNull class]]) {
            value = @"null";
        } else {
            value = [val stringValue];
        }
        
        base = [base stringByAppendingString:[NSString stringWithFormat:@"%@=%@&", key, [self urlEncode:value]]];
    }
    
    return base;
}

+ (NSString *)urlEncode:(NSString *)str {
    return [str stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
}

+ (BOOL)removeFile:(NSString *)file {
    if (![sFileManager fileExistsAtPath:file]) return YES;
    
    NSError *error;
    [sFileManager removeItemAtPath:file error:&error];
    
    if (error) {
        OULogInner(LERROR, TAG, @"Could not remove file.", error);
        return NO;
    } else {
        return YES;
    }
}

+ (BOOL)copyFile:(NSString *)original to:(NSString *)toPath {
    NSError *error;
    [self removeFile:toPath];
    [sFileManager copyItemAtPath:original toPath:toPath error:&error];
    
    if (error) {
        OULogInner(LERROR, TAG, @"Could not copy file.", error);
        return NO;
    } else {
        return YES;
    }
}

+ (void)createDirectory:(NSString *)directory {
    if (![sFileManager fileExistsAtPath:directory isDirectory:nil]) {
        NSError *error;
        
        [sFileManager createDirectoryAtPath:directory withIntermediateDirectories:YES attributes:nil error:&error];
        
        if (error) OULogInner(LERROR, TAG, @"Could not create directory.", error);
    }
}

+ (NSMutableArray *)listFiles:(NSString *)dirPath {
    NSMutableArray *arr = [NSMutableArray new];
    NSError *error;
    
    NSArray *files = [sFileManager contentsOfDirectoryAtPath:dirPath error:&error];
    
    if (error) {
        OULogInner(LERROR, TAG, @"Could not list files.", error);
    } else {
        for (NSString *file in files) {
            [arr addObject:[dirPath stringByAppendingPathComponent:file]];
        }
    }
    
    return arr;
}

+ (void)makeRequest:(NSString *)path body:(NSData *)body response:(OUResponse)responseBlock {
    OULogInner(LDEBUG, TAG, @"Making request.", @{@"path"      : valOrBlank(path),
                                                  @"body_size" : @(body ? body.length : 0)});
    
    path = [self appendQueryParams:path dict:@{@"version" : VERSION}];
    
    NSString *uri = [NSString stringWithFormat:@"%@://%@/%@", sSettings[SETTING_API_SCHEME], sSettings[SETTING_API_HOST], path];
    NSURL *url = [NSURL URLWithString:uri];
    NSMutableURLRequest *request  = [[NSMutableURLRequest alloc] initWithURL:url
                                                                 cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                             timeoutInterval:[sSettings[SETTING_API_TIMEOUT] doubleValue]];
    NSString *method = body ? @"POST" : @"GET";
    request.HTTPMethod = method;
    
    if ([@"POST" isEqualToString:method]) {
        NSData *compressedBody = [self compress:body];
        [request setValue:@"gzip/json" forHTTPHeaderField:@"Content-Type"];
        [request setValue:@"gzip" forHTTPHeaderField:@"Content-Encoding"];
        [request setValue:[@(compressedBody.length) stringValue] forHTTPHeaderField:@"Content-Length"];
        [request setHTTPBody:compressedBody];
    }
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:request
                                    completionHandler:^(NSData *responseData, NSURLResponse *response, NSError *error) {
                                        if (!responseData) {
                                            if (responseBlock) responseBlock(-1, nil, error);
                                        } else {
                                            NSInteger statusCode = ((NSHTTPURLResponse *)response).statusCode;
                                            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseData
                                                                                                 options:0
                                                                                                   error:nil];
                                            
                                            if (responseBlock) responseBlock(statusCode, dict, error);
                                        }
                                    }] resume];
}

+ (void)dispatchTimer:(NSTimer *)timer {
    [self dispatchBlock:timer.userInfo];
}

+ (void)dispatchBlock:(dispatch_block_t)block {
    for (NSBlockOperation *op in sOperationQueue.operations) {
        dispatch_block_t opBlock = op.executionBlocks[0];
        
        if (block == opBlock && !op.isExecuting) [op cancel];
    }
    
    [sOperationQueue addOperation:[NSBlockOperation blockOperationWithBlock:block]];
}

#pragma mark - Encryption

+ (NSData *)generateAESKey {
    unsigned char buf[kCCKeySizeAES128];
    arc4random_buf(buf, sizeof(buf));
    return [NSData dataWithBytes:buf length:sizeof(buf)];
}

+ (NSData *)generateAESIV {
    return [self generateAESKey];
}

+ (NSData *)RSAEncrypt:(NSData *)input publicKey:(SecKeyRef)publicKey {
    if (!input || input.length == 0 || !publicKey) return nil;
    
    size_t   bufferSize = SecKeyGetBlockSize(publicKey);
    uint8_t *buffer     = malloc(bufferSize);
    
    OSStatus status =  SecKeyEncrypt(publicKey,
                                     kSecPaddingPKCS1,
                                     input.bytes, input.length,
                                     buffer, &bufferSize);
    
    NSData *retVal = nil;
    
    if (status == errSecSuccess) {
        retVal = [NSData dataWithBytes:buffer length:bufferSize];
    } else {
        printf("Could not encrypt using RSA. status=%d\n", (int)status);
    }
    
    free(buffer);
    
    return retVal;
}

+ (NSData *)AESEncrypt:(NSData *)input key:(NSData *)key iv:(NSData *)iv {
    if (!input || !key || !iv) return nil;
    
    NSMutableData *output = [NSMutableData dataWithLength:input.length + kCCBlockSizeAES128];
    size_t outLength;
    
    CCCryptorStatus status = CCCrypt(kCCEncrypt,
                                     kCCAlgorithmAES,
                                     kCCOptionPKCS7Padding,
                                     key.bytes, kCCKeySizeAES128,
                                     iv.bytes,
                                     input.bytes, input.length,
                                     output.mutableBytes, output.length,
                                     &outLength);
    
    if (status != kCCSuccess) {
        printf("Could not encrypt using AES. status=%d\n", status);
    } else {
        output.length = outLength;
    }
    
    return output;
}

+ (void)loadPublicKey {
    NSString *certificate = sSettings[SETTING_CERTIFICATE];
    
    if (certificate && certificate.length > 0) {
        NSData *data = [[NSData alloc] initWithBase64EncodedString:certificate options:0];
        SecCertificateRef certificate = SecCertificateCreateWithData(kCFAllocatorDefault, ( __bridge CFDataRef)data);
        
        if (!certificate) {
            OULogInner(LERROR, TAG, @"Invalid certificate.");
            return;
        }
        
        SecPolicyRef policy = SecPolicyCreateBasicX509();
        SecTrustRef trust;
        
        if (SecTrustCreateWithCertificates(certificate, policy, &trust) != 0) {
            OULogInner(LERROR, TAG, @"Invalid trust.");
            return;
        }
        
        sEncryptedAESKey = [self RSAEncrypt:sAESKey publicKey:SecTrustCopyPublicKey(trust)];
    }
}

+ (NSString *)model {
    struct utsname systemInfo;
    uname(&systemInfo);
    
    return [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
}

+ (NSString *)threadName {
    NSString *queue = [NSString stringWithCString:dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL) encoding:NSUTF8StringEncoding];
    if (queue && queue.length > 0) {
        queue = [queue componentsSeparatedByString:@"::"].firstObject;
        
        if (queue && queue.length > 0) queue = [queue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if (queue && queue.length > 0) queue = [queue stringByReplacingOccurrencesOfString:@" " withString:@"_"];
    } else {
        queue = @"";
    }
        
    return [NSString stringWithFormat:@"%d:%@", pthread_mach_thread_np(pthread_self()), queue];
}

+ (NSString *)kvpToString:(NSDictionary *)dict {
    NSMutableString *mString = [NSMutableString new];
    
    for (NSString *key in dict.allKeys) {
        id value = dict[key];
        
        [mString appendString:[self sanitizeKVPKey:key]];
        [mString appendString:@"="];
        
        if ([value isKindOfClass:[NSNull class]]) {
            [mString appendString:@"(null)"];
        } else if ([value isKindOfClass:[NSNumber class]] || [value isKindOfClass:[OUDouble class]]) {
            [mString appendString:[value stringValue]];
        } else {
            [mString appendFormat:@"\"%@\"", [value description]];
        }
        
        [mString appendString:@" "];
    }
    
    return [mString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

+ (NSString *)sanitizeKVPKey:(NSString *)key {
    if (!key) return key;
    
    key = [key stringByReplacingOccurrencesOfString:@" " withString:@"_"];
    key = [key stringByReplacingOccurrencesOfString:@"." withString:@"_"];
    
    if ([key hasPrefix:@"$"]) key = [key substringFromIndex:1];
    
    return key;
}

+ (NSData *)compress:(NSData *)input {
    if (!input) return input;
    
    if (input.length) {
        z_stream stream;
        stream.zalloc    = Z_NULL;
        stream.zfree     = Z_NULL;
        stream.opaque    = Z_NULL;
        stream.avail_in  = (uint) input.length;
        stream.next_in   = (Bytef *)input.bytes;
        stream.total_out = 0;
        stream.avail_out = 0;
        
        if (deflateInit2(&stream, Z_DEFAULT_COMPRESSION, Z_DEFLATED, 31, 8, Z_DEFAULT_STRATEGY) == Z_OK) {
            NSMutableData *data = [NSMutableData dataWithLength:16384];
            
            while (stream.avail_out == 0) {
                if (stream.total_out >= data.length) {
                    data.length += 16384;
                }
                
                stream.next_out = [data mutableBytes] + stream.total_out;
                stream.avail_out = (uint) (data.length - stream.total_out);
                deflate(&stream, Z_FINISH);
            }
            
            deflateEnd(&stream);
            data.length = stream.total_out;
            return data;
        }
    }
    
    return nil;
}

+ (void)toggleUncaughtExceptionHandler {
    lock();
    NSUncaughtExceptionHandler *handler = NSGetUncaughtExceptionHandler();
    
    if ([self getLogUncaughtExceptions] && uncaught_exception_handler != handler) {
        OULogInner(LDEBUG, TAG, @"Using Ouralabs exception handler.");
        
        NSSetUncaughtExceptionHandler(&uncaught_exception_handler);
    } else if (![self getLogUncaughtExceptions] && uncaught_exception_handler == handler) {
        OULogInner(LDEBUG, TAG, @"Removing Ouralabs exception handler.");
        
        NSSetUncaughtExceptionHandler(original_exception_handler);
    }
    unlock();
}

+ (void)toggleLogLifecycle {
    if (sInitialized) {
        lock();
        
        if ([self getLogLifecycle] && !sLifecycleHooked) {
            sLifecycleHooked = YES;
            
            OULogInner(LINFO, TAG, @"Hooking lifecycle events.");
            
            for (NSString *name in sNotifications) addObserver(name, sObserver);
        } else if (![self getLogLifecycle] && sLifecycleHooked) {
            sLifecycleHooked = NO;
            
            OULogInner(LINFO, TAG, @"Unhooking lifecycle events.", @{@"size" : @(sNotifications.count)});
            
            removeObserver(sObserver);
        }
        
        unlock();
    }
}

@end