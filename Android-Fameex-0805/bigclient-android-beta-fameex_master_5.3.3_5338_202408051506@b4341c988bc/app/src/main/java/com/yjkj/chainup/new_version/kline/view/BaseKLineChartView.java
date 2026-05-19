package com.yjkj.chainup.new_version.kline.view;

import android.animation.ValueAnimator;
import android.content.Context;
import android.database.DataSetObserver;
import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.Matrix;
import android.graphics.Paint;
import android.graphics.Path;
import android.graphics.Rect;
import android.graphics.RectF;
import android.graphics.drawable.Drawable;
import android.os.Build;
import android.os.Handler;
import android.os.Looper;
import android.util.AttributeSet;
import android.util.Log;
import android.util.Pair;
import android.view.MotionEvent;
import android.view.ScaleGestureDetector;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.core.content.ContextCompat;
import androidx.core.view.GestureDetectorCompat;

import com.bumptech.glide.Glide;
import com.bumptech.glide.request.target.CustomTarget;
import com.bumptech.glide.request.transition.Transition;
import com.chainup.contract.utils.CpDisplayUtil;
import com.chainup.contract.utils.CpSizeUtils;
import com.yjkj.chainup.R;
import com.yjkj.chainup.app.ChainUpApp;
import com.yjkj.chainup.db.service.PublicInfoDataService;
import com.yjkj.chainup.kline.view.MainKLineView;
import com.yjkj.chainup.kline.view.vice.KDJView;
import com.yjkj.chainup.net.api.ApiConstants;
import com.yjkj.chainup.new_version.kline.base.IChartViewDraw;
import com.yjkj.chainup.new_version.kline.base.IDateFormatter;
import com.yjkj.chainup.new_version.kline.base.IValueFormatter;
import com.yjkj.chainup.new_version.kline.bean.CpIKLine;
import com.yjkj.chainup.new_version.kline.bean.IKLine;
import com.yjkj.chainup.new_version.kline.data.IAdapter;
import com.yjkj.chainup.new_version.kline.formatter.CpValueFormatter;
import com.yjkj.chainup.new_version.kline.formatter.DateFormatter;
import com.yjkj.chainup.new_version.kline.formatter.ValueFormatter;
import com.yjkj.chainup.new_version.kline.view.vice.MACDView;
import com.yjkj.chainup.new_version.kline.view.vice.RSIView;
import com.yjkj.chainup.new_version.kline.view.vice.WRView;
import com.yjkj.chainup.util.BigDecimalUtil;
import com.yjkj.chainup.util.BigDecimalUtils;
import com.yjkj.chainup.util.ColorUtil;
import com.yjkj.chainup.util.DisplayUtil;
import com.yjkj.chainup.util.LogUtil;
import com.yjkj.chainup.util.SizeUtils;
import com.yjkj.chainup.wedegit.ViewUtil;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

/**
 *K-line diagram
 *
 * @author Bertking
 * @Date 2023/3/12-3:35 PM
 *@description: Set the size of all text to be equal
 */
public abstract class BaseKLineChartView extends ScrollAndScaleView {
    public static final String TAG = BaseKLineChartView.class.getSimpleName();

    Matrix matrix = new Matrix();
    protected String waterImageUrl;
    private int childDrawPosition = -1;

    private int mPricePrecision = -1;

    private float translateX = Float.MIN_VALUE;

    private int width = 0;

    private boolean isDrawMarker = true;

    private int topPadding;
    private int childPadding;
    private int bottomPadding;
    private float columnSpace = 0;
    /**
     *Zoom ratio
     */
    private float mainScaleY = 1;

    private float volScaleY = 1;

    private float childScaleY = 1;

    /**
     *The width occupied by all data
     */
    private float dataLen = 0;


    /**
     *Maximum and minimum values on the right side of Kline (scale)
     */
    private float mainMaxValue = Float.MAX_VALUE;

    private float mainMinValue = Float.MIN_VALUE;


    /**
     *The maximum and minimum values of the Kline line
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
    /**
     *Grid brush
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
     *Time brush
     */
    private Paint timePaint = new Paint(Paint.ANTI_ALIAS_FLAG);

    /**
     *The maximum value on the K-line
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

    private IChartViewDraw mMainDraw;
    private MACDView mMACDView;
    private WRView mWRView;
    private RSIView mRSIView;
    private KDJView mKDJView;
    private MainKLineView mainDraw;
    private IChartViewDraw mVolDraw;

    private IAdapter mAdapter;

    private Boolean isWR = false;
    /**
     *That is, whether the sub image indicators are displayed
     */
    private Boolean isShowChild = false;


    /**
     *Price Line Brush
     */
    protected Paint priceLinePaint = new Paint(Paint.ANTI_ALIAS_FLAG);

