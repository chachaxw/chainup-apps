package com.example.viewtest

import android.os.Bundle
import android.text.InputFilter
import android.view.View
import androidx.appcompat.app.AppCompatActivity
import com.chainup.kit.KKDialogUtils
import com.chainup.kit.KKDialogUtils.Companion.showCommonDialog
import com.chainup.kit.KKDialogUtils.Companion.showInputBottomDialog
import com.chainup.kit.KKDialogUtils.DialogDoubleBottomListener
import com.chainup.kit.utils.InputPatternFilter
import com.chainup.kit.views.KKButtonKit

class DialogActivity : AppCompatActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_dialog)

        (findViewById<View>(R.id.kk_btn_1) as KKButtonKit).apply {
            this.setOnClickListener {
                showCommonDialog(
                    this@DialogActivity,
                    title = "Are you sure you want to change your phone number?",
                    listener=object : DialogDoubleBottomListener {
                        override fun sendConfirm() {}
                        override fun sendCancel() {}
                    },
                    confrimTitle = "Confirm",
                    cancelTitle = "Cancel",
                    isShowCancel = true,
                    style = 1
                )
            }
        }
        (findViewById<View>(R.id.kk_btn_2) as KKButtonKit).apply {
            this.setOnClickListener {
                showCommonDialog(
                    this@DialogActivity,
                    "如何应对超大工程复杂度带来的挑战？怎么通过插件化架构高效支撑业务需求的迭代？",
                    "对话框标题",
                    object : DialogDoubleBottomListener {
                        override fun sendConfirm() {}
                        override fun sendCancel() {}
                    },
                    confrimTitle = "Confirm",
                    cancelTitle = "Cancel",
                    isShowCancel = true,
                    style = 1
                )
            }
        }
        (findViewById<View>(R.id.kk_btn_3) as KKButtonKit).apply {
            this.setOnClickListener {
                showCommonDialog(
                    this@DialogActivity,
                    "如何应对超大工程复杂度带来的挑战？怎么通过插件化架构高效支撑业务需求的迭代？",
                    "对话框标题",
                    object : DialogDoubleBottomListener {
                        override fun sendConfirm() {}
                        override fun sendCancel() {}
                    },
                    confrimTitle = "Confirm",
                    cancelTitle = "Cancel",
                    isShowCancel = true,
                    style = 3
                )
            }
        }
        (findViewById<View>(R.id.kk_btn_4) as KKButtonKit).apply {
            this.setOnClickListener {
                showCommonDialog(
                    this@DialogActivity,
                    "如何应对超大工程复杂度带来的挑战？怎么通过插件化架构高效支撑业务需求的迭代？",
                    "对话框标题",
                    object : DialogDoubleBottomListener {
                        override fun sendConfirm() {}
                        override fun sendCancel() {}
                    },
                    confrimTitle = "Confirm",
                    cancelTitle = "Cancel",
                    isShowCancel = false,
                    style = 1
                )
            }
        }
        (findViewById<View>(R.id.kk_btn_5) as KKButtonKit).apply {
            this.setOnClickListener {
                showCommonDialog(
                    this@DialogActivity,
                    "如何应对超大工程复杂度带来的挑战？怎么通过插件化架构高效支撑业务需求的迭代？",
                    "对话框标题",
                    object : DialogDoubleBottomListener {
                        override fun sendConfirm() {}
                        override fun sendCancel() {}
                    },
                    confrimTitle = "Confirm",
                    cancelTitle = "Cancel",
                    isShowCancel = false,
                    style = 3
                )
            }
        }
        (findViewById<View>(R.id.kk_btn_6) as KKButtonKit).apply {
            this.setOnClickListener {
                showCommonDialog(
                    this@DialogActivity,
                    "如何应对超大工程复杂度带来的挑战？怎么通过插件化架构高效支撑业务需求的迭代？",
                    "对话框标题",
                    object : DialogDoubleBottomListener {
                        override fun sendConfirm() {}
                        override fun sendCancel() {}
                    },
                    confrimTitle = "Confirm",
                    cancelTitle = "Cancel",
                    isShowCancel = true,
                    style = 1
                )
            }
        }
        (findViewById<View>(R.id.kk_btn_7) as KKButtonKit).apply {
            this.setOnClickListener {
                showCommonDialog(
                    this@DialogActivity,
                    "如何应对超大工程复杂度带来的挑战？怎么通过插件化架构高效支撑业务需求的迭代？",
                    "对话框标题",
                    object : DialogDoubleBottomListener {
                        override fun sendConfirm() {}
                        override fun sendCancel() {}
                    },
                    confrimTitle = "Confirm",
                    cancelTitle = "Cancel",
                    isShowCancel = true,
                    style = 2
                )
            }
        }
        (findViewById<View>(R.id.kk_btn_8) as KKButtonKit).apply {
            this.setOnClickListener {
                showCommonDialog(
                    this@DialogActivity,
                    "",
                    "对话框标题",
                    object : DialogDoubleBottomListener {
                        override fun sendConfirm() {}
                        override fun sendCancel() {}
                    },
                    confrimTitle = "Confirm",
                    cancelTitle = "Cancel",
                    isShowCancel = true,
                    style = 4,
                    drawableRes = R.mipmap.ic_launcher,
                    isCancelableOutside = true

                )
            }
        }
        //InputFilter[]{new InputPatternFilter("[`~!@#$%^&*()+=|{}':;',\\[\\].<>/?~！@#￥%……&*（）——+|{}【】‘；：”“’。，、？]")}
        (findViewById<View>(R.id.kk_btn_9) as KKButtonKit).apply {
            this.setOnClickListener {
                showInputBottomDialog(
                    this@DialogActivity,
                    "一个输入框的",
                    "取消",
                    "确认",
                    "输入框提示占位",
                    object : KKDialogUtils.DialogDoubleBottomStrListener {
                        override fun sendConfirm(data: String) {
                            println(data);
                        }

                        override fun sendCancel(data: String) {
                        }
                    },
                    filters = arrayOf(InputPatternFilter("[a-zA-Z0-9]",false),InputFilter.LengthFilter(10)),
                )
            }
        }
    }
}