//
//  Ouralabs
//
//  Copyright (c) 2014 Ouralabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

#define OUDouble(value, scaleValue) ([OUDouble doubleWithDouble:value scale:scaleValue])

typedef NS_ENUM(NSInteger, OULogLevel) {
    OULogLevelTrace  = 0,
    OULogLevelDebug  = 1,
    OULogLevelInfo   = 2,
    OULogLevelWarn   = 3,
    OULogLevelError  = 4,
    OULogLevelFatal  = 5
};

OBJC_EXTERN void __attribute__((overloadable)) OULogTrace(NSString *tag, NSString *message, ...) NS_FORMAT_FUNCTION(2, 3);
OBJC_EXTERN void __attribute__((overloadable)) OULogTrace(NSString *tag, NSString *message, NSException *exception);
OBJC_EXTERN void __attribute__((overloadable)) OULogTrace(NSString *tag, NSString *message, NSError *error);
OBJC_EXTERN void __attribute__((overloadable)) OULogTrace(NSString *tag, NSString *message, NSDictionary *kvp);

OBJC_EXTERN void __attribute__((overloadable)) OULogDebug(NSString *tag, NSString *message, ...) NS_FORMAT_FUNCTION(2, 3);
OBJC_EXTERN void __attribute__((overloadable)) OULogDebug(NSString *tag, NSString *message, NSException *exception);
OBJC_EXTERN void __attribute__((overloadable)) OULogDebug(NSString *tag, NSString *message, NSError *error);
OBJC_EXTERN void __attribute__((overloadable)) OULogDebug(NSString *tag, NSString *message, NSDictionary *kvp);

OBJC_EXTERN void __attribute__((overloadable)) OULogInfo(NSString *tag, NSString *message, ...) NS_FORMAT_FUNCTION(2, 3);
OBJC_EXTERN void __attribute__((overloadable)) OULogInfo(NSString *tag, NSString *message, NSException *exception);
OBJC_EXTERN void __attribute__((overloadable)) OULogInfo(NSString *tag, NSString *message, NSError *error);
OBJC_EXTERN void __attribute__((overloadable)) OULogInfo(NSString *tag, NSString *message, NSDictionary *kvp);

OBJC_EXTERN void __attribute__((overloadable)) OULogWarn(NSString *tag, NSString *message, ...) NS_FORMAT_FUNCTION(2, 3);
OBJC_EXTERN void __attribute__((overloadable)) OULogWarn(NSString *tag, NSString *message, NSException *exception);
OBJC_EXTERN void __attribute__((overloadable)) OULogWarn(NSString *tag, NSString *message, NSError *error);
OBJC_EXTERN void __attribute__((overloadable)) OULogWarn(NSString *tag, NSString *message, NSDictionary *kvp);

OBJC_EXTERN void __attribute__((overloadable)) OULogError(NSString *tag, NSString *message, ...) NS_FORMAT_FUNCTION(2, 3);
OBJC_EXTERN void __attribute__((overloadable)) OULogError(NSString *tag, NSString *message, NSException *exception);
OBJC_EXTERN void __attribute__((overloadable)) OULogError(NSString *tag, NSString *message, NSError *error);
OBJC_EXTERN void __attribute__((overloadable)) OULogError(NSString *tag, NSString *message, NSDictionary *kvp);

OBJC_EXTERN void __attribute__((overloadable)) OULogFatal(NSString *tag, NSString *message, ...) NS_FORMAT_FUNCTION(2, 3);
OBJC_EXTERN void __attribute__((overloadable)) OULogFatal(NSString *tag, NSString *message, NSException *exception);
OBJC_EXTERN void __attribute__((overloadable)) OULogFatal(NSString *tag, NSString *message, NSError *error);
OBJC_EXTERN void __attribute__((overloadable)) OULogFatal(NSString *tag, NSString *message, NSDictionary *kvp);

OBJC_EXTERN void __attribute__((overloadable)) OULog(OULogLevel level, NSString *tag, NSString *message, ...) NS_FORMAT_FUNCTION(3, 4);
OBJC_EXTERN void __attribute__((overloadable)) OULog(OULogLevel level, NSString *tag, NSString *message, NSException *exception);
OBJC_EXTERN void __attribute__((overloadable)) OULog(OULogLevel level, NSString *tag, NSString *message, NSError *error);
OBJC_EXTERN void __attribute__((overloadable)) OULog(OULogLevel level, NSString *tag, NSString *message, NSDictionary *kvp);

extern NSString *const OUAttr1;
extern NSString *const OUAttr2;
extern NSString *const OUAttr3;

typedef void (^OUSettingsChangedBlock)(BOOL liveTail, OULogLevel logLevel);

@interface OUDouble : NSObject
@property (assign) double doubleValue;
@property (assign) NSInteger scale;

- (NSString *)stringValue;

+ (OUDouble *)doubleWithDouble:(double)value scale:(NSInteger)scale;

@end

@interface Ouralabs : NSObject

+ (void)initWithKey:(NSString *)key;

+ (void)setLiveTail:(NSNumber *)liveTail;
+ (void)setAppVersion:(NSString *)appVersion;
+ (void)setLogLevel:(NSNumber *)logLevel;
+ (void)setAttributes:(NSDictionary *)attributes;
+ (void)setOptIn:(BOOL)optIn;
+ (void)setDiskOnly:(NSNumber *)diskOnly;
+ (void)setBuffered:(NSNumber *)buffered;
+ (void)setLocation:(CLLocation *)location;
+ (void)setDisableTimedOperations:(BOOL)disable;
+ (void)setLoggerLogsAllowed:(NSNumber *)allowed;
+ (void)setSettingsChangedBlock:(OUSettingsChangedBlock)settingsChangedBlock;
+ (void)setLogLifecycle:(NSNumber *)enable;

+ (BOOL)getInitialized;
+ (BOOL)getLiveTail;
+ (OULogLevel)getLogLevel;
+ (BOOL)getOptIn;
+ (BOOL)getDiskOnly;
+ (BOOL)getBuffered;
+ (NSString *)getAppVersion;
+ (NSString *)getVersion;
+ (NSDictionary *)getAttributes;
+ (CLLocation *)getLocation;
+ (BOOL)getDisableTimedOperations;
+ (BOOL)getLoggerLogsAllowed;
+ (OUSettingsChangedBlock)getSettingsChangedBlock;
+ (BOOL)getLogLifecycle;

+ (void)update;
+ (void)flush;

+ (void)log:(OULogLevel)level tag:(NSString *)tag message:(NSString *)message, ...;
+ (void)log:(OULogLevel)level tag:(NSString *)tag message:(NSString *)message args:(va_list)args;
+ (void)log:(OULogLevel)level tag:(NSString *)tag message:(NSString *)message exception:(NSException *)exception;
+ (void)log:(OULogLevel)level tag:(NSString *)tag message:(NSString *)message error:(NSError *)error;
+ (void)log:(OULogLevel)level tag:(NSString *)tag message:(NSString *)message kvp:(NSDictionary *)kvp;

@end