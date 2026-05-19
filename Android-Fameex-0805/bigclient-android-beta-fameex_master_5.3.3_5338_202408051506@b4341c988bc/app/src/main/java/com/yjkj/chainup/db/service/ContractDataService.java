package com.yjkj.chainup.db.service;

import com.yjkj.chainup.db.MMKVDb;

/**
 *@description: Contract Data Saving
 * @Author: wanghao
 * @CreateDate: 2019-09-30 19:49
 * @UpdateUser: wanghao
 * @UpdateDate 2023-09-30 19:49
 *@ UpdateRemark: Update Description
 */
public class ContractDataService {

    private MMKVDb mMMKVDb;

    private ContractDataService() {
        mMMKVDb = new MMKVDb();
    }

    private static ContractDataService mContractDataService;

    public static ContractDataService getInstance() {
        if (null == mContractDataService)
            mContractDataService = new ContractDataService();
        return mContractDataService;
    }


}
