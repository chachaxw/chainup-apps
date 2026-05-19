package com.yjkj.chainup.new_version.view;

import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;

import com.chad.library.adapter.base.loadmore.BaseLoadMoreView;
import com.chad.library.adapter.base.viewholder.BaseViewHolder;
import com.yjkj.chainup.R;
import com.yjkj.chainup.manager.LanguageUtil;

//spot loading more
public class SpotLoadMoreView extends BaseLoadMoreView {

    @NonNull
    @Override
    public View getLoadComplete(@NonNull BaseViewHolder baseViewHolder) {
        baseViewHolder.setText(R.id.tv_cp_loadmore_finish, LanguageUtil.getString(baseViewHolder.itemView.getContext(), "cp_loadmore_finish"));
        return baseViewHolder.findView(R.id.view_loadComplete);
    }

    @NonNull
    @Override
    public View getLoadEndView(@NonNull BaseViewHolder baseViewHolder) {
//        baseViewHolder.setText(R.id.tv_cp_loadmore_nodata, LanguageUtil.getString(baseViewHolder.itemView.getContext(), "common_text_noMoreData"));
        baseViewHolder.setText(R.id.tv_cp_loadmore_nodata, "");
        return baseViewHolder.findView(R.id.view_loadEnd);
    }

    @NonNull
    @Override
    public View getLoadFailView(@NonNull BaseViewHolder baseViewHolder) {
        baseViewHolder.setText(R.id.tv_cp_loadmore_failed, LanguageUtil.getString(baseViewHolder.itemView.getContext(), "cp_loadmore_failed"));
        return baseViewHolder.findView(R.id.view_loadFail);
    }

    @NonNull
    @Override
    public View getLoadingView(@NonNull BaseViewHolder baseViewHolder) {
        baseViewHolder.setText(R.id.tv_cp_loadmore_loading, LanguageUtil.getString(baseViewHolder.itemView.getContext(), "loading"));
        return baseViewHolder.findView(R.id.view_loading);
    }

    @NonNull
    @Override
    public View getRootView(@NonNull ViewGroup viewGroup) {
        return LayoutInflater.from(viewGroup.getContext()).inflate(R.layout.spot_layout_loadmore,viewGroup,false);
    }
}
