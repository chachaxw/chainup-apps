package com.chainup.contract.view.dialog.listener;

import android.view.View;

import com.chainup.contract.view.dialog.CpTDialog;
import com.chainup.contract.view.dialog.base.CpBindViewHolder;

public interface OnCpViewClickListener {
    void onViewClick(CpBindViewHolder viewHolder, View view, CpTDialog tDialog);
}
