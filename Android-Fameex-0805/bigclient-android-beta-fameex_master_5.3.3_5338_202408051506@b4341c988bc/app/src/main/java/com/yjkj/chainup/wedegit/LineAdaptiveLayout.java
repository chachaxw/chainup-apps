package com.yjkj.chainup.wedegit;

import android.content.Context;
import android.content.res.TypedArray;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.yjkj.chainup.R;
import com.yjkj.chainup.bean.OTCInitInfoBean;
import com.yjkj.chainup.new_version.bean.CashFlowSceneBean;
import com.yjkj.chainup.util.LineSelectOnclickListener;

import java.util.ArrayList;
import java.util.List;

/**
 * @Author lianshangljl
 * @Date 2023/11/19-2:13 PM
 * @Email buptjinlong@163.com
 *@description New Fund Flow
 */
public class LineAdaptiveLayout extends ViewGroup {
    /**
     *All labels
     */
    List<Object> lables;
    /**
     *Select Label
     */
    private List<CashFlowSceneBean.Scene> lableSelected = new ArrayList<>();
    private List<String> lableForCommissionedSelected = new ArrayList<>();
    private List<View> selectView = new ArrayList<>();
    //Custom Properties
    private int LEFT_RIGHT_SPACE; //dip
    private int ROW_SPACE;
    private boolean aLineShow = true;

    public LineAdaptiveLayout(Context context) {
        this(context, null);
    }

    public LineAdaptiveLayout(Context context, AttributeSet attrs) {
        this(context, attrs, 0);
    }

    public LineAdaptiveLayout(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        TypedArray ta = context.obtainStyledAttributes(attrs, R.styleable.LineBreakLayout);
        LEFT_RIGHT_SPACE = ta.getDimensionPixelSize(R.styleable.LineBreakLayout_leftAndRightSpace, DisplayUtils.dip2px(context, 23));
        ROW_SPACE = ta.getDimensionPixelSize(R.styleable.LineBreakLayout_rowSpace, DisplayUtils.dip2px(context, 15));
        ta.recycle(); //Recycling
        // ROW_SPACE=20   LEFT_RIGHT_SPACE=40
    }

    private boolean selectstatus = false;

