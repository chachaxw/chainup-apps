package com.chainup.kit.dialog.listener;

import android.view.View;

import com.chainup.kit.dialog.KKTDialog;
import com.chainup.kit.dialog.base.KKBindViewHolder;


public interface OnKKViewClickListener {
    void onViewClick(KKBindViewHolder viewHolder, View view, KKTDialog tDialog);
}
