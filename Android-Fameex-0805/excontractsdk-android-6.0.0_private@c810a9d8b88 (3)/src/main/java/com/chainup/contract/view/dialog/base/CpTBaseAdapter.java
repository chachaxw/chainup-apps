package com.chainup.contract.view.dialog.base;

import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.LayoutRes;
import androidx.recyclerview.widget.RecyclerView;

import com.chainup.contract.view.dialog.CpTDialog;

import java.util.List;
/**
 *
 * @author Timmy
 * @time 2018/1/24 14:39
 * @GitHub https://github.com/Timmy-zzh/TDialog
 **/
public abstract class CpTBaseAdapter<T> extends RecyclerView.Adapter<CpBindViewHolder> {

    private final int layoutRes;
    private List<T> datas;
    private OnAdapterItemClickListener adapterItemClickListener;
    private CpTDialog dialog;

    protected abstract void onBind(CpBindViewHolder holder, int position, T t);

    public CpTBaseAdapter(@LayoutRes int layoutRes, List<T> datas) {
        this.layoutRes = layoutRes;
        this.datas = datas;
    }

    @Override
    public CpBindViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
        return new CpBindViewHolder(LayoutInflater.from(parent.getContext()).inflate(layoutRes, parent, false));
    }

    @Override
    public void onBindViewHolder(final CpBindViewHolder holder, final int position) {
        onBind(holder, position, datas.get(position));
        holder.itemView.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                adapterItemClickListener.onItemClick(holder, position, datas.get(position), dialog);
            }
        });
    }

    @Override
    public int getItemCount() {
        return datas.size();
    }

    public void setTDialog(CpTDialog tDialog) {
        this.dialog = tDialog;
    }

    public interface OnAdapterItemClickListener<T> {
        void onItemClick(CpBindViewHolder holder, int position, T t, CpTDialog tDialog);
    }

    public void setOnAdapterItemClickListener(OnAdapterItemClickListener listener) {
        this.adapterItemClickListener = listener;
    }
}
