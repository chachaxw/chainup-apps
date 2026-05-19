package cn.ljuns.logcollector;

import android.app.Application;
import androidx.annotation.NonNull;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.OutputStreamWriter;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.Executors;

import cn.ljuns.logcollector.util.CloseUtils;
import cn.ljuns.logcollector.util.FileUtils;
import cn.ljuns.logcollector.util.LevelUtils;
import cn.ljuns.logcollector.util.TypeUtils;

/**
 *Log collection
 */
public class LogCollector implements CrashHandlerListener {

    private static final String UTF8 = "UTF-8";
    private static volatile LogCollector sLogCollector;
    private Application mContext;
    /**
     *Cache Files
     */
    private File mCacheFile;
    /**
     *TAG that needs to be filtered
     */
    private String[] mTags;
    /**
     *List that needs to be filtered
     */
    private String[] mLevels;
    /**
     *String to be filtered
     */
    private String mFilterStr;
    private String mFilterType;
    private Map<String, String> mTagWithLevel;
    /**
     *Filter case or not
     */
    private boolean mIgnoreCase = false;
    /**
     *Do you want to clear cache log files
     */
    private boolean mCleanCache = false;
    private LogRunnable mLogRunnable;

    private LogCollector(Application context) {
        this.mContext = context;
        mTagWithLevel = new HashMap<>();
    }

    public static LogCollector getInstance(Application context) {
        if (sLogCollector == null) {
            synchronized (LogCollector.class) {
                if (sLogCollector == null) {
                    sLogCollector = new LogCollector(context);
                }
            }
        }
        return sLogCollector;
    }

    /**
     *Set cache file
     *
     * @param file file
     * @return LogCollector
     */
    public LogCollector setCacheFile(@NonNull File file) {
        this.mCacheFile = file;
        return this;
    }

    public LogCollector setCacheFile(@NonNull String path) {
        this.mCacheFile = new File(path);
        return this;
    }

    /**
     *Do you want to clear the previous cache
     *
     * @param cleanCache cleanCache
     * @return LogCollector
     */
    public LogCollector setCleanCache(boolean cleanCache) {
        this.mCleanCache = cleanCache;
        return this;
    }

    /**
     *Set the TAGs that need to be filtered
     *
     * @param tags tags
     * @return LogCollector
     */
    public LogCollector setTag(@NonNull String... tags) {
        this.mTags = tags;
        return this;
    }

    /**
     *Set the types that need to be filtered
     *
     * @param levels levels
     * @return LogCollector
     */
    public LogCollector setLevel(@LevelUtils.Level String... levels) {
        this.mLevels = levels;
        return this;
    }

    /**
     *Set the tag: level that needs to be filtered
     *
     * @param tag   tag
     * @param level level
     * @return LogCollector
     */
    public LogCollector setTagWithLevel(@NonNull String tag, @LevelUtils.Level String level) {
        this.mTagWithLevel.put(tag, level);
        return this;
    }

    /**
     *Set the strings that need to be filtered, with case sensitivity by default
     *
     * @param str str
     * @return LogCollector
     */
    public LogCollector setString(@NonNull String str) {
        return setString(str, false);
    }

    /**
     *Set the strings that need to be filtered
     *
     * @param str        str
     * @param ignoreCase ignoreCase
     * @return LogCollector
     */
    public LogCollector setString(@NonNull String str, boolean ignoreCase) {
        this.mFilterStr = str;
        this.mIgnoreCase = ignoreCase;
        return this;
    }

    /**
     *Set the types of logs that need to be filtered
     *
     * @param type type
     * @return LogCollector
     */
    public LogCollector setType(@TypeUtils.Type String type) {
        this.mFilterType = type;
        return this;
    }

    /**
     *Set the string and log type to be filtered, with case sensitivity by default
     *
     * @param str  str
     * @param type type
     * @return LogCollector
     */
    public LogCollector setStringWithType(@NonNull String str, @TypeUtils.Type String type) {
        return setStringWithType(str, type, false);
    }

