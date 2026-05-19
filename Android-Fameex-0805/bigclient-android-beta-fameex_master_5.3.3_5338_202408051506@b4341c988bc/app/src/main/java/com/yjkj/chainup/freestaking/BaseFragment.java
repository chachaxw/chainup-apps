package com.yjkj.chainup.freestaking;


import androidx.fragment.app.Fragment;

public abstract class BaseFragment extends Fragment {

    /**Is the current state of the fragment visible*/
    protected boolean isVisible;

    //Each fragment in the setUserVisibleHint adapter will be called when switching. If switching to the current page, isVisibleToUser==true, otherwise false
    @Override
    public void setUserVisibleHint(boolean isVisibleToUser) {
        super.setUserVisibleHint(isVisibleToUser);
        if(isVisibleToUser) {
            isVisible = true;
            onVisible();
        } else {
            isVisible = false;
            onInvisible();
        }
    }


    /**
     *Visible
     */
    protected void onVisible() {
        lazyLoad();
    }


    /**
     *Invisible
     */
    protected void onInvisible() {


    }

    /**
     *Delayed loading
     *Subclass must override this method
     */
    protected abstract void lazyLoad();


}
