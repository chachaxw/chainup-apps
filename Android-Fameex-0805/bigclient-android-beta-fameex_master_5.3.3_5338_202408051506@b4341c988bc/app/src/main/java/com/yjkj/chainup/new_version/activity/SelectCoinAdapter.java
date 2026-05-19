package com.yjkj.chainup.new_version.activity;

import androidx.annotation.Nullable;
import android.text.TextUtils;
import android.util.Log;
import android.widget.Filter;
import android.widget.Filterable;

import com.chad.library.adapter.base.BaseQuickAdapter;
import com.chad.library.adapter.base.viewholder.BaseViewHolder;
import com.yjkj.chainup.R;
import com.yjkj.chainup.bean.coin.CoinBean;
import com.yjkj.chainup.manager.NCoinManager;
import com.yjkj.chainup.util.GlideUtils;

import java.util.ArrayList;
import java.util.List;

/**
 * @author Bertking
 *@description Search currency
 * @Date 2023/6/7
 */
public class SelectCoinAdapter extends BaseQuickAdapter<CoinBean, BaseViewHolder> implements Filterable {
    private MyFilter filter = null;
    private FilterListener listener = null;
    private List<CoinBean> list = new ArrayList<>();
    private List<CoinBean> beanList = new ArrayList<>();
    private int position;


    public SelectCoinAdapter(@Nullable List<CoinBean> data, int position) {
        super(R.layout.item_select_coin, data);
        this.list = data;
        this.beanList = data;
        this.position = position;
    }


    public void setListener(FilterListener listener) {
        this.listener = listener;
    }

    @Override
    protected void convert(BaseViewHolder helper, CoinBean item) {
        if (item == null) return;
        GlideUtils.loadCoinIcon(getContext(), item.getName(), helper.getView(R.id.iv_coin));
        helper.setText(R.id.tv_coin, NCoinManager.getShowMarket(item.getName()));
//        helper.setVisible(R.id.iv_selected, item.isSelected());
    }

    @Override
    public Filter getFilter() {
        if (filter == null) {
            filter = new MyFilter(list);
        }
        return filter;
    }


    public interface FilterListener {
        void getFilterData(List<CoinBean> list);//Obtain filtered data
    }


    /**
     *Create Inner class to filter data
     */
    class MyFilter extends Filter {
        private List<CoinBean> originalData = new ArrayList<>();

        public MyFilter(List<CoinBean> originalData) {
            this.originalData = originalData;
        }

        /**
         *This method returns search filtered data
         *
         * @param constraint
         * @return
         */
        @Override
        protected FilterResults performFiltering(CharSequence constraint) {
            FilterResults results = new FilterResults();
/**
 *If there is no search content, assign the value and size of the original data to results
 *If the search is performed, filter according to the search rules, and finally assign the value and size of the filtered data to the results
 *
 */
            if (TextUtils.isEmpty(constraint)) {
                results.values = beanList;
                results.count = beanList.size();
            } else {
                //Create a collection to save filtered data
                List<CoinBean> filteredList = new ArrayList<CoinBean>();
                //Traverse the original data set and filter the data according to the search rules
                for (CoinBean s : originalData) {
                    //Here is the specific implementation of filtering rules. There are many rules, and you can decide how to implement them yourself
                    if (NCoinManager.getShowMarket(s.getName()).toLowerCase().contains(constraint.toString().trim().toLowerCase())) {
                        //If the rules match, add the data to the set
                        filteredList.add(s);
                    }
                }
                results.values = filteredList;
                results.count = filteredList.size();
            }

            //Returns the FilterResults object
            return results;
        }

        /**
         *This method is used to refresh the user interface and redisplay the list based on filtered data
         */
        @Override
        protected void publishResults(CharSequence constraint, FilterResults results) {

            //Obtain filtered data
            list = (List<CoinBean>) results.values;
            //If the interface object is not empty, then call the method in the interface to obtain the filtered data, and the specific implementation is executed in the method rewritten when the interface is new
            if (listener != null) {
                listener.getFilterData(list);
            }
            //Refresh Data Source Display
            notifyDataSetChanged();
            notifyItemRangeChanged(0, list.size());
        }
    }


}
