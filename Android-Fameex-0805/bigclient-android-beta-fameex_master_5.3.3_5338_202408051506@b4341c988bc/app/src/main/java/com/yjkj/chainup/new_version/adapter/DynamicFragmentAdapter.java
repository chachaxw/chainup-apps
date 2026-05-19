package com.yjkj.chainup.new_version.adapter;

import android.os.Parcelable;
import androidx.fragment.app.Fragment;
import androidx.fragment.app.FragmentManager;
import androidx.fragment.app.FragmentStatePagerAdapter;
import androidx.viewpager.widget.PagerAdapter;
import android.view.ViewGroup;

import java.util.ArrayList;
import java.util.List;

/**
 * @author Voctex
 * on 2018/08/28 18:07
 */
public class DynamicFragmentAdapter extends FragmentStatePagerAdapter {
    private FragmentManager mFragmentManager;
    private List<Fragment> mFragments = new ArrayList<>();

    public DynamicFragmentAdapter(FragmentManager fm, List<Fragment> list) {
        super(fm);
        this.mFragmentManager = fm;
        if (list == null) return;
        this.mFragments.addAll(list);
    }

    public void updateData(List<Fragment> mlist) {
        if (mlist == null) return;
        this.mFragments.clear();
        this.mFragments.addAll(mlist);
        notifyDataSetChanged();
    }

    @Override
    public Fragment getItem(int arg0) {
        return mFragments.get(arg0);//
    }

    @Override
    public int getCount() {
        return mFragments.size();//
    }

    @Override
    public Parcelable saveState() {
        return null;
    }

    @Override
    public int getItemPosition(Object object) {
        if (!((Fragment) object).isAdded() || !mFragments.contains(object)) {
            return PagerAdapter.POSITION_NONE;
        }
        return mFragments.indexOf(object);
    }

    @Override
    public Object instantiateItem(ViewGroup container, int position) {

        Fragment instantiateItem = ((Fragment) super.instantiateItem(container, position));
        Fragment item = mFragments.get(position);
        if (instantiateItem == item) {
            return instantiateItem;
        } else {
            //If the fragment corresponding to the subscript in the set is inconsistent with the fragment object corresponding to the subscript in the FragmentManager, then it is a new addition, so add it yourself to enter; Why not directly call the super method here, because the mIndex of the fragment is a problem, and there will be opportunities to make up for it in the future.
            mFragmentManager.beginTransaction().add(container.getId(), item).commitNowAllowingStateLoss();
            return item;
        }
    }

    @Override
    public void destroyItem(ViewGroup container, int position, Object object) {
        Fragment fragment = (Fragment) object;
        //If the value in getItemPosition is PagerAdapter.POSITION_ NONE, execute the method.
        if (mFragments.contains(fragment)) {
            super.destroyItem(container, position, fragment);
            return;
        }
        //Perform the removal yourself. Because mFragments removes a certain fragment object during deletion, it is generally necessary to remove the object in the FragmentManager by oneself.
        mFragmentManager.beginTransaction().remove(fragment).commitNowAllowingStateLoss();

    }
}
