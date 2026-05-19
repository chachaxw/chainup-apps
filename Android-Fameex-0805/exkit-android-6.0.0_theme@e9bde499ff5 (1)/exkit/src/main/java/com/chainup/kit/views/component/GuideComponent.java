package com.chainup.kit.views.component;

import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.binioter.guideview.Component;
import com.chainup.kit.utils.GuideUtil;
import com.chainup.kit.utils.PublicSizeUtil;
import com.example.chainup_kit.R;

public class GuideComponent implements Component {
    private int anchor = Component.ANCHOR_BOTTOM;
    private int fitPosition = Component.FIT_START;
    private int xOffset;
    private int yOffset;
    private String message;
    private int arrowOffset;
    private GuideUtil.GuideListener guideListener;

    public void setGuideListener(GuideUtil.GuideListener guideListener) {
        this.guideListener = guideListener;
    }

    public GuideComponent(String message) {
        this.message = message;
    }

    public GuideComponent(String message,int anchor) {
        this.message = message;
        this.anchor = anchor;
    }

    public GuideComponent(String message,int anchor,int fitPosition) {
        this.message = message;
        this.anchor = anchor;
        this.fitPosition = fitPosition;
    }

    public GuideComponent(String message,int anchor,int fitPosition,int xOffset,int yOffset,int arrowOffset) {
        this.message = message;
        this.anchor = anchor;
        this.fitPosition = fitPosition;
        this.xOffset = xOffset;
        this.yOffset = yOffset;
        this.arrowOffset = arrowOffset;
    }


    @Override
    public View getView(LayoutInflater inflater) {

        LinearLayout ll = (LinearLayout) inflater.inflate(R.layout.public_guide_layout, null);
        TextView txTips = ll.findViewById(R.id.tv_title);
        LinearLayout llContent = ll.findViewById(R.id.content);
        TextView tsee = ll.findViewById(R.id.tv_see);
        View arrowView = ll.findViewById(R.id.view_arrow);
        View arrowViewBottom = ll.findViewById(R.id.view_arrow_bottom);
        txTips.setText(message);
        tsee.setText(inflater.getContext().getString(R.string.kk_guide_3));


        ll.post(new Runnable() {
            @Override
            public void run() {
                int rightX = ll.getMeasuredWidth() - arrowView.getMeasuredWidth() - arrowOffset;
                if(fitPosition == Component.FIT_END){
                    arrowOffset = rightX;
                }
                ViewGroup.MarginLayoutParams layoutParams = (ViewGroup.MarginLayoutParams)arrowView.getLayoutParams();
                layoutParams.leftMargin = arrowOffset==0 ? ll.getMeasuredWidth()/2 - PublicSizeUtil.dp2px(inflater.getContext(),16.0f)/2 : arrowOffset;
                arrowView.setLayoutParams(layoutParams);
                arrowViewBottom.setLayoutParams(layoutParams);


            }
        });

        ViewGroup.MarginLayoutParams layoutParams = (ViewGroup.MarginLayoutParams)llContent.getLayoutParams();

        if(anchor == Component.ANCHOR_BOTTOM){
            layoutParams.topMargin = -PublicSizeUtil.dp2px(inflater.getContext(),6.0f);
            layoutParams.bottomMargin = 0;
            arrowView.setVisibility(View.VISIBLE);
            arrowViewBottom.setVisibility(View.GONE);
        }else if(anchor == Component.ANCHOR_TOP){
            layoutParams.topMargin = 0;
            layoutParams.bottomMargin = -PublicSizeUtil.dp2px(inflater.getContext(),6.0f);
            arrowViewBottom.setVisibility(View.VISIBLE);
            arrowView.setVisibility(View.INVISIBLE);
        }else {
            layoutParams.topMargin = -PublicSizeUtil.dp2px(inflater.getContext(),6.0f);
            layoutParams.bottomMargin = 0;
            arrowView.setVisibility(View.VISIBLE);
            arrowViewBottom.setVisibility(View.GONE);
        }
        llContent.setLayoutParams(layoutParams);

        ll.setOnClickListener(view -> {
            if (guideListener != null) {
                guideListener.onDismiss();
            }
        });
        return ll;
    }

    @Override
    public int getAnchor() {
        return anchor;
    }

    @Override
    public int getFitPosition() {
        return fitPosition;
    }

    @Override
    public int getXOffset() {
        return xOffset;
    }

    @Override
    public int getYOffset() {
        return yOffset;
    }


    public static class GuideComponentBuilder {
        private int anchor = Component.ANCHOR_BOTTOM;
        private int fitPosition = Component.FIT_START;
        private int xOffset;
        private int yOffset;
        private String message;
        private int arrowOffset;
        public GuideComponentBuilder(){

        }
        public GuideComponentBuilder setAnchor(int anchor){
            this.anchor = anchor;
            return this;
        }
        public GuideComponentBuilder setFitPosition(int fitPosition){
            this.fitPosition = fitPosition;
            return this;
        }
        public GuideComponentBuilder setXOffset(int offset){
            this.xOffset = offset;
            return this;
        }
        public GuideComponentBuilder setYOffset(int offset){
            this.yOffset = offset;
            return this;
        }
        public GuideComponentBuilder setMessage(String msg){
            this.message = msg;
            return this;
        }

        public GuideComponentBuilder setArrowOffset(int offset){
            this.arrowOffset = offset;
            return this;
        }

        public GuideComponent build(){
            GuideComponent component = new GuideComponent(message,anchor,fitPosition,xOffset,yOffset,arrowOffset);

            return component;
        }
    }

}
