package com.chainup.contract.kline.view;

import android.animation.ValueAnimator;
import android.content.Context;
import android.database.DataSetObserver;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.LinearGradient;
import android.graphics.Paint;
import android.graphics.Path;
import android.graphics.Rect;
import android.graphics.RectF;
import android.graphics.Shader;
import android.os.Build;
import android.os.Handler;
import android.os.Looper;

import androidx.core.content.ContextCompat;
import androidx.core.view.GestureDetectorCompat;

import android.util.AttributeSet;
import android.util.Log;
import android.util.Pair;
import android.view.MotionEvent;
import android.view.ScaleGestureDetector;


import com.blankj.utilcode.util.LogUtils;
import com.chainup.contract.R;
import com.chainup.contract.app.CpMyApp;
import com.chainup.contract.utils.ChainUpLogUtil;
import com.chainup.contract.utils.CpBigDecimalUtils;
import com.chainup.contract.utils.CpColorUtil;
import com.chainup.contract.utils.CpDateUtils;
import com.chainup.contract.utils.CpDisplayUtil;
import com.chainup.contract.utils.CpKLineUtil;
import com.chainup.contract.utils.CpSizeUtils;
import com.yjkj.chainup.kline.view.CpMainKLineView;
import com.yjkj.chainup.new_contract.bean.CpCurrentOrderBean;
import com.yjkj.chainup.new_version.kline.base.CpIChartViewDraw;
import com.yjkj.chainup.new_version.kline.base.CpIDateFormatter;
import com.yjkj.chainup.new_version.kline.base.CpIValueFormatter;
import com.yjkj.chainup.new_version.kline.bean.CpCandleBean;
import com.yjkj.chainup.new_version.kline.bean.CpIKLine;
import com.yjkj.chainup.new_version.kline.data.CpIAdapter;
import com.yjkj.chainup.new_version.kline.formatter.CpDateFormatter;
import com.yjkj.chainup.new_version.kline.formatter.CpValueFormatter;
import com.yjkj.chainup.new_version.kline.view.cp.MainKlineViewStatus;
import com.yjkj.chainup.new_version.kline.view.cp.YLabelModel;

import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.List;
import java.util.regex.Pattern;

/**
 *K-line diagram
 *
 * @author Bertking
 * @Date：2019/3/12-3:35 PM
 *@ Description: All text sizes are set equal
 */
public abstract class CpBaseKLineChartView extends CpScrollAndScaleView {
    public static final String TAG = CpBaseKLineChartView.class.getSimpleName();


    private int childDrawPosition = -1;

    public int mPricePrecision = -1;
    public int mMultiplierPrecision = -1;

    private float translateX = Float.MIN_VALUE;

    private int width = 0;


    private int topPadding;
    private int childPadding;
    private int bottomPadding;
    private float columnSpace = 0;
    /**
     *Zoom
     */
    private float mainScaleY = 1;

    private float volScaleY = 1;

    private float childScaleY = 1;

    /**
     *Width occupied by all data
     */
    private float dataLen = 0;

    /**
     *Maximum and minimum values on the right side of Kline (scale)
     */
    private float mainMaxValue = Float.MAX_VALUE;

    private float mainMinValue = Float.MIN_VALUE;


    /**
     *Maximum&minimum value of Kline line
     */
    private float mainHighMaxValue = 0;

    private float mainLowMinValue = 0;


    private int mainMaxIndex = 0;

    private int mainMinIndex = 0;

    /**
     *Max&min of trading volume graph
     */
    private Float volMaxValue = Float.MAX_VALUE;

    private Float volMinValue = Float.MIN_VALUE;

    /**
     *Max&min of subgraphs
     */
    private Float childMaxValue = Float.MAX_VALUE;

    private Float childMinValue = Float.MIN_VALUE;

    /********-----------------------------------------*********/

    private int startIndex = 0;

    private int stopIndex = 0;

    private float pointWidth = 0;


    /**
     *Grid settings behind the background of the main image
     */
    private int gridRows = 5;
    private int gridColumns = 4;

    //Background rectangle
    private Rect mBgRect;
    /**
     *Mesh brush
     */
    private Paint gridPaint = new Paint(Paint.ANTI_ALIAS_FLAG);


    /**
     *Main image background brush
     */
    private Paint bgPaint = new Paint(Paint.ANTI_ALIAS_FLAG);

    private Paint textPaint = new Paint(Paint.ANTI_ALIAS_FLAG);
    /**
     *Boundary value on the right side of the K line
     */
    private Paint boundaryValuePaint = new Paint(Paint.ANTI_ALIAS_FLAG);
    /**
     *Time Brush
     */
    private Paint timePaint = new Paint(Paint.ANTI_ALIAS_FLAG);

    /**
     *Maximum value on the K line
     */
    private Paint maxMinPaint = new Paint(Paint.ANTI_ALIAS_FLAG);

    /**
     *Long press the selected value
     */
    private Paint selectedTextPaint = new Paint(Paint.ANTI_ALIAS_FLAG);

    /**
     *X axis selected color
     */
    private Paint selectedXLinePaint = new Paint(Paint.ANTI_ALIAS_FLAG);

    /**
     *Y axis selected color
     */
    private Paint selectedYLinePaint = new Paint(Paint.ANTI_ALIAS_FLAG);
    /**
     *Label brushes on the price line
     */
    protected Paint labelInPriceLinePaint = new Paint(Paint.ANTI_ALIAS_FLAG);

    private Paint selectPointPaint = new Paint(Paint.ANTI_ALIAS_FLAG);

    private Paint selectorFramePaint = new Paint(Paint.ANTI_ALIAS_FLAG);

    private int selectedIndex;

    private CpIChartViewDraw mMainDraw;
    private CpMainKLineView mainDraw;
    private CpIChartViewDraw mVolDraw;

    private CpIAdapter mAdapter;

    private Boolean isWR = false;
    /**
     *That is, whether the sub image indicator is displayed
     */
    private Boolean isShowChild = false;


    /**
     *Price Line Brush
     */
    protected Paint priceLinePaint = new Paint(Paint.ANTI_ALIAS_FLAG);

    /**
     *Current Price Border Brush
     */
    protected Paint priceLineBoxPaint = new Paint(Paint.ANTI_ALIAS_FLAG);

    /**
     *Current Price Background Brush
     */
    protected Paint priceLineBoxBgPaint = new Paint(Paint.ANTI_ALIAS_FLAG);

    /**
     *Tail line brush
     */
    protected Paint lineEndPointPaint = new Paint(Paint.ANTI_ALIAS_FLAG);
    /**
     *Fill brush below the tail line
     */
    protected Paint lineEndFillPointPaint = new Paint(Paint.ANTI_ALIAS_FLAG);


    /**
     *Dotted line brush to the right of the price line
     */
    protected Paint priceLineRightPaint = new Paint(Paint.ANTI_ALIAS_FLAG);

    protected Paint rightPriceBoxPaint = new Paint(Paint.ANTI_ALIAS_FLAG);

    /**
     *Dotted line brush to the right of the price line
     */
    protected Paint priceLineRightTextPaint = new Paint(Paint.ANTI_ALIAS_FLAG);

    /**
     *Price box height
     */
    protected float priceLabelInLineBoxHeight = 40;

    /**
     *Price box fillet radius
     */
    protected float priceLabelInLineBoxRadius = 5f;

    /**
     *Price box inner margin
     */
    protected float priceLineBoxPadidng = 8;

    /**
     *The height of the price line graph
     */
    protected float priceShapeHeight = 20;


    /**
     *Width of the price line graph
     */
    protected float priceShapeWidth = CpDisplayUtil.dip2px(12f);

    /**
     *Spacing between price line text and graphics
     */
    protected float priceBoxShapeTextMargin = 4;


    protected float labelSpace = 130;

    /**
     *The text box of the price line is from the margin on the right side of the screen
     */
    protected float priceLineBoxMarginRight = CpDisplayUtil.dip2px(84.53f);

    protected float priceLineMarginPriceLabel = 5;

    protected float priceDotLineItemWidth = 8f;
    protected float priceDotLineItemSpace = 4f;

    protected boolean showPriceLabelInLine;
    protected boolean priceLabelInLineClickable = true;
    protected float priceLabelInLineBoxRight, priceLabelInLineBoxLeft, priceLabelInLineBoxTop, priceLabelInLineBoxBottom;

    protected YLabelModel yLabelModel = YLabelModel.LABEL_NONE_GRID;