    /**
     *Add labels
     *
     *@param labels label set
     *Do you want to add @param add
     *Is @param aLineShow displayed as a single line
     *Whether to reset @param isReset? If so, the first one is selected by default
     *Is @param isClickable clickable
     */
    public void setLables(ArrayList<CashFlowSceneBean.Scene> lables, boolean add, final Boolean aLineShow, boolean isReset, boolean isClickable) {
        this.aLineShow = aLineShow;
        if (this.lables == null) {
            this.lables = new ArrayList<>();
        }
        if (add) {
            this.lables.addAll(lables);
        } else {
            this.lables.clear();
            this.lables.addAll(lables);
            removeAllViews();
        }
        if (lables != null && lables.size() > 0) {
            LayoutInflater inflater = LayoutInflater.from(getContext());
            for (final CashFlowSceneBean.Scene lable : lables) {
                //Obtain label layout
                View tv = inflater.inflate(R.layout.item_new_screening_label, null);
                selectView.add(tv);
                //Place the corresponding label field here
                TextView textView = tv.findViewById(R.id.tv_parent_content);
                textView.setText(lable.getKeyText());
                //Set Selection Effect
                if (isReset) {
                    if (lables.get(0).equals(lable)) {
                        //Selected
                        selectstatus = true;
                        tv.findViewById(R.id.cut_view).setVisibility(VISIBLE);
                        tv.findViewById(R.id.ll_layout).setBackgroundResource(R.drawable.bg_new_select_style);
                        lableForCommissionedSelected.add(lable.getKeyText());
                    } else {
                        //Not selected
                        tv.findViewById(R.id.cut_view).setVisibility(GONE);
                        tv.findViewById(R.id.ll_layout).setBackgroundResource(R.drawable.bg_new_unselect_style);
                        selectstatus = false;
                    }
                } else {
                    if (lableForCommissionedSelected.contains(lable.getKeyText())) {
                        //Selected
                        tv.findViewById(R.id.cut_view).setVisibility(VISIBLE);
                        selectstatus = true;
                    } else {
                        //Not selected
                        tv.findViewById(R.id.cut_view).setVisibility(GONE);
                        tv.findViewById(R.id.ll_layout).setBackgroundResource(0);
                        selectstatus = false;
                    }
                }
                if (isClickable) {
                    tv.setEnabled(true);
                } else {
                    tv.setEnabled(false);
                }

                //After clicking on the label, reset the selected effect
                tv.setOnClickListener(new OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        if (lineSelectOnclickListener != null) {
                            lineSelectOnclickListener.selectMsgIndex(lable.getKey());
                            if (selectstatus) {
                                lineSelectOnclickListener.sendOnclickMsg();
                            }
                        }
                        if (isClickable) {
                            for (View checkBox : selectView) {
                                ImageView imageView = checkBox.findViewById(R.id.cut_view);
                                RelativeLayout frameLayout = checkBox.findViewById(R.id.ll_layout);
                                if (checkBox.equals(tv)) {
                                    if (imageView.getVisibility() == View.VISIBLE) {
                                        frameLayout.setBackgroundResource(0);
                                        imageView.setVisibility(GONE);
                                    } else {
                                        imageView.setVisibility(VISIBLE);
                                        frameLayout.setBackgroundResource(R.drawable.bg_new_select_style);
                                    }
                                } else {
                                    imageView.setVisibility(GONE);
                                    frameLayout.setBackgroundResource(0);
                                }
                            }
                            lableSelected.clear();
                            lableSelected.add(lable);
                        }

                    }
                });

                //Add labels to containers
                addView(tv);
            }
        }
    }


    /**
     *Add tags for historical delegation
     *
     *@param labels label set
     *Do you want to add @param add
     *Is @param aLineShow displayed as a single line
     *Whether to reset @param isReset? If so, the first one is selected by default
     *Is @param isClickable clickable
     */
    public void setLablesForCommissioned(ArrayList<String> lables, boolean add, final Boolean aLineShow, boolean isReset, boolean isClickable) {
        this.aLineShow = aLineShow;
        if (this.lables == null) {
            this.lables = new ArrayList<>();
        }
        if (add) {
            this.lables.addAll(lables);
        } else {
            this.lables.clear();
            this.lables.addAll(lables);
            removeAllViews();
        }
        if (lables != null && lables.size() > 0) {
            LayoutInflater inflater = LayoutInflater.from(getContext());
            for (final String lable : lables) {
                //Obtain label layout
                View tv = inflater.inflate(R.layout.item_new_screening_label, null);
                selectView.add(tv);
                //Place the corresponding label field here
                TextView textView = tv.findViewById(R.id.tv_parent_content);
                textView.setText(lable);
                //Set Selection Effect
                if (isReset) {
                    if (lables.get(0).equals(lable)) {
                        //Selected
                        selectstatus = true;
                        tv.findViewById(R.id.cut_view).setVisibility(VISIBLE);
                        tv.findViewById(R.id.ll_layout).setBackgroundResource(R.drawable.bg_new_select_style);
                        lableForCommissionedSelected.add(lable);
                    } else {
                        //Not selected
                        tv.findViewById(R.id.cut_view).setVisibility(GONE);
                        tv.findViewById(R.id.ll_layout).setBackgroundResource(R.drawable.bg_new_unselect_style);
                        selectstatus = false;
                    }
                } else {
                    if (lableForCommissionedSelected.contains(lable)) {
                        //Selected
                        tv.findViewById(R.id.ll_layout).setBackgroundResource(R.drawable.bg_new_select_style);
                        tv.findViewById(R.id.cut_view).setVisibility(VISIBLE);
                        selectstatus = true;
                    } else {
                        //Not selected
                        tv.findViewById(R.id.cut_view).setVisibility(GONE);
                        tv.findViewById(R.id.ll_layout).setBackgroundResource(R.drawable.bg_new_unselect_style);
                        selectstatus = false;
                    }
                }
                if (isClickable) {
                    tv.setEnabled(true);
                } else {
                    tv.setEnabled(false);
                }

                //After clicking on the label, reset the selected effect
                tv.setOnClickListener(new OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        if (lineSelectOnclickListener != null) {
                            lineSelectOnclickListener.selectMsgIndex(lable);
                            if (selectstatus) {
                                lineSelectOnclickListener.sendOnclickMsg();
                            }
                        }
                        if (isClickable) {
                            for (View checkBox : selectView) {
                                ImageView imageView = checkBox.findViewById(R.id.cut_view);
                                RelativeLayout frameLayout = checkBox.findViewById(R.id.ll_layout);
                                if (checkBox.equals(tv)) {
                                    if (imageView.getVisibility() == View.VISIBLE) {
                                        frameLayout.setBackgroundResource(0);
                                        imageView.setVisibility(GONE);
                                    } else {
                                        imageView.setVisibility(VISIBLE);
                                        frameLayout.setBackgroundResource(R.drawable.bg_new_select_style);
                                    }
                                } else {
                                    imageView.setVisibility(GONE);
                                    frameLayout.setBackgroundResource(0);
                                }
                            }
                            lableForCommissionedSelected.clear();
                            lableForCommissionedSelected.add(lable);
                        }

                    }
                });

                //Add labels to containers
                addView(tv);
            }
        }
    }


    /**
     *Add label for legal currency type
     *
     *@param labels label set
     *Do you want to add @param add
     *Is @param aLineShow displayed as a single line
     *Whether to reset @param isReset? If so, the first one is selected by default
     *Is @param isClickable clickable
     */
    public void setLablesForFiatType(ArrayList<OTCInitInfoBean.Paycoins> lables, boolean add, final Boolean aLineShow, boolean isReset, boolean isClickable) {
        this.aLineShow = aLineShow;
        if (this.lables == null) {
            this.lables = new ArrayList<>();
        }
        if (add) {
            this.lables.addAll(lables);
        } else {
            this.lables.clear();
            this.lables.addAll(lables);
            removeAllViews();
        }
        if (lables != null && lables.size() > 0) {
            LayoutInflater inflater = LayoutInflater.from(getContext());
            for (final OTCInitInfoBean.Paycoins lable : lables) {
                //Obtain label layout
                View tv = inflater.inflate(R.layout.item_new_screening_label, null);
                selectView.add(tv);
                //Place the corresponding label field here
                TextView textView = tv.findViewById(R.id.tv_parent_content);
                textView.setText(lable.getTitle());
                //Set Selection Effect
                if (isReset) {
                    if (lables.get(0).equals(lable)) {
                        //Selected
                        selectstatus = true;
                        tv.findViewById(R.id.cut_view).setVisibility(VISIBLE);
                        tv.findViewById(R.id.ll_layout).setBackgroundResource(R.drawable.bg_new_select_style);
                        lableForCommissionedSelected.add(lable.getTitle());
                    } else {
                        //Not selected
                        tv.findViewById(R.id.cut_view).setVisibility(GONE);
                        tv.findViewById(R.id.ll_layout).setBackgroundResource(R.drawable.bg_new_unselect_style);
                        selectstatus = false;
                    }
                } else {
                    if (lableForCommissionedSelected.contains(lable.getTitle())) {
                        //Selected
                        tv.findViewById(R.id.cut_view).setVisibility(VISIBLE);
                        selectstatus = true;
                    } else {
                        //Not selected
                        tv.findViewById(R.id.cut_view).setVisibility(GONE);
                        tv.findViewById(R.id.ll_layout).setBackgroundResource(R.drawable.bg_new_unselect_style);
                        selectstatus = false;
                    }
                }
                if (isClickable) {
                    tv.setEnabled(true);
                } else {
                    tv.setEnabled(false);
                }

                //After clicking on the label, reset the selected effect
                tv.setOnClickListener(new OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        if (lineSelectOnclickListener != null) {
                            lineSelectOnclickListener.selectMsgIndex(lable.getKey());
                            if (selectstatus) {
                                lineSelectOnclickListener.sendOnclickMsg();
                            }
                        }
                        if (isClickable) {
                            for (View checkBox : selectView) {
                                ImageView imageView = checkBox.findViewById(R.id.cut_view);
                                RelativeLayout frameLayout = checkBox.findViewById(R.id.ll_layout);
                                if (checkBox.equals(tv)) {
                                    if (imageView.getVisibility() == View.VISIBLE) {
                                        frameLayout.setBackgroundResource(0);
                                        imageView.setVisibility(GONE);
                                    } else {
                                        imageView.setVisibility(VISIBLE);
                                        frameLayout.setBackgroundResource(R.drawable.bg_new_select_style);
                                    }
                                } else {
                                    imageView.setVisibility(GONE);
                                    frameLayout.setBackgroundResource(0);
                                }
                            }
                            lableForCommissionedSelected.clear();
                            lableForCommissionedSelected.add(lable.getTitle());
                        }

                    }
                });

                //Add labels to containers
                addView(tv);
            }
        }
    }

    /**
     *Add tags for payment methods
     *
     *@param labels label set
     *Do you want to add @param add
     *Is @param aLineShow displayed as a single line
     *Whether to reset @param isReset? If so, the first one is selected by default
     *Is @param isClickable clickable
     */
    public void setLablesPaymentType(ArrayList<OTCInitInfoBean.PaymentBean> lables, boolean add, final Boolean aLineShow, boolean isReset, boolean isClickable) {
        this.aLineShow = aLineShow;
        if (this.lables == null) {
            this.lables = new ArrayList<>();
        }
        if (add) {
            this.lables.addAll(lables);
        } else {
            this.lables.clear();
            this.lables.addAll(lables);
            removeAllViews();
        }
        if (lables != null && lables.size() > 0) {
            LayoutInflater inflater = LayoutInflater.from(getContext());
            for (final OTCInitInfoBean.PaymentBean lable : lables) {
                //Obtain label layout
                View tv = inflater.inflate(R.layout.item_new_screening_label, null);
                selectView.add(tv);
                //Place the corresponding label field here
                TextView textView = tv.findViewById(R.id.tv_parent_content);
                textView.setText(lable.getTitle());
                //Set Selection Effect
                if (isReset) {
                    if (lables.get(0).equals(lable)) {
                        //Selected
                        selectstatus = true;
                        tv.findViewById(R.id.cut_view).setVisibility(VISIBLE);
                        tv.findViewById(R.id.ll_layout).setBackgroundResource(R.drawable.bg_new_select_style);
                        lableForCommissionedSelected.add(lable.getTitle());
                    } else {
                        //Not selected
                        tv.findViewById(R.id.cut_view).setVisibility(GONE);
                        tv.findViewById(R.id.ll_layout).setBackgroundResource(R.drawable.bg_new_unselect_style);
                        selectstatus = false;
                    }
                } else {
                    if (lableForCommissionedSelected.contains(lable.getTitle())) {
                        //Selected
                        tv.findViewById(R.id.cut_view).setVisibility(VISIBLE);
                        selectstatus = true;
                    } else {
                        //Not selected
                        tv.findViewById(R.id.cut_view).setVisibility(GONE);
                        tv.findViewById(R.id.ll_layout).setBackgroundResource(R.drawable.bg_new_unselect_style);

                        selectstatus = false;
                    }
                }
                if (isClickable) {
                    tv.setEnabled(true);
                } else {
                    tv.setEnabled(false);
                }

                //After clicking on the label, reset the selected effect
                tv.setOnClickListener(new OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        if (lineSelectOnclickListener != null) {
                            lineSelectOnclickListener.selectMsgIndex(lable.getKey());
                            if (selectstatus) {
                                lineSelectOnclickListener.sendOnclickMsg();
                            }
                        }
                        if (isClickable) {
                            for (View checkBox : selectView) {
                                ImageView imageView = checkBox.findViewById(R.id.cut_view);
                                RelativeLayout RelativeLayout = checkBox.findViewById(R.id.ll_layout);
                                if (checkBox.equals(tv)) {
                                    if (imageView.getVisibility() == View.VISIBLE) {
                                        RelativeLayout.setBackgroundResource(0);
                                        imageView.setVisibility(GONE);
                                    } else {
                                        imageView.setVisibility(VISIBLE);
                                        RelativeLayout.setBackgroundResource(R.drawable.bg_new_select_style);
                                    }
                                } else {
                                    imageView.setVisibility(GONE);
                                    RelativeLayout.setBackgroundResource(0);
                                }
                            }
                            lableForCommissionedSelected.clear();
                            lableForCommissionedSelected.add(lable.getTitle());
                        }

                    }
                });

                //Add labels to containers
                addView(tv);
            }
        }
    }


    /**
     *Add tags for selecting a country
     *
     *@param labels label set
     *Do you want to add @param add
     *Is @param aLineShow displayed as a single line
     *Whether to reset @param isReset? If so, the first one is selected by default
     *Is @param isClickable clickable
     */
    public void setLablesForCountry(ArrayList<OTCInitInfoBean.CountryNumberInfo> lables, boolean add, final Boolean aLineShow, boolean isReset, boolean isClickable) {
        this.aLineShow = aLineShow;
        if (this.lables == null) {
            this.lables = new ArrayList<>();
        }
        if (add) {
            this.lables.addAll(lables);
        } else {
            this.lables.clear();
            this.lables.addAll(lables);
            removeAllViews();
        }
        if (lables != null && lables.size() > 0) {
            LayoutInflater inflater = LayoutInflater.from(getContext());
            for (final OTCInitInfoBean.CountryNumberInfo lable : lables) {
                //Obtain label layout
                View tv = inflater.inflate(R.layout.item_new_screening_label, null);
                selectView.add(tv);
                //Place the corresponding label field here
                TextView textView = tv.findViewById(R.id.tv_parent_content);
                textView.setText(lable.getTitle());
                //Set Selection Effect
                if (isReset) {
                    if (lables.get(0).equals(lable)) {
                        //Selected
                        selectstatus = true;
                        tv.findViewById(R.id.cut_view).setVisibility(VISIBLE);
                        tv.findViewById(R.id.ll_layout).setBackgroundResource(R.drawable.bg_new_select_style);
                        lableForCommissionedSelected.add(lable.getTitle());
                    } else {
                        //Not selected
                        tv.findViewById(R.id.cut_view).setVisibility(GONE);
                        tv.findViewById(R.id.ll_layout).setBackgroundResource(R.drawable.bg_new_unselect_style);

                        selectstatus = false;
                    }
                } else {
                    if (lableForCommissionedSelected.contains(lable.getTitle())) {
                        //Selected
                        tv.findViewById(R.id.cut_view).setVisibility(VISIBLE);
                        selectstatus = true;
                    } else {
                        //Not selected
                        tv.findViewById(R.id.cut_view).setVisibility(GONE);
                        tv.findViewById(R.id.ll_layout).setBackgroundResource(R.drawable.bg_new_unselect_style);

                        selectstatus = false;
                    }
                }
                if (isClickable) {
                    tv.setEnabled(true);
                } else {
                    tv.setEnabled(false);
                }

                //After clicking on the label, reset the selected effect
                tv.setOnClickListener(new OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        if (lineSelectOnclickListener != null) {
                            lineSelectOnclickListener.selectMsgIndex(lable.getNumberCode());
                            if (selectstatus) {
                                lineSelectOnclickListener.sendOnclickMsg();
                            }
                        }
                        if (isClickable) {
                            for (View checkBox : selectView) {
                                ImageView imageView = checkBox.findViewById(R.id.cut_view);
                                RelativeLayout frameLayout = checkBox.findViewById(R.id.ll_layout);
                                if (checkBox.equals(tv)) {
                                    if (imageView.getVisibility() == View.VISIBLE) {
                                        frameLayout.setBackgroundResource(0);
                                        imageView.setVisibility(GONE);
                                    } else {
                                        imageView.setVisibility(VISIBLE);
                                        frameLayout.setBackgroundResource(R.drawable.bg_new_select_style);
                                    }
                                } else {
                                    imageView.setVisibility(GONE);
                                    frameLayout.setBackgroundResource(0);
                                }
                            }
                            lableForCommissionedSelected.clear();
                            lableForCommissionedSelected.add(lable.getTitle());
                        }

                    }
                });

                //Add labels to containers
                addView(tv);
            }
        }
    }


    private LineSelectOnclickListener lineSelectOnclickListener;

    public void setLineSelectOncilckListener(LineSelectOnclickListener lineSelectOncilckListener) {
        this.lineSelectOnclickListener = lineSelectOncilckListener;
    }


    public void clearLables() {
        if (lables == null) {
            return;
        }
        this.lables.clear();
        this.lableSelected.clear();
        removeAllViews();
    }


    public CashFlowSceneBean.Scene getLables() {
        return lableSelected.size() > 0 ? lableSelected.get(0) : new CashFlowSceneBean.Scene("", "");
    }

    @Override
    protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {
        //Calculate width and height for all label childViews
        measureChildren(widthMeasureSpec, heightMeasureSpec);

        //Get High Mode
        int heightMode = MeasureSpec.getMode(heightMeasureSpec);
        //Suggested height
        int heightSize = MeasureSpec.getSize(heightMeasureSpec);
        //The width of the layout should be the recommended width (match_parent or size), if wrap is set_ Content is also a match_ The effect of a parent
        int width = MeasureSpec.getSize(widthMeasureSpec);

        int height = 0;
        if (heightMode == MeasureSpec.AT_MOST) {
            //If the height mode is EXACTLY (match_prentor size), use the recommended height
            height = heightSize;
        } else {
            //In other cases (AT-MOST, UNSPECIFIED), the calculation height needs to be calculated
            int childCount = getChildCount();
            if (childCount <= 0) {
                height = 0;   //When there is no label, the height is 0
            } else {
                int row = 1;  //Number of label rows
                int widthSpace = width;//The remaining width on the right side of the current row
                for (int i = 0; i < childCount; i++) {
                    View view = getChildAt(i);
                    if (i == 0) {
                        height = view.getMeasuredHeight();
                    }
                    //Get label width
                    int childW = view.getMeasuredWidth();
                    if (widthSpace >= childW) {
                        //If the remaining width is greater than the width of this label, then place this label on this line
                        widthSpace -= childW;
                    } else {
                        if (aLineShow) {
                            break;
                        } else {
                            height += view.getMeasuredHeight();
                            row++;    //Add a line
                            //If the remaining width cannot accommodate this label, then place this label on one line
                            widthSpace = width - childW;
                        }
                    }
                    //Subtract the left and right spacing of labels
                    widthSpace -= LEFT_RIGHT_SPACE;
                }
                height += (row - 1) * ROW_SPACE;
                //Since the height of each label is the same, simply obtain the height of the first label
                int childH = getChildAt(0).getMeasuredHeight();
                //The height of the final layout=label height * Number of rows+line spacing * (number of rows -1)
//                height = (childH * row) + ROW_SPACE * (row - 1);

            }
        }

        //Set measurement width and measurement height
        setMeasuredDimension(width, height);
    }

    @Override
    protected void onLayout(boolean changed, int l, int t, int r, int b) {
        int row = 0;
        int right = 0;   //The right position of the label relative to the layout
        int botom = 0;       //The bottom position of the label relative to the layout
        boolean isChangeLine = false;
        int beforeHight = 0;
        int lineTop = 0;
        for (int i = 0; i < getChildCount(); i++) {
            View childView = getChildAt(i);
            int childW = childView.getMeasuredWidth();
            int childH = childView.getMeasuredHeight();
            //Right position=the position already occupied by this line+the width of the current label
            right += childW;
            //Bottom position=number of rows already placed * (Label height+line spacing)+current label height
            botom = lineTop + childH;

            //If the right position has exceeded the right edge of the layout, skip to the next line
            if (right > (r - LEFT_RIGHT_SPACE)) {
                if (aLineShow) {
                    return;
                }
                row++;
                right = childW;
                botom = beforeHight + childH;
                lineTop = botom - childH;
            }
            if (row == 0) {
                beforeHight = childH + ROW_SPACE;
            } else {
                beforeHight = botom + ROW_SPACE;
            }
            childView.layout(right - childW, botom - childH, right, botom);

            right += LEFT_RIGHT_SPACE;
        }
    }
}
