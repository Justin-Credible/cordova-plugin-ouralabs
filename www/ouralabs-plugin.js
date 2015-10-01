"use strict";

/*globals OuralabsPlugin_LogToBrowserConsole, OuralabsPlugin_HookBrowserConsole*/

var exec = require("cordova/exec");

/**
 * The Cordova plugin ID for this plugin.
 */
var PLUGIN_ID = "OuralabsPlugin";

// Save a reference to all the browser console logging methods.
// If one of them doesn't exist, attempt to default to console.log or noOp().
// We use these if logToBrowserConsole was set to true.
var
	browserConsole = typeof(console) === "undefined" ? {} : console,
	browserTrace = console.trace || browserConsole.log || noOp,
	browserDebug = console.debug || browserConsole.log || noOp,
	browserInfo = console.info || browserConsole.log || noOp,
	browserLog = console.log || browserConsole.log || noOp,
	browserWarn = console.warn || browserConsole.log || noOp,
	browserError = console.error || browserConsole.log || noOp;

/**
 * Keeps track of if we've hooked the browser's console logging functions.
 */
var hasHookedBrowserConsole = false;

/**
 * Keeps track of if we should be also displaying logs in the browser's console.
 */
var logToBrowserConsole = false;

/**
 * Used for no-ops.
 */
var noOp = function () {};

/**
 * The plugin which will be exported and exposed in the global scope.
 */
var OuralabsPlugin = {};

/**
 * Log levels designate the severity of the log; used with the log() function.
 * Log levels are ordered from least severe to most severe.
 */
OuralabsPlugin.LogLevel = {
	TRACE: 0,
	DEBUG: 1,
	INFO: 2,
	WARN: 3,
	ERROR: 4,
	FATAL: 5
};

/**
 * Initialize the Ourlabs plugin with the given channel ID string value.
 * You can obtain your channel ID from the Ouralabs dashboard.
 * 
 * @param {string} channelId - The ID of the channel that logs will be written to.
 * @param [function] successCallback - The success callback for this asynchronous function.
 * @param [function] failureCallback - The failure callback for this asynchronous function; receives an error string.
 */
OuralabsPlugin.init = function init(channelId, successCallback, failureCallback) {
	exec(successCallback, failureCallback, PLUGIN_ID, "init", [channelId]);
};

/**
 * Used to ensure values logged via the plugin are also displayed in the browser's console.
 * 
 * @param {boolean} enable - True to enable logs to show up in the browser's console, false to disable.
 */
OuralabsPlugin.setLogToBrowserConsole = function (enable) {
	// Ensure we have a boolean value here.
	logToBrowserConsole = !!enable;
};

/**
 * Used to enable hooking of the browser's console logging functions (eg console.log,
 * console.error, etc) to ensure that these logs get logged via Ouralabs.
 * 
 * @param {boolean} enable - True to enable hooking of the console log functions, false to disable.
 */