    /**
     *Animation execution duration
     */
    protected long duration = 400;
    private long time;
    /**
     *Unified text height
     */
    protected float textHeight;

    protected float textDecent;
    /**
     *Unified Text Base Line
     */
    protected float baseLine;
    /**
     *Latest price of current K line
     */
    protected float lastPrice;

    /**
     *Radius of tail point of time sharing line
     */
    protected float lineEndRadius = CpSizeUtils.dp2px(3f);

    /**
     *The radius of the time division line shadow
     */
    private float endShadowLayerWidth;

    /**
     *Radius of tail point of time sharing line
     */
    protected float lineEndMaxMultiply = CpSizeUtils.dp2px(2f);


    private ArrayList<CpCurrentOrderBean> mOrderData=new ArrayList<CpCurrentOrderBean>();

    //Set whether to draw a marker
    private boolean isDrawMarker = true;
    private boolean isSmallKline = false;


    private float overScrollRangeRatio = 0.2f;

    public void setOverScrollRangeRatio(float ratio){
        this.overScrollRangeRatio = ratio;
    }

    public void setmOrderData(ArrayList mOrderData) {
        this.mOrderData = mOrderData;
        invalidate();
    }

    private DataSetObserver mDataSetObserver = new DataSetObserver() {
        @Override
        public void onChanged() {
            itemCount = getAdapter().getCount();
            CpIKLine mIKLine = (CpIKLine) getItem(itemCount);
            lastPrice = mIKLine.getClosePrice();
            Log.d(TAG, "========lastPrice:====" + lastPrice);
            Log.d(TAG, "========mItemCount1:====" + itemCount);
            notifyChanged();
        }

        @Override
        public void onInvalidated() {
            itemCount = getAdapter().getCount();
            notifyChanged();
        }
    };

    /**
     *How many pieces of data are there altogether
     */
    private int itemCount;

    private CpIChartViewDraw childDraw;
    private List<CpIChartViewDraw> childDraws = new ArrayList<>();

    private CpIValueFormatter valueFormatter;
    private CpIDateFormatter dateTimeFormatter;

    private ValueAnimator animator;

    private long animationDuration = 100;

    private float overScrollRange = 0;

    private OnSelectedChangedListener mOnSelectedChangedListener = null;


    /**
     *To draw 3 sub graphs
     * 1.  Main KLine diagram
     * 2.  Transaction volume chart
     * 3.  Subpicture
     */
    private Rect mainRect;

    private Rect volRect;

    private Rect childRect;

    int displayHeight = 0;
    int displayWidth = 0;

    private float mLineWidth;

    public CpBaseKLineChartView(Context context) {
        super(context);
        init();
    }

    public CpBaseKLineChartView(Context context, AttributeSet attrs) {
        super(context, attrs);
        init();
    }

    public CpBaseKLineChartView(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init();
    }

    private void init() {
        setWillNotDraw(false);
        mDetector = new GestureDetectorCompat(getContext(), this);
        mScaleDetector = new ScaleGestureDetector(getContext(), this);

        topPadding = (int) getResources().getDimension(R.dimen.chart_top_padding);
        childPadding = (int) getResources().getDimension(R.dimen.child_top_padding);
        bottomPadding = (int) getResources().getDimension(R.dimen.chart_bottom_padding);

        animator = ValueAnimator.ofFloat(0f, 1f);
        animator.setDuration(animationDuration);
        animator.addUpdateListener(animation -> invalidate());

        priceLinePaint.setAntiAlias(true);
        priceLineRightPaint.setStyle(Paint.Style.STROKE);
        rightPriceBoxPaint.setStyle(Paint.Style.FILL_AND_STROKE);
        priceLineBoxPaint.setStyle(Paint.Style.STROKE);

        priceLineRightPaint.setStrokeWidth(CpSizeUtils.dp2px(0.8f));
        priceLineRightPaint.setTextSize(CpSizeUtils.dp2px(10f));
        priceLineRightPaint.setColor(CpColorUtil.INSTANCE.getColorByMode(R.color.main_color));

        priceLinePaint.setStrokeWidth(CpSizeUtils.dp2px(0.8f));
        priceLinePaint.setStyle(Paint.Style.STROKE);

        priceLinePaint.setColor(CpColorUtil.INSTANCE.getColorByMode(R.color.kline_dot_line_price_color));
        priceLineBoxPaint.setColor(CpColorUtil.INSTANCE.getColorByMode(R.color.price_line_color_day));
        priceLineBoxBgPaint.setColor(CpColorUtil.getColor(getContext(),R.color.card_bg_color_2));


        /**
         *Border settings for selected values
         */
        selectorFramePaint.setStrokeWidth(CpDisplayUtil.INSTANCE.dip2px(0.6f));
        selectorFramePaint.setStyle(Paint.Style.STROKE);
        selectorFramePaint.setColor(ContextCompat.getColor(getContext(), R.color.chart_selected_indicator));

    }


    @Override
    protected void onSizeChanged(int w, int h, int oldw, int oldh) {
        super.onSizeChanged(w, h, oldw, oldh);
        Log.d(TAG, "==========onSizeChanged:width========" + w + ",oldW = " + oldw);
        this.width = w;
//        displayWidth = (int) (width * 0.8f);
        displayWidth = width;
        displayHeight = h - topPadding - bottomPadding;
        initRect();
        setTranslateXFromScrollX(mScrollX);
    }


    /**
     *Fire coin rules
     *Set whether there are subgraphs
     *1 has subgraphs ----- 0.6 | 0.2 | 0.2
     *2 No sub graph ----- 0.8 | 0.2
     */
    private void initRect() {
        setOverScrollRange(width * overScrollRangeRatio);
        Log.d("========", "=====initRect=======" + isShowChild);
        if (isShowChild) {
            int mMainHeight = (int) (displayHeight * 0.6f);
            int mVolHeight = (int) (displayHeight * 0.2f);
            int mChildHeight = (int) (displayHeight * 0.2f);
            mainRect = new Rect(0, topPadding, displayWidth, topPadding + mMainHeight);
            volRect = new Rect(0, mainRect.bottom + childPadding, displayWidth, mainRect.bottom + mVolHeight);
            childRect = new Rect(0, volRect.bottom + childPadding, displayWidth, volRect.bottom + mChildHeight);
        } else {
            Log.d("=====onSizeChanged===", "width:" + width + ",height:" + displayHeight);
            int mMainHeight;
            int mVolHeight;
            if(isSmallKline){
                mMainHeight = (int) (displayHeight * 1f);
                mVolHeight = (int) (displayHeight * 0.2f);
            }else{
                mMainHeight = (int) (displayHeight * 0.8f);
                mVolHeight = (int) (displayHeight * 0.2f);
            }
            mainRect = new Rect(0, topPadding, displayWidth, topPadding + mMainHeight);
            volRect = new Rect(0, mainRect.bottom + childPadding, displayWidth, mainRect.bottom + mVolHeight);
        }
    }

    @Override
    protected void onDraw(Canvas canvas) {
        super.onDraw(canvas);
        if(null==mBgRect){
            canvas.drawColor(bgPaint.getColor());
        }else{
            canvas.drawRect(mBgRect,bgPaint);
        }

        if (width == 0 || mainRect.height() == 0 || itemCount == 0) {
            Log.d(TAG, "发生未知错误。。。");
            return;
        }
        calculateValue();
        canvas.save();
        /**
         *Control the entire canvas here
         */
        canvas.scale(1, 1);
        /**
         * drawGrid()
         */
        drawGird(canvas);

        float tempLeft = -translateX;
//        canvas.save();
//        canvas.translate(translateX, 0);

//        canvas.restore();

        /**
         *Draw K line
         */
        drawK(canvas);

        /**
         *Draw K line length by drawing
         */
//        drawKLongPass(canvas);

        drawText(canvas);

        renderPriceLine(canvas, displayWidth);
        drawMaxAndMin(canvas);
        drawBuyAndSell(canvas);
        drawValue(canvas, isLongPress && isDrawMarker ? selectedIndex : stopIndex);
        canvas.restore();
    }

    public float getMainY(float value) {
        return (mainMaxValue - value) * mainScaleY + mainRect.top;
    }

    public float getMainBottom() {
        return mainRect.bottom;
    }

    public float getVolY(float value) {
        return (volMaxValue - value) * volScaleY + volRect.top;
    }

    public float getChildY(float value) {
        if (childMaxValue.intValue() == 1) {
            childMaxValue = 0.02f;
        }
        return (childMaxValue - value) * childScaleY + childRect.top;
    }

