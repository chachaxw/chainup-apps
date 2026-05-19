package com.yjkj.chainup.util;

import android.os.CountDownTimer;

/**
 *Public Countdown Class
 */
public class CommonCountDownTimer extends CountDownTimer {

    private OnCountDownTimerListener countDownTimerListener;


    public void setCountDownTimerListener(OnCountDownTimerListener listener) {
        this.countDownTimerListener = listener;

    }



    public CommonCountDownTimer(long millisInFuture, long countDownInterval) {
        super(millisInFuture,countDownInterval);

    }


    @Override
    public void onTick(long millisUntilFinished) {

        if (null != countDownTimerListener) {
            countDownTimerListener.onTick(millisUntilFinished);

        }

    }


    @Override
    public void onFinish() {
        if (null != countDownTimerListener) {
            countDownTimerListener.onFinish();

        }

    }


    public interface OnCountDownTimerListener {

        /**
         *Update countdown time
         *
         * @param millisUntilFinished
         */

        void onTick(long millisUntilFinished);


        /**
         *Complete countdown
         */

        void onFinish();

    }
}
