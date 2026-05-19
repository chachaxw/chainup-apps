package com.chainup.contract.ui.fragment;

import android.content.DialogInterface;
import android.graphics.Typeface;
import android.graphics.drawable.ColorDrawable;
import android.os.Build;
import android.os.Bundle;
import android.os.Handler;
import android.text.Editable;
import android.text.TextWatcher;
import android.view.Gravity;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;
import android.widget.EditText;
import android.widget.LinearLayout;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.DialogFragment;
import androidx.fragment.app.Fragment;
import androidx.fragment.app.FragmentManager;
import androidx.viewpager.widget.ViewPager;

import com.chainup.contract.R;
import com.chainup.contract.adapter.CpPageAdapter;
import com.chainup.contract.base.CpNBaseDialogFragment;
import com.chainup.contract.eventbus.CpEventBusUtil;
import com.chainup.contract.eventbus.CpMessageEvent;
import com.chainup.contract.eventbus.CpNLiveDataUtil;
import com.chainup.contract.utils.CpClLogicContractSetting;
import com.chainup.contract.utils.CpDisplayUtils;
import com.chainup.contract.utils.CpJsonUtils;
import com.chainup.contract.utils.ChainUpLogUtil;
import com.chainup.contract.utils.CpSizeUtils;
import com.chainup.contract.utils.CpSoftKeyboardUtil;
import com.chainup.contract.utils.CpWsLinkUtils;
import com.chainup.contract.ws.CpWsContractAgentManager;
import com.chainup.talkingdata.AppAnalyticsExt;
import com.flyco.tablayout.SlidingTabLayout;
import com.flyco.tablayout.listener.OnTabSelectListener;
import com.yjkj.chainup.bean.kline.CpWsLinkBean;
import com.yjkj.chainup.manager.CpLanguageUtil;

import org.jetbrains.annotations.NotNull;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.HashMap;

/**
 *Contract Currency Search Dialog Box
 */
public class CpContractCoinSearchDialog extends CpNBaseDialogFragment implements CpWsContractAgentManager.WsResultCallback {

    private static final String TAG = "ContractCoinSearchDialog";
    public static final String focusViewName = "focusViewName";
    public static final String contractList = "contractList";
    private String focusViewNameValue = "";
    private EditText etSearch;
    private TextView tv_overview_text35;
    private JSONArray mContractList;
    private String contractListJson;
    private ArrayList<String> showTitles = new ArrayList<String>();
    private ArrayList<Fragment> fragments = new ArrayList<Fragment>();