    /**
     *Solve the problem of text centering
     */
    public float fixTextY(float y) {
        Paint.FontMetrics fontMetrics = textPaint.getFontMetrics();
        return y + fontMetrics.descent - fontMetrics.ascent;
    }

    /**
     *Solve the problem of text centering
     */
    public float fixTextY1(float y) {
        Paint.FontMetrics fontMetrics = textPaint.getFontMetrics();
        return (y + (fontMetrics.descent - fontMetrics.ascent) / 2 - fontMetrics.descent);
    }

    /**
     *Draw Table
     * <p>
     * Done
     *
     * @param canvas
     */
    private void drawGird(Canvas canvas) {
        //-----------------------上方k线图------------------------
        //Horizontal grid
        float rowSpace = mainRect.height() / gridRows;
        for (int i = 0; i <= gridRows; i++) {
            /**
             *Draw a horizontal line
             */
            canvas.drawLine(0, rowSpace * i + mainRect.top, width, rowSpace * i + mainRect.top, gridPaint);
        }


        /**
         *------------------------ Lower Subgraph------------------------
         *If there is a childView: Draw the line at the bottom of the trading volume&the line at the bottom of the sub graph
         */
        if (childDraw != null) {
            canvas.drawLine(0, volRect.bottom, width, volRect.bottom, gridPaint);
            canvas.drawLine(0, childRect.bottom, width, childRect.bottom, gridPaint);
        } else {
            canvas.drawLine(0, volRect.bottom, width, volRect.bottom, gridPaint);
        }

        //Vertical grid
        Log.d(TAG, "======columns=========" + gridColumns);
        columnSpace = width / gridColumns;
        for (int i = 1; i < gridColumns; i++) {
            canvas.drawLine(columnSpace * i, 0, columnSpace * i, mainRect.bottom, gridPaint);
            canvas.drawLine(columnSpace * i, mainRect.bottom, columnSpace * i, volRect.bottom, gridPaint);
            if (childDraw != null) {
                /**
                 *From the bottom of the Volu to the bottom of the sub image
                 */
                canvas.drawLine(columnSpace * i, volRect.bottom, columnSpace * i, childRect.bottom, gridPaint);
            }
        }
    }

    /**
     *Draw a k-line diagram
     *
     * @param canvas
     */
    private void drawK(Canvas canvas) {
        //Save previous panning, zooming
        canvas.save();
        Log.d(TAG, "tranX:" + translateX + ",scaleX =" + mScaleX +
                ", startIndex =" + startIndex + ",stopIndex=" + stopIndex);
        canvas.translate(translateX * mScaleX, 0);
        canvas.scale(mScaleX, 1);
        for (int i = startIndex; i <= stopIndex; i++) {
            /**
             *Obtain the corresponding Item based on the subscript
             */
            Object currentPoint = getItem(i);
            /**
             *Obtain the corresponding X-axis position according to the subscript
             */
            float currentPointX = getX(i);

            /**
             *Last Item
             */
            Object lastPoint = i == 0 ? currentPoint : getItem(i - 1);

            float lastX = i == 0 ? currentPointX : getX(i - 1);
            if (!(lastPoint instanceof CpCandleBean&&currentPoint instanceof CpCandleBean)){
                return;
            }
            if (mMainDraw != null) {
                mMainDraw.drawTranslated(lastPoint, currentPoint, lastX, currentPointX, canvas, this, i);
            }
            if (mVolDraw != null) {
                mVolDraw.drawTranslated(lastPoint, currentPoint, lastX, currentPointX, canvas, this, i);
            }
            if (childDraw != null) {
                childDraw.drawTranslated(lastPoint, currentPoint, lastX, currentPointX, canvas, this, i);
            }
        }

        /**
         *Draw the selected portion of the candle line
         */
        if (isLongPress && isDrawMarker) {
//            CpIKLine point = (CpIKLine) getItem(selectedIndex);
            float x = getX(selectedIndex);
            Pair<Float,Float> pairs = getLongPressPositionY();
            float y = pairs.first;
            //Vertical line of k-line diagram
            canvas.drawLine(x, mainRect.top, x, mainRect.bottom, selectedYLinePaint);
            //Horizontal line of k-line diagram
            canvas.drawLine(-translateX, y, -translateX + width / mScaleX, y, selectedXLinePaint);
            //Histogram Vertical Line
            canvas.drawLine(x, mainRect.bottom, x, volRect.bottom, selectedYLinePaint);

            /**
             *Long press to select the intersection of X&Y and draw a circle
             *TODO may need to configure colors and sizes
             */
//            canvas.drawCircle(x, y, 10f, selectedTextPaint);
//
//            canvas.drawCircle(x, y, 30f, selectedYLinePaint);

            if (childDraw != null) {
                //Subline Chart Vertical Line
                canvas.drawLine(x, volRect.bottom, x, childRect.bottom, selectedYLinePaint);
            }
        }
//        float tempLeft = -translateX;
//        renderPriceLine(canvas,tempLeft+displayWidth);
        //Restore Pan Zoom
        canvas.restore();
    }

    Pair<Float,Float> getLongPressPositionY(){
        float positionYScale = Math.min(longPressPositionY / mainRect.height(),1);
        float value = (mainMaxValue - mainMinValue) * (1 - positionYScale);
        float cprice = mainMinValue + value;
        float y = getMainY(cprice) - topPadding;
        return new Pair<>(y,cprice);
    }

    private void drawKLongPass(Canvas canvas) {
        //Save previous panning, zooming
        canvas.save();
        Log.d(TAG, "tranX:" + translateX + ",scaleX =" + mScaleX +
                ", startIndex =" + startIndex + ",stopIndex=" + stopIndex);
        canvas.translate(translateX * mScaleX, 0);
//        canvas.scale(mScaleX, mScaleX);
        /**
         *Draw the selected portion of the candle line
         */
        if (isLongPress && isDrawMarker) {
            CpIKLine point = (CpIKLine) getItem(selectedIndex);
            float x = getX(selectedIndex);
            float y = getMainY(point.getClosePrice());
            /**
             *Long press to select the intersection of X&Y and draw a circle
             *TODO may need to configure colors and sizes
             */
            canvas.drawCircle(x, y, 10f, selectedTextPaint);
            canvas.drawCircle(x, y, 10f*3, selectedYLinePaint);
        }
//        float tempLeft = -translateX;
//        renderPriceLine(canvas,tempLeft+displayWidth);
        //Restore Pan Zoom
        canvas.restore();
    }


    public void setDrawMarker(boolean isDraw){
        this.isDrawMarker = isDraw;
        this.mainDraw.setDrawMarker(isDraw);
    }

    public void setSmallKline(boolean isSmallKline){
        this.isSmallKline = isSmallKline;
        mainDraw.setSmallKline(isSmallKline);
    }

    /**
     *Calculate text length
     *
     * @return
     */
    private int calculateWidth(String text) {
        Rect rect = new Rect();
        textPaint.getTextBounds(text, 0, text.length(), rect);
        return rect.width() + 5;
    }

    /**
     *Calculate text length
     *
     * @return
     */
    private Rect calculateMaxMin(String text) {
        Rect rect = new Rect();
        maxMinPaint.getTextBounds(text, 0, text.length(), rect);
        return rect;
    }

