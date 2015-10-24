# Cordova plugin for Ouralabs

This is a [Cordova](http://cordova.apache.org/) plugin for the Ouralabs centralized remote logging platform.

You can find out more about Ouralabs here: [https://www.ouralabs.com](https://www.ouralabs.com).

This version of the plugin uses versions `2.7.0` (iOS) and `2.7.1` (Android) of the Ouralabs SDK. Documentation for Ouralabs SDK can be found [here](https://www.ouralabs.com/docs).

# Install

To add the plugin to your Cordova project, simply add the plugin from the npm registry:

    cordova plugin add cordova-plugin-ouralabs

Alternatively, you can install the latest version of the plugin directly from git:

    cordova plugin add https://github.com/Justin-Credible/cordova-plugin-ouralabs

# Usage

The plugin is available via a global variable named `OuralabsPlugin`. It exposes the following properties and functions.

All functions accept optional success and failure callbacks as their final two arguments, where the failure callback will receive an error string as an argument unless otherwise noted.

A TypeScript definition file for the JavaScript interface is available in the `typings` directory as well as on [DefinitelyTyped](https://github.com/borisyankov/DefinitelyTyped) via the `tsd` tool.

## Log Levels

Log levels designate the severity of the log; used with the `log()` function. Log levels are ordered as shown below (least severe to most severe).

`Ouralabs.LogLevel`

* TRACE
* DEBUG
* INFO
* WARN
* ERROR
* FATAL

Example Usage:

`OuralabsPlugin.log(OuraLabs.LogLevel.ERROR, ...);`

## Initialization

Initialize the Ouralabs plugin with the given channel ID string value. You can obtain your channel ID from the Ouralabs dashboard.

Method Signature:

`init(channelId, successCallback, failureCallback)`

Parameters:

* channelId (string): The ID of the channel that logs will be written to.

Example Usage:

    OuralabsPlugin.init("123...",
    	function() {
    		// Init success :)
    	},
    	function(err) {
    		// Init failure :(
    	});

## Device Attributes

Allows setting of the three arbitrary attribute values that are stored with the device information.

Method Signature:

`setAttributes(attribute1, attribute2, attribute3, successCallback, failureCallback)`

Parameters:

* `attribute1` (string): The (optional) attribute value to set for the first attribute.
* `attribute2` (string): The (optional) attribute value to set for the second attribute.
* `attribute3` (string): The (optional) attribute value to set for the third attribute.

Example Usage:

`OuralabsPlugin.setAttributes(userId, userName, email);`

## Logging

Logs a message with the given information.

Method Signature:

`log(logLevel, tag, message, metadata, successCallback, failureCallback): void`

Parameters:

* `logLevel` (number): The level of the log; see `LogLevels` for possible values.
* `tag` (string): The tag for the log entry.
* `message` (string): The body of the log message.
* `metadata` (any): An optional object to be appended to the log message in JSON format. If the object cannot be serialized into JSON it will be flattened into key/value pairs.

Example usage:

`OuralabsPlugin.log(OuralabsPlugin.LogLevels.ERROR, "my_function", "Something went horribly wrong", event);`

## Log Helpers

Used to log a message with the given information. These are convenience shortcuts to the `log()` method. All of the following methods have the same method signature.

Methods:

* `logTrace(...)`
* `logDebug(...)`
* `logInfo(...)`
* `logWarn(...)`
* `logError(...)`
* `logFatal(...)`

Parameters:

* `tag` (string): The tag for the log entry.
* `message` (string): The body of the log message.
* `metadata` (any): An optional object to be appended to the log message in JSON format. If the object cannot be serialized into JSON it will be flattened into key/value pairs.

Example usage:

`OuralabsPlugin.logInfo("my_function", "It was called.");`

`OuralabsPlugin.logWarn("other_fucntion", "Something isn't right...", data);`

## Browser Console

The plugin can optionally integrate with the browser console in two ways:

1. Ensure calls to `OuralabsPlugin.log()` (and its helper methods) will also show up in the browser console.
2. Ensure out-of-band calls to the browser's console methods (eg `console.log(...)`, `console.error(...)`, etc) also get pushed into Ouralabs.

Both of these features are disabled by default and can be enabled with the following methods.

*NOTE: It is not recommended to use these features in conjunction with the `cordova-plugin-console` plugin as it duplicates some of its functionality.*

### Show log entries in browser console

Method Signature:

`setLogToBrowserConsole(enable)`

Parameters:

* `enable` (boolean): True to enable, false to disable.

Example Usage:

`OuralabsPlugin.setLogToBrowserConsole(true);`

### Ensure native log entries are logged to Ouralabs

Method Signature:

`setHookBrowserConsole(enable)`

Parameters:

* `enable` (boolean): True to enable, false to disable.

Example Usage:

`OuralabsPlugin.setHookBrowserConsole(true);`