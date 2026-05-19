package com.chainup.kit.utils


import android.view.View
import androidx.recyclerview.widget.RecyclerView
import com.ethanhua.skeleton.RecyclerViewSkeletonScreen
import com.ethanhua.skeleton.Skeleton
import com.ethanhua.skeleton.SkeletonScreen
import com.ethanhua.skeleton.ViewSkeletonScreen
import com.example.chainup_kit.R


object SkeletonUtil {

    fun showRv(rv: RecyclerView, mSkeletonView :Int): RecyclerViewSkeletonScreen.Builder {
       return Skeleton.bind(rv)
            .count(20)
            .color(R.color.btn_color_2)
            .shimmer(true)
            .angle(0)
            .frozen(false)
            .duration(1200)
            .load(mSkeletonView)
    }

    fun showView(mView: View, mSkeletonView :Int): ViewSkeletonScreen.Builder {
        return Skeleton.bind(mView)
            .color(R.color.card_bg_color_1)
            .angle(0)
            .load(mSkeletonView)
    }

    fun hideSkeleton(mSkeletonScreen: SkeletonScreen) {
        mSkeletonScreen.hide()
    }

    fun showViewBind(mView: View, mSkeletonView :Int): ViewSkeletonScreen.Builder {
        return Skeleton.bind(mView)
            .color(R.color.card_bg_color_1)
            .load(mSkeletonView)
    }

    fun hideSkeletonBind(mSkeletonScreen: SkeletonScreen) {
        mSkeletonScreen.hide()
    }

}