    /**
     *Draw text
     *
     * @param canvas
     */
    private void drawText(Canvas canvas) {
        Paint.FontMetrics fm = textPaint.getFontMetrics();
        textHeight = fm.descent - fm.ascent;
        textDecent = fm.descent;
        baseLine = (textHeight - fm.bottom - fm.top) / 2;

        /***--------------Draw the value of the k-line graph to the right)-------------**/

        Log.d(TAG, "===========mainMaxValue:=" + mainMaxValue + ",mainMinValue = " + mainMinValue);

        if (mMainDraw != null) {
            if (mPricePrecision != -1) {
                mainMaxValue = Float.parseFloat(CpBigDecimalUtils.showSNormal(String.valueOf(mainMaxValue), mPricePrecision));
                mainMinValue = Float.parseFloat(CpBigDecimalUtils.showSNormal(String.valueOf(mainMinValue), mPricePrecision));
            }
            canvas.drawText(formatValueWithPrecision(mainMaxValue,mPricePrecision), width - calculateWidth(formatValueWithPrecision(mainMaxValue,mPricePrecision)) - CpDisplayUtil.INSTANCE.dip2px(5f), baseLine + mainRect.top, boundaryValuePaint);
            if(!isSmallKline){
                canvas.drawText(formatValueWithPrecision(mainMinValue,mPricePrecision), width - calculateWidth(formatValueWithPrecision(mainMinValue,mPricePrecision)) - CpDisplayUtil.INSTANCE.dip2px(5f), mainRect.bottom - textHeight + baseLine, boundaryValuePaint);
            }
            float rowValue = (mainMaxValue - mainMinValue) / gridRows;
            float rowSpace = mainRect.height() / gridRows;
            String text = "";
            for (int i = 1; i < gridRows; i++) {
                text = formatValueWithPrecision((rowValue * (gridRows - i) + mainMinValue), mPricePrecision);
                canvas.drawText(text, width - calculateWidth(text) - CpDisplayUtil.INSTANCE.dip2px(5f), fixTextY(rowSpace * i + mainRect.top), boundaryValuePaint);
            }
        }
        /**--------------The value of the subgraph in the drawing-------------**/
        if (mVolDraw != null) {
            /**
             *Draw Maximum
             */
            canvas.drawText(mVolDraw.getValueFormatter().format(volMaxValue),
                    width - calculateWidth(mVolDraw.getValueFormatter().format(volMaxValue)) - CpDisplayUtil.INSTANCE.dip2px(5f), mainRect.bottom + baseLine, boundaryValuePaint);
            /**
             *Draw minimum
             */
//            canvas.drawText(mVolDraw.getValueFormatter().format(volMinValue),
//                    width - calculateWidth(formatValue(volMinValue))-DisplayUtil.INSTANCE.dip2px(15f), volRect.bottom, boundaryValuePaint);
        }

        /**--------------Draw the values of the square subgraph-------------**/
        if (childDraw != null) {
            childMaxValue= Float.valueOf(CpBigDecimalUtils.showSNormal(childMaxValue.toString(),5));
            canvas.drawText(childDraw.getValueFormatter().format(childMaxValue),
                    width - calculateWidth(childDraw.getValueFormatter().format(childMaxValue)) - CpDisplayUtil.INSTANCE.dip2px(5f), volRect.bottom + baseLine, boundaryValuePaint);
            /**
             *Draw minimum
             */
            childMinValue= Float.valueOf(CpBigDecimalUtils.showSNormal(childMinValue.toString(),5));
            canvas.drawText(childDraw.getValueFormatter().format(childMinValue),
                    width - calculateWidth(childDraw.getValueFormatter().format(childMinValue)) - CpDisplayUtil.INSTANCE.dip2px(5f), childRect.bottom, boundaryValuePaint);
        }

        /**--------------Draw time---------------------**/
        float columnSpace = width / gridColumns;
        float y;
        if (isShowChild) {
            y = childRect.bottom + baseLine + 5;
        } else {
            if(isSmallKline){
                y = mainRect.bottom + baseLine + 5;
            }else{
                y = volRect.bottom + baseLine + 5;
            }
        }

        float startX = getX(startIndex) - pointWidth / 2;
        float stopX = getX(stopIndex) + pointWidth / 2;


        //Date of each column
        for (int i = 1; i < gridColumns; i++) {
            float translateX = xToTranslateX(columnSpace * i);
            if (translateX >= startX && translateX <= stopX) {
                int index = indexOfTranslateX(translateX);
                String text = mAdapter.getDate(index);
                if (i == 1) {
                    Log.d(TAG, "======the Time:=====" + text);
                }
                canvas.drawText(text, columnSpace * i - timePaint.measureText(text) / 2, y, timePaint);
            }
        }

        //Start Date
        float translateX = xToTranslateX(0);
        if (translateX >= startX && translateX <= stopX) {
            Log.d(TAG, "======the Time:=====" + getAdapter().getDate(startIndex) + "start Index:" + startIndex);
            canvas.drawText(getAdapter().getDate(startIndex), 0, y, timePaint);
        }


        //End Date
        translateX = xToTranslateX(width);
        if (translateX >= startX && translateX <= stopX) {
            String text = getAdapter().getDate(stopIndex);
            canvas.drawText(text, width - timePaint.measureText(text), y, timePaint);
        }


        /**
         *Long press to select a picture
         */
        if (isLongPress && isDrawMarker) {
            //Draw Y value
            CpIKLine point = (CpIKLine) getItem(selectedIndex);
            float w1 = CpDisplayUtil.INSTANCE.dip2px(5f);
            float w2 = CpDisplayUtil.INSTANCE.dip2px(3f);
            float r = textHeight / 2 + w2;
            Pair<Float,Float> pairs = getLongPressPositionY();
            y = pairs.first;
            float x;
            String text = formatValueWithPrecision(pairs.second,mPricePrecision);
            float textWidth = selectedTextPaint.measureText(text);
//            if (translateXtoX(getX(selectedIndex)) < getChartWidth() / 2) {
//                x = 1;
//                Path path = new Path();
//                path.moveTo(x, y - r);
//                path.lineTo(x, y + r);
//                path.lineTo(textWidth + 2 * w1, y + r);
//                path.lineTo(textWidth + 2 * w1 + w2, y);
//                path.lineTo(textWidth + 2 * w1, y - r);
//                path.close();
//
//                canvas.drawPath(path, selectPointPaint);
//                canvas.drawPath(path, selectorFramePaint);
//                canvas.drawText(text, x + w1, fixTextY1(y), selectedTextPaint);
//            } else {
                x = width - textWidth - 1 - 2 * w1 - w2;
                Path path = new Path();
                path.moveTo(x, y);
                path.lineTo(x + w2, y + r);
                path.lineTo(width - 2, y + r);
                path.lineTo(width - 2, y - r);
                path.lineTo(x + w2, y - r);
                path.close();
                canvas.drawPath(path, selectPointPaint);
                canvas.drawPath(path, selectorFramePaint);
                canvas.drawText(text, x + w1 + w2, fixTextY1(y), selectedTextPaint);
//            }

            //Draw X value
            String date = mAdapter.getDate(selectedIndex);
            textWidth = selectedTextPaint.measureText(date);
            r = textHeight / 2;
            x = translateXtoX(getX(selectedIndex));
            if (isShowChild) {
                y = childRect.bottom;
            } else {
                y = volRect.bottom;
            }

            if (x < textWidth + 2 * w1) {
                x = 1 + textWidth / 2 + w1;
            } else if (width - x < textWidth + 2 * w1) {
                x = width - 1 - textWidth / 2 - w1;
            }

            canvas.drawRect(x - textWidth / 2 - w1, y, x + textWidth / 2 + w1, y + baseLine + r, selectPointPaint);
            canvas.drawRect(x - textWidth / 2 - w1, y, x + textWidth / 2 + w1, y + baseLine + r, selectorFramePaint);
            canvas.drawText(date, x - textWidth / 2, y + baseLine + 5, selectedTextPaint);
        }
    }

    /**
     *Draw the maximum and minimum values of the Kline line
     *
     * @param canvas
     */
    private void drawMaxAndMin(Canvas canvas) {
        if (!mainDraw.isLine()) {
            CpIKLine maxEntry = null, minEntry = null;
            boolean firstInit = true;

            //Draw maximum and minimum values
            float x = translateXtoX(getX(mainMinIndex));

            float y = getMainY(mainLowMinValue);
            String LowString = "── " + CpBigDecimalUtils.showSNormal(String.valueOf(mainLowMinValue),mPricePrecision);
            //Calculate display position
            //Calculate text width
            int lowStringWidth;
            int lowStringHeight = calculateMaxMin(LowString).height();
            if (x < getWidth() / 2) {
                //Draw Right
                canvas.drawText(LowString, x, y + lowStringHeight / 2, maxMinPaint);
            } else {
                //Draw Left
                LowString = CpBigDecimalUtils.showSNormal(String.valueOf(mainLowMinValue),mPricePrecision) + " ──";
                lowStringWidth = calculateMaxMin(LowString).width();
                canvas.drawText(LowString, x - lowStringWidth, y + lowStringHeight / 2, maxMinPaint);
            }
            x = translateXtoX(getX(mainMaxIndex));
            y = getMainY(mainHighMaxValue);

            /**
             *Maximum
             */
            String highString = "── " + CpBigDecimalUtils.showSNormal(String.valueOf(mainHighMaxValue),mPricePrecision);

            int highStringWidth;
            int highStringHeight = calculateMaxMin(highString).height();

            if (x < getWidth() / 2) {
                //Draw Right
                canvas.drawText(highString, x, y + highStringHeight / 2, maxMinPaint);
            } else {
                //Draw Left
                highString = CpBigDecimalUtils.showSNormal(String.valueOf(mainHighMaxValue),mPricePrecision) + " ──";
                highStringWidth = calculateMaxMin(highString).width();
                canvas.drawText(highString, x - highStringWidth, y + highStringHeight / 2, maxMinPaint);

            }
        }
    }