    //Determine whether it is a dialog that disappears after selecting a currency pair
    private boolean dismissTypeBySelectFlag = false;
    private TextWatcher searchTextWatcher = new TextWatcher() {
        @Override
        public void beforeTextChanged(CharSequence s, int start, int count, int after) {
        }

        @Override
        public void onTextChanged(CharSequence s, int start, int before, int count) {
        }

        @Override
        public void afterTextChanged(Editable s) {
            String content = "";
            if (null != s) {
                content = s.toString();
            }
            ChainUpLogUtil.d(TAG, "afterTextChanged==content is " + content);
            CpMessageEvent msgEvent = new CpMessageEvent(CpMessageEvent.coinSearchType);
            msgEvent.setMsg_content(content);
            CpNLiveDataUtil.postValue(msgEvent);
        }
    };

    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setStyle(DialogFragment.STYLE_NORMAL, R.style.leftContractCoinSearchDialogStyle);
    }
    @Override
    public void onStart() {
        super.onStart();
        Window window = this.getDialog().getWindow();
        //Remove the default padding from dialog
        window.getDecorView().setPadding(0, 0, 0, 0);
        WindowManager.LayoutParams lp = window.getAttributes();
        lp.width = CpSizeUtils.dp2px(280.0f);
        lp.height = WindowManager.LayoutParams.MATCH_PARENT;
        lp.gravity = Gravity.LEFT;
        //Animating dialog
        lp.windowAnimations = R.style.leftin_rightout_DialogFg_animstyle_buff;
        window.setAttributes(lp);
        window.setBackgroundDrawable(new ColorDrawable());
        getDialog().setCancelable(true);
        getDialog().setCanceledOnTouchOutside(true);


    }

    @Override
    protected int setContentView() {
        return R.layout.cp_dialog_contract_coin_search;
    }

    @Override
    protected void initView() {

        LinearLayout rootView = findViewById(R.id.root_view);
        CpDisplayUtils.requestDisplayBar(getDialog().getWindow(), new CpDisplayUtils.OnResponseDisplayBar() {
            @Override
            public void doSomeThing(int statusBar, int navigationBar) {
                rootView.setPadding(0,statusBar,0,navigationBar);
            }
        });

        initTab();
        showSearch();
        initAutoTextView();

    }

    private void initAutoTextView() {
        etSearch.setHint(CpLanguageUtil.getString(getContext(), "cp_contract_leftcoin_hint"));
        tv_overview_text35.setText(CpLanguageUtil.getString(getContext(), "cp_overview_text35"));
    }

    /*
     *Grouping to meet leverage needs
     */
    private int type;

    @Override
    protected void loadData() {
        CpWsContractAgentManager.Companion.getInstance().addWsCallback(this);
        Bundle bundle = getArguments();
        if (null != bundle) {
            focusViewNameValue = bundle.getString(focusViewName);
            contractListJson = bundle.getString(contractList);
            try {
                mContractList = new JSONArray(contractListJson);
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }
    }


    private void showSearch() {
        etSearch = findViewById(R.id.et_search);
        tv_overview_text35 = findViewById(R.id.tv_overview_text35);
        etSearch.addTextChangedListener(searchTextWatcher);
        etSearch.setOnFocusChangeListener(new View.OnFocusChangeListener() {
            @Override
            public void onFocusChange(View v, boolean hasFocus) {
                if (hasFocus) {
                    AppAnalyticsExt.Companion.getInstance().clickAction(AppAnalyticsExt.Companion.getAPP_FUTURES_SEARCH_CLICK());
                }
            }
        });
    }


    private void initTab() {
        showTitles.clear();
        fragments.clear();
        boolean isHasU = false; //Forward contract
        boolean isHasB = false;//Currency standard
        boolean isHasH = false;//Mixed contract
        boolean isHasM = false;//Simulated contract
        String[] arrays = new String[mContractList.length()];
        if (mContractList.length() == 0) {
            return;
        }
        for (int i = 0; i < mContractList.length(); i++) {
            try {
                ChainUpLogUtil.e("合约币对", mContractList.getJSONObject(i).get("symbol").toString());
                // (反向：0，1：正向 , 2 : 混合 , 3 : 模拟)
                ChainUpLogUtil.e("合约方向", mContractList.getJSONObject(i).get("contractSide").toString());
                int contractSide = mContractList.getJSONObject(i).getInt("contractSide");
                String contractType = mContractList.getJSONObject(i).getString("contractType");
                int classification = mContractList.getJSONObject(i).getInt("classification");
                //Classification 1, USDT contract 2, currency standard contract 3, hybrid contract 4, simulation contract
                //1. USDT contract 2. Currency standard contract 3. Hybrid contract 4. Simulation contract
                if (classification == 1 ) {
                    isHasU = true;
                } else if (classification == 2 ) {
                    isHasB = true;
                } else if (classification == 4) {
                    isHasM = true;
                } else {
                    isHasH = true;
                }
//                if (contractSide == 1 && contractType.equals("E")) {
//                    isHasU = true;
//                } else if (contractSide == 0 && contractType.equals("E")) {
//                    isHasB = true;
//                } else if (contractType.equals("S")) {
//                    isHasM = true;
//                } else {
//                    isHasH = true;
//                }
                JSONObject obj = (JSONObject) mContractList.get(i);
//                String currentSymbolBuff = (obj.getString("contractType") + "_" + obj.getString("symbol").replace("-", "")).toLowerCase();
                String currentSymbolBuff =obj.getString("subSymbol");
                arrays[i] = currentSymbolBuff;
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }
        HashMap<String, Object> rmap = new HashMap<>();
        rmap.put("bind", true);
        rmap.put("symbols", CpJsonUtils.gson.toJson(arrays));
        CpWsContractAgentManager.Companion.getInstance().sendMessage(rmap, this);

        //Optional
        showTitles.add(CpLanguageUtil.getString(requireActivity(),"cp_contract_customZone"));
        fragments.add(new CpContractLikeFragment());

        //USDT
        if (isHasU) {
            showTitles.add(CpLanguageUtil.getString(getContext(), "cp_contract_data_text13"));
            fragments.add(CpCoinSearchItemFragment.newInstance(1, contractListJson));
        }
        //Currency standard
        if (isHasB) {
            showTitles.add(CpLanguageUtil.getString(getContext(), "cp_contract_data_text10"));
            fragments.add(CpCoinSearchItemFragment.newInstance(0, contractListJson));
        }
        //Mixing
        if (isHasH) {
            showTitles.add(CpLanguageUtil.getString(getContext(), "cp_contract_data_text12"));
            fragments.add(CpCoinSearchItemFragment.newInstance(2, contractListJson));
        }
        //Simulation
        if (isHasM) {
            showTitles.add(CpLanguageUtil.getString(getContext(), "cp_contract_data_text11"));
            fragments.add(CpCoinSearchItemFragment.newInstance(3, contractListJson));
        }


        ViewPager vp_market_aa = findViewById(R.id.vp_market_aa);
        CpPageAdapter marketPageAdapter = new CpPageAdapter(getChildFragmentManager(), showTitles, fragments);
        vp_market_aa.setAdapter(marketPageAdapter);
        vp_market_aa.setOffscreenPageLimit(fragments.size());

        SlidingTabLayout tl_market_aa = findViewById(R.id.tl_market_aa);

        String[] showTitlesArray = new String[showTitles.size()];
        for (int j = 0; j < showTitles.size(); j++) {
            showTitlesArray[j] = showTitles.get(j);
        }
        tl_market_aa.setViewPager(vp_market_aa, showTitlesArray);
        setSTFontTypeface(tl_market_aa);

        //Logic:
        //For the first time, the default selection is AutoSelect. If there is no AutoSelect, enter the first tab on the right of AutoSelect
        //Next time, follow the tab selected by the user
        int ctTabPosition = CpClLogicContractSetting.getContractTabPositionByLeftCoinSearchDialog(requireContext());
        if(-1==ctTabPosition){
            //No self selection
            boolean isNoHasCollect = CpClLogicContractSetting.getContractJsonCollectListArr(requireContext()).isEmpty();
            if(isNoHasCollect) tl_market_aa.setCurrentTab(1);
        }else{
            tl_market_aa.setCurrentTab(ctTabPosition);
        }


        tl_market_aa.setOnTabSelectListener(new OnTabSelectListener() {
            @Override
            public void onTabSelect(int position) {
                ChainUpLogUtil.e(TAG,"点击的position"+position);
                CpClLogicContractSetting.setContractTabPositionByLeftCoinSearchDialog(requireContext(),position);
                if (showTitles.get(position).equals(CpLanguageUtil.getString(getContext(), "cl_market_text7"))){
                    CpEventBusUtil.post(new CpMessageEvent(CpMessageEvent.sl_contract_receive_coupon));
                }
            }

            @Override
            public void onTabReselect(int position) {

            }
        });
        vp_market_aa.addOnPageChangeListener(new ViewPager.OnPageChangeListener() {
            @Override
            public void onPageScrolled(int position, float positionOffset, int positionOffsetPixels) {

            }

            @Override
            public void onPageSelected(int position) {
                CpClLogicContractSetting.setContractTabPositionByLeftCoinSearchDialog(requireContext(),position);
            }

            @Override
            public void onPageScrollStateChanged(int state) {

            }
        });
    }

    //Set the title font for sliderTabLayout
    private void setSTFontTypeface(SlidingTabLayout tl_market_aa) {
        int tabCount = tl_market_aa.getTabCount();
        for (int i = 0; i < tabCount; i++) {
            TextView cTv = tl_market_aa.getTitleView(i);
            Typeface typeface;
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                typeface = getResources().getFont(R.font.dinpro_medium);
            }else{
                typeface = Typeface.DEFAULT;
            }

            cTv.setTypeface(typeface);
        }

    }

    final Handler handler = new Handler();

    @Override
    protected void dismissDialog() {
        if (etSearch != null) {

            etSearch.removeTextChangedListener(searchTextWatcher);
            etSearch.setText("");
        }
        CpSoftKeyboardUtil.hideSoftKeyboard(etSearch);
        super.dismissDialog();
    }

    @Override
    public void showDialog(FragmentManager manager, String tag) {
        super.showDialog(manager, tag);
    }

    @Override
    public void onCpWsMessage(@NotNull String json) {
        try {
            JSONObject jsonObject = new JSONObject(json);
            CpMessageEvent messageEvent = new CpMessageEvent(CpMessageEvent.sl_contract_sidebar_market_event);
            messageEvent.setMsg_content(jsonObject);
            CpEventBusUtil.post(messageEvent);
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        if(!dismissTypeBySelectFlag) {
            CpWsContractAgentManager.Companion.getInstance().unbind(this, true,false,false,false);
            tradeReSub();
        }
        dismissDialog();
        CpWsContractAgentManager.Companion.getInstance().removeWsCallback(this,true);

    }
    private void tradeReSub(){
        final String currentSymbol = getTag();
        final boolean isContractTrade = !"SlContractFragment".equals(currentSymbol);
        if(isContractTrade) {
            CpWsLinkBean tickerBean = CpWsLinkUtils.tickerFor24HLinkBean(currentSymbol, true);
            CpWsContractAgentManager.Companion.getInstance().sendData(tickerBean);
        }
    }

    @Override
    public void onDismiss(@NonNull DialogInterface dialog) {
        if(!dismissTypeBySelectFlag) CpSoftKeyboardUtil.hideSoftKeyboard(getActivity());
        super.onDismiss(dialog);
    }

    public void onItemClick(JSONObject ticker) {
        CpWsContractAgentManager.Companion.getInstance().unbind(this, true,false,false,false);
        clickItemHandler(ticker);
    }
    //Click to process
    public void clickItemHandler(JSONObject ticker){
        final String currentSymbol = getTag();
        dismissTypeBySelectFlag = true;
        if(ticker.optString("subSymbol").equals(currentSymbol)){
            ChainUpLogUtil.d(TAG,"repeat click symbol pair!!!");
            tradeReSub();
            dismissDialog();
            return;
        }

        CpClLogicContractSetting.setContractCurrentSelectedId(getContext(), ticker.optInt("id"));
        CpMessageEvent msgEvent = new CpMessageEvent(CpMessageEvent.sl_contract_left_coin_type);
        msgEvent.setMsg_content(ticker.optInt("id"));
        msgEvent.setMsg_content_data(focusViewNameValue);
        CpEventBusUtil.post(msgEvent);
        dismissDialog();
    }
}
