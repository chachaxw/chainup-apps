package com.yjkj.chainup.new_version.view;


import android.app.Activity;
import android.os.CountDownTimer;

import com.yjkj.chainup.util.Utils;

/**
 * @Author lianshangljl
 * @Date 2023-02-18-12:51
 * @Email buptjinlong@163.com
 * @description
 */

public class CountDownTimerUtil {
    private static CountDownTimerUtil countDownTimerUtil;
    private static final long DefauteMillisInFuture = 0;
    private static final long DefauteCountDownInterval = 1;
    private MyCountDownTimer countDownTimer;

    private CountDownTimerUtil(long millisInFuture, long countDownInterval) {
        countDownTimer = new MyCountDownTimer(millisInFuture, countDownInterval);
    }

    public static CountDownTimerUtil newInstance(long millisInFuture, long countDownInterval) {
        if (countDownTimerUtil == null) {
            countDownTimerUtil = new CountDownTimerUtil(millisInFuture, countDownInterval);
        }
        return countDownTimerUtil;
    }

    public MyCountDownTimer getCountDownTimer() {
        return countDownTimer;
    }

    public void setCountDownTimer(MyCountDownTimer countDownTimer) {
        this.countDownTimer = countDownTimer;
    }

    public static CountDownTimerUtil getDefault() {
        return newInstance(DefauteMillisInFuture, DefauteCountDownInterval);
    }

    public MyCountDownTimer setContinueCountDownTimer(long currentTime) {
        setCountDownTimer(new MyCountDownTimer(currentTime, DefauteCountDownInterval));
        return getCountDownTimer();
    }

    public MyCountDownTimer setContinueCountDownTimer() {
        setCountDownTimer(new MyCountDownTimer(DefauteMillisInFuture, DefauteCountDownInterval));
        return getCountDownTimer();
    }

    public void setTimerListener(OnCountDownTimerListener activity) {
        setOnCountDownTimerListener(activity);
    }

    private OnCountDownTimerListener onCountDownTimerListener;

    public void setOnCountDownTimerListener(OnCountDownTimerListener onCountDownTimerListener) {
        this.onCountDownTimerListener = onCountDownTimerListener;
    }


    /**
     *Start countdown
     */
    public static void StartToCountDown(long currentTime, OnCountDownTimerListener activity) {
        CountDownTimerUtil aDefault = CountDownTimerUtil.getDefault();
        if (aDefault.getCountDownTimer().ismCancelled()) {
            if (currentTime > 0.005f) {
                //At this point, it has already been initialized
                aDefault.setContinueCountDownTimer(currentTime).toStart();
            } else if (currentTime == 0) {
                aDefault.setContinueCountDownTimer().toStart();
            } else {
                aDefault.getCountDownTimer().toStart();
            }
            aDefault.setTimerListener(activity);
        }

    }

    /**
     *Pause countdown
     */
    public static long StopCountDown() {
        CountDownTimerUtil aDefault = CountDownTimerUtil.getDefault();
        aDefault.setTimerListener(null);
        return aDefault.getCountDownTimer().toStop();
    }

    public class MyCountDownTimer extends CountDownTimer {

        private long currrntTime;
        private boolean mCancelled;

        public boolean ismCancelled() {
            return mCancelled;
        }

        public long getCurrrntTime() {
            return currrntTime;
        }


        public void setmCancelled(boolean cancelled) {
            if (mCancelled != cancelled)
                mCancelled = cancelled;
        }

        public void setCurrrntTime(long currrntTime) {
            this.currrntTime = currrntTime;
        }

        /**
         *@param millisInFuture represents the total number of countdowns in milliseconds
         *                          <p>
         *For example, millisInFuture=1000 represents 1 second
         *@param countDownInterval indicates the number of microseconds between calls to the onTick method
         *                          <p>
         *For example, countDownInterval=1000; Represents calling onTick() every 1000 milliseconds
         */
        public MyCountDownTimer(long millisInFuture, long countDownInterval) {
            super(millisInFuture, countDownInterval);
            mCancelled = true;
        }

        @Override
        public void onTick(long millisUntilFinished) {
            setCurrrntTime(millisUntilFinished);
            setmCancelled(false);
            if (onCountDownTimerListener != null) {
                onCountDownTimerListener.onNext(millisUntilFinished);
            }

        }

        /**
         *One second later than expected···
         */
        @Override
        public void onFinish() {
            setmCancelled(true);
            if (onCountDownTimerListener != null) {
                onCountDownTimerListener.onFinish();
            }

        }

        public void toStart() {
            if (ismCancelled()) start();
        }

        public long toStop() {
            if (!ismCancelled()) {
                setmCancelled(true);
                cancel();
            }
            return getCurrrntTime();
        }
    }

    public interface OnCountDownTimerListener {
        void onFinish();

        void onNext(long leftTimeFormatedStrings);
    }
}