    /**
     *Draw the buying and selling icon of Kline line
     *
     * @param canvas
     */
    private void drawBuyAndSell(Canvas canvas) {
        if (!mainDraw.isLine()) {
            for (int i = startIndex; i <= stopIndex; i++) {
                Long dateStartLong = mAdapter.getDateLong(i)*1000;
//                ChainUpLogUtil.e("Kline Date:",dateStartLong);
//               String dateStart= CpDateUtils.Companion.getYearMonthDayHourMinSecond(dateStartLong);
//               String dateEnd= CpDateUtils.Companion.getLongByOffset(dateStartLong, Calendar.MINUTE,15);

                ArrayList<String> kLineScale = CpKLineUtil.INSTANCE.getKLineScale();
                String curTime = CpKLineUtil.INSTANCE.getCurTime();
                Long dateEndLong= Long.valueOf(0);
                Pattern pattern = Pattern.compile("^[0-9]+h$");

                if (curTime.contains("min")){
                    dateEndLong= CpDateUtils.Companion.getLongStrByOffset(dateStartLong, Calendar.MINUTE, Integer.parseInt(curTime.replace("min","")));
                }else if (pattern.matcher(curTime).matches()){
                    dateEndLong= CpDateUtils.Companion.getLongStrByOffset(dateStartLong, Calendar.HOUR_OF_DAY, Integer.parseInt(curTime.replace("h","")));
                }else if (curTime.contains("day")){
                    dateEndLong= CpDateUtils.Companion.getLongStrByOffset(dateStartLong, Calendar.DAY_OF_MONTH,1);
                }else if (curTime.contains("week")){
                    dateEndLong= CpDateUtils.Companion.getLongStrByOffset(dateStartLong, Calendar.WEEK_OF_MONTH,1);
                }else if (curTime.contains("month")){
                    dateEndLong= CpDateUtils.Companion.getLongStrByOffset(dateStartLong, Calendar.MONTH,1);
                }

//                ChainUpLogUtil.e("dateStart dateEnd:",dateStart+"---"+dateEnd);
               Boolean isDrawBuy=false;
               Boolean isDrawSell=false;
                for (int j = 0; j <mOrderData.size(); j++) {
                    CpCurrentOrderBean cpCurrentOrderBean = mOrderData.get(j);
                    Long orderDateLong= Long.valueOf(cpCurrentOrderBean.getCtime());
                    if (dateStartLong<=orderDateLong&&orderDateLong<dateEndLong){
                        if (cpCurrentOrderBean.getOpen().equals("OPEN")){
                            //Buy
                            if (isDrawBuy)continue;
                            isDrawBuy=false;
                            drawBuyAndSellIcon(canvas,i,true);
                        }else {
                            //Sell
                            if (isDrawSell)continue;
                            isDrawSell=false;
                            drawBuyAndSellIcon(canvas,i,false);
                        }
                    }
                }
            }
        }
    }

    private void drawBuyAndSellIcon(Canvas canvas,int  pillarIndex,Boolean isBuy) {
        CpIKLine point = (CpIKLine) getItem(pillarIndex);
        float x =0f;
        float y =0f;
        mainHighMaxValue = point.getHighPrice();
        mainLowMinValue = point.getLowPrice();
        if (isBuy){
            x=translateXtoX(getX(pillarIndex));
            y=getMainY(mainLowMinValue);
            canvas.drawBitmap(BitmapFactory.decodeResource(getResources(),R.drawable.kline_buy),x-20,y,maxMinPaint);
        }else {
            x = translateXtoX(getX(pillarIndex));
            y = getMainY(mainHighMaxValue);
            System.out.println("y = " + "绘制卖ICON x:"+x+"    y:"+y+"    pillarIndex："+pillarIndex);
            canvas.drawBitmap(BitmapFactory.decodeResource(getResources(),R.drawable.kline_sell),x-20,y-50,maxMinPaint);
        }

    }

    /**
     *Draw Value
     *
     * @param canvas
     *@param position Displays the value of a point
     */
    private void drawValue(Canvas canvas, int position) {
        Paint.FontMetrics fm = textPaint.getFontMetrics();
        float textHeight = fm.descent - fm.ascent;
        float baseLine = (textHeight - fm.bottom - fm.top) / 2;
        if (position >= 0 && position < itemCount) {
            if (mMainDraw != null) {
                float y = mainRect.top + baseLine - textHeight;
                mMainDraw.drawText(canvas, this, position, 0, y);
            }
            if (mVolDraw != null) {
                float y = mainRect.bottom + baseLine;
                mVolDraw.drawText(canvas, this, position, 0, y);
            }
            if (childDraw != null) {
                float y = volRect.bottom + baseLine;
                childDraw.drawText(canvas, this, position, CpDisplayUtil.dip2px(5f), y);
            }
        }
    }


    /**
     *Format Value
     */
    public String formatValue(float value) {
        if (getValueFormatter() == null) {
            setValueFormatter(new CpValueFormatter());
        }
        return getValueFormatter().format(value);
    }

    /**
     *Format Value
     */
    public String formatValueWithPrecision(float value,int precision) {
        return new CpValueFormatter(precision).format(value);
    }

    /**
     *Format Value
     */
    public String formatContractValue(float value) {
        if (getValueFormatter() == null) {
            setValueFormatter(new CpValueFormatter());
        }
        return getValueFormatter().format(value);
    }

    /**
     *Recalculate and refresh lines
     */
    public void notifyChanged() {
        if (isShowChild && childDrawPosition == -1) {
            childDraw = childDraws.get(0);
            childDrawPosition = 0;
        }

        if (itemCount != 0) {
            dataLen = (itemCount - 1) * pointWidth;
            checkAndFixScrollX();
            setTranslateXFromScrollX(mScrollX);
        } else {
            setScrollX(0);
        }

        new Handler(Looper.getMainLooper()).post(() -> invalidate());

    }

    /**
     *MA/BOLL switching and hiding
     *
     * @param status MA/BOLL/NONE
     */
    public void changeMainDrawType(MainKlineViewStatus status) {
        if (mainDraw != null && mainDraw.getStatus() != status) {
            mainDraw.setStatus(status);
            invalidate();
        }
    }

    private void calculateSelectedX(float x) {
        selectedIndex = indexOfTranslateX(xToTranslateX(x));
        if (selectedIndex < startIndex) {
            selectedIndex = startIndex;
        }
        if (selectedIndex > stopIndex) {
            selectedIndex = stopIndex;
        }
    }

    @Override
    public void onLongPress(MotionEvent e) {
        super.onLongPress(e);
        int lastIndex = selectedIndex;
        calculateSelectedX(e.getX());
        if (lastIndex != selectedIndex) {
            onSelectedChanged(this, getItem(selectedIndex), selectedIndex);
        }
        invalidate();
    }

    @Override
    protected void onScrollChanged(int l, int t, int oldl, int oldt) {
        super.onScrollChanged(l, t, oldl, oldt);
        setTranslateXFromScrollX(mScrollX);
    }

    @Override
    protected void onScaleChanged(float scale, float oldScale) {
        checkAndFixScrollX();
        setTranslateXFromScrollX(mScrollX);
        super.onScaleChanged(scale, oldScale);
    }

