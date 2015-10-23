package com.ouralabs;

import android.Manifest;
import android.annotation.TargetApi;
import android.app.Activity;
import android.app.Application;
import android.content.Context;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.content.res.Configuration;
import android.location.Location;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.os.Handler;
import android.os.HandlerThread;
import android.os.Looper;
import android.provider.Settings.Secure;
import android.util.Base64;
import android.util.Log;

import org.json.JSONException;
import org.json.JSONObject;

import java.io.BufferedReader;
import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.Closeable;
import java.io.DataOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.FilenameFilter;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.io.PrintWriter;
import java.io.RandomAccessFile;
import java.io.StringWriter;
import java.lang.reflect.Field;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.channels.FileChannel;
import java.nio.charset.Charset;
import java.security.InvalidAlgorithmParameterException;
import java.security.InvalidKeyException;
import java.security.NoSuchAlgorithmException;
import java.security.PublicKey;
import java.security.SecureRandom;
import java.security.cert.Certificate;
import java.security.cert.CertificateException;
import java.security.cert.CertificateFactory;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.Iterator;
import java.util.LinkedHashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Queue;
import java.util.Random;
import java.util.Set;
import java.util.UUID;
import java.util.zip.GZIPOutputStream;

import javax.crypto.BadPaddingException;
import javax.crypto.Cipher;
import javax.crypto.IllegalBlockSizeException;
import javax.crypto.NoSuchPaddingException;
import javax.crypto.spec.IvParameterSpec;
import javax.crypto.spec.SecretKeySpec;

public final class Ouralabs {

    private static final String TAG = "Ouralabs";

    public static final String VERSION = "2.7.1";

    public static final int TRACE = 0;
    public static final int DEBUG = 1;
    public static final int INFO = 2;
    public static final int WARN = 3;
    public static final int ERROR = 4;
    public static final int FATAL = 5;

    public static final String ATTR_1 = "attr_1";
    public static final String ATTR_2 = "attr_2";
    public static final String ATTR_3 = "attr_3";

    private static final Charset UTF8 = Charset.forName("UTF-8");

    private static final String[] LOG_LEVELS = {"TRACE", "DEBUG", "INFO", "WARN", "ERROR", "FATAL"};
    private static final int AES_BLOCK_SIZE = 16;

    private static final String SETTING_API_SCHEME = "api_scheme";
    private static final String SETTING_API_HOST = "api_host";
    private static final String SETTING_API_TIMEOUT = "api_timeout";
    private static final String SETTING_LOG_LEVEL = "log_level";
    private static final String SETTING_MAX_FILE_SIZE = "max_file_size";
    private static final String SETTING_MAX_SIZE = "max_size";
    private static final String SETTING_UPLOAD_INTERVAL_LIVE_TAIL = "upload_interval_live_tail";
    private static final String SETTING_UPLOAD_INTERVAL_WIFI = "upload_interval_wifi";
    private static final String SETTING_UPLOAD_INTERVAL_WWAN = "upload_interval_wwan";
    private static final String SETTING_EXPIRATION = "expiration";
    private static final String SETTING_LIVE_TAIL = "live_tail";
    private static final String SETTING_CERTIFICATE = "certificate";
    private static final String SETTING_DISK_ONLY = "disk_only";
    private static final String SETTING_BUFFERED = "buffered";
    private static final String SETTING_LOGGER_LOGS_ALLOWED = "logger_logs_allowed";
    private static final String SETTING_LOG_LIFECYCLE = "log_lifecycle";
    private static final String SETTING_UNCAUGHT_EXCEPTIONS = "uncaught_exceptions";

    private static final String _SETTING_ATTR_1     = "_attr_1";
    private static final String _SETTING_ATTR_2     = "_attr_2";
    private static final String _SETTING_ATTR_3     = "_attr_3";
    private static final String _SETTING_OPT_IN     = "_opt_in";
    private static final String _SETTING_ANDROID_ID = "_android_id";

    private static final Object sLock = new Object();
    private static final Cache<String, Object> sCache = new Cache<String, Object>(30);

    private static Application sContext;
    private static Handler sHandler;
    private static Handler sMainHandler;
    private static ConnectivityManager sConnectivityManager;
    private static boolean sInitialized;
    private static boolean sLifecycleHooked;
    private static boolean sDisableTimedOperations;
    private static String sChannelKey;
    private static Integer sLogLevel;
    private static Boolean sLiveTail;
    private static Boolean sDiskOnly;
    private static Boolean sBuffered;
    private static Queue<LogEntry> sQueue;
    private static JSONObject sSettings;
    private static String sAppVersion;
    private static Location sLocation;
    private static Map<String, String> sAttributes;
    private static Boolean sLoggerLogsAllowed;
    private static Boolean sLogLifecycle;
    private static Boolean sUncaughtExceptions;

    private static OnSettingsChangeListener sOnSettingsChangeListener;

    private static Handler sOnLogListenerHandler;
    private static OnLogListener sOnLogListener;

    private static ActivityLifecycleCallbacks sActivityLifecycleCallbacks;
    private static OnProvideAssistDataListener sOnProvideAssistDataListener;
    private static ExceptionHandler sExceptionHandler;

    private static SecretKeySpec sAESKey;
    private static byte[] sEncryptedAESKey;
    private static Cipher sAESCipher;

    private static Random sRandom;

    private static File sFile;
    private static long sFileSize;
    private static List<File> sFiles;
    private static OutputStream sOutputStream;
    private static FileComparator sFileComparator;
    private static FilenameFilter sFilenameFilter;

    private static Runnable sSettingsJob;
    private static Runnable sQueueJob;
    private static Runnable sUploadJob;
    private static Runnable sSettingsChangeJob;

    // =============================================================================================
    // Constructor
    // =============================================================================================

    static {
        synchronized (sLock) {
            HandlerThread thread = new HandlerThread("Ouralabs");
            thread.setPriority(Thread.NORM_PRIORITY);
            thread.start();

            sQueue = new LinkedList<LogEntry>();
            sHandler = new Handler(thread.getLooper());
            sMainHandler = new Handler(Looper.getMainLooper());
            sFileComparator = new FileComparator();
            sFilenameFilter = new FileFilter();
            sFiles = new LinkedList<File>();
            sSettings = new JSONObject();

            sRandom = new SecureRandom();
            sExceptionHandler = new ExceptionHandler();

            try {
                sAESCipher = Cipher.getInstance("AES/CBC/PKCS7Padding");
            } catch (NoSuchAlgorithmException ex) {
                Log.e(TAG, "Could not load AES cipher.", ex);
            } catch (NoSuchPaddingException ex) {
                Log.e(TAG, "Could not load AES cipher.", ex);
            }

            sSettingsJob = new SettingsJob();
            sQueueJob = new QueueJob();
            sUploadJob = new UploadJob();
            sSettingsChangeJob = new SettingsChangeJob();
        }
    }

    // =============================================================================================
    // Public API
    // =============================================================================================

