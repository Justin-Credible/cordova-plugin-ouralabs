//
//  OuralabsPlugin.m
//
//  Copyright (c) 2015 Justin Unterreiner. All rights reserved.
//

#import "OuralabsPlugin.h"
#import <objc/runtime.h>

@interface OuralabsPlugin()

@end

@implementation OuralabsPlugin

#pragma mark - Cordova commands

- (void)init:(CDVInvokedUrlCommand *)command {

    // Ensure we have the correct number of arguments.
    if ([command.arguments count] == 0) {
        CDVPluginResult *res = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"A channel ID is required."];
        [self.commandDelegate sendPluginResult:res callbackId:command.callbackId];
        return;
    }

    // Obtain the arguments.
    NSString* applicationId = [command.arguments objectAtIndex:0];

    // Validate the arguments.

    if (!applicationId) {
        CDVPluginResult *res = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"A channel ID is required."];
        [self.commandDelegate sendPluginResult:res callbackId:command.callbackId];
        return;
    }

    // Delegate to the Ouralabs API.
    [self.commandDelegate runInBackground:^{
        [Ouralabs initWithKey:applicationId];

        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                                      messageAsDictionary:[self responseObject]];

        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}