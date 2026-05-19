package com.chainup.contract.view

import android.content.Context
import android.graphics.Typeface
import com.google.android.material.appbar.AppBarLayout
import androidx.core.content.ContextCompat
import androidx.appcompat.app.AppCompatActivity
import android.util.AttributeSet
import android.view.Gravity
import android.view.LayoutInflater
import com.chainup.contract.R
import kotlinx.android.synthetic.main.cp_title_bar_layout.view.*

/**
 *Unified title block
 *1. Cooperate with NestedScrollView to handle title bar linkage issues during sliding
 *2. NestedScrollView requires specifying app: layout_ behavior="@string/appbar_scrolling_view_behavior"
 *3. Wrap the outermost layer with CoordinatorLayout
 *4. If the title bar linkage issue is not considered, you can use the PersonalCenterView control
 *The code used is as follows:
 * <com.yjkj.chainup.contract.widget.SlTitleBarLayout
    android:id="@+id/title_layout"
    app:slTitle=""
    android:layout_width="match_parent"
    app:elevation="0dp"
    android:layout_height="@dimen/dp_105"/>
 */
class CpSlTitleBarLayout : AppBarLayout {
    private val layoutInflater: LayoutInflater = LayoutInflater.from(context)

    constructor(context: Context, attrs: AttributeSet?) : super(context, attrs) {
        initAttrs(attrs)
    }

    private fun initAttrs(attrs: AttributeSet?) {
        attrs?.let {
            var typedArray = context.obtainStyledAttributes(it, R.styleable.CpSlTitleBarLayout, 0, 0)
            title = typedArray.getString(R.styleable.CpSlTitleBarLayout_slTitle) ?: ""
            typedArray.recycle()
        }
    }

    var title = ""
        set(value) {
            field = value
            collapsing_toolbar?.title = title
        }


    init {

         layoutInflater.inflate(R.layout.cp_title_bar_layout, this)
        var activity = context as AppCompatActivity
        activity.setSupportActionBar(toolbar)
        toolbar?.setNavigationOnClickListener {
            activity.finish()
        }
         collapsing_toolbar?.let {
            it.setCollapsedTitleTextColor(ContextCompat.getColor(context, R.color.text_color))
            it.setExpandedTitleColor(ContextCompat.getColor(context, R.color.text_color))
            it.setExpandedTitleTypeface(Typeface.DEFAULT_BOLD)
            it.expandedTitleGravity = Gravity.BOTTOM
        }


    }

}
