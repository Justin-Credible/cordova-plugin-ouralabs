package com.ouralabs;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;
import org.json.JSONArray;
import org.json.JSONException;

public final class OuralabsPlugin extends CordovaPlugin {

    @Override
    public boolean execute(String action, JSONArray args, final CallbackContext callbackContext) throws JSONException {

        if (action == null) {
            return false;
        }

        if (action.equals("init")) {
            this.init(args, callbackContext);
        }
        else if (action.equals("log")) {
            this.log(args, callbackContext);
        }
        else {
            // The given action was not handled above.
            return false;
        }

        // The given action was handled above.
        return true;
    }

    private void init(JSONArray args, final CallbackContext callbackContext) throws JSONException {

        // Ensure we have the correct number of arguments.
        if (args.length() != 1) {
            callbackContext.error("A channel ID is required.");
            return;
        }

        // Obtain the arguments.
        String channelId = args.getString(0);

        // Validate the arguments.

        if (channelId == null || channelId.equals("")) {
            callbackContext.error("A channel ID is required.");
        }

        // Delegate to the Ouralabs API.
        Ouralabs.init(this.cordova.getActivity().getApplicationContext(), channelId);
        callbackContext.success();
    }

    private void log(JSONArray args, final CallbackContext callbackContext) throws JSONException {

        // Ensure we have the correct number of arguments.
        if (args.length() != 3) {
            callbackContext.error("A log level, tag name, and message are required.");
            return;
        }

        // Obtain the arguments.
        int logLevel = args.getInt(0);
        String tag = args.getString(1);
        String message = args.getString(2);

        // Validate the arguments.

        if (logLevel < 0 || logLevel > 5) {
            logLevel = Ouralabs.TRACE;
        }

        if (tag == null || tag.equals("")) {
            callbackContext.error("A tag is required.");
            return;
        }

        if (message == null || message.equals("")) {
            callbackContext.error("A message is required.");
            return;
        }

        // Delegate to the Ouralabs API.
        Ouralabs.log(logLevel, tag, message);
        callbackContext.success();
    }
}