    /**
     *Current price border brush
     */
    protected Paint priceLineBoxPaint = new Paint(Paint.ANTI_ALIAS_FLAG);

    /**
     *Current price background brush
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
     *Dashed brush on the right side of the price line
     */
    protected Paint priceLineRightPaint = new Paint(Paint.ANTI_ALIAS_FLAG);

    protected Paint rightPriceBoxPaint = new Paint(Paint.ANTI_ALIAS_FLAG);

    /**
     *Dashed brush on the right side of the price line
     */
    protected Paint priceLineRightTextPaint = new Paint(Paint.ANTI_ALIAS_FLAG);

    /**
     *Price Box Height
     */
    protected float priceLabelInLineBoxHeight = 40;

    /**
     *Fillet radius of price box
     */
    protected float priceLabelInLineBoxRadius = 20;

    /**
     *Price box inner margin
     */
    protected float priceLineBoxPadidng = 20;

    /**
     *The height of the price line graph
     */
    protected float priceShapeHeight = 20;


    /**
     *The width of the price line graph
     */
    protected float priceShapeWidth = 10;

    /**
     *The spacing between price line text and graphics
     */
    protected float priceBoxShapeTextMargin = 10;


    protected float labelSpace = 130;

    /**
     *The distance between the text box of the price line and the margin on the right side of the screen
     */
    protected float priceLineBoxMarginRight = 120;

    protected float priceLineMarginPriceLabel = 5;

    protected float priceDotLineItemWidth = 8f;
    protected float priceDotLineItemSpace = 4f;

    protected boolean showPriceLabelInLine;
    protected boolean priceLabelInLineClickable = true;
    protected float priceLabelInLineBoxRight, priceLabelInLineBoxLeft, priceLabelInLineBoxTop, priceLabelInLineBoxBottom;
    float priceLabelInLineBoxLeftBuff = 0f, priceLabelInLineBoxRightBuff = 0f;
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
     *Unified Text Foundation Line
     */
    protected float baseLine;
    /**
     *The latest price of the current K-line
     */
    protected float lastPrice;

    /**
     *The radius of the tail point of the time sharing line
     */
    protected float lineEndRadius = SizeUtils.dp2px(3f);

    /**
     *The radius of the shadow on the timeline
     */
    private float endShadowLayerWidth;

    /**
     *The radius of the tail point of the time sharing line
     */
    protected float lineEndMaxMultiply = SizeUtils.dp2px(2f);


    private DataSetObserver mDataSetObserver = new DataSetObserver() {
        @Override
        public void onChanged() {
            itemCount = getAdapter().getCount();
            IKLine mIKLine = (IKLine) getItem(itemCount);
            lastPrice = mIKLine.getClosePrice();


            notifyChanged();
        }

        @Override
        public void onInvalidated() {
            itemCount = getAdapter().getCount();
            notifyChanged();
        }
    };

    /**
     *How many pieces of data are there in total
     */
    private int itemCount;

    private IChartViewDraw childDraw;
    private List<IChartViewDraw> childDraws = new ArrayList<>();

    private IValueFormatter valueFormatter;
    private IDateFormatter dateTimeFormatter;

    private ValueAnimator animator;

    private long animationDuration = 100;

    private float overScrollRange = 0;

    private OnSelectedChangedListener mOnSelectedChangedListener = null;


    /**
     *To draw 3 subgraphs
     *1 Main KLine diagram
     *2 Trading volume chart
     *3 Subplot
     */
    private Rect mainRect;

    private Rect volRect;

    private Rect childRect;

    int displayHeight = 0;
    int displayWidth = 0;

    private float mLineWidth;

    public BaseKLineChartView(Context context) {
        super(context);
        init();
    }

    public BaseKLineChartView(Context context, AttributeSet attrs) {
        super(context, attrs);
        init();
    }

    public BaseKLineChartView(Context context, AttributeSet attrs, int defStyleAttr) {
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

        priceLineRightPaint.setStrokeWidth(SizeUtils.dp2px(0.8f));
        priceLineRightPaint.setTextSize(SizeUtils.dp2px(10f));
        priceLineRightPaint.setColor(ColorUtil.INSTANCE.getColorByMode(R.color.main_color,true));

        priceLinePaint.setStrokeWidth(SizeUtils.dp2px(0.8f));
        priceLinePaint.setStyle(Paint.Style.STROKE);

        priceLinePaint.setColor(ColorUtil.INSTANCE.getColorByMode(R.color.price_line_color_day,true));
        priceLineBoxPaint.setColor(ColorUtil.INSTANCE.getColorByMode(R.color.price_line_color_day,true));
        priceLineBoxBgPaint.setColor(ColorUtil.INSTANCE.getColorByMode(R.color.price_text_color_day,true));


        /**
         *Border settings for selected values
         */
        selectorFramePaint.setStrokeWidth(DisplayUtil.INSTANCE.dip2px(0.6f));
        selectorFramePaint.setStyle(Paint.Style.STROKE);
        selectorFramePaint.setColor(ContextCompat.getColor(getContext(), R.color.chart_selected_indicator));

    }


