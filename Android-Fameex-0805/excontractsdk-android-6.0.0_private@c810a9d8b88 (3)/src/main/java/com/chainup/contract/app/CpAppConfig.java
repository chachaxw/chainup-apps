package com.chainup.contract.app;


import com.chainup.contract.R;
import com.chainup.contract.utils.CpContextUtil;

/**
 * @Description:
 * @Author: wanghao
 * @CreateDate: 2019-08-26 19:47
 * @UpdateUser: wanghao
 * @UpdateDate: 2019-08-26 19:47
 * @UpdateRemark: updateDescription
 */
public class CpAppConfig {

    public static final int cacheSize = 10 * 1024 * 1024;
    public static final long read_time = 15 * 10000;
    public static final long write_time = 15 * 10000;
    public static final long connect_time = 15 * 10000;

    public static final String app_name = CpContextUtil.getString(R.string.app_name);
    public static String app_ver = "1.0.0";
    public static String down_cl = "guanfang";


    public static final boolean IS_DEBUG = true;//Log switch. If true, log will be turned on. If online, it needs to be turned off and changed to false


    public static final String default_host = "https://www.baidu.com/";

    public static final String adl_uri_zh = "https://futuresdoc.gitbook.io/help-center/v/cn/yong-xu-he-yue/untitled-1/zi-dong-jian-cang-adl";
    public static final String adl_uri_en = "https://futuresdoc.gitbook.io/help-center/perpetual/overview/adl";

}