    public static void init(Context context, String channelKey) {
        synchronized (sLock) {
            if (sInitialized) {
                w(TAG, "Ouralabs already initialized.");
            } else if (context == null) {
                e(TAG, "Cannot init with null context.");
            } else if (isEmpty(channelKey)) {
                e(TAG, "Cannot init with null or empty channel key.");
            } else {
                sInitialized = true;
                sContext = (Application) context.getApplicationContext();
                sChannelKey = channelKey;
                sSettings = getDefaultSettings();
                sAESKey = generateAESKey();

                if (Build.VERSION.SDK_INT > 14) {
                    sContext.registerComponentCallbacks(getComponentCallbacks());
                }

                loadSettings();

                updateFiles();
                toggleLogLifecycle();
                toggleUncaughtExceptionHandler();

                l(INFO, TAG, "Initialized Ouralabs.");

                sConnectivityManager = (ConnectivityManager) sContext.getSystemService(Context.CONNECTIVITY_SERVICE);

                sHandler.post(sSettingsJob);
                sHandler.post(sQueueJob);
                sHandler.post(sUploadJob);

                publishOnSettingsChange();
            }
        }
    }

    public static void setLiveTail(Boolean liveTail) {
        l(INFO, TAG, "Set live tail.", new KVP().put("liveTail", liveTail));

        synchronized (sLock) {
            sLiveTail = liveTail;

            publishOnSettingsChange();
        }
    }

    public static void setAppVersion(String appVersion) {
        l(INFO, TAG, "Set app version.", new KVP().put("appVersion", appVersion));

        synchronized (sLock) {
            sAppVersion = appVersion;
        }
    }

    public static void setLogLevel(Integer logLevel) {
        l(INFO, TAG, "Set log level.", new KVP().put("logLevel", logLevel));

        synchronized (sLock) {
            sLogLevel = logLevel;

            if (sLogLevel != null) {
                sLogLevel = Math.min(FATAL, Math.max(TRACE, sLogLevel));
            }

            publishOnSettingsChange();
        }
    }

    public static void setDiskOnly(Boolean diskOnly) {
        l(INFO, TAG, "Set disk only.", new KVP().put("diskOnly", diskOnly));

        synchronized (sLock) {
            sDiskOnly = diskOnly;
        }
    }

    public static void setBuffered(Boolean buffered) {
        l(INFO, TAG, "Set buffered.", new KVP().put("buffered", buffered));

        synchronized (sLock) {
            sBuffered = buffered;
        }
    }

    public static void setAttributes(Map<String, String> attributes) {
        l(INFO, TAG, "Set attributes.", new KVP(attributes));

        synchronized (sLock) {
            if (attributes == null) attributes = new HashMap<String, String>();
            if (sAttributes == null) sAttributes = new HashMap<String, String>();

            String attr1 = sAttributes.containsKey(ATTR_1) ? valOrEmpty(sAttributes.get(ATTR_1)) : "";
            String attr2 = sAttributes.containsKey(ATTR_2) ? valOrEmpty(sAttributes.get(ATTR_2)) : "";
            String attr3 = sAttributes.containsKey(ATTR_3) ? valOrEmpty(sAttributes.get(ATTR_3)) : "";

            boolean changed;

            changed = !attr1.equals(attributes.get(ATTR_1));
            changed = changed || !attr2.equals(attributes.get(ATTR_2));
            changed = changed || !attr3.equals(attributes.get(ATTR_3));

            sAttributes = attributes;

            if (changed) {
                sHandler.post(new SettingsJob());
            }
        }
    }

    public static void setOptIn(boolean optIn) {
        l(INFO, TAG, "Set opt in.", new KVP().put("optIn", optIn));

        synchronized (sLock) {
            try {
                sSettings.put(_SETTING_OPT_IN, optIn);
                saveSettings();
            } catch (JSONException ex) {
                l(ERROR, TAG, "Could not set opt-in.", ex);
            }
        }
    }

    public static void setDisableTimedOperations(boolean disable) {
        l(INFO, TAG, "Set disable timed operations.", new KVP().put("disable", disable));

        synchronized (sLock) {
            sDisableTimedOperations = disable;
        }
    }

    public static void setLocation(Location location) {
        l(INFO, TAG, "Set location.", new KVP().put("location", location));

        synchronized (sLock) {
            sLocation = location;
        }
    }

    public static void setLoggerLogsAllowed(Boolean allowed) {
        l(INFO, TAG, "Set logger logs allowed.", new KVP().put("allowed", allowed));

        synchronized (sLock) {
            sLoggerLogsAllowed = allowed;
        }
    }

    public static void setOnSettingsChangeListener(OnSettingsChangeListener listener) {
        l(INFO, TAG, "Set settings change listener.");

        synchronized (sLock) {
            sOnSettingsChangeListener = listener;
        }
    }

    public static void setLogLifecycle(Boolean enable) {
        l(INFO, TAG, "Set log lifecycle.", new KVP().put("enable", enable));

        synchronized (sLock) {
            sLogLifecycle = enable;

            toggleLogLifecycle();
        }
    }

    public static void setLogUncaughtExceptions(Boolean enable) {
        l(INFO, TAG, "Set uncaught exceptions.", new KVP().put("enabled", enable));

        synchronized (sLock) {
            sUncaughtExceptions = enable;
        }

        toggleUncaughtExceptionHandler();
    }

    public static void setOnLogListener(OnLogListener listener) {
        setOnLogListener(listener, new Handler(Looper.getMainLooper()));
    }

    public static void setOnLogListener(OnLogListener listener, Handler handler) {
        l(INFO, TAG, "Set log listener.");

        synchronized (sLock) {
            sOnLogListener = listener;
            sOnLogListenerHandler = handler != null ? handler : new Handler(Looper.getMainLooper());
        }
    }

    public static void update() {
        synchronized (sLock) {
            if (sInitialized) {
                l(INFO, TAG, "Forcing update.");

                sHandler.removeCallbacks(sSettingsJob);
                sHandler.removeCallbacks(sUploadJob);
                sHandler.post(sSettingsJob);
                sHandler.post(sUploadJob);
            } else {
                l(WARN, TAG, "Attempted to update without initializing.");
            }
        }
    }

    public static void flush() {
        synchronized (sLock) {
            if (sInitialized) {
                l(INFO, TAG, "Forcing flush.");

                sHandler.removeCallbacks(sUploadJob);
                sHandler.post(sUploadJob);
            } else {
                l(WARN, TAG, "Attempted to flush without initializing.");
            }
        }
    }

    public static boolean getInitialized() {
        synchronized (sLock) {
            return sInitialized;
        }
    }

    public static boolean getLiveTail() {
        synchronized (sLock) {
            if (sLiveTail != null) return sLiveTail;
            return sSettings != null && sSettings.optBoolean(SETTING_LIVE_TAIL);
        }
    }

    public static int getLogLevel() {
        synchronized (sLock) {
            if (sLogLevel != null) return sLogLevel;
            return sSettings != null ? sSettings.optInt(SETTING_LOG_LEVEL) : TRACE;
        }
    }

    public static boolean getOptIn() {
        synchronized (sLock) {
            return sSettings == null || sSettings.optBoolean(_SETTING_OPT_IN, true);
        }
    }

    public static boolean getDiskOnly() {
        synchronized (sLock) {
            if (sDiskOnly != null) return sDiskOnly;
            return sSettings == null || sSettings.optBoolean(SETTING_DISK_ONLY, true);
        }
    }

    public static boolean getBuffered() {
        synchronized (sLock) {
            if (sBuffered != null) return sBuffered;
            return sSettings != null && sSettings.optBoolean(SETTING_BUFFERED);
        }
    }

