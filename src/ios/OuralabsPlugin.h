//
//  OuralabsPlugin.h
//
//  Copyright (c) 2015 Justin Unterreiner. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cordova/CDV.h>
#import "AppDelegate.h"
#import "Ouralabs.h"

@interface OuralabsPlugin : CDVPlugin
- (void)init:(CDVInvokedUrlCommand *)command;
@end