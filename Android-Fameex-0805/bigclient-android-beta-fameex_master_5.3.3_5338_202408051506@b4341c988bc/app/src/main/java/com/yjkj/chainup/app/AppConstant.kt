package com.yjkj.chainup.app

class AppConstant {

    companion object {

        val SECRET: String = "amlhb3lpc3VvQDIwMTc="

        var SECRET_MMKV_KEY: String = "Z3VhbmppeEAyMDE3"

        //*/Status of gesture password points
        val POINT_STATE_NORMAL: Int = 0 //Normal state

        val POINT_STATE_SELECTED: Int = 1 //Press Status

        val POINT_STATE_WRONG: Int = 2 //Error status


        /******************Mobile message type: START***********************/

        /**
         *Mobile number registration
         */
        val REGISTER_MOBILE = 1

        /**
         *Bind mobile phone number
         */
        val BIND_MOBILE = 2

        /**
         *Modify mobile phone number
         */
        val CHANGE_MOBILE = 3

        /**
         *Bind email
         */
        val BIND_EMAIL = 4

        /**
         *Set fund password
         */
        val SET_CAPITAL_PWD = 6


        /**
         *Change fund password
         */
        val CHANGE_CAPITAL_PWD = 7


        /**
         *Change password
         */

        val CHANGE_PWD = 9


        /**
         *Add Digital Currency Address
         */

        val ADD_WITHDRAW_ADDRESS = 11
        const val ADD_WITHDRAW_ADDRESS_EMAIL = 13

        /**
         *Modify&Delete Digital Currency Address
         */
        val CHANGE_WITHDRAW_ADDRESS = 12


        /**
         *Digital currency withdrawal
         */

        val CRYPTO_WITHDRAW = 13
        val CRYPTO_WITHDRAW_EMAIL = 10

        /**
         *Turn off mobile verification
         */
        val CLOSE_MOBILE_VERIFY = 14


        /**
         *Modify email
         */

        val CHANGE_EMAIL = 15

        /**
         *Retrieve password
         */
        val FIND_PWD_MOBILE = 24


        /**
         *Mobile login
         */
        val MOBILE_LOGIN = 25

        /**
         *Turn off Google authentication
         */

        val CLOASE_GOOGLE_VERIFY = 26

        /**
         *Turn on or off gesture password
         */
        val GESTURE_PWD = 27


        /**
         *Email registration
         */
        val REGISTER_EMAIL = 1

        /**
         *Retrieve password
         */
        val FIND_PWD_EMAIL = 3

        /**
         *Email login
         */
        val EMAIL_LOGIN = 4

        val ACCOUNT_DELETE_PHONE = 301

        val ACCOUNT_DELETE_EMAIL = 30


        /**
         *Transfer 4 iPhone
         */
        val CONFIRM_TRANSFER_IPHONE = 34

        /**
         *Transfer 4 email
         */
        val CONFIRM_TRANSFER_EMAIL = 19

        // 忘记资金密码
        const val CAPITALPWD_FORGET = 35
        // 解绑资金密码
        const val UNBIND_CAPITALPWD = 36
        // 白名单开关状态
        const val WHITE_LIST_STATUS_OPEN = 37
        const val WHITE_LIST_STATUS_CLOSE = 40
        // C2C卖单
        const val C2C_ORDER_SELL = 38
        // C2C确认放币
        const val C2C_ORDER_CONFIRM = 39
        // 提币地址删除
        const val DEL_WITHDRAW_ADDRESS = 12


        /***********Email message type: END************/




        /************APP port type************/
        /**
         *Default disk port
         */
        const val DEFAULT_TAPE = 0
        /**
         *Only buy
         */
        const val BUY_TAPE = 1
        /**
         *Only Sell
         */
        const val SELL_TAPE = 2



        var IS_NEW_CONTRACT = false
        const val SIMPLEX = "Simplex"
        const val BANXA = "Banxa"


    }

}
