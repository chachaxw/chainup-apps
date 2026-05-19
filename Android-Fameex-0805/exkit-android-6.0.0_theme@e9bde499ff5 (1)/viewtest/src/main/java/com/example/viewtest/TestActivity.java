package com.example.viewtest;

import android.content.Intent;
import android.os.Bundle;
import android.text.InputFilter;
import android.view.View;
import android.widget.EditText;

import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.content.ContextCompat;

import com.chainup.kit.dialog.KKLoadingDialog;
import com.chainup.kit.utils.InputPatternFilter;
import com.chainup.kit.views.KKCommonListItemView;
import com.qmuiteam.qmui.util.QMUIStatusBarHelper;

public class TestActivity extends AppCompatActivity {
    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.layout_test);
        QMUIStatusBarHelper.translucent(this, ContextCompat.getColor(this, R.color.card_bg_color_1));
        QMUIStatusBarHelper.setStatusBarLightMode(this);

        ((KKCommonListItemView) this.findViewById(R.id.kkItemViewItem0)).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                startActivity(new Intent(TestActivity.this, RefreshActivity.class));
            }
        });

        ((KKCommonListItemView) this.findViewById(R.id.kkItemViewItem0_1)).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                showLoadingDialog();
            }
        });


        ((KKCommonListItemView) this.findViewById(R.id.kkItemViewItem0_2)).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                startActivity(new Intent(TestActivity.this, SkeletonActivity.class));
            }
        });

        ((KKCommonListItemView) this.findViewById(R.id.kkItemViewItem0_3)).setOnClickListener(new View.OnClickListener() {

            @Override
            public void onClick(View view) {
                startActivity(new Intent(TestActivity.this, TagActivity.class));
            }
        });


        ((KKCommonListItemView) this.findViewById(R.id.kkItemViewItem0_4)).setOnClickListener(new View.OnClickListener() {

            @Override
            public void onClick(View view) {
                startActivity(new Intent(TestActivity.this, DropDownActivity.class));
            }
        });


        ((KKCommonListItemView) this.findViewById(R.id.kkItemViewItem0_5)).setOnClickListener(new View.OnClickListener() {

            @Override
            public void onClick(View view) {
                startActivity(new Intent(TestActivity.this, BtnActivity.class));
            }
        });


        ((KKCommonListItemView) this.findViewById(R.id.kkItemViewItem0_6)).setOnClickListener(new View.OnClickListener() {

            @Override
            public void onClick(View view) {
                startActivity(new Intent(TestActivity.this, SwitchActivity.class));
            }
        });


        ((KKCommonListItemView) this.findViewById(R.id.kkItemViewItem0_7)).setOnClickListener(new View.OnClickListener() {

            @Override
            public void onClick(View view) {
                startActivity(new Intent(TestActivity.this, DialogActivity.class));
            }
        });


        ((KKCommonListItemView) this.findViewById(R.id.kkItemViewItem0_8)).setOnClickListener(new View.OnClickListener() {

            @Override
            public void onClick(View view) {
                startActivity(new Intent(TestActivity.this, TitleActivity.class));
            }
        });


        ((KKCommonListItemView) this.findViewById(R.id.kkItemViewItem0_9)).setOnClickListener(new View.OnClickListener() {

            @Override
            public void onClick(View view) {
                startActivity(new Intent(TestActivity.this, TabLayoutActivity.class));
            }
        });


        ((KKCommonListItemView) this.findViewById(R.id.kkItemViewItem0_10)).setOnClickListener(new View.OnClickListener() {

            @Override
            public void onClick(View view) {
                startActivity(new Intent(TestActivity.this, ItemViewActivity.class));
            }
        });


        ((KKCommonListItemView) this.findViewById(R.id.kkItemViewItem0_11)).setOnClickListener(new View.OnClickListener() {

            @Override
            public void onClick(View view) {
                startActivity(new Intent(TestActivity.this, InputActivity.class));
            }
        });


        ((KKCommonListItemView) this.findViewById(R.id.kkItemViewItem0_12)).setOnClickListener(new View.OnClickListener() {

            @Override
            public void onClick(View view) {
                startActivity(new Intent(TestActivity.this, BottomSheetActivity.class));
            }
        });


        ((KKCommonListItemView) this.findViewById(R.id.kkItemViewItem0_13)).setOnClickListener(new View.OnClickListener() {

            @Override
            public void onClick(View view) {
                startActivity(new Intent(TestActivity.this, SegmentActivity.class));
            }
        });


        ((KKCommonListItemView) this.findViewById(R.id.kkItemViewItem0_14)).setOnClickListener(new View.OnClickListener() {

            @Override
            public void onClick(View view) {
                  startActivity(new Intent(TestActivity.this,CheckBoxActivity.class));
            }
        });


        ((KKCommonListItemView) this.findViewById(R.id.kkItemViewItem0_15)).setOnClickListener(new View.OnClickListener() {

            @Override
            public void onClick(View view) {
                  startActivity(new Intent(TestActivity.this,MultiStateActivity.class));
            }
        });
        ((KKCommonListItemView) this.findViewById(R.id.kkItemViewItem0_16)).setOnClickListener(new View.OnClickListener() {

            @Override
            public void onClick(View view) {
                startActivity(new Intent(TestActivity.this,GuideActivity.class));
            }
        });


        ((EditText)this.findViewById(R.id.et_pattern_filter)).setFilters(new InputFilter[]{new InputPatternFilter("[`~!@#$%^&*()+=|{}':;',\\[\\].<>/?~！@#￥%……&*（）——+|{}【】‘；：”“’。，、？]",true)});







