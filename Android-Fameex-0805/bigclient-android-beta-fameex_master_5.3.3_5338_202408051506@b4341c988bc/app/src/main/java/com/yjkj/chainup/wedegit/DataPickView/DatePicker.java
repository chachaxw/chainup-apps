package com.yjkj.chainup.wedegit.DataPickView;

import android.content.Context;
import android.icu.util.Calendar;
import android.widget.TextView;

import androidx.core.content.ContextCompat;

import com.yjkj.chainup.R;
import com.yjkj.chainup.manager.LanguageUtil;
import com.yjkj.chainup.util.StringUtils;
import com.yjkj.chainup.util.Utils;
import com.yjkj.chainup.wedegit.DataPickView.bean.DateType;
import com.yjkj.chainup.wedegit.DataPickView.genview.WheelGeneralAdapter;
import com.yjkj.chainup.wedegit.DataPickView.view.WheelDateView;

import java.util.Date;

/**
 * Created by codbking on 2016/8/10.
 */
public class DatePicker extends BaseWheelPick {

    private static final String TAG = "WheelPicker";

    private WheelDateView yearView;
    private WheelDateView monthView;
    private WheelDateView dayView;
    private TextView weekView;
    private WheelDateView hourView;
    private WheelDateView minuteView;

    private Integer[] yearArr, mothArr, dayArr, hourArr, minutArr;
    private DatePickerHelper datePicker;

    public DateType type = DateType.TYPE_YMD;

    private Date beginTime,endTime;
    private int selectType;

    //Start time
    private Date startDate = new Date();
    //Annual limit, default to 5 years
    private int yearLimt = 5;

    private OnChangeLisener onChangeLisener;
    private int selectDay;

    //Select time callback
    public void setOnChangeLisener(OnChangeLisener onChangeLisener) {
        this.onChangeLisener = onChangeLisener;
    }
    private Context context;
    public DatePicker(Context context, DateType type) {
        super(context);
        this.context = context;
        if(this.type!=null){
            this.type = type;
        }
    }
    public void setStartDate(Date startDate) {
        this.startDate = startDate;
    }

    public void setStartDate(Date startDate,Date beginTime,Date endTime,int type) {
        this.startDate = startDate;
        this.beginTime = beginTime;
        this.endTime   = endTime;
        this.selectType= type;
    }

    public void setYearLimt(int yearLimt) {
        this.yearLimt = yearLimt;
    }

    //Initialization value
    public void init() {

        this.minuteView = findViewById(R.id.minute);
        this.hourView = findViewById(R.id.hour);
        this.weekView = findViewById(R.id.week);
        this.dayView = findViewById(R.id.day);
        this.monthView = findViewById(R.id.month);
        this.yearView = findViewById(R.id.year);

        switch (type) {
            case TYPE_ALL:
                this.minuteView.setVisibility(VISIBLE);
                this.hourView.setVisibility(VISIBLE);
                this.weekView.setVisibility(VISIBLE);
                this.dayView.setVisibility(VISIBLE);
                this.monthView.setVisibility(VISIBLE);
                this.yearView.setVisibility(VISIBLE);
                break;
            case TYPE_YMDHM:
                this.minuteView.setVisibility(VISIBLE);
                this.hourView.setVisibility(VISIBLE);
                this.weekView.setVisibility(GONE);
                this.dayView.setVisibility(VISIBLE);
                this.monthView.setVisibility(VISIBLE);
                this.yearView.setVisibility(VISIBLE);
                break;
            case TYPE_YMDH:
                this.minuteView.setVisibility(GONE);
                this.hourView.setVisibility(VISIBLE);
                this.weekView.setVisibility(GONE);
                this.dayView.setVisibility(VISIBLE);
                this.monthView.setVisibility(VISIBLE);
                this.yearView.setVisibility(VISIBLE);
                break;
            case TYPE_YMD:
                this.minuteView.setVisibility(GONE);
                this.hourView.setVisibility(GONE);
                this.weekView.setVisibility(GONE);
                this.dayView.setVisibility(VISIBLE);
                this.monthView.setVisibility(VISIBLE);
                this.yearView.setVisibility(VISIBLE);
                break;
            case TYPE_HM:
                this.minuteView.setVisibility(VISIBLE);
                this.hourView.setVisibility(VISIBLE);
                this.weekView.setVisibility(GONE);
                this.dayView.setVisibility(GONE);
                this.monthView.setVisibility(GONE);
                this.yearView.setVisibility(GONE);
                break;
        }

        datePicker = new DatePickerHelper(beginTime,endTime,selectType);
        datePicker.setStartDate(startDate, yearLimt);

        dayArr = datePicker.getDayDataAry();
        yearArr = datePicker.getYearDataAry();
        mothArr = datePicker.getMothDataAry();
        hourArr = datePicker.genHour();
        minutArr = datePicker.genMinut();

        weekView.setText(datePicker.getDisplayStartWeek());

        setWheelListener(yearView, yearArr, false);
        setWheelListener(monthView, mothArr, true);
        setWheelListener(dayView, dayArr, true);
        setWheelListener(hourView, hourArr, true);
        setWheelListener(minuteView, minutArr, true);

        yearView.setSelectTextColor(ContextCompat.getColor(getContext(),R.color.hint_color),ContextCompat.getColor(getContext(),R.color.text_color));
        dayView.setSelectTextColor(ContextCompat.getColor(getContext(),R.color.hint_color),ContextCompat.getColor(getContext(),R.color.text_color));
        monthView.setSelectTextColor(ContextCompat.getColor(getContext(),R.color.hint_color),ContextCompat.getColor(getContext(),R.color.text_color));
        hourView.setSelectTextColor(ContextCompat.getColor(getContext(),R.color.hint_color),ContextCompat.getColor(getContext(),R.color.text_color));
        minuteView.setSelectTextColor(ContextCompat.getColor(getContext(),R.color.hint_color),ContextCompat.getColor(getContext(),R.color.text_color));
        yearView.setCurrentItem(datePicker.findIndextByValue(datePicker.getToady(DatePickerHelper.Type.YEAR), yearArr));
        monthView.setCurrentItem(datePicker.findIndextByValue(datePicker.getToady(DatePickerHelper.Type.MOTH), mothArr));
        dayView.setCurrentItem(datePicker.findIndextByValue(datePicker.getToady(DatePickerHelper.Type.DAY), dayArr));
        hourView.setCurrentItem(datePicker.findIndextByValue(datePicker.getToady(DatePickerHelper.Type.HOUR), hourArr));
        minuteView.setCurrentItem(datePicker.findIndextByValue(datePicker.getToady(DatePickerHelper.Type.MINUTE), minutArr));

    }


