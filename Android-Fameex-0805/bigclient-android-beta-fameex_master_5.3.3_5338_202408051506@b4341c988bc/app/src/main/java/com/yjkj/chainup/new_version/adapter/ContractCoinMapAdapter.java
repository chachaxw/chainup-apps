package com.yjkj.chainup.new_version.adapter;

import android.text.TextUtils;
import android.view.View;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.recyclerview.widget.DiffUtil;

import com.chad.library.adapter.base.BaseQuickAdapter;
import com.chad.library.adapter.base.viewholder.BaseViewHolder;
import com.chainup.contract.utils.CpClLogicContractSetting;
import com.yjkj.chainup.R;
import com.yjkj.chainup.manager.NCoinManager;
import com.yjkj.chainup.manager.RateManager;
import com.yjkj.chainup.new_version.home.callback.EmployeeDiffCallback;
import com.yjkj.chainup.util.BigDecimalUtils;
import com.yjkj.chainup.util.ColorUtil;

import org.json.JSONObject;

/**
 * @author Bertking
 * @Date 2023/5/28
 * <p>
 *Reference link: https://blog.csdn.net/csdnzouqi/article/details/53642130
 */
public class ContractCoinMapAdapter extends BaseQuickAdapter<JSONObject, BaseViewHolder> {
    public static final String TAG = ContractCoinMapAdapter.class.getSimpleName();

    boolean isSearch = true;
    boolean leverStatus = false;

    public ContractCoinMapAdapter() {
        super(R.layout.item_coin_map);
    }

    public void setSearch(boolean search) {
        isSearch = search;
    }

    public void setLeverStatus(boolean status) {
        leverStatus = status;
    }

    @Override
    protected void convert(BaseViewHolder helper, JSONObject item) {
        if (item == null) {
            return;
        }
        String symbol = item.optString("symbol");
        if (leverStatus) {
            helper.setGone(R.id.ib_add, true);
            helper.setGone(R.id.tv_market, true);
            helper.setText(R.id.tv_coin, NCoinManager.getShowMarketName(item.optString("name")));
        } else {
            String name = CpClLogicContractSetting.getContractShowNameById(getContext(),item.optInt("id"));
            helper.setText(R.id.tv_coin, name);
            TextView tvSort = helper.getView(R.id.tv_sort);
            if (isSearch) {
//                helper.getView(R.id.ib_add).setVisibility(View.GONE);
                tvSort.setVisibility(View.VISIBLE);
//                int temp = helper.getAdapterPosition();
//                tvSort.setText((temp + 1) + "");
            } else {
//                helper.getView(R.id.ib_add).setVisibility(View.VISIBLE);
                tvSort.setVisibility(View.GONE);
            }
            boolean isAdd = CpClLogicContractSetting.hasCollect(getContext(),item.optInt("id"));
            if(isAdd){
                try {
                    item.put("isAdd",isAdd);
                }catch (Exception e){
                    e.printStackTrace();
                }
            }
            /**
             *Initialization status
             */
            if (isAdd) {
                ((ImageView) helper.getView(R.id.ib_add)).setImageResource(R.mipmap.public_favorites);
            } else {
                ((ImageView) helper.getView(R.id.ib_add)).setImageResource(R.mipmap.public_notfavorited);
            }


            String close = item.optString("close");
            if (TextUtils.isEmpty(close)) {
                helper.setText(R.id.tv_close_price, "--");
            } else {
                helper.setText(R.id.tv_close_price, close);
            }

            String rose = item.optString("rose");
            TextView tvRose = (TextView) helper.getView(R.id.tv_rose);
            RateManager.Companion.getRoseText(tvRose, rose);

            tvRose.setTextColor(ColorUtil.INSTANCE.getMainColorV2Type(getContext(),RateManager.Companion.getRoseTrend(rose)));
        }
    }

    public void setDiffData(EmployeeDiffCallback diffCallback) {
        if (getEmptyLayout() != null && getEmptyLayout().getChildCount() == 1) {
            setList(diffCallback.getNewData());
            return;
        }
        DiffUtil.DiffResult diffResult = DiffUtil.calculateDiff(diffCallback, true);
        diffResult.dispatchUpdatesTo(this);
        setData$com_github_CymChad_brvah(diffCallback.getNewData());
    }




    public int getCurrentPosition(int position) {
        return getHeaderLayoutCount() + position;
    }

}
