package com.yjkj.chainup.new_version.view;

import androidx.recyclerview.widget.GridLayoutManager;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import android.view.View;
import android.view.ViewGroup;

import java.lang.reflect.Field;

/**
 * @Author lianshangljl
 * @Date 2023/6/10-2:11 PM
 * @Email buptjinlong@163.com
 * @description
 */
public class WapHeaderAndFooterAdapter extends RecyclerView.Adapter<RecyclerView.ViewHolder> {

    private int headtype = 0x11111;
    private int normaltype = 0x11112;
    private int foottype = 0x11113;
    private View headerView;
    private View footerView;
    private RecyclerView.Adapter badapter;//Target adapter
    private int mOrientation = -1;
    private OnLoadMoreListener onloadMoreListener;

    public WapHeaderAndFooterAdapter(RecyclerView.Adapter badapter) {
        this.badapter = badapter;
    }

    public void addHeader(View header) {
        headerView = header;
    }

    public void removeHeader() {
        headerView = null;
    }

    public void addFooter(View footer) {
        footerView = footer;
    }

    private boolean loadMore = false;

    //Implement loading more interfaces
    public void setOnloadMoreListener(final OnLoadMoreListener onloadMoreListener, RecyclerView recyclerView) {

        this.onloadMoreListener = onloadMoreListener;
        if (recyclerView != null && onloadMoreListener != null) {
            recyclerView.addOnScrollListener(new RecyclerView.OnScrollListener() {
                @Override
                public void onScrollStateChanged(RecyclerView recyclerView, int newState) {
                    super.onScrollStateChanged(recyclerView, newState);
                    if (newState == RecyclerView.SCROLL_STATE_IDLE) {
                        final RecyclerView.LayoutManager layoutManager = recyclerView.getLayoutManager();
                        int lastVisiblePosition = 0;
                        if (layoutManager instanceof LinearLayoutManager) {
                            lastVisiblePosition = ((LinearLayoutManager) layoutManager).findLastVisibleItemPosition();
                        } else if (layoutManager instanceof GridLayoutManager) {
                            lastVisiblePosition = ((GridLayoutManager) layoutManager).findLastVisibleItemPosition();
                        }
                        if (lastVisiblePosition >= layoutManager.getItemCount() - 1 && loadMore) {
                            loadMore = false;
                            if (onloadMoreListener != null) {
                                onloadMoreListener.onLoadMore();
                            }
                        }
                    }
                }

                @Override
                public void onScrolled(RecyclerView recyclerView, int dx, int dy) {
                    super.onScrolled(recyclerView, dx, dy);
                    loadMore = dy > 0;
                }
            });
        }
    }

    /**
     *Return the corresponding type based on the head and tail. If else is not abbreviated here, making it easy to see the logic
     *
     * @param position
     * @return
     */
    @Override
    public int getItemViewType(int position) {

        if (headerView != null && footerView != null)//Added both head and tail
        {
            if (position == 0)//When position is 0, display the header
            {
                return headtype;
            } else if (position == getItemCount() - 1)//When the position is the last one, display the footer
            {
                return foottype;
            } else//At other times, display the original adapter
            {
                if (badapter.getItemCount() > 1) {
                    return badapter.getItemViewType(position);
                }
                return normaltype;
            }
        } else if (headerView != null) {//Only the head
            if (position == 0)
                return headtype;
            if (badapter.getItemCount() > 1) {
                return badapter.getItemViewType(position);
            }
            return normaltype;
        } else if (footerView != null)//Only the tail
        {
            if (position == getItemCount() - 1) {
                return foottype;
            } else {
                if (badapter.getItemCount() > 1) {
                    return badapter.getItemViewType(position);
                }
                return normaltype;
            }
        } else {
            if (badapter.getItemCount() > 1) {
                return badapter.getItemViewType(position);
            }
            return normaltype;
        }
    }

