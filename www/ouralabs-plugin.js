"use strict";

var exec = require("cordova/exec");

var PLUGIN_ID = "OuralabsPlugin";

exports.LogLevel = {
	TRACE: 0,
	DEBUG: 1,
	INFO: 2,
	WARN: 3,
	ERROR: 4,
	FATAL: 5
};

exports.init = function init(channelId, successCallback, failureCallback) {
	exec(successCallback, failureCallback, PLUGIN_ID, "init", [channelId]);
};

exports.setAttributes = function setAttributes(attribute1, attribute2, attribute3, successCallback, failureCallback) {
	
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

exports.logTrace = function logTrace(tag, message, metadata, successCallback, failureCallback) {
	this.log(this.LogLevel.TRACE, tag, message, metadata, successCallback, failureCallback);
};

exports.logDebug = function logDebug(tag, message, metadata, successCallback, failureCallback) {
	this.log(this.LogLevel.DEBUG, tag, message, metadata, successCallback, failureCallback);
};

exports.logInfo = function logInfo(tag, message, metadata, successCallback, failureCallback) {
	this.log(this.LogLevel.INFO, tag, message, metadata, successCallback, failureCallback);
};

exports.logWarn = function logWarn(tag, message, metadata, successCallback, failureCallback) {
	this.log(this.LogLevel.WARN, tag, message, metadata, successCallback, failureCallback);
};

exports.logError = function logError(tag, message, metadata, successCallback, failureCallback) {
	this.log(this.LogLevel.ERROR, tag, message, metadata, successCallback, failureCallback);
};

exports.logFatal = function logFatal(tag, message, metadata, successCallback, failureCallback) {
	this.log(this.LogLevel.FATAL, tag, message, metadata, successCallback, failureCallback);
};

exports.log = function log(logLevel, tag, message, metadata, successCallback, failureCallback) {
	
	if (logLevel == null) {
		logLevel = this.LogLevel.TRACE;
	}
	
	if (!tag || typeof(tag) !== "string") {
		tag = "[No Tag]";
	}
	
	if (!message || typeof(message) !== "string") {
		message = "[No Message]";
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
	
	exec(successCallback, failureCallback, PLUGIN_ID, "log", [logLevel, tag, message]);
};