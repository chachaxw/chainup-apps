package com.yjkj.chainup.wedegit;

import android.content.Context;
import android.util.AttributeSet;
import android.util.Log;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.LinearLayout;
import android.widget.TextView;
import androidx.annotation.Nullable;
import androidx.core.content.ContextCompat;
import com.airbnb.lottie.LottieAnimationView;
import com.airbnb.lottie.LottieComposition;
import com.airbnb.lottie.LottieOnCompositionLoadedListener;
import com.airbnb.lottie.LottieProperty;
import com.airbnb.lottie.model.KeyPath;
import com.chainup.kit.utils.PublicSizeUtil;
import com.yjkj.chainup.R;
import com.yjkj.chainup.util.LogUtil;
import java.util.ArrayList;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * @Description:
 * @Author: wanghao
 * @CreateDate: 2019-10-25 11:33
 * @UpdateUser: wanghao
 * @UpdateDate 2023-10-25 11:33
 *@ UpdateRemark: Update Description
 */
public class NTabNavView extends LinearLayout {

    private static final String TAG = "NTabNavView";

    private Context context;

    public NTabNavView(Context context) {
        super(context);
        this.context = context;
    }

    public NTabNavView(Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
        this.context = context;
    }

    public NTabNavView(Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        this.context = context;
    }

    public NTabNavView(Context context, AttributeSet attrs, int defStyleAttr, int defStyleRes) {
        super(context, attrs, defStyleAttr, defStyleRes);
        this.context = context;
    }

    private ArrayList<View> views;
    private ArrayList<Integer> res;
    private int cPosition = 0;
    public void setData(ArrayList<Integer> imgIDs, ArrayList<String> titles, OnClickListener l, int contractIndex, boolean isShow) {
        if (null == imgIDs || null == titles || imgIDs.size() != titles.size()) {
            return;
        }
        int count = imgIDs.size();
        if (count <= 0)
            return;
        this.removeAllViews();
        cPosition = 0;
        LayoutInflater inflater = LayoutInflater.from(getContext());
        views = new ArrayList<>();
        res = new ArrayList<>();
        this.post(new Runnable() {
            @Override
            public void run() {
                int itemW = PublicSizeUtil.getScreenWidth(context) / count;
                int itemH = PublicSizeUtil.dp2px(context,60.0f);

                LogUtil.d(TAG, "setData==itemW is " + itemW + ",itemH is " + itemH);
                for (int i = 0; i < count; i++) {
                    View view = inflater.inflate(R.layout.item_main_home_tab, null);

                    View item_view_ll = view.findViewById(R.id.item_tab_view_ll);

                    LayoutParams params = new LayoutParams(itemW, itemH);
                    params.gravity = Gravity.CENTER;
                    item_view_ll.setLayoutParams(params);

                    LottieAnimationView animationView = item_view_ll.findViewById(R.id.imageview);
                    TextView textview = item_view_ll.findViewById(R.id.textview);

                    if (i == contractIndex) {
                        View toast = view.findViewById(R.id.toast);
                        toast.setVisibility(isShow ? VISIBLE : INVISIBLE);
                    }
                    int assetIndex = imgIDs.get(i);
                    switch (assetIndex){
                        case R.mipmap.tabbar_home:
                            res.add(R.raw.tab_home);
                            break;
                        case R.mipmap.tabbar_quotation:
                            res.add(R.raw.tab_market);
                            break;
                        case R.mipmap.tabbar_trading:
                            res.add(R.raw.tab_trade);
                            break;
                        case R.mipmap.tabbar_contract:
                            res.add(R.raw.tab_contract);
                            break;
                        case R.mipmap.tabbar_assest:
                            res.add(R.raw.tab_asset);
                            break;
                    }
                    setBottonTab(animationView, assetIndex);
                    textview.setText(titles.get(i));
                    textview.setTag(assetIndex);
                    item_view_ll.setTag(i);
                    item_view_ll.setOnClickListener(l);
                    views.add(view);
                    NTabNavView.this.addView(view);
                    animationView.addLottieOnCompositionLoadedListener(new IndexLottieOnCompositionLoadedListener(animationView));
                    if(0 == i) {
                        animationView.cancelAnimation();
                        animationView.setAnimation(res.get(i));
                        animationView.setSpeed(1.8f);
                        animationView.playAnimation();
                        textview.setSelected(true);
                    }
                }
            }
        });
    }

