"use strict";

/*globals OuralabsPlugin_LogToBrowserConsole, OuralabsPlugin_HookBrowserConsole*/

var exec = require("cordova/exec");

var PLUGIN_ID = "OuralabsPlugin";

// Grab the global variables used for configuration of the plugin.
var logToBrowserConsole = typeof(OuralabsPlugin_LogToBrowserConsole) !== "undefined" && OuralabsPlugin_LogToBrowserConsole;
var hookBrowserConsole = typeof(OuralabsPlugin_HookBrowserConsole) !== "undefined" && OuralabsPlugin_HookBrowserConsole;

var noOp = function () {};

var OuralabsPlugin = {};

// Save a reference to all the browser console logging methods.
// If one of them doesn't exist, attempt to default to console.log or noOp().
// We use these if OuralabsPlugin_LogToBrowserConsole was set to true.
var
	browserConsole = console || {},
	browserTrace = console.trace || console.log || noOp,
	browserDebug = console.debug || console.log || noOp,
	browserInfo = console.info || console.log || noOp,
	browserLog = console.log || console.log || noOp,
	browserWarn = console.warn || console.log || noOp,
	browserError = console.error || console.log || noOp;

// Here we hook each of the browser log functions to delegate to the OuralabsPlugin.
// The tag will be the name of the function, the message will be the first argument,
// and the metadata object will be the remaining arguments (if any). We do this if
// OuralabsPlugin_HookBrowserConsole was set to true.
if (hookBrowserConsole) {
	
	// Treat calls to log() as debug level.
	console.log = function() {
		var args = Array.prototype.slice.call(arguments, 1);
		OuralabsPlugin.logDebug("console.log()", arguments[0], args.length === 0 ? null : args);
	};
	
	console.trace = function() {
		var args = Array.prototype.slice.call(arguments, 1);
		OuralabsPlugin.logTrace("console.trace()", arguments[0], args.length === 0 ? null : args);
	};
	
	console.debug = function() {
		var args = Array.prototype.slice.call(arguments, 1);
		OuralabsPlugin.logDebug("console.debug()", arguments[0], args.length === 0 ? null : args);
	};
	
	console.info = function() {
		var args = Array.prototype.slice.call(arguments, 1);
		OuralabsPlugin.logInfo("console.info()", arguments[0], args.length === 0 ? null : args);
	};
	
	console.warn = function() {
		var args = Array.prototype.slice.call(arguments, 1);
		OuralabsPlugin.logWarn("console.warn()", arguments[0], args.length === 0 ? null : args);
	};
	
	console.error = function() {
		var args = Array.prototype.slice.call(arguments, 1);
		OuralabsPlugin.logError("console.error()", arguments[0], args.length === 0 ? null : args);
	};
}

OuralabsPlugin.LogLevel = {
	TRACE: 0,
	DEBUG: 1,
	INFO: 2,
	WARN: 3,
	ERROR: 4,
	FATAL: 5
};

OuralabsPlugin.init = function init(channelId, successCallback, failureCallback) {
	exec(successCallback, failureCallback, PLUGIN_ID, "init", [channelId]);
};

OuralabsPlugin.setAttributes = function setAttributes(attribute1, attribute2, attribute3, successCallback, failureCallback) {
	
	var attributes = [];
	
	if (attribute1 != null && typeof(attribute1) !== "string") {
		throw new Error("The attribute1 value must be null or a string.");
	}
	else {
		attributes.push(attribute1);
	}
	
	if (attribute2 != null && typeof(attribute2) !== "string") {
		throw new Error("The attribute2 value must be null or a string.");
	}
	else {
		attributes.push(attribute2);
	}
	
	if (attribute3 != null && typeof(attribute3) !== "string") {
		throw new Error("The attribute1 value must be null or a string.");
	}
	else {
		attributes.push(attribute3);
	}
	
	exec(successCallback, failureCallback, PLUGIN_ID, "setAttributes", attributes);
};