    /**
     *Calculate the current display area
     */
    private void calculateValue() {
        Log.d(TAG, "===calculateValue()====" + width);

        if (!isLongPress()) {
            selectedIndex = -1;
        }

        mainMaxValue = Float.MIN_VALUE;
        mainMinValue = Float.MAX_VALUE;


        volMaxValue = Float.MIN_VALUE;
        volMinValue = Float.MAX_VALUE;


        childMaxValue = Float.MIN_VALUE;
        childMinValue = Float.MAX_VALUE;


        startIndex = indexOfTranslateX(xToTranslateX(0));
        stopIndex = indexOfTranslateX(xToTranslateX(displayWidth));
        Log.d(TAG, "========stopIndex:==" + stopIndex);

//        stopIndex = indexOfTranslateX(xToTranslateX(displayWidth));

        mainMaxIndex = startIndex;
        mainMinIndex = startIndex;


        /**
         *Maximum and Maximum Price
         */
        mainHighMaxValue = Float.MIN_VALUE;
        /**
         *Lowest Lowest Price
         */
        mainLowMinValue = Float.MAX_VALUE;

        for (int i = startIndex; i <= stopIndex; i++) {
            CpIKLine point = (CpIKLine) getItem(i);
            if (mMainDraw != null) {
                mainMaxValue = Math.max(mainMaxValue, mMainDraw.getMaxValue(point));

                mainMinValue = Math.min(mainMinValue, mMainDraw.getMinValue(point));
                /**
                 *Determine maximum and maximum prices, minimum and minimum prices
                 */
                if (mainHighMaxValue != Math.max(mainHighMaxValue, point.getHighPrice())) {
                    mainHighMaxValue = point.getHighPrice();
                    mainMaxIndex = i;
                }
                if (mainLowMinValue != Math.min(mainLowMinValue, point.getLowPrice())) {
                    mainLowMinValue = point.getLowPrice();
                    mainMinIndex = i;
                }
            }

            /**
             *Determine transaction volume ->maximum value
             */
            if (mVolDraw != null) {
                volMaxValue = Math.max(volMaxValue, mVolDraw.getMaxValue(point));
                volMinValue = Math.min(volMinValue, mVolDraw.getMinValue(point));
            }

            /**
             *Determine the maximum value of sub graph
             */
            if (childDraw != null) {
                childMaxValue = Math.max(childMaxValue, childDraw.getMaxValue(point));
                childMinValue = Math.min(childMinValue, childDraw.getMinValue(point));
                Log.d(TAG, "====max:=" + childMaxValue + "min:" + childMinValue);
            }

        }


        if (mainMaxValue != mainMinValue) {
            float padding = (mainMaxValue - mainMinValue) * 0.05f;
            mainMaxValue += padding;
            mainMinValue -= padding;
        } else {
            //Increase the maximum and decrease the minimum when both the maximum and minimum values are equal
            mainMaxValue += Math.abs(mainMaxValue * 0.05f);
            mainMinValue -= Math.abs(mainMinValue * 0.05f);
            if (mainMaxValue == 0) {
                mainMaxValue = 1;
            }
        }

        if (Math.abs(volMaxValue) < 0.01) {
            volMaxValue = 15.00f;
        }

        if (Math.abs(childMaxValue) < 0.000001 && Math.abs(childMinValue) < 0.000001) {
            childMaxValue = 1f;
        } else if (childMaxValue.equals(childMinValue)) {
            //Increase the maximum and decrease the minimum when both the maximum and minimum values are equal
            childMaxValue += Math.abs(childMaxValue * 0.05f);
            childMinValue -= Math.abs(childMinValue * 0.05f);
            if (childMaxValue == 0) {
                childMaxValue = 1f;
            }
        }

        if (isWR) {
            childMaxValue = 0f;
            if (Math.abs(childMinValue) < 0.01) {
                childMinValue = -10.00f;
            }
        }

        mainScaleY = mainRect.height() * 1f / (mainMaxValue - mainMinValue);

        volScaleY = volRect.height() * 1f / (volMaxValue - volMinValue);

        if (childRect != null) {
            childScaleY = childRect.height() * 1f / (childMaxValue - childMinValue);
        }

        if (animator.isRunning()) {
            float value = (float) animator.getAnimatedValue();
            stopIndex = startIndex + Math.round(value * (stopIndex - startIndex));
        }


    }

    /**
     *Get the minimum value for translation
     *
     * @return
     */
    private float getMinTranslateX() {
        if (!isFullScreen()) {
            return getMaxTranslateX();
        }
        return -dataLen + width / mScaleX - pointWidth / 2;
    }


    /**
     *Get the maximum value of translation
     *
     * @return
     */
    private float getMaxTranslateX() {
        return pointWidth / 2;
    }

    @Override
    public int getMinScrollX() {
        return (int) -(overScrollRange / mScaleX);
    }

    @Override
    public int getMaxScrollX() {
        return Math.round(getMaxTranslateX() - getMinTranslateX());
    }


    public int indexOfTranslateX(float translateX) {
        return indexOfTranslateX(translateX, 0, itemCount - 1);
    }

    /**
     *Draw a line in the main area
     *
     *@param startX abscissa of the start point
     *The value of the @param stopX start point
     *@param stopX abscissa of the end point
     *@param stopValue The value of the end point
     */
    public void drawMainLine(Canvas canvas, Paint paint, float startX, float startValue, float stopX, float stopValue) {
        canvas.drawLine(startX, getMainY(startValue), stopX, getMainY(stopValue), paint);
    }


    /**
     *Draw a time division line in the main area
     *
     *@param startX abscissa of the start point
     *The value of the @param stopX start point
     *@param stopX abscissa of the end point
     *@param stopValue The value of the end point
     */
    public void drawMainMinuteLine(Canvas canvas, Paint paint, float startX, float startValue, float stopX, float stopValue) {
        Path path5 = new Path();
        path5.moveTo(startX, displayHeight + topPadding + bottomPadding);
        path5.lineTo(startX, getMainY(startValue));
        path5.lineTo(stopX, getMainY(stopValue));
        path5.lineTo(stopX, displayHeight + topPadding + bottomPadding);
        path5.close();
        canvas.drawPath(path5, paint);
    }

    /**
     *Draw lines in sub areas
     *
     *@param startX abscissa of the start point
     *@param startValue The value of the start point
     *@param stopX abscissa of the end point
     *@param stopValue The value of the end point
     */
    public void drawChildLine(Canvas canvas, Paint paint, float startX, float startValue, float stopX, float stopValue) {
        canvas.drawLine(startX, getChildY(startValue), stopX, getChildY(stopValue), paint);
    }

    /**
     *Draw lines in sub areas
     *
     *@param startX abscissa of the start point
     *@param startValue The value of the start point
     *@param stopX abscissa of the end point
     *@param stopValue The value of the end point
     */
    public void drawVolLine(Canvas canvas, Paint paint, float startX, float startValue, float stopX, float stopValue) {
        canvas.drawLine(startX, getVolY(startValue), stopX, getVolY(stopValue), paint);
    }

    /**
     *Get entities based on index
     *
     *@param position index value
     * @return
     */
    public Object getItem(int position) {
        if (mAdapter != null) {
            return mAdapter.getItem(position);
        } else {
            return null;
        }
    }

    /**
     *Take the x coordinate according to the index
     *
     *@param position index value
     * @return
     */
    public float getX(int position) {
        return position * pointWidth;
    }

    /**
     *Get Adapter
     *
     * @return
     */
    public CpIAdapter getAdapter() {
        return mAdapter;
    }

    /**
     *Set current subgraph
     *
     * @param position
     */
    public void setChildDraw(int position) {
        if (childDrawPosition != position) {
            if (!isShowChild) {
                isShowChild = true;
                initRect();
            }
            childDraw = childDraws.get(position);
            childDrawPosition = position;
            isWR = position == 5;
            invalidate();
        }
    }

    /**
     *Set Precision
     *
     * @param position
     */
    public void setPricePrecision(int position) {
        mPricePrecision = position;

        if (mainDraw != null) {
            mainDraw.setMaPricePrecision(position);
        }
    }

    public void setMultiplierPrecision(int precision){
        mMultiplierPrecision = precision;
        if (mainDraw != null) {
            mainDraw.setMaMultiplierPrecision(mMultiplierPrecision);
        }
    }


    /**
     *Hide Subgraph
     */
    public void hideChildDraw() {
        childDrawPosition = -1;
        isShowChild = false;
        childDraw = null;
        initRect();
        invalidate();
    }

    /**
     *Add a drawing method to a sub area
     *
     * @param childDraw IChartViewDraw
     */
    public void addChildDraw(CpIChartViewDraw childDraw) {
        childDraws.add(childDraw);
    }

    /**
     *ScrollX to TranslateX
     *
     * @param scrollX
     */
    private void setTranslateXFromScrollX(int scrollX) {
        translateX = scrollX + getMinTranslateX();
        invalidate();
    }

    /**
     *Get ValueFormatter
     *
     * @return
     */
    public CpIValueFormatter getValueFormatter() {
        return valueFormatter;
    }

    /**
     *Set ValueFormatter
     *
     *@param valueFormatter value formatter
     */
    public void setValueFormatter(CpIValueFormatter valueFormatter) {
        this.valueFormatter = valueFormatter;
    }

    /**
     *Get DatetimeFormatter
     *
     *@return Time Formatter
     */
    public CpIDateFormatter getDateTimeFormatter() {
        return dateTimeFormatter;
    }