    protected String[] convertData(WheelDateView wheelDateView, Integer[] data) {
        if (wheelDateView == yearView) {
            return datePicker.getDisplayValue(data,"");
        } else if (wheelDateView == monthView) {
            return datePicker.getDisplayValue(data,"");
        } else if (wheelDateView == dayView) {
            return datePicker.getDisplayValue(data,"");
        } else if (wheelDateView == hourView) {
            return datePicker.getDisplayValue(data, "");
        } else if (wheelDateView == minuteView) {
            return datePicker.getDisplayValue(data, "");
        }
        return new String[0];
    }




    @Override
    protected int getLayout() {
        return R.layout.cbk_wheel_picker;
    }

    @Override
    protected int getItemHeight() {
        return dayView.getItemHeight();
    }


    @Override
    protected void setData(Object[] datas) {
    }

    private void setChangeDaySelect(int year, int moth) {
        dayArr = datePicker.genDay(year, moth);
        WheelGeneralAdapter adapter= (WheelGeneralAdapter) dayView.getViewAdapter();
        adapter.setData(convertData(dayView,  dayArr));

        int indxt = datePicker.findIndextByValue(selectDay, dayArr);
        if (indxt == -1) {
            dayView.setCurrentItem(0);
        } else {
            dayView.setCurrentItem(indxt);
        }
    }

    public void setValueByDate(Date date){
        int yearPosition = datePicker.findIndextByValue(Utils.getYear(date),yearArr);
        int mothPosition = datePicker.findIndextByValue(Utils.getMoth(date),mothArr);
        int dayPosition = datePicker.findIndextByValue(Utils.getDay(date),dayArr);
        yearView.setCurrentItem(yearPosition);
        monthView.setCurrentItem(mothPosition);
        dayView.setCurrentItem(dayPosition);
    }

    @Override
    public void onChanged(WheelDateView wheel, int oldValue, int newValue) {

        int year = yearArr[yearView.getCurrentItem()];
        int moth = mothArr[monthView.getCurrentItem()];
        int day = dayArr[dayView.getCurrentItem()];
        int hour = hourArr[hourView.getCurrentItem()];
        int minut = minutArr[minuteView.getCurrentItem()];

        if (wheel == yearView || wheel == monthView) {
            setChangeDaySelect(year, moth);
        } else {
            selectDay = day;
        }

        if (wheel == yearView || wheel == monthView || wheel == dayView) {
            weekView.setText(datePicker.getDisplayWeek(year, moth, day));
        }

        if (onChangeLisener != null) {
            onChangeLisener.onChanged(Utils.getDate(year, moth, day, hour, minut));
        }

    }

    @Override
    public void onScrollingStarted(WheelDateView wheel) {
    }

    @Override
    public void onScrollingFinished(WheelDateView wheel) {
    }


    //Get Selected Date
    public Date getSelectDate() {

        int year = yearArr[yearView.getCurrentItem()];
        int moth = mothArr[monthView.getCurrentItem()];
        int day = dayArr[dayView.getCurrentItem()];
        int hour = hourArr[hourView.getCurrentItem()];
        int minut = minutArr[minuteView.getCurrentItem()];

        if(type==DateType.TYPE_YMD){

            return Utils.parseServerTime(year+"-"+moth+"-"+day);
        }
        return Utils.getDate(year, moth, day, hour, minut);

    }



}
