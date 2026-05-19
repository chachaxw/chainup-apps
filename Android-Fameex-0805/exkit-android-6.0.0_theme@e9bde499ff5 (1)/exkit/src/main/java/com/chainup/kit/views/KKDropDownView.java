
package com.chainup.kit.views;

import android.app.Activity;
import android.content.Context;
import android.content.res.TypedArray;
import android.util.AttributeSet;
import android.util.TypedValue;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.CheckBox;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.annotation.IntDef;
import androidx.core.content.ContextCompat;

import com.bumptech.glide.Glide;
import com.bumptech.glide.load.resource.bitmap.CircleCrop;
import com.bumptech.glide.request.RequestOptions;
import com.chainup.kit.utils.ColorUtil;
import com.example.chainup_kit.R;
import com.qmuiteam.qmui.layout.QMUIRelativeLayout;
import com.qmuiteam.qmui.util.QMUILangHelper;
import com.scwang.smart.refresh.layout.util.SmartUtil;
import com.warkiz.widget.SizeUtils;

import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;


public class KKDropDownView extends QMUIRelativeLayout {

    private ImageView mImgLeft;
    private ImageView mImgRight;
    private ImageView mImgRightDownicon;
    private TextView mTvTitle;
    private TextView mTvLeft;
    private TextView mTvRight;
    private TextView mTvRightHint;
    private TextView mTvLeftHint;

    private String tvLeftHint;
    private String tvLeftText;
    private String tvRightHint;
    private String tvRightText;
    private int IvLeftIcon;
    private int IvRightIcon;

    private int leftTextColor;

    private boolean isShowLeftIcon;
    private boolean isShowLeftText;
    private boolean isShowRightIcon;
    private boolean isShowRightText;
    private boolean isShowRightDownIcon;
    private String mShowTitle;

    public KKDropDownView(Context context) {
        this(context, null);
    }

    public KKDropDownView(Context context, AttributeSet attrs) {
        this(context, attrs, R.attr.QMUICommonListItemViewStyle);
    }

    public KKDropDownView(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init(context, attrs, defStyleAttr);
    }

    protected void init(Context context, AttributeSet attrs, int defStyleAttr) {
//        setChangeAlphaWhenDisable(true);
//        setChangeAlphaWhenPress(true);
//        setAlpha(.1f);tv_title
        setBackgroundColor(ContextCompat.getColor(context,R.color.transparent));

        LayoutInflater.from(context).inflate(R.layout.kk_drop_down_item, this, true);

        TypedArray array = context.obtainStyledAttributes(attrs, R.styleable.KKDropDownView, defStyleAttr, 0);
        tvLeftHint = array.getString(R.styleable.KKDropDownView_kk_item_left_hint);
        tvLeftText = array.getString(R.styleable.KKDropDownView_kk_item_left_text);
        tvRightHint = array.getString(R.styleable.KKDropDownView_kk_item_right_hint);
        tvRightText = array.getString(R.styleable.KKDropDownView_kk_item_right_text);
        leftTextColor = array.getColor(R.styleable.KKDropDownView_kk_item_left_textColor ,ContextCompat.getColor(context,R.color.text_color_1));
        IvLeftIcon = array.getResourceId(R.styleable.KKDropDownView_kk_item_left_icon, 0);
        IvRightIcon = array.getResourceId(R.styleable.KKDropDownView_kk_item_right_icon, 0);
        isShowLeftIcon = array.getBoolean(R.styleable.KKDropDownView_kk_item_show_left_icon, false);
        isShowLeftText = array.getBoolean(R.styleable.KKDropDownView_kk_item_show_left_text, false);
        isShowRightIcon = array.getBoolean(R.styleable.KKDropDownView_kk_item_show_right_icon, false);
        isShowRightText = array.getBoolean(R.styleable.KKDropDownView_kk_item_show_right_text, false);
        isShowRightDownIcon = array.getBoolean(R.styleable.KKDropDownView_kk_item_show_right_down_icon, true);
        mShowTitle = array.getString(R.styleable.KKDropDownView_kk_item_title);
        array.recycle();

        mImgLeft = findViewById(R.id.img_left);
        mImgRight = findViewById(R.id.img_right);
        mImgRightDownicon = findViewById(R.id.img_right_downicon);
        mTvLeft = findViewById(R.id.tv_left);
        mTvRight = findViewById(R.id.tv_right);
        mTvRightHint = findViewById(R.id.tv_right_hint);
        mTvLeftHint = findViewById(R.id.tv_left_hint);
        mTvTitle = findViewById(R.id.tv_title);

        mTvTitle.setVisibility(QMUILangHelper.isNullOrEmpty(mShowTitle)?VISIBLE:GONE);
        mImgLeft.setVisibility(isShowLeftIcon?VISIBLE:GONE);
        mImgRight.setVisibility(isShowRightIcon?VISIBLE:GONE);
        mImgRightDownicon.setVisibility(isShowRightDownIcon?VISIBLE:GONE);
        mTvLeft.setVisibility(isShowLeftText?VISIBLE:GONE);
        mTvLeftHint.setVisibility(isShowLeftText?VISIBLE:GONE);
        mTvRight.setVisibility(isShowRightText?VISIBLE:GONE);
        mTvRightHint.setVisibility(isShowRightText?VISIBLE:GONE);


        mTvTitle.setText(mShowTitle);
        mTvLeft.setTextColor(leftTextColor);
        mTvLeftHint.setTextColor(leftTextColor);

        mTvLeftHint.setHint(tvLeftHint);
        mTvLeft.setText(tvLeftText);
        mTvRightHint.setHint(tvRightHint);
        mTvRight.setText(tvRightText);

        setTitle(mShowTitle);
        setLeftTvTitle(tvLeftText);
        setRightTvTitle(tvRightText);


    }


