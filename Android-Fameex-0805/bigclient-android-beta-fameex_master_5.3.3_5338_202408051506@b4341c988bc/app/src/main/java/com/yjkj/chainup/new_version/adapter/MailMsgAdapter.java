package com.yjkj.chainup.new_version.adapter;

import androidx.annotation.Nullable;
import androidx.annotation.RequiresApi;

import android.os.Build;
import android.util.Log;

import com.chad.library.adapter.base.BaseQuickAdapter;
import com.chad.library.adapter.base.viewholder.BaseViewHolder;
import com.fengniao.news.util.DateUtil;
import com.yjkj.chainup.R;
import com.yjkj.chainup.bean.Message;
import com.yjkj.chainup.bean.dev.MessageBean;
import com.yjkj.chainup.manager.LanguageUtil;

import java.util.List;

/**
 * @author Bertking
 * @Date 2023/5/24
 *@description The item adapter for the message on the website
 */
public class MailMsgAdapter extends BaseQuickAdapter<MessageBean.UserMessage, BaseViewHolder> {
    public static final String TAG = MailMsgAdapter.class.getSimpleName();

    private List<MessageBean.Type> typeList;

    public MailMsgAdapter(@Nullable List<MessageBean.UserMessage> data, List<MessageBean.Type> typeList) {
        super(R.layout.item_msg_mail, data);
        this.typeList = typeList;
    }

    @Override
    protected void convert(BaseViewHolder helper, MessageBean.UserMessage item) {
        

        /**
         *1- Unread, 2- Read
         */
        helper.getView(R.id.iv_msg_status).setBackgroundResource(item.getStatus() == 1 ? R.drawable.shape_banner_point_bg_disable : R.drawable.ic_dot);
        helper.setVisible(R.id.iv_msg_status,item.getStatus()==1);
        if (item.getStatus()==1){
        helper.setTextColor(R.id.tv_type_title, getContext().getResources().getColor(R.color.text_color));
        helper.setTextColor(R.id.tv_content, getContext().getResources().getColor(R.color.text_color));
        }else {
            helper.setTextColor(R.id.tv_type_title, getContext().getResources().getColor(R.color.normal_text_color));
            helper.setTextColor(R.id.tv_content, getContext().getResources().getColor(R.color.normal_text_color));
        }


        for (MessageBean.Type type : typeList) {
            if (type.getTid() == item.getMessageType()) {
                helper.setText(R.id.tv_type_title, type.getTitle());
            }
        }
        helper.setText(R.id.tv_ctime, DateUtil.INSTANCE.longToString("yyyy-MM-dd HH:mm:ss", item.getCtime()));
        helper.setText(R.id.tv_content, item.getMessageContent());

    }
}
