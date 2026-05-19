package com.yjkj.chainup.new_version.adapter;

import androidx.annotation.Nullable;

import com.chad.library.adapter.base.BaseQuickAdapter;
import com.chad.library.adapter.base.viewholder.BaseViewHolder;
import com.fengniao.news.util.DateUtil;
import com.yjkj.chainup.R;
import com.yjkj.chainup.app.AppConstant;
import com.yjkj.chainup.bean.fund.CashFlowBean;
import com.yjkj.chainup.manager.LanguageUtil;
import com.yjkj.chainup.manager.NCoinManager;
import com.yjkj.chainup.util.BigDecimalUtils;

import java.util.List;

import static com.yjkj.chainup.new_version.activity.asset.ChargeSymbolRecordActivityKt.OTC_TRANSFER;
import static com.yjkj.chainup.new_version.activity.asset.ChargeSymbolRecordActivityKt.OTHER_INDEX;
import static com.yjkj.chainup.new_version.activity.asset.ChargeSymbolRecordActivityKt.RECHARGE_INDEX;
import static com.yjkj.chainup.new_version.activity.asset.ChargeSymbolRecordActivityKt.WITHDRAW_INDEX;

/**
 * @author Bertking
 * @Date 2023/5/23
 * <p>
 */
public class CashFlowAdapter extends BaseQuickAdapter<CashFlowBean.Finance, BaseViewHolder> {

    int index = 0;


    public int getIndex() {
        return index;
    }

    public void setIndex(int index) {
        this.index = index;
    }

    public CashFlowAdapter(@Nullable List<CashFlowBean.Finance> data) {
        super(R.layout.item_cashflow_com, data);
    }

    @Override
    protected void convert(BaseViewHolder helper, CashFlowBean.Finance item) {
        if (item == null) {
            return;
        }
        helper.setText(R.id.tv_title, item.getType_text());
        switch (index) {
            case RECHARGE_INDEX:

                //Date
                helper.setText(R.id.tv_date, item.getTranCreateTime());

                //Transfer quantity
                helper.setText(R.id.tv_count, BigDecimalUtils.divForDown(item.getAmount(), NCoinManager.getCoinShowPrecision(item.getCoinSymbol())).toPlainString());

                //Status//'Recharge status: 0 unconfirmed, 1 completed, 2 abnormal'
                helper.setText(R.id.tv_status, item.getStatusText());


                break;
            case WITHDRAW_INDEX:

                //Date
                helper.setText(R.id.tv_date, item.getTranCreateTime());


                //Transfer quantity
                helper.setText(R.id.tv_count, BigDecimalUtils.divForDown(item.getAmount(), NCoinManager.getCoinShowPrecision(item.getCoinSymbol())).toPlainString());

                //Status/Withdrawal Status: 0 Not Reviewed, 1 Reviewed, 2 Reviewed Rejected, 3 Payment in Progress, 4 Payment Failed, 5 Completed, 6 Revoked
                helper.setText(R.id.tv_status, item.getStatusText());


                break;
            case OTHER_INDEX:

                if (AppConstant.Companion.getIS_NEW_CONTRACT()) {
                    //Date
                    helper.setText(R.id.tv_date, DateUtil.INSTANCE.longToString("yyyy-MM-dd HH:mm:ss", item.getCreatedAtTime()));
                    //Transfer quantity
                    helper.setText(R.id.tv_count, BigDecimalUtils.divForDown(item.getAmount(), NCoinManager.getCoinShowPrecision(item.getCoinSymbol())).toPlainString());
                    //Status//"status": 1 transfer in 2 transfer out
                    String statusStr = "";
                    if (item.getStatus() == 1) {
                        statusStr = LanguageUtil.getString(getContext(),"contract_assets_record_transfer_from_swap_account");
                    } else {
                        statusStr = LanguageUtil.getString(getContext(),"contract_assets_record_transfer_to_swap_account");
                    }
                    helper.setText(R.id.tv_status, statusStr);
                } else {
                    //Date
                    helper.setText(R.id.tv_date, item.getTranCreateTime());
                    //Transfer quantity
                    helper.setText(R.id.tv_count, BigDecimalUtils.divForDown(item.getAmount(), NCoinManager.getCoinShowPrecision(item.getCoinSymbol())).toPlainString());
                    //Status//'Recharge status: 0 unconfirmed, 1 completed, 2 abnormal'
                    helper.setText(R.id.tv_status, item.getStatusText());
                }


                break;
            case OTC_TRANSFER:
                //Date
                helper.setText(R.id.tv_date, item.getCreateTime());


                //Transfer quantity
                helper.setText(R.id.tv_count, BigDecimalUtils.divForDown(item.getAmount(), NCoinManager.getCoinShowPrecision(item.getCoinSymbol())).toPlainString());

                //Status//'Recharge status: 0 unconfirmed, 1 completed, 2 abnormal'
                helper.setText(R.id.tv_status, item.getTransactionType_text());

                break;
            default:
                break;
        }


    }
}
