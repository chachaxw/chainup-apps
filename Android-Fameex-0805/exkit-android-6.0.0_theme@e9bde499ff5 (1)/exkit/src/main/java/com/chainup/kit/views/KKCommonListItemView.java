
package com.chainup.kit.views;

import android.content.Context;
import android.content.res.TypedArray;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.CheckBox;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import androidx.annotation.IntDef;
import androidx.core.content.ContextCompat;

import com.example.chainup_kit.R;
import com.qmuiteam.qmui.layout.QMUIRelativeLayout;
import com.qmuiteam.qmui.util.QMUILangHelper;
import com.warkiz.widget.SizeUtils;

import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;

/**
 *Through lists (personal center, settings interface, etc.)
 *Supports the following styles:
 * <ul>
 *<li>Set a line of text through {@ link # setTitle (CharSequence)}</li>
 *<li>Set a line of explanatory text through {@ link # setStatusText (CharSequence)}
 *<li>Set the type of the right view through {@ link # setAccessoryType (int)}. The optional types can be found in {@ link QMUICommonListItemAccessoryType},
 * </ul>
 */



public class KKCommonListItemView extends KKRelativeLayout implements SwitchButtonView.OnKKSwitchListener {

    private SwitchButtonView.OnKKSwitchListener listener;

    public SwitchButtonView.OnKKSwitchListener getListener() {
        return listener;
    }

    public void setSwitchListener(SwitchButtonView.OnKKSwitchListener listener) {
        this.listener = listener;
    }



    /**
     *Nothing displayed on the right side
     */
    public final static int ACCESSORY_TYPE_NONE = 0;
    /**
     *Show an arrow on the right
     */
    public final static int ACCESSORY_TYPE_CHEVRON = 1;
    /**
     *A switch is displayed on the right side
     */
    public final static int ACCESSORY_TYPE_SWITCH = 2;
    /**
     *Customize the View displayed on the right side
     */
    public final static int ACCESSORY_TYPE_CUSTOM = 3;

    private final static int TIP_SHOW_NOTHING = 0;
    private final static int TIP_SHOW_RED_POINT = 1;
    private final static int TIP_SHOW_NEW = 2;

    /**
     *DetailText below the title text
     */
    public final static int VERTICAL = 0;
    /**
     *DetailText on the right side of the item
     */
    public final static int HORIZONTAL = 1;

    /**
     *TIP on the left
     */
    public final static int TIP_POSITION_LEFT = 0;
    /**
     *TIP on the right
     */
    public final static int TIP_POSITION_RIGHT = 1;

    @Override
    public void onSwitch(boolean b) {
        if(listener!=null){
            listener.onSwitch(b);
        }
    }

    @IntDef({ACCESSORY_TYPE_NONE, ACCESSORY_TYPE_CHEVRON, ACCESSORY_TYPE_SWITCH, ACCESSORY_TYPE_CUSTOM})
    @Retention(RetentionPolicy.SOURCE)
    public @interface QMUICommonListItemAccessoryType {
    }

    /**
     *The type of View on the right side of the Item
     */
    @QMUICommonListItemAccessoryType
    private int mAccessoryType;

    protected ImageView mImageView;
    private SwitchButtonView ivSwitchOn;
    protected TextView mTextView;
    protected TextView mDetailTextView;
    protected CheckBox mSwitch;
    private ImageView mRedDot;
    private ImageView mRightView;


    public KKCommonListItemView(Context context) {
        this(context, null);
    }

    public KKCommonListItemView(Context context, AttributeSet attrs) {
        this(context, attrs, R.attr.QMUICommonListItemViewStyle);
    }

    public KKCommonListItemView(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init(context, attrs, defStyleAttr);
    }