    /**
     *Here, the corresponding ViewHolder is returned based on the value returned by getItemViewType
     *The ViewHolder for the head and tail is just a simple default class that integrates RecyclerView. ViewHolder, and there is no processing in it.
     *This completes the return of the type (pay attention to Wae Ireoni?)
     *
     * @param parent
     * @param viewType
     * @return
     */
    @Override
    public RecyclerView.ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
        if (viewType == headtype)//Return the ViewHolder of the header
            return new HeaderViewHolder(headerView);
        else if (viewType == foottype)//Returns the ViewHolder at the end
            return new FoogerViewHolder(footerView);//Return the ViewHolder of the incoming adapter directly for the others
        return badapter.onCreateViewHolder(parent, viewType);
    }

    /**
     *When binding ViewHolder, when the header or footer is used, it is returned directly because there is no need to bind it,
     *When the adapter is passed in, simply call adapter. onBindViewHolder
     *
     * @param holder
     * @param position
     */
    @Override
    public void onBindViewHolder(RecyclerView.ViewHolder holder, final int position) {

        if (footerView != null) {
            footerView.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    if (onloadMoreListener != null) {
                        onloadMoreListener.onClickLoadMore();
                    }
                }
            });
        }

        if (headerView != null && footerView != null)//Having a head and tail
        {
            if (position == 0)//Head directly returns without binding
            {
                return;
            } else if (position == getItemCount() - 1)//The tail returns directly without binding
            {
                return;
            } else {
                holder.itemView.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        if (onloadMoreListener != null) {
                            onloadMoreListener.onItemClick(v, position - 1);
                        }
                    }
                });
                badapter.onBindViewHolder(holder, position - 1);//Call the adapter's binding method for the rest
            }
        } else if (headerView != null) {
            if (position == 0) {
                return;
            } else {
                holder.itemView.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        if (onloadMoreListener != null) {
                            onloadMoreListener.onItemClick(v, position - 1);
                        }
                    }
                });
                badapter.onBindViewHolder(holder, position - 1);
            }
        } else if (footerView != null) {
            if (position == getItemCount() - 1) {
                return;
            } else {
                holder.itemView.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        if (onloadMoreListener != null) {
                            onloadMoreListener.onItemClick(v, position);
                        }
                    }
                });
                badapter.onBindViewHolder(holder, position);
            }
        } else {
            holder.itemView.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    if (onloadMoreListener != null) {
                        onloadMoreListener.onItemClick(v, position);
                    }
                }
            });
            badapter.onBindViewHolder(holder, position);
        }
    }

    /**
     *Returns the number of items,
     *
     * @return
     */
    @Override
    public int getItemCount() {
        if (badapter == null) {
            return 0;
        }
        if (headerView != null && footerView != null)//With a head and tail, there are 2 more
        {
            return badapter.getItemCount() + 2;
        } else if (headerView != null)//Only one more head
        {
            return badapter.getItemCount() + 1;
        } else if (footerView != null)//Only the tail has an extra 1
        {
            return badapter.getItemCount() + 1;
        }
        return badapter.getItemCount();//The rest are the default values, no more, no less
    }

    /**
     *ViewHolder for the head
     */
    private class HeaderViewHolder extends RecyclerView.ViewHolder {
        public HeaderViewHolder(View itemView) {
            super(itemView);
        }
    }

    /**
     *ViewHolder at the tail
     */
    private class FoogerViewHolder extends RecyclerView.ViewHolder {
        public FoogerViewHolder(View itemView) {
            super(itemView);
        }
    }

    /**
     *When dealing with the effects of the Gridview type at that time, the head and tail were also set to a whole row (which is one of the advantages of RecyclerView, where each row of the list can have different numbers of columns)
     *
     * @param recyclerView
     */
    @Override
    public void onAttachedToRecyclerView(RecyclerView recyclerView) {
        final RecyclerView.LayoutManager layoutManager = recyclerView.getLayoutManager();
        mOrientation = getOrientation(layoutManager);
        if (layoutManager instanceof GridLayoutManager) {
            /**
             *The return value of getSpanSize means: how many columns does the width of the item at position occupy
             *For example, if the total number is 4 columns and all the headers are displayed, it should occupy 4 columns. At this point, 4 is returned
             *The others only occupy one column, so it returns 1, and the remaining three columns are filled in sequence by the following items.
             */
            ((GridLayoutManager) layoutManager).setSpanSizeLookup(new GridLayoutManager.SpanSizeLookup() {
                @Override
                public int getSpanSize(int position) {
                    if (headerView != null && footerView != null) {
                        if (position == 0) {
                            return ((GridLayoutManager) layoutManager).getSpanCount();
                        } else if (position == getItemCount() - 1) {
                            return ((GridLayoutManager) layoutManager).getSpanCount();
                        } else {
                            return 1;
                        }
                    } else if (headerView != null) {
                        if (position == 0) {
                            return ((GridLayoutManager) layoutManager).getSpanCount();
                        }
                        return 1;
                    } else if (footerView != null) {
                        if (position == getItemCount() - 1) {
                            return ((GridLayoutManager) layoutManager).getSpanCount();
                        }
                        return 1;
                    }
                    return 1;
                }
            });

        }
    }

    /**
     *Determine if it's at the bottom
     *
     * @param recyclerView
     * @return
     */
    protected boolean isSlideToBottom(RecyclerView recyclerView) {
        if (recyclerView == null) return false;
        if (mOrientation == LinearLayoutManager.VERTICAL) {
            return recyclerView.computeVerticalScrollExtent() + recyclerView.computeVerticalScrollOffset() >= recyclerView.computeVerticalScrollRange();
        } else {
            return recyclerView.computeHorizontalScrollExtent() + recyclerView.computeHorizontalScrollOffset() >= recyclerView.computeHorizontalScrollRange();
        }
    }

    /**
     *Load more callback interfaces
     */
    public interface OnLoadMoreListener {
        void onLoadMore();

        void onClickLoadMore();

        void onItemClick(View view, int position);
    }

    private int getOrientation(RecyclerView.LayoutManager layoutManager) {
        int mOrientation = 0;
        Class<?> clazz = null;
        try {
            clazz = Class.forName("androidx.recyclerview.widget.LinearLayoutManager");
            Field field = clazz.getDeclaredField("mOrientation");
            field.setAccessible(true);
            mOrientation = field.getInt(layoutManager);
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
        } catch (IllegalAccessException e) {
            e.printStackTrace();
        } catch (NoSuchFieldException e) {
            e.printStackTrace();
        }
        return mOrientation;
    }

}
