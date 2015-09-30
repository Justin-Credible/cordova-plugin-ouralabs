//
//  OuralabsPlugin.m
//
//  Copyright (c) 2015 Justin Unterreiner. All rights reserved.
//

#import "OuralabsPlugin.h"
#import <objc/runtime.h>

@interface OuralabsPlugin()

- (OULogLevel)logLevelWithNumber:(NSNumber*)number;

@end

@implementation OuralabsPlugin

#pragma mark - Helper Methods

- (OULogLevel)logLevelWithNumber:(NSNumber*)number {
    switch ([number intValue]) {
        case 0:
            return OULogLevelTrace;
        case 1:
            return OULogLevelDebug;
        case 2:
            return OULogLevelInfo;
        case 3:
            return OULogLevelWarn;
        case 4:
            return OULogLevelError;
        case 5:
            return OULogLevelFatal;
    }

    return OULogLevelTrace;
}

#pragma mark - Cordova commands

- (void)init:(CDVInvokedUrlCommand *)command {

    // Ensure we have the correct number of arguments.
    if ([command.arguments count] != 1) {
        CDVPluginResult *res = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"A channel ID is required."];
        [self.commandDelegate sendPluginResult:res callbackId:command.callbackId];
        return;
    }

    // Obtain the arguments.
    NSString* channelId = [command.arguments objectAtIndex:0];

    // Validate the arguments.

    if (!channelId) {
        CDVPluginResult *res = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"A channel ID is required."];
        [self.commandDelegate sendPluginResult:res callbackId:command.callbackId];
        return;
    }

    // Delegate to the Ouralabs API.
    [self.commandDelegate runInBackground:^{
        [Ouralabs initWithKey:channelId];

        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

- (void)setAttributes:(CDVInvokedUrlCommand *)command {

    // Ensure we have the correct number of arguments.
    if ([command.arguments count] != 3) {
        CDVPluginResult *res = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Three attribute values are required."];
        [self.commandDelegate sendPluginResult:res callbackId:command.callbackId];
        return;
    }

    // Obtain the arguments.
    NSString* attribute1 = [command.arguments objectAtIndex:0];
    NSString* attribute2 = [command.arguments objectAtIndex:1];
    NSString* attribute3 = [command.arguments objectAtIndex:2];

    // Build the dictionary of arguments for the Ouralabs API.
    NSDictionary *attrs = @{OUAttr1 : attribute1,
                            OUAttr2 : attribute2,
                            OUAttr3 : attribute3};

    // Delegate to the Ouralabs API.
    [self.commandDelegate runInBackground:^{
        [Ouralabs setAttributes:attrs];

        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

- (void)log:(CDVInvokedUrlCommand *)command {

    // Ensure we have the correct number of arguments.
    if ([command.arguments count] != 3) {
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"A log level, tag name, and message are required."];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return;
    }

    // Obtain the arguments.
    OULogLevel logLevel = [self logLevelWithNumber: [command.arguments objectAtIndex:0]];
    NSString* tag = [command.arguments objectAtIndex:1];
    NSString* message = [command.arguments objectAtIndex:2];

    // Validate the arguments.

    if (tag == nil) {
        CDVPluginResult *pluginResult =[CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"A tag is required."];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return;
    }

    if (message == nil) {
        CDVPluginResult *pluginResult =[CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"A message is required."];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return;
    }

    // Delegate to the Ouralabs API.
    [self.commandDelegate runInBackground:^{
        [Ouralabs log:logLevel tag:tag message:message];

        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

@end