    public static String getAppVersion() {
        synchronized (sLock) {
            if (sAppVersion != null) return sAppVersion;

            if (!sInitialized) {
                l(ERROR, TAG, "Could not get app version.", new KVP().put("reason", "SDK not initialized"));
                return "0.0.0";
            }

            try {
                PackageInfo packageInfo = sContext.getPackageManager().getPackageInfo(sContext.getPackageName(), 0);
                String version = valOr(packageInfo.versionName, "0.0.0");
                int build =  packageInfo.versionCode;

                sAppVersion = version + "-" + build;
            } catch (PackageManager.NameNotFoundException ex) {
                l(ERROR, TAG, "Could not get app version.", ex);
                sAppVersion = "0.0.0";
            }

            return sAppVersion;
        }
    }

    public static String getVersion() {
        return VERSION;
    }

    public static Map<String, String> getAttributes() {
        synchronized (sLock) {
            Map<String, String> attrs = new HashMap<String, String>();

            if (sAttributes != null) attrs.putAll(sAttributes);

            return attrs;
        }
    }

    public static boolean getDisableTimedOperations() {
        synchronized (sLock) {
            return sDisableTimedOperations;
        }
    }

    public static Location getLocation() {
        synchronized (sLock) {
            return sLocation;
        }
    }

    public static boolean getLoggerLogsAllowed() {
        synchronized (sLock) {
            if (sLoggerLogsAllowed != null) return sLoggerLogsAllowed;
            return sSettings != null && sSettings.optBoolean(SETTING_LOGGER_LOGS_ALLOWED);
        }
    }

    public static OnSettingsChangeListener getOnSettingsChangeListener() {
        synchronized (sLock) {
            return sOnSettingsChangeListener;
        }
    }

    public static boolean getLogLifecycle() {
        synchronized (sLock) {
            if (sLogLifecycle != null) return sLogLifecycle;
            return sSettings != null && sSettings.optBoolean(SETTING_LOG_LIFECYCLE);
        }
    }

    public static boolean getLogUncaughtExceptions() {
        synchronized (sLock) {
            if (sUncaughtExceptions != null) return sUncaughtExceptions;
            return sSettings != null && sSettings.optBoolean(SETTING_UNCAUGHT_EXCEPTIONS);
        }
    }

    public static OnLogListener getOnLogListener() {
        synchronized (sLock) {
            return sOnLogListener;
        }
    }

    public static void t(String tag, String message) {
        log(TRACE, tag, message);
    }

    public static void t(String tag, String message, Object... args) {
        log(TRACE, tag, message, args);
    }

    public static void t(String tag, String message, Throwable tr) {
        log(TRACE, tag, message, tr);
    }

    public static void t(String tag, String message, KVP kvp) {
        log(TRACE, tag, message, kvp);
    }

    public static void d(String tag, String message) {
        log(DEBUG, tag, message);
    }

    public static void d(String tag, String message, Object... args) {
        log(DEBUG, tag, message, args);
    }

    public static void d(String tag, String message, Throwable tr) {
        log(DEBUG, tag, message, tr);
    }

    public static void d(String tag, String message, KVP kvp) {
        log(DEBUG, tag, message, kvp);
    }

    public static void i(String tag, String message) {
        log(INFO, tag, message);
    }

    public static void i(String tag, String message, Object... args) {
        log(INFO, tag, message, args);
    }

    public static void i(String tag, String message, Throwable tr) {
        log(INFO, tag, message, tr);
    }

    public static void i(String tag, String message, KVP kvp) {
        log(INFO, tag, message, kvp);
    }

    public static void w(String tag, String message) {
        log(WARN, tag, message);
    }

    public static void w(String tag, String message, Object... args) {
        log(WARN, tag, message, args);
    }

    public static void w(String tag, String message, Throwable tr) {
        log(WARN, tag, message, tr);
    }

    public static void w(String tag, String message, KVP kvp) {
        log(WARN, tag, message, kvp);
    }

    public static void e(String tag, String message) {
        log(ERROR, tag, message);
    }

    public static void e(String tag, String message, Object... args) {
        log(ERROR, tag, message, args);
    }

    public static void e(String tag, String message, Throwable tr) {
        log(ERROR, tag, message, tr);
    }

    public static void e(String tag, String message, KVP kvp) {
        log(ERROR, tag, message, kvp);
    }

    public static void f(String tag, String message) {
        log(FATAL, tag, message);
    }

    public static void f(String tag, String message, Object... args) {
        log(FATAL, tag, message, args);
    }

    public static void f(String tag, String message, Throwable tr) {
        log(FATAL, tag, message, tr);
    }

    public static void f(String tag, String message, KVP kvp) {
        log(FATAL, tag, message, kvp);
    }

    public static void log(int level, String tag, String message) {
        if (!shouldLog(level)) return;

        logInternal(level, tag, valOrEmpty(message));
    }

    public static void log(int level, String tag, String message, Object... args) {
        if (!shouldLog(level)) return;

        logInternal(level, tag, String.format(valOrEmpty(message), args));
    }

    public static void log(int level, String tag, String message, Throwable tr) {
        if (!shouldLog(level)) return;

        logInternal(level, tag, valOrEmpty(message) + '\n' + getStackTraceString(tr));
    }

    public static void log(int level, String tag, String message, KVP kvp) {
        if (!shouldLog(level)) return;

        logInternal(level, tag, valOrEmpty(message) + " " + (kvp != null ? kvp.toString() : ""));
    }

    private static void l(int level, String tag, String message) {
        if (getLoggerLogsAllowed()) log(level, tag, message);
    }

    private static void l(int level, String tag, String message, Object... args) {
        if (getLoggerLogsAllowed()) log(level, tag, message, args);
    }

    private static void l(int level, String tag, String message, Throwable tr) {
        if (getLoggerLogsAllowed()) log(level, tag, message, tr);
    }

    private static void l(int level, String tag, String message, KVP kvp) {
        if (getLoggerLogsAllowed()) log(level, tag, message, kvp);
    }

    // =============================================================================================
    // Internals
    // =============================================================================================

    private static void logInternal(int level, String tag, String message) {
        synchronized (sLock) {
            LogEntry log = new LogEntry(
                    getLocation(),
                    Thread.currentThread().getName(),
                    System.currentTimeMillis(),
                    level,
                    tag,
                    message,
                    getAppVersion());

            if (getBuffered() && level < ERROR) {
                sQueue.offer(log);

                if (sQueue.size() == 1) {
                    sHandler.removeCallbacks(sQueueJob);
                    sHandler.post(sQueueJob);
                }
            } else {
                processLog(log);
            }
        }
    }

