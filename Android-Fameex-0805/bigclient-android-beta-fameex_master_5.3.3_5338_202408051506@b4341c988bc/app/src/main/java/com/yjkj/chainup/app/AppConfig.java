package com.yjkj.chainup.app;

import com.yjkj.chainup.R;
import com.yjkj.chainup.util.ContextUtil;

/**
 * @Description:
 * @Author: wanghao
 * @CreateDate: 2019-08-26 19:47
 * @UpdateUser: wanghao
 * @UpdateDate 2023-08-26 19:47
 *@ UpdateRemark: Update Description
 */
public class AppConfig {

    public static final int cacheSize = 10 * 1024 * 1024;
    public static final long read_time = 10 * 1000;
    public static final long write_time = 10 * 1000;
    public static final long connect_time = 10 * 1000;

    public static final String app_name = ContextUtil.getString(R.string.app_name);
    public static String app_ver = "1.0.0";
    public static String down_cl = "guanfang";


    public static final boolean needUmengStatistics = false;//False in the development phase, changed to true after launch
    public static final boolean IS_DEBUG = true;//Log switch, true to turn on logs, but when going online, it needs to be turned off and changed to false
    public static final boolean isOpenLeakCanary = false; //LeakCanary Memory leak detection tool, which needs to be changed to false when it is online
    public static final boolean isBuglyOpen = true; //Bugly log statistics tool, needs to be changed to true when going online
    public static final boolean isFirebaseAnalyticsOpen = true; //Google firebas tool, needs to be changed to true when going online


    public static final String default_host = "https://www.baidu.com/";

    public static final String ossPath = "https://bigcustom-oss.oss-cn-hongkong.aliyuncs.com/";
    public static final String ossPath2 = "https://chainup.oss-accelerate.aliyuncs.com/";
    public static final String ossPath3 = "https://chainup-test.s3.ap-northeast-1.amazonaws.com/";

    public static final String quickTradeBanxaSuccessfulUrl = "https://banxa.com/blog";
    public static final String quickTradeBanxaFailedUrl = "https://banxa.com/blog";
    public static final String quickTradeBanxaUrlKey = "banxa.com/blog";

}