OuralabsPlugin.setHookBrowserConsole = function (enable) {
	
	// Ensure we have a boolean value here.
	enable = !!enable;
	
	// If the flag being set is the same as the current value there is nothing to do.
	if (enable === hasHookedBrowserConsole) {
		return;
	}
	
	if (enable) {
		// Here we hook each of the browser log functions to delegate to the OuralabsPlugin.
		// The tag will be the name of the function, the message will be the first argument,
		// and the metadata object will be the remaining arguments (if any).
		
		// Treat calls to log() as debug level.
		console.log = function() {
			var args = Array.prototype.slice.call(arguments, 1);
			OuralabsPlugin.logDebug("console.log()", arguments[0], args.length === 0 ? null : args);
		};
		
		// Trace doesn't normally accept arguments, however some browsers (like Chrome) will accept them.
		// We'll mock trace as well for those cases (without the arguments it isn't as helpful for logging).
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
	else {
		// Restore the native function calls.
		console.log = browserLog;
		console.trace = browserTrace;
		console.debug = browserDebug;
		console.info = browserInfo;
		console.warn = browserWarn;
		console.error = browserError;
	}
};

/**
 * Allows setting of the three arbitrary attribute values that are stored with the device information.
 * 
 * @param [string] attribute1 - The (optional) attribute value to set for the first attribute.
 * @param [string] attribute2 - The (optional) attribute value to set for the first attribute.
 * @param [string] attribute3 - The (optional) attribute value to set for the first attribute.
 * @param [function] successCallback - The success callback for this asynchronous function.
 * @param [function] failureCallback - The failure callback for this asynchronous function; receives an error string.
 */
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

/**
 * Logs a log message of level TRACE with the given information.
 * 
 * @param {string} tag - The tag for the log entry.
 * @param {string} message - The body of the log message.
 * @param [*] metadata - An optional object to be appended to the log message in JSON format. If the object cannot be serialized into JSON it will be flattened into key/value pairs.
 * @param [function] successCallback - The success callback for this asynchronous function.
 * @param [function] failureCallback - The failure callback for this asynchronous function; receives an error string.
 */
OuralabsPlugin.logTrace = function logTrace(tag, message, metadata, successCallback, failureCallback) {
	OuralabsPlugin.log(this.LogLevel.TRACE, tag, message, metadata, successCallback, failureCallback);
};

/**
 * Logs a log message of level DEBUG with the given information.
 * 
 * @param {string} tag - The tag for the log entry.
 * @param {string} message - The body of the log message.
 * @param [*] metadata - An optional object to be appended to the log message in JSON format. If the object cannot be serialized into JSON it will be flattened into key/value pairs.
 * @param [function] successCallback - The success callback for this asynchronous function.
 * @param [function] failureCallback - The failure callback for this asynchronous function; receives an error string.
 */
OuralabsPlugin.logDebug = function logDebug(tag, message, metadata, successCallback, failureCallback) {
	OuralabsPlugin.log(this.LogLevel.DEBUG, tag, message, metadata, successCallback, failureCallback);
};

/**
 * Logs a log message of level INFO with the given information.
 * 
 * @param {string} tag - The tag for the log entry.
 * @param {string} message - The body of the log message.
 * @param [*] metadata - An optional object to be appended to the log message in JSON format. If the object cannot be serialized into JSON it will be flattened into key/value pairs.
 * @param [function] successCallback - The success callback for this asynchronous function.
 * @param [function] failureCallback - The failure callback for this asynchronous function; receives an error string.
 */
OuralabsPlugin.logInfo = function logInfo(tag, message, metadata, successCallback, failureCallback) {
	OuralabsPlugin.log(this.LogLevel.INFO, tag, message, metadata, successCallback, failureCallback);
};

/**
 * Logs a log message of level WARN with the given information.
 * 
 * @param {string} tag - The tag for the log entry.
 * @param {string} message - The body of the log message.
 * @param [*] metadata - An optional object to be appended to the log message in JSON format. If the object cannot be serialized into JSON it will be flattened into key/value pairs.
 * @param [function] successCallback - The success callback for this asynchronous function.
 * @param [function] failureCallback - The failure callback for this asynchronous function; receives an error string.
 */
OuralabsPlugin.logWarn = function logWarn(tag, message, metadata, successCallback, failureCallback) {
	OuralabsPlugin.log(this.LogLevel.WARN, tag, message, metadata, successCallback, failureCallback);
};

/**
 * Logs a log message of level ERROR with the given information.
 * 
 * @param {string} tag - The tag for the log entry.
 * @param {string} message - The body of the log message.
 * @param [*] metadata - An optional object to be appended to the log message in JSON format. If the object cannot be serialized into JSON it will be flattened into key/value pairs.
 * @param [function] successCallback - The success callback for this asynchronous function.
 * @param [function] failureCallback - The failure callback for this asynchronous function; receives an error string.
 */
OuralabsPlugin.logError = function logError(tag, message, metadata, successCallback, failureCallback) {
	OuralabsPlugin.log(this.LogLevel.ERROR, tag, message, metadata, successCallback, failureCallback);
};

/**
 * Logs a log message of level FATAL with the given information.
 * 
 * @param {string} tag - The tag for the log entry.
 * @param {string} message - The body of the log message.
 * @param [*] metadata - An optional object to be appended to the log message in JSON format. If the object cannot be serialized into JSON it will be flattened into key/value pairs.
 * @param [function] successCallback - The success callback for this asynchronous function.
 * @param [function] failureCallback - The failure callback for this asynchronous function; receives an error string.
 */
OuralabsPlugin.logFatal = function logFatal(tag, message, metadata, successCallback, failureCallback) {
	OuralabsPlugin.log(this.LogLevel.FATAL, tag, message, metadata, successCallback, failureCallback);
};

/**
 * Logs a message with the given information.
 * 
 * @param {number} logLevel - The level of the log; see OuralabsPlugin.LogLevels for possible values.
 * @param {string} tag - The tag for the log entry.
 * @param {string} message - The body of the log message.
 * @param [*] metadata - An optional object to be appended to the log message in JSON format. If the object cannot be serialized into JSON it will be flattened into key/value pairs.
 * @param [function] successCallback - The success callback for this asynchronous function.
 * @param [function] failureCallback - The failure callback for this asynchronous function; receives an error string.
 */
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
