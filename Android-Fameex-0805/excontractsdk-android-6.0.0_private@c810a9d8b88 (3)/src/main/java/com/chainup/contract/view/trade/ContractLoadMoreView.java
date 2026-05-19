package com.chainup.contract.view.trade;

import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import androidx.annotation.NonNull;

import com.chad.library.adapter.base.loadmore.BaseLoadMoreView;
import com.chad.library.adapter.base.viewholder.BaseViewHolder;
import com.chainup.contract.R;
import com.yjkj.chainup.manager.CpLanguageUtil;

//Contract Load More
public class ContractLoadMoreView extends BaseLoadMoreView {

    @NonNull
    @Override
    public View getLoadComplete(@NonNull BaseViewHolder baseViewHolder) {
        baseViewHolder.setText(R.id.tv_cp_loadmore_finish, CpLanguageUtil.getString(baseViewHolder.itemView.getContext(), "cp_loadmore_finish"));
        return baseViewHolder.findView(R.id.view_loadComplete);
    }

    @NonNull
    @Override
    public View getLoadEndView(@NonNull BaseViewHolder baseViewHolder) {
        baseViewHolder.setText(R.id.tv_cp_loadmore_nodata, CpLanguageUtil.getString(baseViewHolder.itemView.getContext(), "cp_loadmore_nodata"));
        return baseViewHolder.findView(R.id.view_loadEnd);
    }

    @NonNull
    @Override
    public View getLoadFailView(@NonNull BaseViewHolder baseViewHolder) {
        baseViewHolder.setText(R.id.tv_cp_loadmore_failed, CpLanguageUtil.getString(baseViewHolder.itemView.getContext(), "cp_loadmore_failed"));
        return baseViewHolder.findView(R.id.view_loadFail);
    }

    @NonNull
    @Override
    public View getLoadingView(@NonNull BaseViewHolder baseViewHolder) {
        baseViewHolder.setText(R.id.tv_cp_loadmore_loading, CpLanguageUtil.getString(baseViewHolder.itemView.getContext(), "cp_loadmore_loading"));
        return baseViewHolder.findView(R.id.view_loading);
    }

    @NonNull
    @Override
    public View getRootView(@NonNull ViewGroup viewGroup) {
        return LayoutInflater.from(viewGroup.getContext()).inflate(R.layout.contract_layout_loadmore,viewGroup,false);
    }
}
