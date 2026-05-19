package com.yjkj.chainup.freestaking;

import android.content.Context;
import android.content.res.TypedArray;
import android.util.AttributeSet;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.appcompat.widget.Toolbar;

import com.yjkj.chainup.R;

/**
 *A custom ToolBar
 */
public class CustomToolBar extends Toolbar {

    private ImageView mImageViewLeft;
    private ImageView mImageViewRight;
    private TextView mTextView;
    private RightImageClickListener rightImageClickListener;
    private RightTextClickListener rightTextClickListener;
    private LeftImageClickListener leftImageClickListener;
    private View view;
    private int rightImageId;
    private int leftImageId;
    private String rightTwoText;
    private String titleText;
    private boolean isShowRightImage;
    private boolean isShowRightText;

    public CustomToolBar(Context context) {
        this(context, null);
    }

    public CustomToolBar(Context context, AttributeSet attrs) {
        this(context, attrs, 0);

    }

    public CustomToolBar(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        TypedArray array = context.obtainStyledAttributes(attrs, R.styleable.CustomToolBar, defStyleAttr, 0);
        rightImageId = array.getResourceId(R.styleable.CustomToolBar_rightImage, R.drawable.personal_mail);
        leftImageId = array.getResourceId(R.styleable.CustomToolBar_returnImage, R.drawable.ic_return);
        rightTwoText = array.getString(R.styleable.CustomToolBar_rightTwoText);
        isShowRightImage = array.getBoolean(R.styleable.CustomToolBar_isShowRightImage, false);
        isShowRightText = array.getBoolean(R.styleable.CustomToolBar_isShowRightText, false);
        array.recycle();
        initView();

    }

    private void initView() {
        view = LayoutInflater.from(getContext()).inflate(R.layout.toolbar_layout, null);
        mImageViewRight = (ImageView) view.findViewById(R.id.iv_right);
        mImageViewLeft = (ImageView) view.findViewById(R.id.iv_return);
        mTextView = (TextView) view.findViewById(R.id.tv_right);
        LayoutParams lp = new LayoutParams(LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT, Gravity.CENTER_HORIZONTAL);
        addView(view, lp);
        mImageViewRight.setOnClickListener(v -> rightImageClickListener.onRightImageClick());
        mTextView.setOnClickListener(v -> rightTextClickListener.onRightTextClick());
        mImageViewLeft.setOnClickListener(v -> leftImageClickListener.onLeftImageClick());
    }

    /**
     *Right icon callback interface
     */
    public interface RightImageClickListener {
        void onRightImageClick();
    }

    /**
     *Click on the callback icon on the right side
     *
     * @param listener
     */
    public void setOnRightImageClickListener(RightImageClickListener listener) {
        this.rightImageClickListener = listener;
    }

    //Right text callback interface
    public interface RightTextClickListener {
        void onRightTextClick();
    }

    /**
     *Right text click callback
     *
     * @param listener
     */
    public void setOnRightTextClickListener(RightTextClickListener listener) {
        this.rightTextClickListener = listener;
    }

    //Right icon callback interface
    public interface LeftImageClickListener {
        void onLeftImageClick();
    }

    /**
     *Click on the callback button on the left side on the right
     *
     * @param listener
     */
    public void setOnLeftImageClickListener(LeftImageClickListener listener) {
        this.leftImageClickListener = listener;
    }

    /**
     *Set Right Text
     *
     * @param rightText
     */
    public void setRightText(String rightText) {
        this.rightTwoText=rightText;
        mTextView.setText(rightText);

    }

    /**
     *Set whether the text on the right is displayed
     * @param isShowRightText
     */
    public void isShowRightText(boolean isShowRightText) {
        this.isShowRightText=isShowRightText;
        if (isShowRightText) {
            mTextView.setVisibility(VISIBLE);
        }else{
            mTextView.setVisibility(GONE);
        }

    }

    /**
     *Set Right Icon
     *
     * @param rightImageId
     */
    public void setRightImage(int rightImageId) {
        this.rightImageId=rightImageId;
        mImageViewRight.setImageResource(rightImageId);
        if(rightImageId==0){
            mImageViewRight.setVisibility(GONE);
        }
    }

    /**
     *Set whether the icon on the right is displayed
     * @param isShowRightImage
     */
    public void isShowRightImage(boolean isShowRightImage) {
        this.isShowRightImage=isShowRightImage;
        if (isShowRightImage) {
            mImageViewRight.setVisibility(VISIBLE);
        }else{
            mImageViewRight.setVisibility(GONE);
        }

    }

    /**
     *Set left icon
     *
     * @param leftImageId
     */
    public void setLeftImage(int leftImageId) {
        this.leftImageId=leftImageId;
        mImageViewLeft.setImageResource(leftImageId);

    }
}