    @SuppressWarnings("All")
    private static void processLog(final LogEntry log) {
        if (!getDiskOnly()) {
            switch (log.getLogLevel()) {
                case TRACE:
                    Log.println(Log.VERBOSE, log.getTag(), log.getMessage());
                    break;
                case DEBUG:
                    Log.println(Log.DEBUG, log.getTag(), log.getMessage());
                    break;
                case INFO:
                    Log.println(Log.INFO, log.getTag(), log.getMessage());
                    break;
                case WARN:
                    Log.println(Log.WARN, log.getTag(), log.getMessage());
                    break;
                case ERROR:
                case FATAL:
                    Log.println(Log.ERROR, log.getTag(), log.getMessage());
                    break;
            }
        }

        synchronized (sLock) {
            if (sOnLogListener != null) {
                sOnLogListenerHandler.post(new Runnable() {
                    @Override
                    public void run() {
                        sOnLogListener.onLog(log);
                    }
                });
            }

            if (sFile == null) return;

            if (sOutputStream != null) {
                IvParameterSpec ivSpec = generateAESIV();
                String msg = log.getFullMessage();
                byte[] message = msg.getBytes();
                byte[] encrypted = AESEncrypt(message, sAESKey, ivSpec);

                if (encrypted != null) {
                    byte[] iv = ivSpec.getIV();
                    byte[] merged = new byte[sEncryptedAESKey.length + iv.length + encrypted.length];
                    System.arraycopy(sEncryptedAESKey, 0, merged, 0, sEncryptedAESKey.length);
                    System.arraycopy(iv, 0, merged, sEncryptedAESKey.length, iv.length);
                    System.arraycopy(encrypted, 0, merged, sEncryptedAESKey.length + iv.length, encrypted.length);

                    byte[] base64 = Base64.encode(merged, Base64.NO_WRAP);

                    try {
                        sOutputStream.write(base64);
                        sOutputStream.write('\n');
                        sOutputStream.flush();
                    } catch (IOException ex) {
                        Log.e(TAG, "Could not write line", ex);
                    }

                    sFileSize += base64.length + 1; // +1 for new line char
                }
            }

            if (sFileSize >= sSettings.optLong(SETTING_MAX_FILE_SIZE)) rollFile();
        }
    }

    private static boolean shouldLog(int requestLevel) {
        synchronized (sLock) {
            if (!sInitialized)            return false;
            if (sEncryptedAESKey == null) return false;
            if (!getOptIn())              return false;
            if (sLogLevel != null)        return requestLevel >= sLogLevel;

            return requestLevel >= sSettings.optInt(SETTING_LOG_LEVEL);
        }
    }

    private static void publishOnSettingsChange() {
        synchronized (sLock) {
            if (getOnSettingsChangeListener() != null) {
                sMainHandler.post(sSettingsChangeJob);
            }
        }
    }

    private static void close(Closeable closeable) {
        if (closeable == null) return;

        try {
            closeable.close();
        } catch (IOException e) {
            // no-op
        }
    }

    private static String getAndroidID() {
        try {
            return sSettings.getString(_SETTING_ANDROID_ID);
        } catch (JSONException ex) {
            String androidID = Secure.getString(sContext.getContentResolver(), Secure.ANDROID_ID);

            if (isEmpty(androidID)) {
                androidID = UUID.randomUUID().toString();
            }

            try {
                sSettings.put(_SETTING_ANDROID_ID, androidID);
            } catch (JSONException ex1) {
                l(ERROR, TAG, "Could not get android ID.");
            }

            return androidID;
        }
    }

    @TargetApi(9)
    private static String getSerial() {
        return Build.VERSION.SDK_INT >= 9 ? Build.SERIAL : "";
    }

    @SuppressWarnings("all")
    private static File getRootDirectory() {
        File file = new File(sContext.getFilesDir(), "ouralabs");
        if (!file.exists()) file.mkdirs();
        return file;
    }

    @SuppressWarnings("All")
    private static File getDirectory() {
        File file = new File(getRootDirectory(), sChannelKey);
        if (!file.exists()) file.mkdirs();
        return file;
    }

    @SuppressWarnings("All")
    private static File getWorkingDirectory() {
        File file = new File(getDirectory(), "working");
        if (!file.exists()) file.mkdirs();
        return file;
    }

    private static File getFile() {
        return new File(getDirectory(), sChannelKey + ".txt");
    }

    private static File getRolledFile(File file) {
        File directory = file.getParentFile();

        int index = file.getName().lastIndexOf('.');
        String ext = file.getName().substring(index + 1);
        String name = file.getName().substring(0, index);

        String newName = String.format("%s.%d.%s", name, System.currentTimeMillis(), ext);

        return new File(directory, newName);
    }

    @SuppressWarnings("All")
    private static void rollFile() {
        File rollTo = getRolledFile(sFile);
        sFile.renameTo(rollTo);

        updateFiles();

        long total = 0;
        int delCount = 0;

        for (int i = sFiles.size() - 1; i >= 0; i--) {
            total += sFiles.get(i).length();

            if (total > sSettings.optLong(SETTING_MAX_SIZE)) {
                delCount++;
            }
        }

        for (int i = 0; i < delCount; i++) {
            File file = sFiles.get(i);

            file.delete();
            sFiles.remove(file);
        }
    }

    @SuppressWarnings("All")
    private static void clearDir(File file) {
        if (file == null) return;

        if (file.isDirectory()) {
            File[] children = file.listFiles();

            for (File child : children) {
                if (child.isDirectory()) {
                    clearDir(child);
                } else {
                    child.delete();
                }
            }
        }
    }

    @SuppressWarnings("all")
    private static void loadSettings() {
        synchronized (sLock) {
            JSONObject jsonObject = new JSONObject();

            File file = new File(getDirectory(), "settings.json");

            if (file.exists()) {
                RandomAccessFile randomAccessFile = null;

                try {
                    randomAccessFile = new RandomAccessFile(file, "r");
                    byte[] bytes = new byte[(int) randomAccessFile.length()];
                    randomAccessFile.read(bytes);

                    jsonObject = new JSONObject(new String(bytes));
                } catch (IOException ex) {
                    // no-op
                } catch (JSONException ex) {
                    // no-op
                } finally {
                    close(randomAccessFile);
                }

            }

            Iterator<String> itr = jsonObject.keys();
            while (itr.hasNext()) {
                String key = itr.next();
                Object val = jsonObject.opt(key);

                if (key.startsWith("_attr")) continue;

                try {
                    sSettings.put(key, val);
                } catch (JSONException ex) {
                    // no-op
                }
            }

            if (sAttributes == null) sAttributes = new HashMap<String, String>();

            if (jsonObject.has(_SETTING_ATTR_1)) {
                sAttributes.put(ATTR_1, jsonObject.optString(_SETTING_ATTR_1));
            }

            if (jsonObject.has(_SETTING_ATTR_2)) {
                sAttributes.put(ATTR_2, jsonObject.optString(_SETTING_ATTR_2));
            }

            if (jsonObject.has(_SETTING_ATTR_3)) {
                sAttributes.put(ATTR_3, jsonObject.optString(_SETTING_ATTR_3));
            }

            loadCipher();
        }
    }

    private static void saveSettings() {
        synchronized (sLock) {
            File file = new File(getDirectory(), "settings.json");

            PrintWriter printWriter = null;

            try {
                if (sAttributes != null) {
                    if (sAttributes.containsKey(ATTR_1)) {
                        sSettings.put(_SETTING_ATTR_1, sAttributes.get(ATTR_1));
                    }

                    if (sAttributes.containsKey(ATTR_2)) {
                        sSettings.put(_SETTING_ATTR_2, sAttributes.get(ATTR_2));
                    }

                    if (sAttributes.containsKey(ATTR_3)) {
                        sSettings.put(_SETTING_ATTR_3, sAttributes.get(ATTR_3));
                    }
                }

                printWriter = new PrintWriter(file);
                printWriter.write(sSettings.toString());
                printWriter.flush();
            } catch (IOException ex) {
                // no-op
            } catch (JSONException ex) {
                // no-op
            } finally {
                close(printWriter);
            }
        }
    }