    private void setBottonTab(LottieAnimationView animationView, int id) {
        if (id == R.mipmap.tabbar_home) {
            animationView.setImageResource(id);
        }
        if (id == R.mipmap.tabbar_quotation) {
            animationView.setImageResource(id);
        }
        if (id == R.mipmap.tabbar_trading) {
            animationView.setImageResource(id);
        }
//        if (id == R.drawable.bg_otc_tab) {
//            animationView.setImageResource(id);
//        }
        if (id == R.mipmap.tabbar_contract) {
            animationView.setImageResource(id);
        }
        if (id == R.mipmap.tabbar_assest) {
            animationView.setImageResource(id);
        }
    }

    public void showCurTabView(int curIndex) {
        if (null == views || views.size() <= 0) return;
        if(curIndex==cPosition) {
            View view = views.get(curIndex);
            LottieAnimationView animView = view.findViewById(R.id.imageview);
            animView.cancelAnimation();
            animView.setAnimation(res.get(curIndex));
            animView.setSpeed(1.8f);
            animView.playAnimation();
            return;
        }
        for (int i = 0; i < views.size(); i++) {
            View view = views.get(i);
            LottieAnimationView animView = view.findViewById(R.id.imageview);
            View textview = view.findViewById(R.id.textview);
            animView.setSelected(i == curIndex);
            textview.setSelected(i == curIndex);
            int assetIndex = (int)textview.getTag();
            if(i == curIndex){
                cPosition = curIndex;
                animView.cancelAnimation();
                animView.setAnimation(res.get(curIndex));
                animView.setSpeed(1.8f);
                animView.playAnimation();
            } else {
                animView.cancelAnimation();
                setBottonTab(animView, assetIndex);
            }
        }
    }

    class IndexLottieOnCompositionLoadedListener implements LottieOnCompositionLoadedListener{
        LottieAnimationView lview;
        IndexLottieOnCompositionLoadedListener(LottieAnimationView view){
            this.lview = view;
        }
        public void setView(LottieAnimationView view){
            lview = view;
        }
        public LottieAnimationView getView(){
            return lview;
        }

        @Override
        public void onCompositionLoaded(LottieComposition composition) {
            List<KeyPath> list = getView().resolveKeyPath(new KeyPath("**"));
            for (KeyPath path : list) {
                String pathString = path.keysToString();
                Log.d("LottieKeyPath", path.keysToString());
                //Home, market, trade ["tabbar_home_home" contour, group 2, fill 1]
                String regStr = "^\\[“[a-zA-Z\\_]+”轮廓, 组 2, 填充 1\\]$";
                String contractRegStr2 = "^\\[“[a-zA-Z\\_]+”轮廓, 组 1, 填充 1\\]$";
                String contractRegStr3 = "^\\[“[a-zA-Z\\_]+”轮廓, 组 2, 填充 1\\]$";

                if(pathString.contains("tabbar_assest_hover")){
                    regStr = "^\\[“[a-zA-Z\\_]+”轮廓, 组 3, 填充 1\\]$";
                }else if(pathString.contains("tabbar_contract_hover")){
                    regStr = "^\\[“[a-zA-Z\\_]+”轮廓, 组 7, 填充 1\\]$";
                    Pattern contractPattern2 = Pattern.compile(contractRegStr2);
                    Matcher contractMatcher2 = contractPattern2.matcher(pathString);
                    Pattern contractPattern3 = Pattern.compile(contractRegStr3);
                    Matcher contractMatcher3 = contractPattern3.matcher(pathString);
                    if (contractMatcher2.matches()||contractMatcher3.matches()) {
                        getView().addValueCallback(path, LottieProperty.COLOR, lottieFrameInfo -> ContextCompat.getColor(context,R.color.main_color));
                        continue;
                    }
                }
                Pattern pattern = Pattern.compile(regStr);
                Matcher matcher = pattern.matcher(pathString);
                if (matcher.matches()) {
                    getView().addValueCallback(path, LottieProperty.COLOR, lottieFrameInfo -> ContextCompat.getColor(context,R.color.main_color));
                }
            }
        }
    }
}
