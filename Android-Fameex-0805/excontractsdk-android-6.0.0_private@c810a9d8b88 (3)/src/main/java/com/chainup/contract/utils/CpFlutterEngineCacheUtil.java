package com.chainup.contract.utils;

import android.content.Context;
import android.util.Log;
import android.view.ContextThemeWrapper;

import androidx.core.content.ContextCompat;

import com.blankj.utilcode.util.GsonUtils;
import com.chainup.contract.R;
import com.chainup.contract.app.CpMyApp;
import com.chainup.kit.utils.SystemUtils;
import com.yjkj.chainup.manager.CpLanguageUtil;

import java.util.HashMap;

import io.flutter.BuildConfig;
import io.flutter.embedding.android.FlutterView;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.engine.FlutterEngineCache;
import io.flutter.embedding.engine.dart.DartExecutor;
import io.flutter.embedding.engine.plugins.FlutterPlugin;

public class CpFlutterEngineCacheUtil {
    private final static String TAG = CpFlutterEngineCacheUtil.class.getSimpleName();
    public final static String bibi_kline_engine_id = "bibi_kline_engine";
    public final static String contract_kline_engine_id = "contract_kline_engine";
    public final static String contract_kline_page_engine_id = "contract_kline_page_engine";

    public static String FLUTTER_KLINE = "/kline";
    public static String FLUTTER_KLINE_DETAIL = "/klineDetail";

    public static void addEngine(Context context,String engineId,String initRoute) {
        Log.d(TAG,"Contract Flutter Engine "+engineId+" ready finish.");
        FlutterEngine flutterEngine = new FlutterEngine(context);
        // Configure an initial route.
        flutterEngine.getNavigationChannel().setInitialRoute(initRoute+"?"+withPublicParamsStr(context));
        Log.d(TAG," route para: "+withPublicParamsStr(context));
        flutterEngine.getPlugins().add(new CpExFlutterPlugin());
        // Start executing Dart code to pre-warm the FlutterEngine.
        flutterEngine.getDartExecutor().executeDartEntrypoint(
                DartExecutor.DartEntrypoint.createDefault()
        );
        // Cache the FlutterEngine to be used by FlutterActivity or FlutterFragment.
        FlutterEngineCache
                .getInstance()
                .put(engineId, flutterEngine);
    }

    public static void removeAllEngine(){
        FlutterEngine engine = FlutterEngineCache.getInstance().get(contract_kline_page_engine_id);
        FlutterEngine engine2 = FlutterEngineCache.getInstance().get(contract_kline_engine_id);
        FlutterEngine engine3 = FlutterEngineCache.getInstance().get(bibi_kline_engine_id);
        if(engine!=null) engine.destroy();
        if(engine2!=null) engine2.destroy();
        if(engine3!=null) engine3.destroy();
        FlutterEngineCache.getInstance().clear();
        Log.d(TAG,"Contract Flutter Engine removeAllEngine finish.");
    }

    public static void removeEngine(String engineId){
        if(FlutterEngineCache.getInstance().contains(engineId)){
            FlutterEngine engine = FlutterEngineCache.getInstance().get(engineId);
            if(engine!=null) engine.destroy();
            FlutterEngineCache.getInstance().remove(engineId);
        }
    }

    private static String withPublicParamsStr(Context context){
        boolean isNight = CpClLogicContractSetting.getThemeMode(context) == CpClLogicContractSetting.THEME_MODE_NIGHT;
        int colorSelect = CpColorUtil.getColorType(context);
        String lan = CpLanguageUtil.getSelectLanguage();
        if("".equals(lan)){
            lan = SystemUtils.getSystemLocaleLanguage();
        }
        HashMap<String,Object> map = new HashMap<>();
        map.put("exToken",CpClLogicContractSetting.getToken());
        map.put("lan", lan);
        map.put("theme",isNight?"dark":"light");
        map.put("riseFallTrend", colorSelect);
        map.put("isDebug", BuildConfig.DEBUG ? "1" : "0");
        map.put("domain","");
        map.put("needSubWs",false);
        String guideFlag = CpPreferenceManager.getInstance(CpMyApp.Companion.instance()).getSharedString(CpPreferenceManager.CONTRACT_KLINE_GUIDE_FLAG1,"0");
        map.put("klineGuideFlag",guideFlag);
        map.put("main1",String.format("#%06X", (0xFFFFFF & ContextCompat.getColor(context, R.color.main_1))));
        map.put("main2",String.format("#%06X", (0xFFFFFF & ContextCompat.getColor(context, R.color.main_2))));
        map.put("main3",String.format("#%06X", (0xFFFFFF & ContextCompat.getColor(context, R.color.main_3))));
        map.put("main4",String.format("#%06X", (0xFFFFFF & ContextCompat.getColor(context, R.color.main_4))));
        map.put("text4",String.format("#%06X", (0xFFFFFF & ContextCompat.getColor(context, R.color.text_4))));

        return GsonUtils.getGson().toJson(map);
    }


    public static FlutterView getFlutterKlineView(Context mContext) {
        FlutterView flutterView = new FlutterView(mContext);
        FlutterEngine engine = getEngine(mContext,contract_kline_engine_id);
        if(engine==null) engine = new FlutterEngine(mContext);
        flutterView.attachToFlutterEngine(engine);
        flutterView.setId(R.id.cp_sm_kline);
        return flutterView;
    }


    public static FlutterView getFlutterKlineViewBibi(Context mContext) {
        FlutterView flutterView = new FlutterView(mContext);
        FlutterEngine engine = getEngine(mContext,bibi_kline_engine_id);
        if(engine==null) engine = new FlutterEngine(mContext);
        flutterView.attachToFlutterEngine(engine);
        flutterView.setId(R.id.cp_sm_kline);
        return flutterView;
    }

    public static CpExFlutterPlugin getPlugin(Context context,String engineId){
        FlutterEngine engine = getEngine(context,engineId);
        if(engine!=null){
            FlutterPlugin plugin = engine.getPlugins().get(CpExFlutterPlugin.class);
            return (CpExFlutterPlugin) plugin;
        }
        return null;
    }

    public static CpExFlutterPlugin getPlugin(Context context){
        return getPlugin(context,contract_kline_page_engine_id);
    }

    public static FlutterEngine getEngine(Context context, String engineId){
        FlutterEngine engine = FlutterEngineCache.getInstance().get(engineId);
        if(engine == null) {
            String initRoute;
            if(contract_kline_engine_id.equals(engineId)){
                initRoute = FLUTTER_KLINE;
            }else if(bibi_kline_engine_id.equals(engineId)){
                initRoute = FLUTTER_KLINE;
            }else{
                initRoute = FLUTTER_KLINE_DETAIL;
            }
            addEngine(context,engineId,initRoute);
        }
        engine = FlutterEngineCache.getInstance().get(engineId);
        return engine;
    }

    public static String getEngineId(Context context,String engineId){
        getEngine(context,engineId);
        return engineId;
    }
    public static FlutterEngine getEngine(Context context){
        return getEngine(context,contract_kline_page_engine_id);
    }
}