    /**
     *Set dateTimeFormatter
     *
     *@param dateTimeFormatter Time Formatter
     */
    public void setDateTimeFormatter(CpIDateFormatter dateTimeFormatter) {
        this.dateTimeFormatter = dateTimeFormatter;
    }

    /**
     *Format Time
     *
     * @param date
     */
    public String formatDateTime(Date date) {
        if (getDateTimeFormatter() == null) {
            setDateTimeFormatter(new CpDateFormatter());
        }
        return getDateTimeFormatter().format(date);
    }

    /**
     *Get the IChartViewDraw of the main area
     *
     * @return IChartViewDraw
     */
    public CpIChartViewDraw getMainDraw() {
        return mMainDraw;
    }

    /**
     *Set IChartViewDraw for the main area
     *
     * @param mainDraw IChartViewDraw
     */
    public void setMainDraw(CpIChartViewDraw mainDraw) {
        mMainDraw = mainDraw;
        this.mainDraw = (CpMainKLineView) mMainDraw;
    }

    public CpIChartViewDraw getVolDraw() {
        return mVolDraw;
    }

    public void setVolDraw(CpIChartViewDraw mVolDraw) {
        this.mVolDraw = mVolDraw;
    }

    /**
     *Binary search for the index of the current value
     *Recursive TODO call (may cause stack overflow)
     *
     * @return
     */
    public int indexOfTranslateX(float translateX, int start, int end) {
        while (true) {
            if (end <= start) {
                return start;
            }
            if (end - start == 1) {
                float startValue = getX(start);
                float endValue = getX(end);
                return Math.abs(translateX - startValue) < Math.abs(translateX - endValue) ? start : end;
            }
            int mid = start + (end - start) / 2;
            float midValue = getX(mid);
            if (translateX < midValue) {
                end = mid;
            } else if (translateX > midValue) {
                start = mid;
            } else {
                return mid;
            }
        }
    }

    /**
     *Set up data adapter
     */
    public void setAdapter(CpIAdapter adapter) {
        if (mAdapter != null && mDataSetObserver != null) {
            mAdapter.unregisterDataSetObserver(mDataSetObserver);
        }
        mAdapter = adapter;
        if (mAdapter != null) {
            mAdapter.registerDataSetObserver(mDataSetObserver);
            itemCount = mAdapter.getCount();
            Log.d(TAG, "========itemCount:====" + itemCount);
        } else {
            itemCount = 0;
        }
        notifyChanged();
    }

    /**
     *Start Animation
     */
    public void startAnimation() {
        if (animator != null) {
            animator.start();
        }
    }

    /**
     *Set Animation Time
     */
    public void setAnimationDuration(long duration) {
        if (animator != null) {
            animator.setDuration(duration);
        }
    }

    /**
     *Set the number of table rows
     */
    public void setGridRows(int gridRows) {
        if (gridRows < 1) {
            gridRows = 1;
        }
        this.gridRows = gridRows;
    }

    /**
     *Set the number of table columns
     */
    public void setGridColumns(int gridColumns) {
        if (gridColumns < 1) {
            gridColumns = 1;
        }
        this.gridColumns = gridColumns;
    }

    /**
     *Convert x in view to TranslateX
     *
     * @param x
     * @return
     */
    public float xToTranslateX(float x) {
        return -translateX + x / mScaleX;
    }

    public float xToTranslateXBuff(float x) {
        return -translateX + x;
    }

    /**
     *TranslateX is converted to x in view
     *
     * @param translateX
     * @return
     */
    public float translateXtoX(float translateX) {
        return (translateX + this.translateX) * mScaleX;
    }

    /**
     *Get upper padding
     */
    public float getTopPadding() {
        return topPadding;
    }

    /**
     *Get upper padding
     */
    public float getChildPadding() {
        return childPadding;
    }

    /**
     *Getting child attempts to top padding
     */
    public float getmChildScaleYPadding() {
        return childPadding;
    }

    /**
     *Get the width of the graph
     *
     * @return
     */
    public int getChartWidth() {
        return width;
    }

    /**
     *Long press or not
     */
    public boolean isLongPress() {
        return isLongPress;
    }

    /**
     *Get Selection Index
     */
    public int getSelectedIndex() {
        return selectedIndex;
    }

    public Rect getChildRect() {
        return childRect;
    }

    public Rect getVolRect() {
        return volRect;
    }

    /**
     *Set selection listening
     */
    public void setOnSelectedChangedListener(OnSelectedChangedListener l) {
        this.mOnSelectedChangedListener = l;
    }

    public void onSelectedChanged(CpBaseKLineChartView view, Object point, int index) {
        if (this.mOnSelectedChangedListener != null) {
            mOnSelectedChangedListener.onSelectedChanged(view, point, index);
        }
    }

    /**
     *Whether the data fills the screen
     *
     * @return
     */
    public boolean isFullScreen() {
        return dataLen >= width / mScaleX;
    }

    /**
     *Set the sliding range beyond the right
     */
    public void setOverScrollRange(float overScrollRange) {
        if (overScrollRange < 0) {
            overScrollRange = 0;
        }
        this.overScrollRange = overScrollRange;
    }

    /**
     *Set upper padding
     *
     * @param topPadding
     */
    public void setTopPadding(int topPadding) {
        this.topPadding = topPadding;
    }

    /**
     *Set lower padding
     *
     * @param bottomPadding
     */
    public void setBottomPadding(int bottomPadding) {
        this.bottomPadding = bottomPadding;
    }

    /**
     *Set Table Line Width
     */
    public void setGridLineWidth(float width) {
        gridPaint.setStrokeWidth(width);
    }

    /**
     *Set Table Line Color
     */
    public void setGridLineColor(int color) {
        gridPaint.setColor(color);
    }

    /**
     *Set selector horizontal line width
     */
    public void setSelectedXLineWidth(float width) {
        selectedXLinePaint.setStrokeWidth(width);
    }

    /**
     *Set selector horizontal line color
     */
    public void setSelectedXLineColor(int color) {
        selectedXLinePaint.setColor(color);
    }

    /**
     *Set selector vertical line width
     */
    public void setSelectedYLineWidth(float width) {
        selectedYLinePaint.setStrokeWidth(width);
    }

    /**
     *Set selector vertical line color
     */
    public void setSelectedYLineColor(int color) {
        selectedYLinePaint.setColor(color);
    }

    public void setSelectedTextColor(int color) {
        selectedTextPaint.setColor(color);
    }


    /**
     *Set Text Color
     */
    public void setTextColor(int color) {
        textPaint.setColor(color);
    }