    private static JSONObject getDefaultSettings() {
        JSONObject jsonObject = new JSONObject();

        try {
            jsonObject
                    .put(SETTING_API_SCHEME, "https")
                    .put(SETTING_API_HOST, "www.ouralabs.com")
                    .put(SETTING_API_TIMEOUT, 120d)
                    .put(SETTING_LOG_LEVEL, WARN)
                    .put(SETTING_MAX_FILE_SIZE, 1024l * 512l)
                    .put(SETTING_MAX_SIZE, 1024l * 1024l * 20l)
                    .put(SETTING_DISK_ONLY, true)
                    .put(SETTING_BUFFERED, false)
                    .put(SETTING_UPLOAD_INTERVAL_LIVE_TAIL, 5d)
                    .put(SETTING_UPLOAD_INTERVAL_WIFI, 60d * 5d)
                    .put(SETTING_UPLOAD_INTERVAL_WWAN, 60d * 60d)
                    .put(SETTING_EXPIRATION, 60d * 60d)
                    .put(SETTING_LIVE_TAIL, false)
                    .put(SETTING_CERTIFICATE, "")
                    .put(SETTING_LOGGER_LOGS_ALLOWED, false)
                    .put(SETTING_LOG_LIFECYCLE, true)
                    .put(SETTING_UNCAUGHT_EXCEPTIONS, false);
        } catch (JSONException ex) {
            l(ERROR, TAG, "Could not create default settings.", ex);
        }

        return jsonObject;
    }

    private static JSONObject getDevice() {
        JSONObject jsonObject = new JSONObject();

        try {
            jsonObject
                    .put("platform", "android")
                    .put("platform_version", Build.VERSION.RELEASE)
                    .put("manufacturer", Build.MANUFACTURER)
                    .put("model", Build.MODEL)
                    .put("serial", getSerial())
                    .put("android_id", getAndroidID())
                    .put("app_identifier", getAppIdentifier())
                    .put("app_version", getAppVersion())
                    .put("opt_in", getOptIn())
                    .put("live_tail", sLiveTail != null ? sLiveTail : JSONObject.NULL)
                    .put("log_level", sLogLevel != null ? sLogLevel : JSONObject.NULL);

            if (sAttributes != null) {
                if (sAttributes.containsKey(ATTR_1))
                    jsonObject.put(ATTR_1, sAttributes.get(ATTR_1));
                if (sAttributes.containsKey(ATTR_2))
                    jsonObject.put(ATTR_2, sAttributes.get(ATTR_2));
                if (sAttributes.containsKey(ATTR_3))
                    jsonObject.put(ATTR_3, sAttributes.get(ATTR_3));
            }
        } catch (JSONException ex) {
            l(ERROR, TAG, "Could not get device.", ex);
        }

        return jsonObject;
    }

    private static String getStackTraceString(Throwable tr) {
        if (tr == null) return "";

        StringWriter stringWriter = new StringWriter();
        PrintWriter printWriter = new PrintWriter(stringWriter);

        tr.printStackTrace(printWriter);

        return stringWriter.toString();
    }

    private static String valOrEmpty(String message) {
        return valOr(message, "");
    }

    private static String valOr(String val, String defaultVal) {
        if (val == null) return defaultVal;
        return val;
    }

    private static boolean isEmpty(String val) {
        return val == null || val.length() == 0;
    }

    private static boolean hasPermission(String permission) {
        return sContext.checkCallingOrSelfPermission(permission) == PackageManager.PERMISSION_GRANTED;
    }

    private static boolean isWifi() {
        if (hasPermission(Manifest.permission.ACCESS_NETWORK_STATE)) {
            NetworkInfo info = sConnectivityManager.getActiveNetworkInfo();

            return info != null &&
                    info.isConnectedOrConnecting() &&
                    info.getType() == ConnectivityManager.TYPE_WIFI;
        } else {
            return false;
        }
    }

    private static boolean isConnected() {
        if (hasPermission(Manifest.permission.ACCESS_NETWORK_STATE)) {
            NetworkInfo networkinfo = sConnectivityManager.getActiveNetworkInfo();
            return networkinfo != null && networkinfo.isConnected();
        } else {
            return true;
        }
    }

    private static String getAppIdentifier() {
        return sContext.getPackageName();
    }

    private static long getNextDispatch(double val) {
        long interval = (long) (val * 1000l);
        long offset = Math.abs(Integer.valueOf(Build.FINGERPRINT.hashCode()) % interval);
        long current = (System.currentTimeMillis() % 86400000) + offset;
        long next = (long) (Math.ceil((double) current / interval) * interval) - current;

        return next == 0 ? interval : next;
    }

    private static void updateFiles() {
        close(sOutputStream);

        sFile = getFile();
        sFileSize = sFile.length();

        File[] files = getDirectory().listFiles(sFilenameFilter);

        sFiles.clear();
        if (files != null) sFiles.addAll(Arrays.asList(files));
        Collections.sort(sFiles, sFileComparator);

        try {
            sOutputStream = new FileOutputStream(sFile, true);
        } catch (IOException ex) {
            // no-op
        }
    }

    private static SecretKeySpec generateAESKey() {
        byte[] bytes = new byte[AES_BLOCK_SIZE];
        sRandom.nextBytes(bytes);
        return new SecretKeySpec(bytes, "AES");
    }

    private static IvParameterSpec generateAESIV() {
        byte[] bytes = new byte[AES_BLOCK_SIZE];
        sRandom.nextBytes(bytes);
        return new IvParameterSpec(bytes);
    }

    private static void loadCipher() {
        if (sSettings.has(SETTING_CERTIFICATE) && sSettings.optString(SETTING_CERTIFICATE).length() > 0) {
            try {
                String certificate = sSettings.optString(SETTING_CERTIFICATE);
                byte[] data = Base64.decode(certificate, Base64.NO_WRAP);

                CertificateFactory factory = CertificateFactory.getInstance("X.509");
                Certificate cert = factory.generateCertificate(new ByteArrayInputStream(data));
                PublicKey publicKey = cert.getPublicKey();

                sEncryptedAESKey = RSAEncrypt(sAESKey.getEncoded(), publicKey);
            } catch (CertificateException ex) {
                l(ERROR, TAG, "Could not load cipher.", ex);
            }
        }
    }

    @SuppressWarnings("all")
    private static byte[] RSAEncrypt(byte[] input, PublicKey publicKey) {
        if (input == null || publicKey == null) return null;

        try {
            Cipher cipher = Cipher.getInstance("RSA/ECB/PKCS1Padding");
            cipher.init(Cipher.ENCRYPT_MODE, publicKey);
            return cipher.doFinal(input);
        } catch (IllegalBlockSizeException ex) {
            Log.e(TAG, ex.getMessage());
        } catch (BadPaddingException ex) {
            Log.e(TAG, ex.getMessage());
        } catch (NoSuchAlgorithmException ex) {
            Log.e(TAG, ex.getMessage());
        } catch (InvalidKeyException ex) {
            Log.e(TAG, ex.getMessage());
        } catch (NoSuchPaddingException ex) {
            Log.e(TAG, ex.getMessage());
        }

        return null;
    }