    protected void init(Context context, AttributeSet attrs, int defStyleAttr) {
        LayoutInflater.from(context).inflate(R.layout.kk_common_list_item, this, true);
        TypedArray array = context.obtainStyledAttributes(attrs, R.styleable.KKCommonListItemView, defStyleAttr, 0);
        @QMUICommonListItemAccessoryType int accessoryType = array.getInt(R.styleable.KKCommonListItemView_kk_accessory_type, ACCESSORY_TYPE_NONE);
        final String tvItemTitle = array.getString(R.styleable.KKCommonListItemView_kk_item_title_text);
        final String tvItemValue = array.getString(R.styleable.KKCommonListItemView_kk_item_value_text);
        final int IvItemTitle = array.getResourceId(R.styleable.KKCommonListItemView_kk_item_title_icon,0);
        final boolean isShowRedPoint = array.getBoolean(R.styleable.KKCommonListItemView_kk_item_show_red,false);
        final boolean isShowLine = array.getBoolean(R.styleable.KKCommonListItemView_kk_item_show_line,false);
        array.recycle();

        mImageView = findViewById(R.id.group_list_item_imageView);
        mTextView = findViewById(R.id.group_list_item_textView);
        mRedDot = findViewById(R.id.group_list_item_tips_dot);
        mRightView = findViewById(R.id.group_list_item_right_imageView);
        mDetailTextView = findViewById(R.id.group_list_item_detailTextView);
        ivSwitchOn = findViewById(R.id.iv_switch_on);
        ivSwitchOn.setListener(this);
        setAccessoryType(accessoryType);
        setTitle(tvItemTitle);
        setStatusText(tvItemValue);
        setImageDrawable(IvItemTitle);
        showRedDot(isShowRedPoint);
        updateBottomDivider(0, 0, isShowLine? SizeUtils.dp2px(context,0.5f):0, ContextCompat.getColor(context,R.color.line_color));
        this.setBackgroundResource(R.drawable.kk_setting_item_color);
    }

    public void setImageDrawable(int res) {
        if (res == 0) {
            mImageView.setVisibility(View.GONE);
        } else {
            mImageView.setImageResource(res);
            mImageView.setVisibility(View.VISIBLE);
        }
    }
    public CharSequence getText() {
        return mTextView.getText();
    }

    public void setTitle(CharSequence text) {
        mTextView.setText(text);
        if (QMUILangHelper.isNullOrEmpty(text)) {
            mTextView.setVisibility(View.GONE);
        } else {
            mTextView.setVisibility(View.VISIBLE);
        }
    }

    /**
     *Switch whether to display small red dots
     *
     *Does @param isShow display small red dots
     */
    public void showRedDot(boolean isShow) {
        if(isShow){
            mRedDot.setVisibility(View.VISIBLE);
        }else{
            mRedDot.setVisibility(View.GONE);
        }
    }

    public void showRedDot(boolean isShow, int res) {
        if(isShow){
            mRedDot.setVisibility(View.VISIBLE);
            if(res!=0){
                mRedDot.setImageResource(res);
            }
        }else{
            mRedDot.setVisibility(View.GONE);
        }
    }


    public CharSequence getDetailText() {
        return mDetailTextView.getText();
    }


    public void setStatusText(CharSequence text) {
        mDetailTextView.setText(text);
        if (QMUILangHelper.isNullOrEmpty(text)) {
            mDetailTextView.setVisibility(View.GONE);
        } else {
            mDetailTextView.setVisibility(View.VISIBLE);
        }
    }

    public int getAccessoryType() {
        return mAccessoryType;
    }

    /**
     *Set the type of View on the right.
     *
     *@param type see {@ link QMUICommonListItemAccessoryType}
     */
    public void setAccessoryType(@QMUICommonListItemAccessoryType int type) {
        mAccessoryType = type;

        switch (type) {
            //Arrow to the right
            case ACCESSORY_TYPE_CHEVRON: {
                mRightView.setVisibility(View.VISIBLE);
            }
            break;
            //Switch switch
            case ACCESSORY_TYPE_SWITCH: {
                ivSwitchOn.setVisibility(View.VISIBLE);
            }
            break;
            //Custom View
            case ACCESSORY_TYPE_CUSTOM:
                break;
            //Clear all accessoryViews
            case ACCESSORY_TYPE_NONE:
                break;
        }
    }


    public TextView getTextView() {
        return mTextView;
    }

    public TextView getDetailTextView() {
        return mDetailTextView;
    }

    public CheckBox getSwitch() {
        return mSwitch;
    }
    public void isSwitchClick(boolean isClick) {
        ivSwitchOn.setSwitchStatus(isClick);
    }
}
