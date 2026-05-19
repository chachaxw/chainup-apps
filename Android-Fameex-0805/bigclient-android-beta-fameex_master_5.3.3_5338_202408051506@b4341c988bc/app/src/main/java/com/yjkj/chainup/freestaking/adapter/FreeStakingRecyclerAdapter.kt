package com.yjkj.chainup.freestaking.adapter

import android.app.Activity
import android.graphics.Bitmap
import androidx.core.content.ContextCompat
import com.bumptech.glide.Glide
import com.chad.library.adapter.base.BaseQuickAdapter
import com.yjkj.chainup.R
import com.bumptech.glide.request.target.SimpleTarget
import com.bumptech.glide.request.transition.Transition
import com.chad.library.adapter.base.viewholder.BaseViewHolder
import com.yjkj.chainup.app.ChainUpApp
import com.yjkj.chainup.freestaking.bean.CurrencyBean
import com.yjkj.chainup.manager.LanguageUtil

/**
 *Adapter for FreeStacking homepage project list
 */
class FreeStakingRecyclerAdapter(data: ArrayList<CurrencyBean>) :
        BaseQuickAdapter<CurrencyBean, BaseViewHolder>(R.layout.item_freestaking_symbol, data) {

    override fun convert(helper: BaseViewHolder, item: CurrencyBean) {
        var simpleTarget: SimpleTarget<Bitmap> = object : SimpleTarget<Bitmap>() {
            override fun onResourceReady(resource: Bitmap, transition: Transition<in Bitmap>?) {
                helper?.setImageBitmap(R.id.iv_logo, resource)
            }
        }
        helper.setText(R.id.tv_lockDay,LanguageUtil.getString(context,"pos_string_lockDateNumber"))
        helper.setText(R.id.tv_lockProgress,LanguageUtil.getString(context,"pos_string_lockProcess"))
        helper.setText(R.id.tv_interestRate,LanguageUtil.getString(context,"pos_string_interestRate"))

        Glide.with(context)
                .asBitmap()
                .load(item?.logo)
                .into(simpleTarget)
        //Currency abbreviation
        helper?.setText(R.id.tv_name, item?.shortName)
        helper?.setTextColor(R.id.tv_status, ContextCompat.getColor(ChainUpApp.appContext, R.color.normal_text_color))
        helper?.setVisible(R.id.iv_label, false)
        when (item?.projectType) {
            1 -> {
                when (item?.status) {
                    0 -> {


                    }
                    1 -> {
                        //Project status (1: To be started 2: In progress 3: Ended 4: Full warehouse)
                        helper?.setText(R.id.tv_status, "「" + LanguageUtil.getString(context,"pos_state_start") + "」")
                        helper?.setVisible(R.id.iv_label, true)
                        when (item.labelType) {
                            0 -> {
                            }
                            1 -> {
                                //Label type (0. None 1. Hot 2. New)
                                helper?.setImageResource(R.id.iv_label, R.drawable.personal_hot)
                            }
                            2 -> {
                                helper?.setImageResource(R.id.iv_label, R.drawable.personal_new)

                            }

                        }
                    }
                    2 -> {
                        //Project status (1: To be started 2: In progress 3: Ended 4: Full warehouse)
                        helper?.setText(R.id.tv_status, "「" + LanguageUtil.getString(context,"pos_state_processing") + "」")
                        helper?.setTextColor(R.id.tv_status, ContextCompat.getColor(ChainUpApp.appContext, R.color.main_blue))

                    }

                    3 -> {
                        helper?.setText(R.id.tv_status, "「" + LanguageUtil.getString(context,"pos_state_end") + "」")

                    }
                }

            }
            3 -> {
                when (item?.status) {
                    0 -> {
//Project status (1: To be started 2: In progress 3: Ended 4: Full warehouse)
                        helper?.setText(R.id.tv_status, "「" + LanguageUtil.getString(context,"pos_state_start") + "」")
                        helper?.setVisible(R.id.iv_label, true)
                        when (item.labelType) {
                            0 -> {
                            }
                            1 -> {
                                //Label type (0. None 1. Hot 2. New)
                                helper?.setImageResource(R.id.iv_label, R.drawable.personal_hot)
                            }
                            2 -> {
                                helper?.setImageResource(R.id.iv_label, R.drawable.personal_new)

                            }

                        }
                    }
                    1 -> {
                        //Project status (1: To be started 2: In progress 3: Ended 4: Full warehouse)
                        helper?.setText(R.id.tv_status, "「" + LanguageUtil.getString(context,"pos_state_buying") + "」")
                        helper?.setVisible(R.id.iv_label, true)
                        helper?.setTextColor(R.id.tv_status, ContextCompat.getColor(ChainUpApp.appContext, R.color.main_blue))
                        when (item.labelType) {
                            0 -> {
                            }
                            1 -> {
                                //Label type (0. None 1. Hot 2. New)
                                helper?.setImageResource(R.id.iv_label, R.drawable.personal_hot)
                            }
                            2 -> {
                                helper?.setImageResource(R.id.iv_label, R.drawable.personal_new)

                            }

                        }
                    }
                    2 -> {
                        //Project status (1: To be started 2: In progress 3: Ended 4: Full warehouse)
                        helper?.setText(R.id.tv_status, "「" + LanguageUtil.getString(context,"pos_state_waitInterest") + "」")
                    }

                    3 -> {
                        helper?.setText(R.id.tv_status, "「" + LanguageUtil.getString(context,"pos_state_InterestIng") + "」")

                    }
                    4 -> {
                        helper?.setText(R.id.tv_status, "「" + LanguageUtil.getString(context,"pos_state_InterestEnd") + "」")
                    }
                    5 -> {
                        helper?.setText(R.id.tv_status, "「" + LanguageUtil.getString(context,"pos_state_release") + "」")
                    }
                    6 -> {
                        helper?.setText(R.id.tv_status, "「" + LanguageUtil.getString(context,"pos_state_fulled") + "」")
                    }
                }

            }
        }


        //Project Name
        helper?.setText(R.id.tv_current, item?.name)
        //Annualized income
        helper?.setText(R.id.tv_percentage, item?.gainRate.toString() + "%")
        when (item?.projectType) {
            0 -> {

            }
            1 -> {
                helper?.setGone(R.id.tv_lockDay, !false)
                helper?.setGone(R.id.tv_dayNumber, !false)
                helper?.setGone(R.id.tv_lockProgress, !false)
                helper?.setGone(R.id.tv_progressNumber, !false)
            }
            2 -> {

            }
            3 -> {
                helper?.setGone(R.id.tv_lockDay, !true)
                helper?.setGone(R.id.tv_dayNumber, !true)
                helper?.setGone(R.id.tv_lockProgress, !true)
                helper?.setGone(R.id.tv_progressNumber, !true)
                //Lockout days
                helper?.setText(R.id.tv_dayNumber, item.lockDay.toString())
                //Lockout progress
                helper?.setText(R.id.tv_progressNumber, item.progress)
            }

        }

    }

}