    private static byte[] AESEncrypt(byte[] input, SecretKeySpec key, IvParameterSpec iv) {
        if (input == null || key == null || iv == null || sAESCipher == null) return null;

        try {
            sAESCipher.init(Cipher.ENCRYPT_MODE, key, iv);
            return sAESCipher.doFinal(input);
        } catch (InvalidAlgorithmParameterException ex) {
            Log.e(TAG, ex.getMessage());
        } catch (InvalidKeyException ex) {
            Log.e(TAG, ex.getMessage());
        } catch (BadPaddingException ex) {
            Log.e(TAG, ex.getMessage());
        } catch (IllegalBlockSizeException ex) {
            Log.e(TAG, ex.getMessage());
        }

        return null;
    }

    private static byte[] compress(byte[] input) {
        if (input == null) return null;

        byte[] output = null;
        ByteArrayOutputStream os = null;
        GZIPOutputStream gos = null;

        try {
            os = new ByteArrayOutputStream(input.length);
            gos = new GZIPOutputStream(os);

            gos.write(input);
            gos.finish();

            output = os.toByteArray();
        } catch (IOException ex) {
            l(ERROR, TAG, "Could not compress text", ex);
        } finally {
            close(gos);
            close(os);
        }

        return output;
    }

    private static String getTag(Object obj) {
        Class clazz = obj.getClass();

        if (sCache.containsKey(clazz.getName())) {
            return (String) sCache.get(clazz.getName());
        }

        String tag = null;

        try {
            Field field = clazz.getDeclaredField("TAG");
            field.setAccessible(true);

            tag = (String) field.get(null);
        } catch (NoSuchFieldException ex) {
            // no-op
        } catch (IllegalAccessException ex) {
            // no-op
        }

        if (isEmpty(tag)) {
            tag = clazz.getSimpleName();
        }

        sCache.put(clazz.getName(), tag);

        return tag;
    }

    @TargetApi(18)
    private static void toggleLogLifecycle() {
        if (Build.VERSION.SDK_INT >= 14 && sInitialized) {
            synchronized (sLock) {
                if (getLogLifecycle() && !sLifecycleHooked) {
                    sLifecycleHooked = true;

                    l(INFO, TAG, "Hooking lifecycle events.");

                    sActivityLifecycleCallbacks = new ActivityLifecycleCallbacks();

                    sContext.registerActivityLifecycleCallbacks(sActivityLifecycleCallbacks);

                    if (Build.VERSION.SDK_INT >= 18) {
                        sOnProvideAssistDataListener = new OnProvideAssistDataListener();
                        sContext.registerOnProvideAssistDataListener(sOnProvideAssistDataListener);
                    }
                } else if (!getLogLifecycle() && sLifecycleHooked) {
                    sLifecycleHooked = false;

                    l(INFO, TAG, "Unhooking lifecycle events.");

                    sContext.unregisterActivityLifecycleCallbacks(sActivityLifecycleCallbacks);

                    sActivityLifecycleCallbacks = null;

                    if (Build.VERSION.SDK_INT >= 18) {
                        sContext.unregisterOnProvideAssistDataListener(sOnProvideAssistDataListener);
                        sOnProvideAssistDataListener = null;
                    }
                }
            }
        }
    }

    private static void toggleUncaughtExceptionHandler() {
        synchronized (sLock) {
            Thread.UncaughtExceptionHandler handler = Thread.getDefaultUncaughtExceptionHandler();

            if (getLogUncaughtExceptions() && handler != sExceptionHandler) {
                l(DEBUG, TAG, "Using Ouralabs exception handler.");
                Thread.setDefaultUncaughtExceptionHandler(sExceptionHandler);
            } else if (!getLogUncaughtExceptions() && handler == sExceptionHandler) {
                l(DEBUG, TAG, "Removing Ouralabs exception handler.");
                Thread.setDefaultUncaughtExceptionHandler(sExceptionHandler.getOriginalUncaughtExceptionHandler());
            }
        }
    }

    // =============================================================================================
    // Log
    // =============================================================================================

    public static class LogEntry {

        private static final String NULL_STRING = "(null)";

        private Location mLocation;
        private String mThread;
        private long mTime;
        private int mLevel;
        private String mTag;
        private String mMessage;
        private String mAppVersion;

        private LogEntry(Location location, String thread, long time, int level, String tag, String message, String appVersion) {
            mLocation = location;
            mThread = thread != null && thread.length() > 0 ? thread.replace(' ', '_') : NULL_STRING;
            mTime = time;
            mLevel = level;
            mTag = tag != null && tag.length() > 0 ? tag : NULL_STRING;
            mMessage = message != null ? message : "";
            mAppVersion = appVersion;
        }

        public String getFullMessage() {
            String lat = String.valueOf(mLocation != null ? mLocation.getLatitude() : 0);
            String lon = String.valueOf(mLocation != null ? mLocation.getLongitude() : 0);
            String lvl = mLevel < LOG_LEVELS.length ? LOG_LEVELS[mLevel] : "UNKNOWN";

            return mAppVersion + " " + lat + "," + lon + " " + mTime + " - " + mThread + " [" + mTag + "] " + lvl + " " + mMessage;
        }

        public Location getLocation() {
            return mLocation;
        }

        public String getThread() {
            return mThread;
        }

        public long getTime() {
            return mTime;
        }

        public int getLogLevel() {
            return mLevel;
        }

        public String getTag() {
            return mTag;
        }

        public String getMessage() {
            return mMessage;
        }

        public String getAppVersion() {
            return mAppVersion;
        }
    }

    // =============================================================================================
    // Files
    // =============================================================================================

    private static class FileComparator implements Comparator<File> {
        @Override
        public int compare(File file, File file2) {
            return file.getName().compareTo(file2.getName());
        }
    }

    private static class FileFilter implements FilenameFilter {
        @Override
        @SuppressWarnings("all")
        public boolean accept(File file, String s) {
            if ("settings.json".equals(s) ||
                    getWorkingDirectory().getName().equals(s) ||
                    sFile.getName().equals(s)) return false;

            return true;
        }
    }

    // =============================================================================================
    // HTTP
    // =============================================================================================

    private static void makeRequest(String path, byte[] body, OnResponseListener listener) {
        l(DEBUG, TAG, "Making request.",
                new KVP().
                        put("path", path).
                        put("body_size", body != null ? body.length : 0));

        String url = new Uri.Builder()
                .scheme(sSettings.optString(SETTING_API_SCHEME))
                .encodedAuthority(sSettings.optString(SETTING_API_HOST))
                .encodedPath(path)
                .build().toString();

        int timeout = (int) (1000 * sSettings.optDouble(SETTING_API_TIMEOUT));
        int statusCode = -1;
        JSONObject jsonObject = new JSONObject();
        Exception exception = null;

        DataOutputStream outputStream = null;
        InputStream inputStream = null;
        InputStreamReader inputStreamReader = null;
        BufferedReader bufferedReader = null;

        try {
            HttpURLConnection urlConnection = (HttpURLConnection) new URL(url).openConnection();
            urlConnection.setRequestMethod(body == null ? "GET" : "POST");

            urlConnection.setConnectTimeout(timeout);
            urlConnection.setReadTimeout(timeout);

            if (body != null) {
                body = compress(body);

                urlConnection.setDoOutput(true);
                urlConnection.setRequestProperty("Content-Type", "gzip/json");
                urlConnection.setRequestProperty("Content-Encoding", "gzip");
                urlConnection.setRequestProperty("Content-Length", String.valueOf(body.length));

                outputStream = new DataOutputStream(urlConnection.getOutputStream());
                outputStream.write(body);
                outputStream.close();
            }

            statusCode = urlConnection.getResponseCode();

            inputStream = urlConnection.getInputStream();
            inputStreamReader = new InputStreamReader(inputStream);
            bufferedReader = new BufferedReader(inputStreamReader);

            String line;
            StringBuilder builder = new StringBuilder();
            while ((line = bufferedReader.readLine()) != null) {
                builder.append(line);
            }

            jsonObject = new JSONObject(builder.toString());
        } catch (Exception ex) {
            exception = ex;
        } finally {
            close(outputStream);
            close(inputStream);
            close(inputStreamReader);
            close(bufferedReader);

            if (listener != null) {
                listener.onResponse(statusCode, jsonObject, exception);
            }
        }
    }

