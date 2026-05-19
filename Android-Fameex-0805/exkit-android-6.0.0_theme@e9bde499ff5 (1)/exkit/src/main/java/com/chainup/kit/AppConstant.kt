package com.chainup.kit

class AppConstant {

    companion object {

        val SECRET: String = "jiaoyisuo@2017"


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

        /**
         *Modify&Delete Digital Currency Address
         */
        val CHANGE_WITHDRAW_ADDRESS = 12


        /**
         *Digital currency withdrawal
         */

        val CRYPTO_WITHDRAW = 13

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


        /**
         *Log out of login
         */
        val USER_LOGOUT = 222

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

         var FLUTTER_ENGINE_ID = "chainup_ex"


        val CRYPTO_WITHDRAW_EMAIL = 16


    }

}
