package com.yjkj.chainup.wedegit.DataPickView;

import android.app.Dialog;
import android.content.Context;
import android.os.Bundle;
import android.view.Gravity;
import android.view.View;
import android.view.WindowManager;
import android.widget.FrameLayout;
import android.widget.TextView;

import com.yjkj.chainup.R;
import com.yjkj.chainup.manager.LanguageUtil;
import com.yjkj.chainup.util.ToastUtils;
import com.yjkj.chainup.util.Utils;
import com.yjkj.chainup.wedegit.DataPickView.bean.DateType;

import java.util.Calendar;
import java.util.Date;


/**
 * Created by codbking on 2016/8/11.
 */
public class DatePickDialog extends Dialog implements OnChangeLisener {

    private TextView tv_cancel,tv_confirm;
    private FrameLayout wheelLayout;

    private DateType type = DateType.TYPE_YMD;

    private Date beginTime,endTime;
    private int selectType;

    //Start time
    private Date startDate = new Date();
    //Annual limit, default to 5 years
    private int yearLimt = 5;

    private OnChangeLisener onChangeLisener;

    private OnSureLisener onSureLisener;

    private DatePicker mDatePicker;
    private Context context;

    //Setting mode
    public void setType(DateType type) {
        this.type = type;
    }

    //Set Start Time
    public void setStartDate(Date startDate) {
        this.startDate = startDate;
    }

    //Set year restrictions, up and down years
    public void setYearLimt(int yearLimt) {
        this.yearLimt = yearLimt;
    }

    //Set Selection Callback
    public void setOnChangeLisener(OnChangeLisener onChangeLisener) {
        if(onChangeLisener!=null){
            this.onChangeLisener = onChangeLisener;
        }
    }

    //Set the selected date type 0 start 1 end
    public void setDateValue(Date beginTime,Date endTime,int type) {
        this.beginTime = beginTime;
        this.endTime   = endTime;
        this.selectType= type;
    }

    //Set the callback by clicking the OK button
    public void setOnSureLisener(OnSureLisener onSureLisener) {
        this.onSureLisener = onSureLisener;
    }

    public DatePickDialog(Context context) {
        super(context, R.style.dialog_style);
        this.context = context;
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.cbk_dialog_pick_time);

        initView();
        initParas();
    }

    private DatePicker getDatePicker() {
        DatePicker picker = new DatePicker(context, type);
        picker.setStartDate(startDate,beginTime,endTime,selectType);
        picker.setYearLimt(yearLimt);
        picker.setOnChangeLisener(this);
        picker.init();
        return picker;
    }

    private void initView() {
        this.wheelLayout = findViewById(R.id.wheelLayout);
        this.tv_cancel   = findViewById(R.id.tv_cancel);
        this.tv_confirm  = findViewById(R.id.tv_confirm);

        mDatePicker = getDatePicker();
        this.wheelLayout.addView(mDatePicker);

        this.tv_cancel.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                dismiss();
            }
        });

        this.tv_confirm.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {

                Date currentDate = mDatePicker.getSelectDate();
                if(selectType==0){
                    if(endTime!=null){
                        if(endTime.compareTo(currentDate) < 0){
                            //The start time must be earlier than the end time
                            ToastUtils.showToast(getContext(), LanguageUtil.getString(getContext(),"datepicker_tip1"));
                            return ;
                        }
                    }
                }
                if(selectType==1){
                    if(beginTime!=null){
                        if(beginTime.compareTo(currentDate) > 0){
                            //The end time must be later than the start time
                            ToastUtils.showToast(getContext(), LanguageUtil.getString(getContext(),"datepicker_tip2"));
                            return ;
                        }
                    }
                }

                dismiss();

                if (onSureLisener != null) {

                    onSureLisener.onSure(currentDate);
                }
            }
        });
    }

    private void initParas() {
        WindowManager.LayoutParams params = getWindow().getAttributes();
        params.gravity = Gravity.BOTTOM;
        params.width = Utils.getScreenWidth(context);
        getWindow().setAttributes(params);
    }

    @Override
    public void onChanged(Date date) {

        if (onChangeLisener != null) {
            onChangeLisener.onChanged(date);
        }
    }


}
