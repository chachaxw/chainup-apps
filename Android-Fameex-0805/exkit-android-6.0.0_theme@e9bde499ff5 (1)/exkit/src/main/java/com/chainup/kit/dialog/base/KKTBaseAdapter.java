package com.chainup.kit.dialog.base;

import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.LayoutRes;
import androidx.recyclerview.widget.RecyclerView;


import com.chainup.kit.dialog.KKTDialog;

import java.util.List;

/**
 *
 * @author Timmy
 * @time 2018/1/24 14:39
 * @GitHub https://github.com/Timmy-zzh/TDialog
 **/
public abstract class KKTBaseAdapter<T> extends RecyclerView.Adapter<KKBindViewHolder> {

    private final int layoutRes;
    private List<T> datas;
    private OnAdapterItemClickListener adapterItemClickListener;
    private KKTDialog dialog;

    protected abstract void onBind(KKBindViewHolder holder, int position, T t);

    public KKTBaseAdapter(@LayoutRes int layoutRes, List<T> datas) {
        this.layoutRes = layoutRes;
        this.datas = datas;
    }

    @Override
    public KKBindViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
        return new KKBindViewHolder(LayoutInflater.from(parent.getContext()).inflate(layoutRes, parent, false));
    }

    @Override
    public void onBindViewHolder(final KKBindViewHolder holder, final int position) {
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

    public void setTDialog(KKTDialog tDialog) {
        this.dialog = tDialog;
    }

    public interface OnAdapterItemClickListener<T> {
        void onItemClick(KKBindViewHolder holder, int position, T t, KKTDialog tDialog);
    }

    public void setOnAdapterItemClickListener(OnAdapterItemClickListener listener) {
        this.adapterItemClickListener = listener;
    }
}
