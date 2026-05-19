package com.yjkj.chainup.freestaking

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.widget.ImageView
import android.widget.TextView
import androidx.core.content.ContextCompat
import androidx.fragment.app.Fragment
import androidx.viewpager.widget.ViewPager
import com.alibaba.android.arouter.facade.annotation.Route
import com.bumptech.glide.Glide
import com.bumptech.glide.load.resource.bitmap.CircleCrop
import com.bumptech.glide.load.resource.bitmap.RoundedCorners
import com.bumptech.glide.request.RequestOptions
import com.chainup.kit.utils.PublicSizeUtil
import com.jaeger.library.StatusBarUtil
import com.yjkj.chainup.R
import com.yjkj.chainup.db.constant.ParamConstant
import com.yjkj.chainup.db.constant.RoutePath
import com.yjkj.chainup.extra_service.arouter.ArouterUtil
import com.yjkj.chainup.freestaking.adapter.FreeStakingFragmentAdapter
import com.yjkj.chainup.freestaking.bean.FreeStakingBean
import com.yjkj.chainup.freestaking.bean.NotificationRefreshBean
import com.yjkj.chainup.manager.LanguageUtil
import com.yjkj.chainup.manager.LoginManager
import com.yjkj.chainup.net.HttpClient
import com.yjkj.chainup.net.retrofit.NetObserver
import com.yjkj.chainup.new_version.activity.NewBaseActivity
import com.yjkj.chainup.new_version.view.GlideRoundTransform
import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.schedulers.Schedulers
import kotlinx.android.synthetic.main.activity_free_staking.*
import kotlinx.android.synthetic.main.what_is_freestaking.view.*
import org.greenrobot.eventbus.EventBus


/**
 *FreeStaking homepage
 */
@Route(path = RoutePath.FreeStakingActivity)
class FreeStakingActivity : NewBaseActivity() {
    private var tabList = ArrayList<String>()
    private var fragmentList = ArrayList<Fragment>()
    private var url: String = ""
    private var faqUrl: String = ""
    lateinit var adapter: FreeStakingFragmentAdapter
    private var ivIcon:ImageView? = null
    private var ivText:TextView? = null
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_free_staking)
        StatusBarUtil.setColor(this, ContextCompat.getColor(this,R.color.bg_card_color), 0)
        getFreeStakingData()

    }

    private fun initClick() {

        ivIcon?.setOnClickListener {
            var bundle = Bundle()
            bundle.putString(ParamConstant.web_url, url)
            bundle.putString(ParamConstant.head_title, "")
            ArouterUtil.greenChannel(RoutePath.ItemDetailActivity, bundle)
        }
        ivText?.setOnClickListener {
            if (LoginManager.checkLogin(this, true)) {
                val bundle = Bundle()
                bundle.putInt(PROJECT_TYPE, 3)
                ArouterUtil.greenChannel(RoutePath.PositionRecordActivity, bundle)
            }
        }


        /**
         *FAQ Click Event
         */
        ll_what_is_freestaking.tv_problem.setOnClickListener {
            var bundle = Bundle()
            bundle.putString(ParamConstant.web_url, faqUrl)
            ArouterUtil.greenChannel(RoutePath.ItemDetailActivity, bundle)
        }


    }


    private fun initView(freeStakingBean: FreeStakingBean?) {
        val rightView = LayoutInflater.from(this).inflate(R.layout.layout_header_custom_staking,null)
        ivIcon = rightView.findViewById(R.id.ic_image)
        ivText = rightView.findViewById(R.id.tv_text)

        v_head.setTitleContent("")
        ivText?.text = freeStakingBean?.tipMine?:""

        ll_what_is_freestaking.tv_what_is_freestaking.text = freeStakingBean?.footTitle
        ll_what_is_freestaking.tv_content.text = freeStakingBean?.detail
        ll_what_is_freestaking.tv_contactUs.text = freeStakingBean?.contact
        url = freeStakingBean?.url.toString()
        if(url.isEmpty()){
            ivIcon?.visibility = View.GONE
        }else{
            ivIcon?.visibility = View.VISIBLE
        }
        v_head.setRightCustomLayout(rightView)
        faqUrl = freeStakingBean?.faqUrl.toString()
        //Top banner image
        if (isDestroyed) {
            return
        }

        Glide.with(this)
            .load(freeStakingBean?.banner)
            .transform(GlideRoundTransform(this,4))
            .into(iv_head)
        tabList.clear()
        fragmentList.clear()
        tabList.add(LanguageUtil.getString(this,"pos_string_all"))
        for (i in freeStakingBean?.typeConfig!!) {
            tabList.add(i.typeName.toString())

        }
        for (i in 0 until tabList.size) {
            if (i == 0) {
                fragmentList.add(FreeStakingFragment.newInstance(vp_container, "", i))
            } else {
                fragmentList.add(FreeStakingFragment.newInstance(vp_container, freeStakingBean.typeConfig!![i - 1].typeSn!!, i))

            }


        }
        adapter = FreeStakingFragmentAdapter(supportFragmentManager, tabList, fragmentList)
        vp_container.adapter = adapter
        stl_kind.setViewPager(vp_container)
        vp_container.resetHeight(0)
        try {
            vp_container.addOnPageChangeListener(object : ViewPager.OnPageChangeListener {
                override fun onPageScrollStateChanged(state: Int) {
                    /**
                     *0- No change
                     *1- Rolling
                     *2- Sliding completed
                     */
                }

                override fun onPageScrolled(position: Int, positionOffset: Float, positionOffsetPixels: Int) {
                    /**
                     *Position the current page and the page you clicked to slide;
                     *PositionOffset: The percentage of the current page offset;
                     *PositionOffsetPixels: The pixel position offset by the current page
                     */
                }

                override fun onPageSelected(position: Int) {
                    vp_container.currentItem = position
                    vp_container.resetHeight(position)
                    //This processing is done to create an illusion that the latest data is reloaded every time, as it needs to be restored to its original state during each switch
                    EventBus.getDefault().post(NotificationRefreshBean("refresh"))
                }
            })
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }


    /**
     *Obtain FreeStaking homepage data
     */
    private fun getFreeStakingData() {
        HttpClient.instance.getFreeStakingData()
                .subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(object : NetObserver<FreeStakingBean>() {
                    override fun onHandleSuccess(freeStakingBean: FreeStakingBean?) {
                        freeStakingBean?.let {
                            initView(it)
                            initClick()
                        }

                    }

                    override fun onHandleError(code: Int, msg: String?) {
                        super.onHandleError(code, msg)
                    }

                })

    }

}