    /**
     *Set the strings and log types that need to be filtered
     *
     * @param str        str
     * @param type       type
     * @param ignoreCase ignoreCase
     * @return LogCollector
     */
    public LogCollector setStringWithType(@NonNull String str, @TypeUtils.Type String type, boolean ignoreCase) {
        this.mFilterStr = str;
        this.mFilterType = type;
        this.mIgnoreCase = ignoreCase;
        return this;
    }

    /**
     *Start
     */
    public synchronized void start() {
        mCacheFile = FileUtils.createLogCacheFile(mContext, mCacheFile, mCleanCache);
        CrashHandler.getInstance().init(mContext, mCleanCache).crash(this);

        mLogRunnable = new LogRunnable();
        Executors.newSingleThreadExecutor().execute(mLogRunnable);
    }

    @Override
    public void crashHandler() {
        mLogRunnable.isCrash = true;
    }

    /**
     *Filter strings and log categories
     *
     * @param str str
     * @return boolean
     */
    private boolean filterStringType(String str) {
        if (mFilterType != null && mFilterStr != null) {
            String result = str;
            String filter = mFilterStr;
            if (mIgnoreCase) {
                result = result.toLowerCase();
                filter = filter.toLowerCase();
            }
            return !result.contains(filter)
                    && !str.contains(mFilterType + "/");
        } else if (mFilterStr != null) {
            String result = str;
            String filter = mFilterStr;
            if (mIgnoreCase) {
                result = result.toLowerCase();
                filter = filter.toLowerCase();
            }
            return !result.contains(filter);
        } else if (mFilterType != null) {
            return !str.contains(mFilterType + "/");
        }
        return false;
    }

    /**
     *Clear cache logs
     */
    private void createCleanCommand() throws IOException {
        List<String> commandLine = new ArrayList<>();
        commandLine.add("logcat");
        commandLine.add("-c");
        Runtime.getRuntime().exec(commandLine.toArray(new String[commandLine.size()]));
    }

    /**
     *Get logs
     *
     * @param commandLine commandLine
     */
    private void createGetCommand(List<String> commandLine) {
        commandLine.add("logcat");
        commandLine.add("-b");
        commandLine.add("main");
        commandLine.add("-v");
        commandLine.add("time");

        //Filter TAG
        if (mTags != null && mTags.length > 0) {
            commandLine.add("-s");
            commandLine.addAll(Arrays.asList(mTags));
        }

        //Filter Category
        if (mLevels != null && mLevels.length > 0) {
            commandLine.add("sh");
            commandLine.add("-c");
            for (String level : mLevels) {
                commandLine.add("*:" + level);
            }
        }

        //Filter tag: level
        if (!mTagWithLevel.isEmpty()) {
            for (Map.Entry<String, String> entry : mTagWithLevel.entrySet()) {
                commandLine.add(entry.getKey() + ":" + entry.getValue());
            }

            /**
             *When there is no tag or level, if you want tag: level to take effect, you need to add *: S,
             *Plus *: S means only make tag: level effective
             */
            boolean addCommand = (mTags == null || mTags.length == 0) &&
                    (mLevels == null || mLevels.length == 0);
            if (addCommand) {
                commandLine.add("*:S");
            }
        }
    }

    private class LogRunnable implements Runnable {
        volatile boolean isCrash = false;

        @Override
        public void run() {
            List<String> getCommandLine = new ArrayList<>();
            createGetCommand(getCommandLine);

            BufferedReader reader = null;
            BufferedWriter writer = null;
            try {
                createCleanCommand();
                //Obtain logcat
                Process process = Runtime.getRuntime().exec(
                        getCommandLine.toArray(new String[getCommandLine.size()]));

                reader = new BufferedReader(
                        new InputStreamReader(process.getInputStream(), UTF8));
                writer = new BufferedWriter(
                        new OutputStreamWriter(new FileOutputStream(mCacheFile), UTF8));

                String str;
                while (!isCrash && ((str = reader.readLine()) != null)) {
                    createCleanCommand();
                    if (filterStringType(str)) { continue; }

                    //Write data
                    writer.write(str);
                    writer.newLine();
                    writer.flush();
                }
            } catch (IOException e) {
                e.printStackTrace();
            } finally {
                CloseUtils.close(reader);
                CloseUtils.close(writer);
            }
        }
    }
}
