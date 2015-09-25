package com.ouralabs;

import com.crashlytics.android.Crashlytics;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;
import org.json.JSONArray;
import org.json.JSONException;

import javax.security.auth.callback.Callback;

public final class OuralabsPlugin extends CordovaPlugin {

    @Override
    public boolean execute(String action, JSONArray args, final CallbackContext callbackContext) throws JSONException {

        if (action == null) {
            return false;
        }

        if (action.equals("init")) {

            if (args.length() != 1) {
                callbackContext.error("A channel ID is required.");
                return false;
            }

            String applicationId = args.getString(0);

            Ouralabs.init(this.cordova.getActivity().getApplicationContext(), applicationId);

            callbackContext.success();
            return true;
        }

        return false;
    }
}
