package com.chainup.contract

import com.chainup.contract.utils.ChainUpLogUtil
import com.chainup.contract.utils.CpDateUtils
import org.junit.Test

import org.junit.Assert.*
import java.text.SimpleDateFormat

/**
 * Example local unit test, which will execute on the development machine (host).
 *
 * See [testing documentation](http://d.android.com/tools/testing).
 */
class ExampleUnitTest {
    @Test
    fun addition_isCorrect() {
//        val otime = 1673331219000L


        val time = CpDateUtils.getAgoTimeByAmountDays(-30)

        System.out.println("getHistoryCommonOrderList"+">>>"+time+">>>"+SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(time))
//        val dtime = ctimes - otime
//        val days = CpDateUtils.getTimeAgo(dtime)
//        System.out.println("getHistoryCommonOrderList"+">>>"+days)
    }
}