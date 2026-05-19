package cn.ljuns.logcollector;

import android.app.Application;
import androidx.annotation.NonNull;

import com.elvishew.xlog.LogConfiguration;
import com.elvishew.xlog.LogLevel;
import com.elvishew.xlog.XLog;
import com.elvishew.xlog.interceptor.BlacklistTagsFilterInterceptor;
import com.elvishew.xlog.printer.AndroidPrinter;
import com.elvishew.xlog.printer.Printer;
import com.elvishew.xlog.printer.file.FilePrinter;
import com.elvishew.xlog.printer.file.backup.NeverBackupStrategy;
import com.elvishew.xlog.printer.file.clean.FileLastModifiedCleanStrategy;
import com.elvishew.xlog.printer.file.naming.DateFileNameGenerator;

import java.io.File;
import java.util.HashMap;
import java.util.Map;

import cn.ljuns.logcollector.util.FileUtils;
import cn.ljuns.logcollector.util.LevelUtils;
import cn.ljuns.logcollector.util.TypeUtils;

/**
 *Log collection
 */
public class LogNetCollector {

    private static final String UTF8 = "UTF-8";
    private static volatile LogNetCollector sLogCollector;
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
    private String printLog;

    public String getPrintLog() {
        return printLog;
    }

    public void setPrintLog(String printLog) {
        this.printLog = printLog;
    }

    private LogNetCollector(Application context) {
        this.mContext = context;
        mTagWithLevel = new HashMap<>();
    }

    public static LogNetCollector getInstance(Application context) {
        if (sLogCollector == null) {
            synchronized (LogNetCollector.class) {
                if (sLogCollector == null) {
                    sLogCollector = new LogNetCollector(context);
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
    public LogNetCollector setCacheFile(@NonNull File file) {
        this.mCacheFile = file;
        return this;
    }

    public LogNetCollector setCacheFile(@NonNull String path) {
        this.mCacheFile = new File(path);
        return this;
    }

    /**
     *Do you want to clear the previous cache
     *
     * @param cleanCache cleanCache
     * @return LogCollector
     */
    public LogNetCollector setCleanCache(boolean cleanCache) {
        this.mCleanCache = cleanCache;
        return this;
    }

    /**
     *Set the TAGs that need to be filtered
     *
     * @param tags tags
     * @return LogCollector
     */
    public LogNetCollector setTag(@NonNull String... tags) {
        this.mTags = tags;
        return this;
    }

    /**
     *Set the types that need to be filtered
     *
     * @param levels levels
     * @return LogCollector
     */
    public LogNetCollector setLevel(@LevelUtils.Level String... levels) {
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
    public LogNetCollector setTagWithLevel(@NonNull String tag, @LevelUtils.Level String level) {
        this.mTagWithLevel.put(tag, level);
        return this;
    }

    /**
     *Set the strings that need to be filtered, with case sensitivity by default
     *
     * @param str str
     * @return LogCollector
     */
    public LogNetCollector setString(@NonNull String str) {
        return setString(str, false);
    }

    /**
     *Set the strings that need to be filtered
     *
     * @param str        str
     * @param ignoreCase ignoreCase
     * @return LogCollector
     */
    public LogNetCollector setString(@NonNull String str, boolean ignoreCase) {
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
    public LogNetCollector setType(@TypeUtils.Type String type) {
        this.mFilterType = type;
        return this;
    }

    public static final int BUFFER_SIZE = 1024 * 400; //400k

    /**
     *Start
     */
    public synchronized void start(String time) {
        LogConfiguration config = new LogConfiguration.Builder()
                .logLevel(BuildConfig.DEBUG ? LogLevel.ALL             //Specify the log level below which logs will not be printed, defaulting to LogLevel.ALL
                        : LogLevel.ERROR)
                .tag("ChainUP")                                         //Specify TAG, default to 'X-LOG'
                .st(2)                                                 //Allow printing of call stack information with a depth of 2, disabled by default
                .addInterceptor(new BlacklistTagsFilterInterceptor(    //Add blacklist TAG filter
                        "blacklist1", "blacklist2", "blacklist3"))
                .build();
        String fileLog = FileUtils.getCacheFileDir(mContext, "log");
        com.elvishew.xlog.printer.Printer androidPrinter = new AndroidPrinter();             //A printer that prints logs through android.util.Log
        Printer filePrinter = new FilePrinter                   //Printers for printing logs to files
                .Builder(fileLog)                              //Specify the path to save the log file
                .fileNameGenerator(new DateFileNameGenerator())        //Specify the log file name generator, which defaults to ChangelessFileNameGenerator ("log")
                .backupStrategy(new NeverBackupStrategy())              //Specify the log file backup strategy, default to FileSizeBackupStrategy (1024 * 1024)
                .cleanStrategy(new FileLastModifiedCleanStrategy(MAX_TIME))     //Specify the log file cleaning policy, which defaults to NeverCleanStrategy()
                .build();

        XLog.init(config, androidPrinter, filePrinter);

    }

    private static final long MAX_TIME = 1000 * 60 * 60 * 24 * 3; // two days

    public void print(String message) {
        XLog.e(message);
    }


}
