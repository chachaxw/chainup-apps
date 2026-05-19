package com.chainup.contract.listener;

import androidx.fragment.app.FragmentManager;

import com.timmy.tdialog.base.BindViewHolder;

public interface OnTDBindViewListener {
    void bindView(BindViewHolder viewHolder, FragmentManager fm);
}