    @Override
    protected void onSizeChanged(int w, int h, int oldw, int oldh) {
        super.onSizeChanged(w, h, oldw, oldh);

        this.width = w;
//        displayWidth = (int) (width * 0.8f);
        displayWidth = width;
        displayHeight = h - topPadding - bottomPadding;
        initRect();
        setTranslateXFromScrollX(mScrollX);
    }


    /**
     *Fire Coin Rules
     *Set whether there are subgraphs
     *1 has subgraphs -0.6 | 0.2 | 0.2
     *2 No subgraphs -0.8 | 0.2
     */
    private void initRect() {
        setOverScrollRange(width * 0.2f);
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
            int mMainHeight = (int) (displayHeight * 0.8f);
            int mVolHeight = (int) (displayHeight * 0.2f);
            mainRect = new Rect(0, topPadding, displayWidth, topPadding + mMainHeight);
            volRect = new Rect(0, mainRect.bottom + childPadding, displayWidth, mainRect.bottom + mVolHeight);
        }
    }

    @Override
    protected void onDraw(Canvas canvas) {
        super.onDraw(canvas);
        canvas.drawColor(bgPaint.getColor());
        if (width == 0 || mainRect.height() == 0 || itemCount == 0) {

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
        // logo
        drawWaterBitmap(canvas);
        float tempLeft = -translateX;
//        canvas.save();
//        canvas.translate(translateX, 0);

//        canvas.restore();

        /**
         *Draw K line
         */
        drawK(canvas);

        drawText(canvas);

        drawMaxAndMin(canvas);
        renderPriceLine(canvas, tempLeft + displayWidth);
        drawValue(canvas, isLongPress ? selectedIndex : stopIndex);
        canvas.restore();
    }

    public float getMainY(float value) {
        return (mainMaxValue - value) * mainScaleY + mainRect.top;
    }

    public float getMainBottom() {
        return mainRect.bottom;
    }

    public float getVolY(float value) {
        Log.d("=====getVolY======", "max:" + volMaxValue + ",scale:" + volScaleY + ",top:" + volRect.top);
        return (volMaxValue - value) * volScaleY + volRect.top;
    }

    public float getChildY(float value) {
        Log.d("=====getChildY======", "max:" + (childMaxValue - value) + ",scale:" + childScaleY + ",top:" + childRect.top);
        return (childMaxValue - value) * childScaleY + childRect.top;
    }

    /**
     *Solving the problem of text centering
     */
    public float fixTextY(float y) {
        Paint.FontMetrics fontMetrics = textPaint.getFontMetrics();
        return y + fontMetrics.descent - fontMetrics.ascent;
    }

    /**
     *Solving the problem of text centering
     */
    public float fixTextY1(float y) {
        Paint.FontMetrics fontMetrics = textPaint.getFontMetrics();
        return (y + (fontMetrics.descent - fontMetrics.ascent) / 2 - fontMetrics.descent);
    }

    /**
     *Draw a table
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
         *------- Lower Square Subgraph------------------------
         *If there is a childView: Draw the line at the bottom of the trading volume and the line at the bottom of the subgraph
         */
        if (childDraw != null) {
            canvas.drawLine(0, volRect.bottom, width, volRect.bottom, gridPaint);
            canvas.drawLine(0, childRect.bottom, width, childRect.bottom, gridPaint);
        } else {
            canvas.drawLine(0, volRect.bottom, width, volRect.bottom, gridPaint);
        }

        //Vertical grid

        columnSpace = width / gridColumns;
        for (int i = 1; i < gridColumns; i++) {
            canvas.drawLine(columnSpace * i, 0, columnSpace * i, mainRect.bottom, gridPaint);
            canvas.drawLine(columnSpace * i, mainRect.bottom, columnSpace * i, volRect.bottom, gridPaint);
            if (childDraw != null) {
                /**
                 *From the bottom of Volu to the bottom of the sub image
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
        //Save previous pan, zoom
        canvas.save();
        Log.d(TAG, "tranX:" + translateX + ",scaleX =" + mScaleX +
                ", startIndex =" + startIndex + ",stopIndex=" + stopIndex);
        canvas.translate(translateX * mScaleX, 0);
        canvas.scale(mScaleX, 1);
        for (int i = startIndex; i <= stopIndex; i++) {
            /**
             *Obtain the corresponding item based on the subscript
             */
            Object currentPoint = getItem(i);
            /**
             *Obtain the corresponding X-axis position based on the subscript
             */
            float currentPointX = getX(i);

            /**
             *Last Item
             */
            Object lastPoint = i == 0 ? currentPoint : getItem(i - 1);

            float lastX = i == 0 ? currentPointX : getX(i - 1);

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
         *Draw the selected part of the candle line
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
            //Bar chart vertical line
            canvas.drawLine(x, mainRect.bottom, x, volRect.bottom, selectedYLinePaint);

            /**
             *Long press to select the intersection of X&Y, draw a circle
             *TODO may need to configure colors and sizes
             */
//            canvas.drawCircle(x, y, 10f, selectedTextPaint);
//
//            canvas.drawCircle(x, y, 30f, selectedYLinePaint);

            if (childDraw != null) {
                //Subline Vertical
                canvas.drawLine(x, volRect.bottom, x, childRect.bottom, selectedYLinePaint);
            }
        }
//        float tempLeft = -translateX;
//        renderPriceLine(canvas,tempLeft+displayWidth);
        //Restore Pan Zoom
        canvas.restore();
    }

    Pair<Float,Float> getLongPressPositionY(){
        float positionYScale = Math.min((longPressPositionY-topPadding) / mainRect.height(),1);
        float value = (mainMaxValue - mainMinValue) * (1 - positionYScale);
        float cprice = mainMinValue + value;
        float y = getMainY(cprice);
        return new Pair<>(y,cprice);
    }


    /**
     *Calculate Text Length
     *
     * @return
     */
    private int calculateWidth(String text) {
        Rect rect = new Rect();
        textPaint.getTextBounds(text, 0, text.length(), rect);
        return rect.width() + 5;
    }

    /**
     *Calculate Text Length
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

        /***--------------Draw the values on the right side of the k-line graph-------------**/



        if (mMainDraw != null) {
            if (mPricePrecision != -1) {
                mainMaxValue = Float.parseFloat(BigDecimalUtils.showSNormal(String.valueOf(mainMaxValue), mPricePrecision));
                mainMinValue = Float.parseFloat(BigDecimalUtils.showSNormal(String.valueOf(mainMinValue), mPricePrecision));
            }
            canvas.drawText(formatValue(mainMaxValue), width - calculateWidth(formatValue(mainMaxValue)) - DisplayUtil.INSTANCE.dip2px(5f), baseLine + mainRect.top, boundaryValuePaint);
            canvas.drawText(formatValue(mainMinValue), width - calculateWidth(formatValue(mainMinValue)) - DisplayUtil.INSTANCE.dip2px(5f), mainRect.bottom - textHeight + baseLine, boundaryValuePaint);
            float rowValue = (mainMaxValue - mainMinValue) / gridRows;
            float rowSpace = mainRect.height() / gridRows;
            String text = "";
            for (int i = 1; i < gridRows; i++) {
                if (mPricePrecision != -1) {
                    text = BigDecimalUtils.showSNormal((rowValue * (gridRows - i) + mainMinValue) + "", mPricePrecision);
                } else {
                    text = formatValue(rowValue * (gridRows - i) + mainMinValue);
                }
//                String text = formatValue(rowValue * (gridRows - i) + mainMinValue);
                canvas.drawText(text, width - calculateWidth(text) - DisplayUtil.INSTANCE.dip2px(5f), fixTextY(rowSpace * i + mainRect.top), boundaryValuePaint);
            }
        }
        /**--------------The value of the subgraph in the drawing-------------**/
        if (mVolDraw != null) {
            /**
             *Draw maximum value
             */
            canvas.drawText(mVolDraw.getValueFormatter().format(volMaxValue),
                    width - calculateWidth(formatValue(volMaxValue)) - DisplayUtil.INSTANCE.dip2px(5f), mainRect.bottom + baseLine, boundaryValuePaint);
            /**
             *Draw minimum value
             */
//            canvas.drawText(mVolDraw.getValueFormatter().format(volMinValue),
//                    width - calculateWidth(formatValue(volMinValue))-DisplayUtil.INSTANCE.dip2px(15f), volRect.bottom, boundaryValuePaint);
        }

        /**--------------Draw the values of the square subgraph-------------**/
        if (childDraw != null) {
            childMaxValue= Float.valueOf(new BigDecimal(childMaxValue).setScale(5,2).toPlainString());
            canvas.drawText(childDraw.getValueFormatter().format(childMaxValue),
                    width - calculateWidth(formatValue(childMaxValue)) - DisplayUtil.INSTANCE.dip2px(15f), volRect.bottom + baseLine, boundaryValuePaint);
            /**
             *Draw minimum value
             */
            canvas.drawText(childDraw.getValueFormatter().format(childMinValue),
                    width - calculateWidth(formatValue(childMinValue)) - DisplayUtil.INSTANCE.dip2px(15f), childRect.bottom, boundaryValuePaint);
        }

        /**--------------Draw time---------------------**/
        float columnSpace = width / gridColumns;
        float y;
        if (isShowChild) {
            y = childRect.bottom + baseLine + 5;
        } else {
            y = volRect.bottom + baseLine + 5;
        }

        float startX = getX(startIndex) - pointWidth / 2;
        float stopX = getX(stopIndex) + pointWidth / 2;

        for (int i = 1; i < gridColumns; i++) {
            float translateX = xToTranslateX(columnSpace * i);
            if (translateX >= startX && translateX <= stopX) {
                int index = indexOfTranslateX(translateX);
                String text = mAdapter.getDate(index);
                if (i == 1) {

                }
                canvas.drawText(text, columnSpace * i - timePaint.measureText(text) / 2, y, timePaint);
            }
        }

        float translateX = xToTranslateX(0);
        if (translateX >= startX && translateX <= stopX) {

//            canvas.drawText(getAdapter().getDate(startIndex).split(" ")[1], 0, y, timePaint);
            canvas.drawText(getAdapter().getDate(startIndex), 0, y, timePaint);
        }


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
            IKLine point = (IKLine) getItem(selectedIndex);
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
    public String formatValueWithPrecision(float value,int precision) {
        return new CpValueFormatter(precision).format(value);
    }

    /**
     *Draw the maximum and minimum values of the Kline line
     *
     * @param canvas
     */
    private void drawMaxAndMin(Canvas canvas) {
        if (!mainDraw.isLine()) {
            IKLine maxEntry = null, minEntry = null;
            boolean firstInit = true;

            //Draw maximum and minimum values
            float x = translateXtoX(getX(mainMinIndex));

            float y = getMainY(mainLowMinValue);
            String LowString = "── " + BigDecimalUtils.showSNormal(String.valueOf(mainLowMinValue));
            //Calculate display position
            //Calculate text width
            int lowStringWidth = calculateMaxMin(LowString).width();
            int lowStringHeight = calculateMaxMin(LowString).height();
            if (x < getWidth() / 2) {
                //Draw Right
                canvas.drawText(LowString, x, y + lowStringHeight / 2, maxMinPaint);
            } else {
                //Draw Left
                LowString = BigDecimalUtils.showSNormal(String.valueOf(mainLowMinValue)) + " ──";
                canvas.drawText(LowString, x - lowStringWidth, y + lowStringHeight / 2, maxMinPaint);
            }

            x = translateXtoX(getX(mainMaxIndex));

            y = getMainY(mainHighMaxValue);

            /**
             *Maximum value
             */
            String highString = "── " + BigDecimalUtils.showSNormal(String.valueOf(mainHighMaxValue));

            int highStringWidth = calculateMaxMin(highString).width();
            int highStringHeight = calculateMaxMin(highString).height();

            if (x < getWidth() / 2) {
                //Draw Right
                canvas.drawText(highString, x, y + highStringHeight / 2, maxMinPaint);
            } else {
                //Draw Left
                highString = BigDecimalUtils.showSNormal(String.valueOf(mainHighMaxValue)) + " ──";
                canvas.drawText(highString, x - highStringWidth, y + highStringHeight / 2, maxMinPaint);

            }

        }
    }

    /**
     *Draw Value
     *
     * @param canvas
     *@param position displays the value of a certain point
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
                childDraw.drawText(canvas, this, position, 0, y);
            }
        }
    }


    /**
     *Format Value
     */
    public String formatValue(float value) {
        if (getValueFormatter() == null) {
            setValueFormatter(new ValueFormatter());
        }
        return getValueFormatter().format(value);
    }

    /**
     *Format Value
     */
    public String formatContractValue(float value) {
        if (getValueFormatter() == null) {
            setValueFormatter(new ValueFormatter());
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


//        stopIndex = indexOfTranslateX(xToTranslateX(displayWidth));

        mainMaxIndex = startIndex;
        mainMinIndex = startIndex;


        /**
         *The largest and highest price
         */
        mainHighMaxValue = Float.MIN_VALUE;
        /**
         *Lowest lowest price
         */
        mainLowMinValue = Float.MAX_VALUE;

        for (int i = startIndex; i <= stopIndex; i++) {
            IKLine point = (IKLine) getItem(i);
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
             *Determine the maximum value of subgraph -
             */
            if (childDraw != null) {
                childMaxValue = Math.max(childMaxValue, childDraw.getMaxValue(point));
                childMinValue = Math.min(childMinValue, childDraw.getMinValue(point));

            }

        }


        if (mainMaxValue != mainMinValue) {
            float padding = (mainMaxValue - mainMinValue) * 0.05f;
            mainMaxValue += padding;
            mainMinValue -= padding;
        } else {
            //When the maximum and minimum values are equal, increase the maximum and decrease the minimum values respectively
            mainMaxValue += Math.abs(mainMaxValue * 0.05f);
            mainMinValue -= Math.abs(mainMinValue * 0.05f);
            if (mainMaxValue == 0) {
                mainMaxValue = 1;
            }
        }

        if (Math.abs(volMaxValue) < 0.01) {
            volMaxValue = 15.00f;
        }

        if (childMaxValue.equals(childMinValue)) {
            //When the maximum and minimum values are equal, increase the maximum and decrease the minimum values respectively
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
     *Obtain the minimum value of translation
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
     *Obtain the maximum value of translation
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
     *Draw lines in the main area
     *
     *Horizontal coordinate of the starting point of @param startX
     *The value of the starting point of @param stopX
     *@param stopX The abscissa of the end point
     *@param stopValue The value of the end point
     */
    public void drawMainLine(Canvas canvas, Paint paint, float startX, float startValue, float stopX, float stopValue) {
        canvas.drawLine(startX, getMainY(startValue), stopX, getMainY(stopValue), paint);
    }


    /**
     *Draw a timeline in the main area
     *
     *Horizontal coordinate of the starting point of @param startX
     *The value of the starting point of @param stopX
     *@param stopX The abscissa of the end point
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
     *Horizontal coordinate of the starting point of @param startX
     *@param startValue The value of the starting point
     *@param stopX The abscissa of the end point
     *@param stopValue The value of the end point
     */
    public void drawChildLine(Canvas canvas, Paint paint, float startX, float startValue, float stopX, float stopValue) {
        canvas.drawLine(startX, getChildY(startValue), stopX, getChildY(stopValue), paint);
    }

    /**
     *Draw lines in sub areas
     *
     *Horizontal coordinate of the starting point of @param startX
     *@param startValue The value of the starting point
     *@param stopX The abscissa of the end point
     *@param stopValue The value of the end point
     */
    public void drawVolLine(Canvas canvas, Paint paint, float startX, float startValue, float stopX, float stopValue) {
        canvas.drawLine(startX, getVolY(startValue), stopX, getVolY(stopValue), paint);
    }

    /**
     *Retrieve entities based on index
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
     *Take the x coordinate based on the index index
     *
     *@param position index value
     * @return
     */
    public float getX(int position) {
        return position * pointWidth;
    }

    /**
     *Get adapter
     *
     * @return
     */
    public IAdapter getAdapter() {
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
     *Setting Precision
     *
     * @param position
     */
    public void setPricePrecision(int position) {
        mPricePrecision = position;
        if (mainDraw != null) {
            mainDraw.setMaPricePrecision(position);
        }
        if (mMACDView != null) {
            mMACDView.setMaPricePrecision(position);
        }
        if (mWRView != null) {
            mWRView.setMaPricePrecision(position);
        }
        if (mRSIView != null) {
            mRSIView.setMaPricePrecision(position);
        }
        if (mKDJView != null) {
            mKDJView.setMaPricePrecision(position);
        }
    }


    /**
     *Hide subgraph
     */
    public void hideChildDraw() {
        childDrawPosition = -1;
        isShowChild = false;
        childDraw = null;
        initRect();
        invalidate();
    }

    /**
     *Add drawing methods to sub regions
     *
     * @param childDraw IChartViewDraw
     */
    public void addChildDraw(IChartViewDraw childDraw) {
        childDraws.add(childDraw);
    }

    /**
     *Convert scrollX to TranslateX
     *
     * @param scrollX
     */
    private void setTranslateXFromScrollX(int scrollX) {
        translateX = scrollX + getMinTranslateX();
    }

    /**
     *Get ValueFormatter
     *
     * @return
     */
    public IValueFormatter getValueFormatter() {
        return valueFormatter;
    }

    /**
     *Set ValueFormatter
     *
     *@param valueFormatter value formatter
     */
    public void setValueFormatter(IValueFormatter valueFormatter) {
        this.valueFormatter = valueFormatter;
    }

    /**
     *Get DatetimeFormatter
     *
     *@return Time Formatter
     */
    public IDateFormatter getDateTimeFormatter() {
        return dateTimeFormatter;
    }

    /**
     *Set the dateTimeFormatter
     *
     *@param dateTimeFormatter Time Formatter
     */
    public void setDateTimeFormatter(IDateFormatter dateTimeFormatter) {
        this.dateTimeFormatter = dateTimeFormatter;
    }

    /**
     *Format Time
     *
     * @param date
     */
    public String formatDateTime(Date date) {
        if (getDateTimeFormatter() == null) {
            setDateTimeFormatter(new DateFormatter());
        }
        return getDateTimeFormatter().format(date);
    }

    /**
     *Obtain IChartViewDraw for the main area
     *
     * @return IChartViewDraw
     */
    public IChartViewDraw getMainDraw() {
        return mMainDraw;
    }

    /**
     *Set IChartViewDraw for the main area
     *
     * @param mainDraw IChartViewDraw
     */
    public void setMainDraw(IChartViewDraw mainDraw) {
        mMainDraw = mainDraw;
        this.mainDraw = (MainKLineView) mMainDraw;
    }
    public void setMACDView(MACDView macdView) {
        mMACDView = macdView;
    }
    public void setWRView(WRView wrView) {
        mWRView = wrView;
    }
    public void setKDJDraw(KDJView KkdjView) {
        mKDJView = KkdjView;
    }
    public void setRSIDraw(RSIView rsiView) {
        mRSIView = rsiView;
    }

    public IChartViewDraw getVolDraw() {
        return mVolDraw;
    }

    public void setVolDraw(IChartViewDraw mVolDraw) {
        this.mVolDraw = mVolDraw;
    }

    /**
     *Index for binary search of the current value
     *TODO recursive call (may cause stack overflow)
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
    public void setAdapter(IAdapter adapter) {
        if (mAdapter != null && mDataSetObserver != null) {
            mAdapter.unregisterDataSetObserver(mDataSetObserver);
        }
        mAdapter = adapter;
        if (mAdapter != null) {
            mAdapter.registerDataSetObserver(mDataSetObserver);
            itemCount = mAdapter.getCount();

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
     *TranslateX converted to x in view
     *
     * @param translateX
     * @return
     */
    public float translateXtoX(float translateX) {
        return (translateX + this.translateX) * mScaleX;
    }

    /**
     *Obtain upper padding
     */
    public float getTopPadding() {
        return topPadding;
    }

    /**
     *Obtain upper padding
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
     *Obtain the width of the graph
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
     *Set Selection Listening
     */
    public void setOnSelectedChangedListener(OnSelectedChangedListener l) {
        this.mOnSelectedChangedListener = l;
    }

    public void onSelectedChanged(BaseKLineChartView view, Object point, int index) {
        if (this.mOnSelectedChangedListener != null) {
            mOnSelectedChangedListener.onSelectedChanged(view, point, index);
        }
    }

    /**
     *Is the data filling the screen
     *
     * @return
     */
    public boolean isFullScreen() {
        return dataLen >= width / mScaleX;
    }

    /**
     *Set the sliding range beyond the right side
     */
    public void setOverScrollRange(float overScrollRange) {
        if (overScrollRange < 0) {
            overScrollRange = 0;
        }
        this.overScrollRange = overScrollRange;
    }

    /**
     *Setting the upper padding
     *
     * @param topPadding
     */
    public void setTopPadding(int topPadding) {
        this.topPadding = topPadding;
    }

    /**
     *Setting the padding below
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

    /**
     *Set the selected point value to display the background
     */
    public void setSelectPointColor(int color) {
        selectPointPaint.setColor(color);
    }

//    @BindingAdapter("app:kc_background_color")
    public void kc_background_color(int color) {
        bgPaint.setColor(color);
    }

    public void kc_grid_line_color(int color) {
        gridPaint.setColor(color);
    }


    /**
     *Listening when the selected point changes
     */
    public interface OnSelectedChangedListener {
        /**
         *When the selected point changes
         *
         *@param view Current view
         *@param point Selected point
         *@param index The index of the selected point
         */
        void onSelectedChanged(BaseKLineChartView view, Object point, int index);
    }

    /**
     *Get Text Size
     */
    public float getTextSize() {
        return textPaint.getTextSize();
    }

    /**
     *Obtain curve width
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
        LogUtil.e("lastPrice : Y轴", y + "");
        LogUtil.e("lastPrice : tempRight", tempRight + "");
        String priceText = formatValue(lastPrice);
        float textWidth = textPaint.measureText(priceText);
        float textLeft = tempRight - textWidth - 13f;
        float klineRight = getX(stopIndex);
        boolean isEnd = stopIndex == itemCount - 1;
        LogUtil.e("lastPrice : klineRight", klineRight + " isEnd " + isEnd);
        if (isEnd) {
//            float toRight = (this.mainRect.width() * 4) / 5 + this.mScrollX;
            float toRight = translateXtoX(getX(stopIndex));
//            LogUtil.e("lastPrice : tempRight Line", toRight + "");
//            canvas.drawLine(toRight, y, ((float) this.mainRect.width()) - textWidth, y, this.priceLinePaint);
//            renderRightPriceLabel(canvas, y, priceText, textWidth, textLeft);
//            showPriceLabelInLine = false;

            renderDotLine(canvas, toRight, ((float) this.mainRect.width()) - textWidth - priceLineMarginPriceLabel, y, priceLineRightPaint);
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
        renderDotLine(canvas, 0, ((float) this.mainRect.width()) - priceLineMarginPriceLabel, y, priceLinePaint);
        float halfPriceBoxHeight = priceLabelInLineBoxHeight / 2;
        priceLabelInLineBoxRight = ((float) this.mainRect.width()) - priceLineBoxMarginRight;
        priceLabelInLineBoxRightBuff = tempRight - priceLineBoxMarginRight;
        priceLabelInLineBoxLeft = priceLabelInLineBoxRight - textWidth - priceShapeWidth - priceLineBoxPadidng * 2 - priceBoxShapeTextMargin;
        priceLabelInLineBoxLeftBuff = priceLabelInLineBoxRightBuff - textWidth - priceShapeWidth - priceLineBoxPadidng * 2 - priceBoxShapeTextMargin;
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
            float x = xToTranslateXBuff(e.getX());
            float y = e.getY();
            if (priceLabelInLineBoxTop < y && priceLabelInLineBoxBottom > y && priceLabelInLineBoxLeftBuff < x && priceLabelInLineBoxRightBuff > x) {
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
     *To the right of the price line label
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
        rightPriceBoxPaint.setColor(ContextCompat.getColor(getContext(), com.chainup.contract.R.color.main_color));
        canvas.drawRoundRect(new RectF((int) textLeft - CpDisplayUtil.INSTANCE.dip2px(8f), (int)rectTopPosition, (int) (textLeft + textWidth), (int)rectBottomPosition),5f,5f,rightPriceBoxPaint);
        priceLineRightTextPaint.setColor(ContextCompat.getColor(getContext(), com.chainup.contract.R.color.white));
        priceLineRightTextPaint.setTextSize(CpSizeUtils.dp2px(10f));
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            priceLineRightTextPaint.setTypeface(getResources().getFont(com.chainup.contract.R.font.dinpro_regular));
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
        canvas.drawRoundRect(new RectF(boxLeft, boxTop, boxRight, boxBottom), rectRadius, rectRadius, priceLineBoxPaint);
        float temp = priceShapeHeight / 2;
        float shapeLeft = boxRight - priceShapeWidth - priceLineBoxPadidng;
        //Price line triangle
        Path shape = new Path();
        shape.moveTo(shapeLeft, y - temp);
        shape.lineTo(shapeLeft, y + temp);
        shape.lineTo(shapeLeft + priceShapeWidth, y);
        shape.close();
        canvas.drawPath(shape, labelInPriceLinePaint);
        labelInPriceLinePaint.setColor(ContextCompat.getColor(ChainUpApp.appContext, R.color.price_line_color_day));
        labelInPriceLinePaint.setTextSize(SizeUtils.dp2px(10f));
        canvas.drawText(priceText, boxLeft + priceLineBoxPadidng, (y + (textHeight / 2 - textDecent)), labelInPriceLinePaint);
    }

    /**
     *Do not refresh pages repeatedly within 15 milliseconds
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

    public Bitmap mWaterBmp;
    private Paint mWaterPaint = new Paint(1);
    protected float mWaterScale;

    private void drawWaterBitmap(Canvas canvas) {
        if (this.mWaterBmp == null) {
            Glide.with(getContext()).asBitmap().load(this.waterImageUrl).into(new CustomTarget<Bitmap>() {
                @Override
                public void onResourceReady(@NonNull Bitmap bitmap, @Nullable Transition<? super Bitmap> transition) {
                    if (BaseKLineChartView.this.mWaterScale > 0.0f) {
                        BaseKLineChartView.this.matrix.reset();
                        BaseKLineChartView.this.matrix.postScale(BaseKLineChartView.this.mWaterScale, BaseKLineChartView.this.mWaterScale);
                        mWaterBmp = Bitmap.createBitmap(bitmap, 0, 0, bitmap.getWidth(), bitmap.getHeight(), BaseKLineChartView.this.matrix, false);
                        return;
                    }
                    BaseKLineChartView.this.mWaterBmp = bitmap;
                }

                @Override
                public void onLoadCleared(@Nullable Drawable placeholder) {

                }
            });
        }
        if (this.mWaterBmp != null) {
            canvas.drawBitmap(this.mWaterBmp, (float) (this.mainRect.left + ViewUtil.INSTANCE.dpToPx(10.0f)), (float) ((this.mainRect.bottom - this.mWaterBmp.getHeight()) - ViewUtil.INSTANCE.dpToPx(10.0f)), this.mWaterPaint);
        }
    }

    public String getWaterImageUrl() {
        return waterImageUrl;
    }

    public void setWaterImageUrl(String waterImageUrl) {
        this.waterImageUrl = waterImageUrl;
    }

    @Override
    public boolean dispatchTouchEvent(MotionEvent ev) {

        if (ev.getAction() == MotionEvent.ACTION_DOWN) {
            if (isLongPress) {
                isLongPress = false;
                isCanScroll = false;
                invalidate();
                return true;
            }else{
                isCanScroll = true;
            }
        }

        return super.dispatchTouchEvent(ev);
    }
}