    public void setBoundaryValueColor(int color) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            boundaryValuePaint.setTypeface(getResources().getFont(R.font.dinpro_regular));
            timePaint.setTypeface(getResources().getFont(R.font.dinpro_regular));
        }
        boundaryValuePaint.setColor(color);
        timePaint.setColor(color);
    }


    /**
     *Set Text Size
     */
    public void setTextSize(float textSize) {
        textPaint.setTextSize(textSize);
        boundaryValuePaint.setTextSize(textSize);
        timePaint.setTextSize(textSize);
        selectedTextPaint.setTextSize(textSize);
    }

    /**
     *Set maximum/minimum text color
     */
    public void setMTextColor(int color) {
        maxMinPaint.setColor(color);
    }

    /**
     *Set maximum/minimum text size
     */
    public void setMTextSize(float textSize) {
        maxMinPaint.setTextSize(textSize);
    }

    /**
     *Set Background Color
     */
    @Override
    public void setBackgroundColor(int color) {
        bgPaint.setColor(color);
    }

    //Set Gradient Background Color
    public void setLinearGradientColor(Rect rect,int ...colors){
        mBgRect = rect;
        bgPaint.setShader(new LinearGradient(0, 0, 0, mBgRect.bottom, colors[0], colors[1], Shader.TileMode.MIRROR));
    }

    /**
     *Set the selected point value to display the background
     */
    public void setSelectPointColor(int color) {
        selectPointPaint.setColor(color);
    }

    /**
     *Monitoring when the selected point changes
     */
    public interface OnSelectedChangedListener {
        /**
         *When the selected point changes
         *
         *@param view Current view
         *@param point Selected point
         *@param index The index of the selected point
         */
        void onSelectedChanged(CpBaseKLineChartView view, Object point, int index);
    }

    /**
     *Get Text Size
     */
    public float getTextSize() {
        return textPaint.getTextSize();
    }

    /**
     *Get Curve Width
     */
    public float getLineWidth() {
        return mLineWidth;
    }

    /**
     *Set the width of the curve
     */
    public void setLineWidth(float lineWidth) {
        mLineWidth = lineWidth;
    }

    /**
     *Set the width of each point
     */
    public void setPointWidth(float pointWidth) {
        this.pointWidth = pointWidth;
    }

    public Paint getGridPaint() {
        return gridPaint;
    }

    public Paint getTextPaint() {
        return textPaint;
    }

    public Paint getBackgroundPaint() {
        return bgPaint;
    }

    public int getDisplayHeight() {
        return displayHeight + topPadding + bottomPadding;
    }


    private void renderPriceLine(Canvas canvas, float tempRight) {
        float y = getMainY(lastPrice);
        ChainUpLogUtil.e("lastPrice : Y轴", y + "");
        ChainUpLogUtil.e("lastPrice : tempRight", tempRight + "");
        String priceText = formatValueWithPrecision(lastPrice,mPricePrecision);
        float textWidth = textPaint.measureText(priceText);
        float textLeft = tempRight - textWidth - 13f;
        float klineRight = getX(stopIndex);
        ChainUpLogUtil.e("lastPrice : klineRight", klineRight + "");
        if (stopIndex == itemCount - 1) {
//            float toRight = (this.mainRect.width() * 4) / 5 + this.mScrollX;
            float toRight = translateXtoX(getX(stopIndex));
//            LogUtil.e("lastPrice : tempRight Line", toRight + "");
//            canvas.drawLine(toRight, y, ((float) this.mainRect.width()) - textWidth, y, this.priceLinePaint);
//            renderRightPriceLabel(canvas, y, priceText, textWidth, textLeft);
//            showPriceLabelInLine = false;

            renderDotLine(canvas, toRight, ((float) this.mainRect.width()) - textWidth - priceLineMarginPriceLabel- CpDisplayUtil.INSTANCE.dip2px(10f), y, priceLineRightPaint);
            renderRightPriceLabel(canvas, y, priceText, textWidth, ((float) this.mainRect.width()) - textWidth - priceLineMarginPriceLabel);
            showPriceLabelInLine = false;
            return;
        }
        if (y < getMainY(mainMaxValue)) {
            y = getMainY(mainMaxValue);
        }
        if (y > getMainY(mainMinValue)) {
            y = getMainY(mainMinValue);
        }
        renderDotLine(canvas, 0, ((float) this.mainRect.width()) - textWidth - priceLineMarginPriceLabel- CpDisplayUtil.INSTANCE.dip2px(10f), y, priceLinePaint);
        float halfPriceBoxHeight = priceLabelInLineBoxHeight / 2;
        priceLabelInLineBoxRight = tempRight - priceLineBoxMarginRight;
        priceLabelInLineBoxLeft = priceLabelInLineBoxRight - textWidth - priceShapeWidth - priceLineBoxPadidng * 2 - priceBoxShapeTextMargin;
        priceLabelInLineBoxTop = y - halfPriceBoxHeight;
        priceLabelInLineBoxBottom = y + halfPriceBoxHeight;
        renderPriceLabelInPriceLine(canvas,
                priceLabelInLineBoxLeft,
                priceLabelInLineBoxTop,
                priceLabelInLineBoxRight,
                priceLabelInLineBoxBottom,
                priceLabelInLineBoxRadius,
                y,
                priceText);
        showPriceLabelInLine = true;

    }

    @Override
    public boolean onSingleTapUp(MotionEvent e) {
        if (priceLabelInLineClickable && showPriceLabelInLine) {
//            float x = xToTranslateXBuff(e.getX());
            float x = e.getX();
            float y = e.getY();
            if (priceLabelInLineBoxTop < y && priceLabelInLineBoxBottom > y && priceLabelInLineBoxLeft < x && priceLabelInLineBoxRight > x) {
                mScrollX = (int) getMaxTranslateX() - (int) columnSpace;
                setTranslateXFromScrollX(mScrollX);
                return true;
            }
        }
        return super.onSingleTapUp(e);

    }

    /**
     *Horizontal screen price line
     *
     * @param canvas canvas
     * @param y      y
     */
    private void renderDotLine(Canvas canvas, float left, float right, float y, Paint paint) {
        float dotWidth = priceDotLineItemWidth + priceDotLineItemSpace;
        for (; left < right; left += dotWidth) {
            canvas.drawLine(left, y, left + priceDotLineItemWidth, y, paint);
        }
    }

    /**
     *Right side of price line label
     *
     * @param canvas      canvas
     * @param y           y
     * @param priceString priceString
     * @param textWidth   textWidth
     * @param textLeft    textLeft
     */
    private void renderRightPriceLabel(Canvas canvas, float y, String priceString, float textWidth, float textLeft) {

        textLeft = textLeft - CpDisplayUtil.INSTANCE.dip2px(5f);
        float halfTextHeight = textHeight / 2;
        float top = y - halfTextHeight;

        float textPosition = Math.max((top + baseLine), baseLine);
        float rectTopPosition = Math.max(top, baseLine);
        float rectBottomPosition = Math.max((int) (y + halfTextHeight), (int) (baseLine + halfTextHeight));

//        rightPriceBoxPaint.setColor(CpColorUtil.INSTANCE.getColorByMode(R.color.right_price_box_color_day));
        rightPriceBoxPaint.setColor(ContextCompat.getColor(getContext(),R.color.main_color));
        canvas.drawRoundRect(new RectF((int) textLeft - CpDisplayUtil.INSTANCE.dip2px(8f), (int)rectTopPosition, (int) (textLeft + textWidth), (int)rectBottomPosition),5f,5f,rightPriceBoxPaint);
        priceLineRightTextPaint.setColor(ContextCompat.getColor(getContext(),R.color.white));
        priceLineRightTextPaint.setTextSize(CpSizeUtils.dp2px(10f));
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            priceLineRightTextPaint.setTypeface(getResources().getFont(R.font.dinpro_regular));
        }
        canvas.drawText(priceString, textLeft - CpDisplayUtil.INSTANCE.dip2px(4f), textPosition, priceLineRightTextPaint);
    }

    /**
     *Price label on the price line
     *
     * @param canvas    canvas
     * @param y         y
     * @param priceText priceText
     */
    private void renderPriceLabelInPriceLine(Canvas canvas, float boxLeft, float boxTop, float boxRight, float boxBottom, float rectRadius, float y, String priceText) {
        canvas.drawRoundRect(new RectF(boxLeft, boxTop, boxRight, boxBottom), rectRadius, rectRadius, priceLineBoxBgPaint);
//        canvas.drawRoundRect(new RectF(boxLeft, boxTop, boxRight, boxBottom), rectRadius, rectRadius, priceLineBoxPaint);
//        float temp = priceShapeHeight / 2;
//        float shapeLeft = boxRight - priceShapeWidth - priceLineBoxPadidng;
        //Price Line Triangle
//        Path shape = new Path();
//        shape.moveTo(shapeLeft, y - temp);
//        shape.lineTo(shapeLeft, y + temp);
//        shape.lineTo(shapeLeft + priceShapeWidth, y);
//        shape.close();
        Bitmap bitmap = BitmapFactory.decodeResource(getContext().getResources(),R.mipmap.public_ic_kline_price_more);
        int topPosition = (int) ((((boxBottom - boxTop) - bitmap.getHeight()) / 2) + boxTop);
        canvas.drawBitmap(bitmap,boxRight - bitmap.getWidth() - priceLineBoxPadidng,topPosition,labelInPriceLinePaint);

//        canvas.drawPath(shape, labelInPriceLinePaint);
        labelInPriceLinePaint.setColor(ContextCompat.getColor(CpMyApp.Companion.instance(), R.color.text_color_2));
        labelInPriceLinePaint.setTextSize(CpSizeUtils.dp2px(10f));
        canvas.drawText(priceText, boxLeft + priceLineBoxPadidng, (y + (textHeight / 2 - textDecent)), labelInPriceLinePaint);
    }

    /**
     *Do not refresh the page repeatedly within 15 milliseconds
     */
    public void animInvalidate() {
        if (System.currentTimeMillis() - time > 15) {
            invalidate();
            time = System.currentTimeMillis();
        }
    }

    public int getViceDrawStatus() {
        return childDrawPosition;
    }



    @Override
    public boolean dispatchTouchEvent(MotionEvent ev) {

        if (ev.getAction() == MotionEvent.ACTION_DOWN) {
            if (isLongPress) {
                isLongPress = false;
                invalidate();
                return true;
            }
        }

        return super.dispatchTouchEvent(ev);
    }

}
