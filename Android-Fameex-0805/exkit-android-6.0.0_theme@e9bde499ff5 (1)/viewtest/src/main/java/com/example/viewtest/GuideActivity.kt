package com.example.viewtest

import android.os.Bundle
import android.view.View
import androidx.appcompat.app.AppCompatActivity
import com.binioter.guideview.Component
import com.chainup.kit.utils.GuideUtil
import com.chainup.kit.views.KKButtonKit
import com.chainup.kit.views.component.GuideComponent

class GuideActivity : AppCompatActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_guide)
        val btn = findViewById<KKButtonKit>(R.id.btn_guide)
        val btn2 = findViewById<KKButtonKit>(R.id.btn_guide2)
        val btn3 = findViewById<KKButtonKit>(R.id.btn_guide3)
        val btn4 = findViewById<KKButtonKit>(R.id.btn_guide4)
        val btn5 = findViewById<KKButtonKit>(R.id.btn_guide5)
        btn.setOnClickListener(object: View.OnClickListener{
            override fun onClick(v: View?) {
                val guideList = arrayListOf<GuideUtil.GuideTargetModel>()


                guideList.add(
                    GuideUtil.GuideTargetModel(
                        target = btn,
                        key = "ceshi",
                        message = null,
                        component = GuideComponent("trade_FutureGrid_tips", Component.ANCHOR_BOTTOM,
                            Component.FIT_END,0,0,20)
                    )
                )
                GuideUtil.showMultipleGuide(context = this@GuideActivity,guideList)
            }

        })

        btn2.setOnClickListener(object: View.OnClickListener{
            override fun onClick(v: View?) {
                val guideList = arrayListOf<GuideUtil.GuideTargetModel>()


                guideList.add(
                    GuideUtil.GuideTargetModel(
                        target = btn2,
                        key = "ceshi",
                        message = null,
                        component = GuideComponent("trade_FutureGrid_tips", Component.ANCHOR_BOTTOM,
                            Component.FIT_START,0,0,20)
                    )
                )
                GuideUtil.showMultipleGuide(context = this@GuideActivity,guideList)
            }

        })

        btn3.setOnClickListener(object: View.OnClickListener{
            override fun onClick(v: View?) {
                val guideList = arrayListOf<GuideUtil.GuideTargetModel>()

                guideList.add(
                    GuideUtil.GuideTargetModel(
                        target = btn3,
                        key = "ceshi",
                        message = null,
                        component = GuideComponent("trade_FutureGrid_tips", Component.ANCHOR_TOP,
                            Component.FIT_START,0,0,20)
                    )
                )
                GuideUtil.showMultipleGuide(context = this@GuideActivity,guideList)
            }

        })

        btn4.setOnClickListener(object: View.OnClickListener{
            override fun onClick(v: View?) {
                val guideList = arrayListOf<GuideUtil.GuideTargetModel>()

                guideList.add(
                    GuideUtil.GuideTargetModel(
                        target = btn4,
                        key = "ceshi",
                        message = null,
                        component = GuideComponent("trade_FutureGrid_tips", Component.ANCHOR_TOP,
                            Component.FIT_END,0,0,20)
                    )
                )
                GuideUtil.showMultipleGuide(context = this@GuideActivity,guideList)
            }

        })

        btn5.setOnClickListener(object: View.OnClickListener{
            override fun onClick(v: View?) {
                val guideList = arrayListOf<GuideUtil.GuideTargetModel>()

                guideList.add(
                    GuideUtil.GuideTargetModel(
                        target = btn5,
                        key = "ceshi",
                        message = null,
                        component = GuideComponent("trade_FutureGrid_tips", Component.ANCHOR_TOP,
                            Component.FIT_START,0,0,20)
                    )
                )
                GuideUtil.showMultipleGuide(context = this@GuideActivity,guideList)
            }

        })
    }
}