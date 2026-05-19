package com.chainup.contract.ui.fragment

import android.os.Bundle
import android.view.View
import androidx.recyclerview.widget.LinearLayoutManager
import com.chad.library.adapter.base.BaseQuickAdapter
import com.chad.library.adapter.base.listener.OnItemClickListener
import com.chad.library.adapter.base.viewholder.BaseViewHolder
import com.chainup.contract.R
import com.chainup.contract.base.CpNBaseFragment
import com.chainup.contract.bean.ContractListBean
import com.chainup.contract.eventbus.CpEventBusUtil
import com.chainup.contract.eventbus.CpMessageEvent
import com.chainup.contract.utils.CpClLogicContractSetting
import com.chainup.contract.view.CpNewDialogUtils
import com.chainup.contract.view.dialog.CpTDialog
import com.chainup.kit.views.KKEmptyViewKit
import com.yjkj.chainup.manager.CpLanguageUtil
import kotlinx.android.synthetic.main.fragment_dialog_symbol.*
import java.util.*
import kotlin.collections.ArrayList


/**
 *For dialog with searchbar
 */
class DialogSymbolFragment private constructor(): CpNBaseFragment(), OnItemClickListener {
    private var iclassification: Int? = null
    private var imContractList:ArrayList<ContractListBean>? = arrayListOf()
    private var origin_imContractList:ArrayList<ContractListBean>? = arrayListOf()
    private var adapter:MyAdapter? = null

    private var selectContractId:Int = -1
    private var callback: CpNewDialogUtils.DialogOnSigningItemClickListener? = null
    //The dialog corresponding to fg is passed in and copied by the dialog through setCallback
    private var dialog: CpTDialog? = null

    override fun setContentView(): Int = R.layout.fragment_dialog_symbol

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        arguments?.let {
            iclassification = it.getInt(classification)
            val list = it.getSerializable(mContractList)
            if(list!=null){
                imContractList = (list as ArrayList<ContractListBean>)
                Collections.sort(imContractList)
            }
        }
    }

    override fun initView() {
        symbolRv?.layoutManager = LinearLayoutManager(mActivity,LinearLayoutManager.VERTICAL,false)
        adapter = MyAdapter(imContractList!!)
        symbolRv?.adapter = adapter
        adapter?.run {
            setEmptyView(KKEmptyViewKit(requireContext()))
            setOnItemClickListener(this@DialogSymbolFragment)
        }

    }

    override fun loadData() {
        super.loadData()
        //If not all=- 1 Filter
        if(iclassification!=-1){
            imContractList = imContractList?.filter {
                it.classification==iclassification
            } as ArrayList<ContractListBean>
        }else{
            //If it is - 1 All Contracts//ContractListBean
            imContractList = arrayListOf(
                ContractListBean(id = -2)
            )

        }

        origin_imContractList?.addAll(imContractList!!)
    }

    //Search
    fun searchDataByKeyword(keyword:String){
        imContractList?.clear()
        if(keyword.isEmpty()){
            imContractList?.addAll(origin_imContractList!!)
            adapter?.setList(imContractList)
            return
        }
        val searchResult = origin_imContractList?.filter {
            val showName = CpClLogicContractSetting.getContractShowNameById(context,it.id!!)

            if(iclassification==-1) showName.uppercase().contains(keyword.uppercase())
            else it.classification==iclassification && showName.uppercase().contains(keyword.uppercase())
        } as ArrayList<ContractListBean>

        imContractList?.addAll(searchResult)
        adapter?.setList(imContractList)
    }

    //Set the selected id
    fun setSelectContractId(id:Int){
        this.selectContractId = id
    }

    //Set up listening
    fun setCallback(callback: CpNewDialogUtils.DialogOnSigningItemClickListener,dialog:CpTDialog?){
        this.callback = callback
        this.dialog = dialog
    }

    companion object {
        var classification = "symbol_classification"
        var mContractList = "contractList"

        @JvmStatic
        fun newInstance(params_classification:Int,params_ContractList:ArrayList<ContractListBean>) =
            DialogSymbolFragment().apply {
                arguments = Bundle().apply {
                    putInt(classification, params_classification)
                    putSerializable(mContractList,params_ContractList)
                }
            }
    }



    inner class MyAdapter(data:ArrayList<ContractListBean>) : BaseQuickAdapter<ContractListBean,BaseViewHolder>(R.layout.item_dialog_symbol_rv_layout,data){

        override fun convert(holder: BaseViewHolder, item: ContractListBean) {
            holder.setText(
                R.id.symbolText,
                if(iclassification==-1){
                    CpLanguageUtil.getString(context,"cp_contract_all_contracts")
                }else{
                    CpClLogicContractSetting.getContractShowNameById(context,item.id!!)
                }
            )
            holder.setGone(R.id.select_ic,selectContractId!=item.id)
        }
    }

    override fun onItemClick(adapter: BaseQuickAdapter<*, *>, view: View, position: Int) {
        val itemBean = imContractList?.get(position)
        selectContractId = itemBean?.id!!
        adapter?.notifyItemChanged(position)

        val event = CpMessageEvent(CpMessageEvent.sl_contract_record_switch_contract_event)
        event.msg_content = itemBean.id
        CpEventBusUtil.post(event)
        //Callback Required
        callback?.clickItem(itemBean.id,itemBean.symbol!!)
        //To add an additional callback for extension, it is not necessary to implement doContractSymbolSelect
        callback?.doContractSymbolSelect(itemBean)

        dialog?.dismiss()
    }
}
