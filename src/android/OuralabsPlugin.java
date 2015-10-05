package com.ouralabs;

import java.util.Map;
import java.util.HashMap;
import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;
import org.json.JSONArray;
import org.json.JSONException;

public final class OuralabsPlugin extends CordovaPlugin {

    @Override
    public boolean execute(String action, final JSONArray args, final CallbackContext callbackContext) throws JSONException {

        if (action == null) {
            return false;
        }

        if (action.equals("init")) {

            cordova.getThreadPool().execute(new Runnable() {
                public void run() {
                    try {
                        OuralabsPlugin.this.init(args, callbackContext);
                    }
                    catch (Exception exception) {
                        callbackContext.error("OuralabsPlugin uncaught exception: " + exception.getMessage());
                    }
                }
            });

            return true;
        }
        else if (action.equals("setAttributes")) {

            cordova.getThreadPool().execute(new Runnable() {
                public void run() {
                    try {
                        OuralabsPlugin.this.setAttributes(args, callbackContext);
                    }
                    catch (Exception exception) {
                        callbackContext.error("OuralabsPlugin uncaught exception: " + exception.getMessage());
                    }
                }
            });

            return true;
        }
        else if (action.equals("log")) {

            cordova.getThreadPool().execute(new Runnable() {
                public void run() {
                    try {
                        OuralabsPlugin.this.log(args, callbackContext);
                    }
                    catch (Exception exception) {
                        callbackContext.error("OuralabsPlugin uncaught exception: " + exception.getMessage());
                    }
                }
            });

            return true;
        }
        else {
            // The given action was not handled above.
            return false;
        }
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

    private void setAttributes(JSONArray args, final CallbackContext callbackContext) throws JSONException {

        // Ensure we have the correct number of arguments.
        if (args.length() != 3) {
            callbackContext.error("Three attribute values are required.");
            return;
        }

        // Obtain the arguments.
        String attribute1 = args.getString(0);
        String attribute2 = args.getString(1);
        String attribute3 = args.getString(2);

        // Build the dictionary of arguments for the Ouralabs API.
        Map<String, String> attrs = new HashMap<String, String>();
        attrs.put(Ouralabs.ATTR_1, attribute1);
        attrs.put(Ouralabs.ATTR_2, attribute2);
        attrs.put(Ouralabs.ATTR_3, attribute3);

        // Delegate to the Ouralabs API.
        Ouralabs.setAttributes(attrs);
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
