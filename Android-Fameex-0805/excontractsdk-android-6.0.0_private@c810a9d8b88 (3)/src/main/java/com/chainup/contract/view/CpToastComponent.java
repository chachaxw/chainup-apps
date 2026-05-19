package com.chainup.contract.view;

import android.view.LayoutInflater;
import android.view.View;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;
import com.binioter.guideview.Component;
import com.chainup.contract.R;
import com.chainup.contract.utils.CpGuideUtil;
import com.yjkj.chainup.manager.CpLanguageUtil;

/**
 * Created by binIoter on 16/6/17.
 */
public class CpToastComponent implements Component {
    private String message = "";
    private String isLeft = "";
    private CpGuideUtil.GuideListener guideListener;

    public CpGuideUtil.GuideListener getGuideListener() {
        return guideListener;
    }

    public void setGuideListener(CpGuideUtil.GuideListener guideListener) {
        this.guideListener = guideListener;
    }

    public CpToastComponent(String message) {
        this.message = message;
    }

    @Override
    public View getView(LayoutInflater inflater) {

        RelativeLayout rl = (RelativeLayout) inflater.inflate(R.layout.cp_guide_layout_toast, null);
        TextView txTips = rl.findViewById(R.id.tv_title);
        TextView tsee = rl.findViewById(R.id.tv_see);
        txTips.setText(message);
        tsee.setText(CpLanguageUtil.getString(inflater.getContext(),"guide_3"));
        rl.setOnClickListener(view -> {
            if (guideListener != null) {
                guideListener.onDismiss();
            }
        });
        return rl;
    }

    @Override
    public int getAnchor() {
        return Component.ANCHOR_BOTTOM;
    }

    @Override
    public int getFitPosition() {
        return Component.FIT_END;
    }

    @Override
    public int getXOffset() {
        return 0;
    }

    @Override
    public int getYOffset() {
        return 0;
    }
}