    private interface OnResponseListener {
        void onResponse(int statusCode, JSONObject jsonObject, Exception ex);
    }

    // =============================================================================================
    // Jobs
    // =============================================================================================

    private static class SettingsJob implements Runnable {
        @Override
        @SuppressWarnings("all")
        public void run() {
            if (isConnected()) {
                final long start = System.currentTimeMillis();

                Uri.Builder builder = new Uri.Builder().path(String.format(Locale.US, "api/v1/channels/%s/settings", sChannelKey));
                JSONObject device = getDevice();

                Iterator<String> itr = device.keys();
                while (itr.hasNext()) {
                    String key = itr.next();
                    builder.appendQueryParameter(key, device.opt(key).toString());
                }

                builder.appendQueryParameter("version", VERSION);

                String path = builder.build().toString();

                makeRequest(path, null, new OnResponseListener() {
                    @Override
                    public void onResponse(int statusCode, JSONObject jsonObject, Exception ex) {
                        double delta = (System.currentTimeMillis() - start) / 1000.0;

                        if (statusCode == 200) {
                            Iterator<String> itr = jsonObject.keys();

                            synchronized (sLock) {
                                while (itr.hasNext()) {
                                    String key = itr.next();
                                    Object val = jsonObject.opt(key);

                                    try {
                                        sSettings.put(key, val);
                                    } catch (JSONException e) {
                                        l(ERROR, TAG, "Could not set settings.", e);
                                    }
                                }

                                updateFiles();
                                loadCipher();
                            }

                            saveSettings();
                            publishOnSettingsChange();
                            toggleLogLifecycle();
                            toggleUncaughtExceptionHandler();
                        } else {
                            String error = ex != null ? ex.getMessage() : jsonObject.optString("error");

                            l(ERROR, TAG, "Could not retrieve settings.",
                                    new KVP().
                                            put("time", delta, 3).
                                            put("error", error).
                                            put("status", statusCode));
                        }
                    }
                });
            } else {
                l(WARN, TAG, "Could not update settings. Not connected to the internet.");
            }

            if (getDisableTimedOperations()) return;

            sHandler.postDelayed(sSettingsJob, getNextDispatch(sSettings.optDouble(SETTING_EXPIRATION)));
        }
    }

    private static class UploadJob implements Runnable {
        @Override
        @SuppressWarnings("All")
        public void run() {
            if (isConnected()) {
                File[] files;

                String path = String.format("api/v1/channels/%s/logs?version=%s", sChannelKey, VERSION);

                File workingDir = getWorkingDirectory();

                synchronized (sLock) {
                    rollFile();

                    files = getDirectory().listFiles(sFilenameFilter);

                    for (File file : files) {
                        if (file.length() == 0) {
                            file.delete();
                        } else {
                            FileChannel in = null, out = null;

                            try {
                                File output = new File(workingDir, file.getName());
                                output.createNewFile();

                                in = new FileInputStream(file).getChannel();
                                out = new FileOutputStream(output).getChannel();

                                out.transferFrom(in, 0, in.size());
                            } catch (FileNotFoundException ex) {
                                l(ERROR, TAG, "Could not move file to working dir", ex);
                            } catch (IOException ex) {
                                l(ERROR, TAG, "Could not move file to working dir", ex);
                            } finally {
                                close(in);
                                close(out);
                            }
                        }
                    }
                }

                files = workingDir.listFiles();

                for (final File file : files) {
                    final long start = System.currentTimeMillis();

                    RandomAccessFile randomAccessFile = null;
                    final byte[] bytes;

                    try {
                        randomAccessFile = new RandomAccessFile(file, "r");
                        bytes = new byte[(int) randomAccessFile.length()];

                        randomAccessFile.read(bytes);

                        String text = new String(bytes, UTF8);
                        JSONObject jsonObject = new JSONObject();

                        try {
                            jsonObject
                                    .put("device", getDevice())
                                    .put("text", text);
                        } catch (JSONException ex) {
                            l(ERROR, TAG, "Could not create log json", ex);
                        }

                        makeRequest(path, jsonObject.toString().getBytes(UTF8), new OnResponseListener() {
                            @Override
                            public void onResponse(int statusCode, JSONObject jsonObject, Exception ex) {
                                double delta = (System.currentTimeMillis() - start) / 1000.0;
                                File original = new File(getDirectory(), file.getName());

                                if (statusCode == 201) {
                                    original.delete();
                                } else if (statusCode == 404) {
                                    l(ERROR, TAG, "Invalid channel key.",
                                            new KVP().
                                                    put("time", delta, 3).
                                                    put("status", statusCode));

                                    original.delete();
                                } else {
                                    String error = ex != null ? ex.getMessage() : jsonObject.optString("error");

                                    l(ERROR, TAG, "Could not upload logs.",
                                            new KVP().
                                                    put("time", delta, 3).
                                                    put("error", error).
                                                    put("size", bytes.length).
                                                    put("status", statusCode));
                                }

                                file.delete();
                            }
                        });
                    } catch (IOException ex) {
                        l(ERROR, TAG, "Could not upload logs", ex);
                    } finally {
                        close(randomAccessFile);
                    }
                }

                clearDir(workingDir);
            } else {
                l(WARN, TAG, "Could not upload logs. Not connected to internet.");
            }

            if (getDisableTimedOperations() && !getLiveTail()) return;

            long nextDispatch;

            if (getLiveTail()) {
                nextDispatch = getNextDispatch(sSettings.optDouble(SETTING_UPLOAD_INTERVAL_LIVE_TAIL));
            } else {
                nextDispatch = getNextDispatch(isWifi()
                        ? sSettings.optDouble(SETTING_UPLOAD_INTERVAL_WIFI)
                        : sSettings.optDouble(SETTING_UPLOAD_INTERVAL_WWAN));
            }

            sHandler.postDelayed(sUploadJob, nextDispatch);
        }
    }

    private static class QueueJob implements Runnable {
        @Override
        public void run() {
            List<LogEntry> logs = new ArrayList<LogEntry>();

            synchronized (sLock) {
                logs.addAll(sQueue);
                sQueue.clear();
            }

            for (LogEntry log : logs) {
                processLog(log);
            }

            synchronized (sLock) {
                if (!sQueue.isEmpty()) {
                    sHandler.removeCallbacks(this);
                    sHandler.post(this);
                }
            }
        }
    }

    private static class SettingsChangeJob implements Runnable {
        @Override
        public void run() {
            synchronized (sLock) {
                OnSettingsChangeListener listener = getOnSettingsChangeListener();

                if (listener != null) {
                    listener.onSettingsChange(getLiveTail(), getLogLevel());
                }
            }
        }
    }