//        ((BaseEditTextKit)this.findViewById(R.id.searchView2)).setOnClickListener(new View.OnClickListener() {
//            @Override
//            public void onClick(View view) {
//                ToastUtils.showToast(TestActivity.this,"ceshi");
//            }
//        });
//        ((BaseEditTextKit)this.findViewById(R.id.baseview)).addTextChangedListener(new TextWatcher() {
//            @Override
//            public void beforeTextChanged(CharSequence charSequence, int i, int i1, int i2) {
//                BaseEditTextKit viewById = (BaseEditTextKit) findViewById(R.id.baseview);
//                if(viewById.getText().length()>7){
//                    viewById.setErrorMode();
//                }else{
//                    viewById.clearErrorMode();
//                }
//            }
//
//            @Override
//            public void onTextChanged(CharSequence charSequence, int i, int i1, int i2) {
//
//            }
//
//            @Override
//            public void afterTextChanged(Editable editable) {
//
//            }
//        });
//        ((KKEditFormGroupKit)findViewById(R.id.kfg_kit)).setTextListener(new BaseEditTextKit.OnKKBaseTextChangeListener() {
//            @Override
//            public void textChange(@NonNull String text) {
//                if(text.length()>8){
//                    ((KKEditFormGroupKit)findViewById(R.id.kfg_kit)).setErrorMode();
//                }else{
//                    ((KKEditFormGroupKit)findViewById(R.id.kfg_kit)).clearErrorMode();
//                }
//            }
//        });
//
//
//        ((KKButtonKit)findViewById(R.id.kkbtn)).setOnClickListener((view) -> {
//            ArrayList<KKItemTabInfo> items = new ArrayList<>();
//            for (int i = 0; i < 5; i++) {
//                items.add(new KKItemTabInfo("第"+i+"个",i,""));
//            }
//
//            KKDialogUtils.Companion.showBottomSheetList(TestActivity.this, items, -1, null, new KKDialogUtils.DialogOnItemClickListener() {
//                @Override
//                public void clickItem(int position) {
//
//                }
//            });
//        });
//
//        ((KKButtonKit)findViewById(R.id.lodingbtn)).setOnClickListener((view) -> {
//            ((KKButtonKit)findViewById(R.id.lodingbtn)).showLoading();
//        });
//
//        ((KKButtonKit)findViewById(R.id.enabledBtn)).isEnable(false);
//        ((KKButtonKit)findViewById(R.id.cancelBtn2)).isEnable(false);
//        ((KKButtonKit)findViewById(R.id.cancelBtn4enabel)).isEnable(false);
//        ((KKButtonKit)findViewById(R.id.cancelBtn4)).setOnClickListener(new View.OnClickListener() {
//            @Override
//            public void onClick(View view) {
//                ((KKButtonKit)findViewById(R.id.cancelBtn4)).isEnable(false);
//            }
//        });
//
//        findViewById(R.id.cancelBtn).setOnClickListener(new View.OnClickListener() {
//            @Override
//            public void onClick(View view) {
//
//            }
//        });
//
//        ((KKButtonKit)findViewById(R.id.textBtn5)).setOnClickListener(new View.OnClickListener() {
//            @Override
//            public void onClick(View view) {
//
//                ((KKButtonKit)findViewById(R.id.textBtn5)).isEnable(false);
//
//            }
//        });
//
//        ((KKButtonKit)findViewById(R.id.dialog_style1)).setOnClickListener(new View.OnClickListener() {
//            @Override
//            public void onClick(View view) {
//                KKDialogUtils.Companion.showCommonDialog(TestActivity.this, "hello", "title", new KKDialogUtils.DialogDoubleBottomListener() {
//                    @Override
//                    public void sendConfirm() {
//
//                    }
//
//                    @Override
//                    public void sendCancel() {
//
//                    }
//                },null,null,true,1);
//            }
//        });
//
//        ((KKButtonKit)findViewById(R.id.dialog_style2)).setOnClickListener(new View.OnClickListener() {
//            @Override
//            public void onClick(View view) {
//                KKDialogUtils.Companion.showCommonDialog(TestActivity.this, "hello", "title", new KKDialogUtils.DialogDoubleBottomListener() {
//                    @Override
//                    public void sendConfirm() {
//
//                    }
//
//                    @Override
//                    public void sendCancel() {
//
//                    }
//                },null,null,true,2);
//            }
//        });
//
//        ((KKButtonKit)findViewById(R.id.dialog_style3)).setOnClickListener(new View.OnClickListener() {
//            @Override
//            public void onClick(View view) {
//                KKDialogUtils.Companion.showCommonDialog(TestActivity.this, "hello", "title", new KKDialogUtils.DialogDoubleBottomListener() {
//                    @Override
//                    public void sendConfirm() {
//
//                    }
//
//                    @Override
//                    public void sendCancel() {
//
//                    }
//                },null,null,true,3);
//            }
//        });
//
//        ((KKButtonKit)findViewById(R.id.showtoast)).setOnClickListener(new View.OnClickListener() {
//            @Override
//            public void onClick(View view) {
//                ToastUtils.showToast(TestActivity.this,"Error message text");
//
//            }
//        });
//
//        ((BaseEditTextKit)findViewById(R.id.baseview2)).setClearIconVisible(false);
//        ((BaseEditTextKit)findViewById(R.id.baseview3)).setClearIconVisible(false);
//        ((BaseEditTextKit)findViewById(R.id.baseview4)).setNotNeedIcon(true);
//
//
//        KKButtonKit guideBtn = (KKButtonKit) findViewById(R.id.showGuide);
//        KKButtonKit guideBtn2 = (KKButtonKit) findViewById(R.id.showGuide2);
//        guideBtn.setOnClickListener(new View.OnClickListener() {
//            @Override
//            public void onClick(View view) {
//                GuideUtil.showGuide(
//                        TestActivity.this,
//                        new GuideUtil.GuideTargetModel(
//                                findViewById(R.id.cancelBtn4),
//                                "这是一个引导文字这是一个引导文字这是一个引导文字这是一个引导文字这是一个引导文字",
//                                GuideUtil.GUIDE_CESHI4,
//                                null
//                        ),
//                        -1
//                );
//            }
//        });
//
//        guideBtn2.setOnClickListener(new View.OnClickListener() {
//            @Override
//            public void onClick(View view) {
//                GuideUtil.GuideTargetModel model = new GuideUtil.GuideTargetModel(
//                        findViewById(R.id.showGuide),
//                        "ceshi1",
//                        GuideUtil.GUIDE_CESHI1,
//                        null
//                );
//                GuideUtil.GuideTargetModel model2 = new GuideUtil.GuideTargetModel(
//                        findViewById(R.id.showtoast),
//                        "ceshi2",
//                        GuideUtil.GUIDE_CESHI2,
//                        new GuideComponent.GuideComponentBuilder()
//                                .setMessage("ceshi10000")
//                                .setAnchor(Component.ANCHOR_TOP)
//                                .setFitPosition(Component.FIT_END)
//                                .setArrowOffset(40)
//                                .build()
//                );
//                GuideUtil.GuideTargetModel model3 = new GuideUtil.GuideTargetModel(
//                        findViewById(R.id.dialog_style3),
//                        "ceshi3",
//                        GuideUtil.GUIDE_CESHI3,
//                        null
//                );
//                ArrayList<GuideUtil.GuideTargetModel> models = new ArrayList<>();
//                models.add(model);
//                models.add(model2);
//                models.add(model3);
//                GuideUtil.showMultipleGuide(TestActivity.this,models);
//            }
//        });
//
//        KKSelectRatioViewKit ratioView = (KKSelectRatioViewKit)findViewById(R.id.srv_view);
//        ratioView.setRadios(new Float[]{0.25f,0.50f,0.75f,1.00f},null,null);
//
//        KKButtonKit showPopover = ((KKButtonKit)findViewById(R.id.showPopover));
//        showPopover.setOnClickListener(new View.OnClickListener() {
//            @Override
//            public void onClick(View view) {
//                KKDialogUtils.Companion.createMarketPop(TestActivity.this, showPopover, new String[]{"Delete optional", "Top", "Ceshi"}, new KKDialogUtils.DialogOnSigningItemClickListener() {
//                    @Override
//                    public void clickItem(int position, @NonNull String text) {
//                        Log.d("showPopover","clickitem:position="+position+"text="+text);
//                    }
//                });
//            }
//        });
//
//        PublicHeaderKit header = (PublicHeaderKit)findViewById(R.id.mHeaderKit);
//        header.setFilterTitleContent("BTC-USDT");
//        header.setBackIconGone(true);
//
//
//        ((KKButtonKit)findViewById(R.id.showBottomCardDialog)).setOnClickListener(new View.OnClickListener() {
//            @Override
//            public void onClick(View view) {
//                ArrayList<KKItemCardEntity> list = new ArrayList<KKItemCardEntity>();
//                list.add(new KKItemCardEntity(KKItemCardEntity.CARD_LAYOUT_TYPE_1,"简体中文","content1"));
//                KKItemCardEntity englishEntity = new KKItemCardEntity(KKItemCardEntity.CARD_LAYOUT_TYPE_1, "English", "content2");
//                englishEntity.setSelect(true);
//                list.add(englishEntity);
//                list.add(new KKItemCardEntity(KKItemCardEntity.CARD_LAYOUT_TYPE_1,"日本",""));
//
//                KKDialogUtils.Companion.showBottomCardSelectDialog(
//                        TestActivity.this,
//                        list,
//                        new KKDialogUtils.DialogOnItemClickListener() {
//                            @Override
//                            public void clickItem(int position) {
//
//                            }
//                        },
//                        "Choose a language",
//                        "Please select the mainnet that is consistent with the withdrawal platform for deposit, otherwise your funds may be lost"
//
//                );
//            }
//        });
//
//
//        ((KKButtonKit)findViewById(R.id.showBottomCardDialog2)).setOnClickListener(new View.OnClickListener() {
//            @Override
//            public void onClick(View view) {
//                ArrayList<KKItemCardEntity> list = new ArrayList<KKItemCardEntity>();
//                list.add(new KKItemCardEntity(KKItemCardEntity.CARD_LAYOUT_TYPE_2,"Transfer money via blockchain","Mention to other data currency addresses via the blockchain network"));
//                list.add(new KKItemCardEntity(KKItemCardEntity.CARD_LAYOUT_TYPE_2,"Transfer via email/mobile/ID","Transfers for this platform only, 0 fees"));
//
//                KKDialogUtils.Companion.showBottomCardSelectDialog(
//                        TestActivity.this,
//                        list,
//                        new KKDialogUtils.DialogOnItemClickListener() {
//                            @Override
//                            public void clickItem(int position) {
//
//                            }
//                        },
//                        "Withdrawal Type",
//                        null
//
//                );
//            }
//        });
//
//        SlidingTabLayout tabLayout = ((SlidingTabLayout)findViewById(R.id.stl_tab));
//        CommonTabLayout tabLayouttwo = ((CommonTabLayout)findViewById(R.id.stl_tab2));
//
//        ArrayList<CustomTabEntity> arrayList = new ArrayList<>();
//        int i;
//        for (i=0; i < 4; i++) {
//            int finalI = i;
//            arrayList.add(new CustomTabEntity() {
//                @Override
//                public String getTabTitle() {
//                    return "title"+ finalI;
//                }
//
//                @Override
//                public int getTabSelectedIcon() {
//                    return 0;
//                }
//
//                @Override
//                public int getTabUnselectedIcon() {
//                    return 0;
//                }
//            });
//        }
//        tabLayouttwo.setTabData(arrayList);
//        tabLayout.setTitle(new String[]{"Example","Example","Example"});
//
//
//        KKCommonTabKit tabLayout1 = ((KKCommonTabKit) findViewById(R.id.tab_1));
//        KKCommonTabKit tabLayout2 = ((KKCommonTabKit) findViewById(R.id.tab_2));
//        KKCommonTabKit tabLayout3 = ((KKCommonTabKit) findViewById(R.id.tab_3));
//        KKCommonTabKit tabLayout4 = ((KKCommonTabKit) findViewById(R.id.tab_4));
//        KKCommonTabKit tabLayout5 = ((KKCommonTabKit) findViewById(R.id.tab_5));
//
//        tabLayout1.setTabs(new String[]{"Example","Example","Example","Example"});
//        tabLayout2.setTabs(new String[]{"Example","Example"});
//        tabLayout3.setTabs(new String[]{"Example","Example","Example"});
//        tabLayout4.setTabs(new String[]{"Buy","Sell"});
//        tabLayout5.setTabs(new String[]{"Cross","Isolated"});
//
////----------------------------------------------------------------------------------
//        tabLayout4.setBlockColor(ContextCompat.getColor(TestActivity.this,R.color.main_green));
//        tabLayout4.setOutLineColor(ContextCompat.getColor(TestActivity.this,R.color.main_green));
//        tabLayout4.setListener(new KKCommonTabKit.OnKKTabSelectListener() {
//            @Override
//            public void onTabSelect(int position) {
//                switch (position){
//                    case 0:
//                        tabLayout4.setBlockColor(ContextCompat.getColor(TestActivity.this,R.color.main_green));
//                        tabLayout4.setOutLineColor(ContextCompat.getColor(TestActivity.this,R.color.main_green));
//                        break;
//                    case 1:
//                        tabLayout4.setBlockColor(ContextCompat.getColor(TestActivity.this,R.color.main_red));
//                        tabLayout4.setOutLineColor(ContextCompat.getColor(TestActivity.this,R.color.main_red));
//                        break;
//                }
//            }
//        });
////----------------------------------------------------------------------------------
//
//        tabLayout5.setStyle(1);
//
//
//        KKPopupSelectKit selectKit = findViewById(R.id.mSelectView);
//        ArrayList<KKItemTabInfo> list = new ArrayList<>();
//        list.add(new KKItemTabInfo("额比福安你啊ssjifn",1,""));
//        list.add(new KKItemTabInfo("爱死哦大家拿",2,""));
//        list.add(new KKItemTabInfo("3阿斯顿",3,true));
//        selectKit.setData(list);
//        selectKit.setCurrentPosition(1);
//
//        selectKit.setTipVisible(true);
//
//
//        KKPopupSelectKit selectKit2 = findViewById(R.id.mSelectView2);
//        ArrayList<KKItemTabInfo> list2 = new ArrayList<>();
//        list2.add(new KKItemTabInfo("币",1,""));
//        list2.add(new KKItemTabInfo("张",2,""));
//        selectKit2.setData(list2);
////        selectKit.setCurrentPosition(0);
//        selectKit2.setAnimationStyle(R.style.ani_popwindow_top_right);
//
//        selectKit.setListener(new KKPopupSelectKit.OnKKPopupSelectListener() {
//            @Override
//            public void onChangeSelect(int position) {
//                ToastUtils.showToast(TestActivity.this,"onChangeSelect" + position);
//            }
//
//            @Override
//            public void onPopTipClick(int position) {
//                ToastUtils.showToast(TestActivity.this,"onPopTipClick" + position);
//            }
//
//            @Override
//            public void onSelectTipClick() {
//                ToastUtils.showToast(TestActivity.this,"onSelectTipClick");
//            }
//        });
    }


    private KKLoadingDialog mLoadingDialog = null;

    private void showLoadingDialog() {
        closeLoadingDialog();
        if (null != this) {
            if (null == mLoadingDialog) {
                mLoadingDialog = new KKLoadingDialog(this);
            }
            mLoadingDialog.showLoadingDialog();
        }
    }

    private void closeLoadingDialog() {
        if (null != this) {
            if (null != mLoadingDialog) {
                mLoadingDialog.closeLoadingDialog();
                mLoadingDialog = null;
            }
        }
    }

}
