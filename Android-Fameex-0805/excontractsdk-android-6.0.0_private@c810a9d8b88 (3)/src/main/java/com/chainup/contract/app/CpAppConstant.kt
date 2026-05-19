package com.chainup.contract.app

class CpAppConstant {

    companion object {

        val SECRET: String = "jiaoyisuo@2017"


        //*/ statusOfGesturePasswordPoint
        val POINT_STATE_NORMAL: Int = 0 // normalState

        val POINT_STATE_SELECTED: Int = 1 // pressStatus

        val POINT_STATE_WRONG: Int = 2 // errorStatus


        /******************smsType：START***********************/

        /**
         * mobileNumberRegistration
         */
        val REGISTER_MOBILE = 1

        /**
         * bindMobilePhoneNumber
         */
        val BIND_MOBILE = 2

        /**
         * modifyMobilePhoneNumber
         */
        val CHANGE_MOBILE = 3

        /**
         * bindMail
         */
        val BIND_EMAIL = 4

        /**
         * setFundPassword
         */
        val SET_CAPITAL_PWD = 6


        /**
         * modifyFundPassword
         */
        val CHANGE_CAPITAL_PWD = 7


        /**
         *changePassword
         */

        val CHANGE_PWD = 9


        /**
         * addDigitalCurrencyAddress
         */

        val ADD_WITHDRAW_ADDRESS = 11

        /**
         *Modify&deleteDigitalCurrencyAddress
         */
        val CHANGE_WITHDRAW_ADDRESS = 12


        /**
         * digitalCurrencyWithdrawal
         */

        val CRYPTO_WITHDRAW = 13

        /**
         * turnOffMobilePhoneVerification
         */
        val CLOSE_MOBILE_VERIFY = 14


        /**
         * modifyMail
         */

        val CHANGE_EMAIL = 15

        /**
         * retrievePassword
         */
        val FIND_PWD_MOBILE = 24


        /**
         * mobileLogin
         */
        val MOBILE_LOGIN = 25

        /**
         * turnOffGoogleAuthentication
         */

        val CLOASE_GOOGLE_VERIFY = 26

        /**
         * turnOnOrOffGesturePassword
         */
        val GESTURE_PWD = 27


        /**
         * emailRegistration
         */
        val REGISTER_EMAIL = 1

        /**
         * retrievePassword
         */
        val FIND_PWD_EMAIL = 3

        /**
         * mailLogin
         */
        val EMAIL_LOGIN = 4

        /***********eMailMessageType：END************/




        /************APP TAPEType************/
        /**
         * Default TAPE
         */
        const val DEFAULT_TAPE = 0
        /**
         * only BUY
         */
        const val BUY_TAPE = 1
        /**
         * only SELL
         */
        const val SELL_TAPE = 2



         var IS_NEW_CONTRACT = false


    }

}