    // =============================================================================================
    // KVP
    // =============================================================================================

    public static class KVP {

        private Map<String, Object> mMap;

        @SuppressWarnings("all")
        public KVP(Map<String, ?> map) {
            this();

            if (map != null) {
                synchronized (map) {
                    mMap.putAll(map);
                }
            }
        }

        public KVP(Bundle bundle) {
            this();

            if (bundle != null) {
                for (String key : bundle.keySet()) {
                    if ("android:viewHierarchyState".equals(key)) continue;

                    mMap.put(key, bundle.get(key));
                }
            }
        }

        public KVP() {
            mMap = new HashMap<String, Object>();
        }

        public KVP put(String key, double value, int scale) {
            return put(key, new KVPDouble(value, scale));
        }

        public KVP put(String key, Object value) {
            if (key != null && key.length() > 0) mMap.put(key, value);

            return this;
        }

        public Object get(String key) {
            return mMap.get(key);
        }

        public Set<String> keySet() {
            return mMap.keySet();
        }

        public KVP merge(KVP kvp) {
            if (kvp != null) {
                for (String key : kvp.keySet()) {
                    put(key, kvp.get(key));
                }
            }

            return this;
        }

        @Override
        @SuppressWarnings("all")
        public String toString() {
            StringBuilder builder = new StringBuilder();

            for (Map.Entry<String, Object> pair : mMap.entrySet()) {
                builder.append(sanitizeKey(pair.getKey())).append("=");
                Object value = pair.getValue();

                if (value == null) {
                    builder.append("\"(null)\"");
                } else if (value instanceof KVPDouble ||
                        value instanceof Number ||
                        value instanceof Boolean) {
                    builder.append(value);
                } else {
                    builder.append("\"" + pair.getValue() + "\"");
                }

                builder.append(" ");
            }

            return builder.toString().trim();
        }

        private String sanitizeKey(String key) {
            if (key == null) return null;

            key = key.replace(' ', '_');
            key = key.replace('.', '_');

            if (key.startsWith("$")) key = key.substring(1);

            return key;
        }

        private static class KVPDouble {
            private double value;
            private String scale;

            public KVPDouble(double value, int scale) {
                this.value = value;
                this.scale = "%." + scale + "f";
            }

            @Override
            public String toString() {
                return String.format(scale, value);
            }
        }
    }

    // =============================================================================================
    // OnSettingsChangeListener
    // =============================================================================================

    public interface OnSettingsChangeListener {
        void onSettingsChange(boolean liveTail, int logLevel);
    }

    // =============================================================================================
    // OnLogListener
    // =============================================================================================

    public interface OnLogListener {
       void onLog(LogEntry log);
    }

    // =============================================================================================
    // Exception Handler
    // =============================================================================================

    private static final class ExceptionHandler implements Thread.UncaughtExceptionHandler {

        private Thread.UncaughtExceptionHandler mOriginal;

        public ExceptionHandler() {
            mOriginal = Thread.getDefaultUncaughtExceptionHandler();
        }

        public Thread.UncaughtExceptionHandler getOriginalUncaughtExceptionHandler() {
            return mOriginal;
        }

        @Override
        public void uncaughtException(Thread thread, Throwable throwable) {
            if (throwable != null) {
                if (Looper.getMainLooper().getThread() == thread) {
                    f("AndroidRuntime", throwable.getMessage(), throwable);
                } else {
                    e("AndroidRuntime", throwable.getMessage(), throwable);
                }
            }

            if (mOriginal != null) {
                l(DEBUG, TAG, "Forwarding uncaught exception.", new KVP().put("handler", mOriginal.toString()));
                mOriginal.uncaughtException(thread, throwable);
            }
        }
    }

    // =============================================================================================
    // Cache
    // =============================================================================================

    private static class Cache<K, V> {
        private final Object mLock = new Object();
        private final Map<K, V> mInternal;

        public Cache(final int size) {
            mInternal = new LinkedHashMap<K, V>(size * 4/3, 0.75f, true) {
                @Override
                protected boolean removeEldestEntry(Map.Entry<K, V> eldest) {
                    return size() > size;
                }
            };
        }

        public boolean containsKey(K key) {
            return mInternal.containsKey(key);
        }

        public V put(K key, V value) {
            synchronized (mLock) {
                return mInternal.put(key, value);
            }
        }

        public V get(K key) {
            synchronized (mLock) {
                return mInternal.get(key);
            }
        }

        public void clear() {
            synchronized (mLock) {
                mInternal.clear();
            }
        }

        public int size() {
            synchronized (mLock) {
                return mInternal.size();
            }
        }
    }

    // =============================================================================================
    // Callbacks
    // =============================================================================================

    @TargetApi(14)
    private static final class ActivityLifecycleCallbacks implements Application.ActivityLifecycleCallbacks {

        @Override
        public void onActivityCreated(Activity activity, Bundle bundle) {
            KVP kvp = new KVP(bundle);

            if (activity.getIntent() != null && activity.getIntent().getExtras() != null) {
                kvp.merge(new KVP(activity.getIntent().getExtras()));
            }

            i(getTag(activity), "onActivityCreated.", kvp);
        }

        @Override
        public void onActivityStarted(Activity activity) {
            i(getTag(activity), "onActivityStarted.");
        }

        @Override
        public void onActivityResumed(Activity activity) {
            i(getTag(activity), "onActivityResumed.");
        }

        @Override
        public void onActivityPaused(Activity activity) {
            i(getTag(activity), "onActivityPaused.");
        }

        @Override
        public void onActivityStopped(Activity activity) {
            i(getTag(activity), "onActivityStopped.");
        }

        @Override
        public void onActivitySaveInstanceState(Activity activity, Bundle bundle) {
            KVP kvp = new KVP(bundle);

            i(getTag(activity), "onActivitySaveInstanceState.", kvp);
        }

        @Override
        public void onActivityDestroyed(Activity activity) {
            i(getTag(activity), "onActivityDestroyed.");
        }
    }

    @TargetApi(14)
    private static android.content.ComponentCallbacks2 getComponentCallbacks() {
        if (Build.VERSION.SDK_INT < 14) return null;

        return new android.content.ComponentCallbacks2() {
            private static final String TAG = "ComponentCallbacks";

            @Override
            public void onConfigurationChanged(Configuration configuration) {
                if (getLogLifecycle()) {
                    KVP kvp = new KVP()
                            .put("orientation", configuration.orientation)
                            .put("keyboardHidden", configuration.keyboardHidden);

                    i(TAG, "onConfigurationChanged.", kvp);
                }
            }

            @Override
            public void onLowMemory() {
                if (getLogLifecycle()) {
                    w(TAG, "onLowMemory.");
                }

                l(INFO, TAG, "Clearing Ouralabs cache.", new KVP().put("size", sCache.size()));
                sCache.clear();
            }

            @Override
            public void onTrimMemory(int level) {
                if (getLogLifecycle()) {
                    i(TAG, "onTrimMemory.", new KVP().put("level", level));
                }
            }
        };
    }

    @TargetApi(18)
    private static final class OnProvideAssistDataListener implements Application.OnProvideAssistDataListener {

        @Override
        public void onProvideAssistData(Activity activity, Bundle bundle) {
            KVP kvp = new KVP(bundle);

            i(getTag(activity), "onProvideAssistData.", kvp);
        }
    }
}
