package com.chainup.contract.listener

/**
 * @author ZhongWei
 * @time 2020/7/2 12:07
 *@ description Execution event
 **/
interface CpDoListener {

    /**
     *Perform Action
     */
    fun doThing(obj: Any? = null): Boolean

}