    public void setImageLeftIcon(String resLink) {
        loadCoinImage(getContext(),resLink,mImgLeft);
    }


    public void setImageRightStatus(String resLink,Boolean isShow) {
        if(isShow){
            mImgRight.setVisibility(View.VISIBLE);
            loadCoinImage(getContext(),resLink,mImgRight);
        } else {
            mImgRight.setVisibility(View.GONE);
        }
    }

    public void setImageRightIcon(String resLink) {
        loadCoinImage(getContext(),resLink,mImgRight);
    }

    public void setImageRightIcon(int resLink) {
        mImgRight.setImageResource(resLink);
        mImgRight.setVisibility(View.VISIBLE);
    }

    public void setTitle(CharSequence text) {
        mTvTitle.setText(text);
        if (QMUILangHelper.isNullOrEmpty(text)) {
            mTvTitle.setVisibility(View.GONE);
        } else {
            mTvTitle.setVisibility(View.VISIBLE);
        }
    }

    public void setLeftTvTitle(CharSequence text) {
        mTvLeft.setText(text);
        if (QMUILangHelper.isNullOrEmpty(text)) {
            mTvLeft.setVisibility(View.GONE);
            mTvLeftHint.setVisibility(View.VISIBLE);
        } else {
            mTvLeft.setVisibility(View.VISIBLE);
            mTvLeftHint.setVisibility(View.GONE);
        }
    }

    public void setRightTvTitle(CharSequence text) {
        mTvRight.setText(text);
        if (QMUILangHelper.isNullOrEmpty(text)) {
            mTvRight.setVisibility(View.GONE);
            mTvRightHint.setVisibility(View.VISIBLE);
        } else {
            mTvRight.setVisibility(View.VISIBLE);
            mTvRightHint.setVisibility(View.GONE);
        }
    }

    public void setRightTvColor(int color,int textSize) {
        mTvRight.setTextColor(ColorUtil.INSTANCE.getColor(getContext(),color));
        mTvRight.setTextSize(TypedValue.COMPLEX_UNIT_PX, SmartUtil.dp2px(textSize));
    }

    public void setLeftTvColor(int color,int textSize) {
        mTvLeft.setTextColor(ColorUtil.INSTANCE.getColor(getContext(),color));
        mTvLeft.setTextSize(TypedValue.COMPLEX_UNIT_PX, SmartUtil.dp2px(textSize));
    }

    public  void loadCoinImage(Context context, String url, ImageView imageView) {
        RequestOptions requestOptions = new RequestOptions();
        requestOptions.error(R.drawable.assets_defaulticon).placeholder(R.drawable.assets_defaulticon).bitmapTransform(new CircleCrop());
        Glide.with(context).load(url).apply(requestOptions).into(imageView);
    }

    public CharSequence getRightTvTitle() {
        return mTvRight.getText();
    }
}