OuralabsPlugin.logTrace = function logTrace(tag, message, metadata, successCallback, failureCallback) {
	OuralabsPlugin.log(this.LogLevel.TRACE, tag, message, metadata, successCallback, failureCallback);
};

OuralabsPlugin.logDebug = function logDebug(tag, message, metadata, successCallback, failureCallback) {
	OuralabsPlugin.log(this.LogLevel.DEBUG, tag, message, metadata, successCallback, failureCallback);
};

OuralabsPlugin.logInfo = function logInfo(tag, message, metadata, successCallback, failureCallback) {
	OuralabsPlugin.log(this.LogLevel.INFO, tag, message, metadata, successCallback, failureCallback);
};

OuralabsPlugin.logWarn = function logWarn(tag, message, metadata, successCallback, failureCallback) {
	OuralabsPlugin.log(this.LogLevel.WARN, tag, message, metadata, successCallback, failureCallback);
};

OuralabsPlugin.logError = function logError(tag, message, metadata, successCallback, failureCallback) {
	OuralabsPlugin.log(this.LogLevel.ERROR, tag, message, metadata, successCallback, failureCallback);
};

OuralabsPlugin.logFatal = function logFatal(tag, message, metadata, successCallback, failureCallback) {
	OuralabsPlugin.log(this.LogLevel.FATAL, tag, message, metadata, successCallback, failureCallback);
};

OuralabsPlugin.log = function log(logLevel, tag, message, metadata, successCallback, failureCallback) {
	
	if (logLevel == null) {
		logLevel = this.LogLevel.DEBUG;
	}
	
	if (!tag || typeof(tag) !== "string") {
		tag = "[No Tag]";
	}
	
	if (!message || typeof(message) !== "string") {
		message = "[No Message]";
	}
	
	// If we are configured to log to the browser console, we'll do it here before
	// we add the metadata into the message body since the browser console will handle
	// showing the objects natively. Note that we do not use console.log() etc directly
	// as we may have overridden these methods to delegate back into the OuralabsPlugin.
	if (logToBrowserConsole) {
		try {
			var logFunction,
				level;
			
			switch (logLevel) {
				case OuralabsPlugin.LogLevel.TRACE:
					level = "[TRACE]";
					logFunction = browserTrace;
					break;
				case OuralabsPlugin.LogLevel.DEBUG:
					level = "[DEBUG]";
					logFunction = browserDebug;
					break;
				case OuralabsPlugin.LogLevel.INFO:
					level = "[INFO]";
					logFunction = browserInfo;
					break;
				case OuralabsPlugin.LogLevel.WARN:
					level = "[WARN]";
					logFunction = browserWarn;
					break;
				case OuralabsPlugin.LogLevel.ERROR:
					level = "[ERROR]";
					logFunction = browserError;
					break;
				case OuralabsPlugin.LogLevel.FATAL:
					level = "[FATAL]";
					logFunction = browserError;
					break;
				default:
					logFunction = browserLog;
			}
			
			if (metadata) {
				logFunction.call(browserConsole, level + " " + tag + ": " + message, metadata);
			}
			else {
				logFunction.call(browserConsole, level + " " + tag + ": " + message);
			}
		}
		catch (exception) { }
	}
	
	// If a metadata object was also logged, attempt to flatten it into the message body.
	if (metadata) {
		
		// First try serializing to JSON.
		try {
			message += " " + JSON.stringify(metadata);
		}
		catch (exception) {
			
			// If we couldn't serialize to JSON we may have gotten an object with a circular
			// reference (eg DOM nodes on an event object). In that case, lets just try to
			// flatten the object by iterating over the keys.
			try {
				for (var key in metadata) {
					if (metadata.hasOwnProperty(key)) {
						message += " " + key + "=" + metadata[key];
					}
				}
			}
			catch (exception) {
				message += " [unable to flatten the metadata object]";
			}
		}
	}
	
	// Call into our native plugin code.
	exec(successCallback, failureCallback, PLUGIN_ID, "log", [logLevel, tag, message]);
};

module.exports = OuralabsPlugin;
