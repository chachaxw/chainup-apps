package com.yjkj.chainup.net.retrofit;


import android.text.TextUtils;
import android.util.Log;

import com.google.gson.Gson;
import com.yjkj.chainup.net.api.HTTPCode;

import java.io.IOException;
import java.lang.reflect.Type;

import okhttp3.ResponseBody;
import retrofit2.Converter;

public class GsonResponseBodyConverter<T> implements Converter<ResponseBody, T> {

    private final Gson gson;
    private final Type type;


    public GsonResponseBodyConverter(Gson gson, Type type) {
        this.gson = gson;
        this.type = type;
    }

    @Override
    public T convert(ResponseBody value) throws IOException {
        String response = value.string();
        //First, parse the returned JSON data into the Response. If code=200, then parse it into our entity base class. Otherwise, throw an exception
        ResultResponse httpResult = gson.fromJson(response, ResultResponse.class);

        Log.d("==AA==","response:"+httpResult.toString()+"|||"+response);

        if (httpResult.getCode() == 0) {
            //At 200, it can be parsed directly, and there is no possibility of parsing exceptions. Because the generics passed in to our entity base class are the format when the data is successful
            return gson.fromJson(response, type);
        } else {
//            ErrorResponse errorResponse = gson.fromJson(response,ErrorResponse.class);
////Throw a custom ResultException to pass in the status code and information when the failure occurs
//            throw new ResultException(errorResponse.getCode(),errorResponse.getMsg());
            //If the server returns an error code, it returns the string after clearing the data to prevent JSON from parsing errors and ensure that the msg can communicate
            if(httpResult.getCode()== HTTPCode.VERIFY_CODE_ERROR.code){
                return gson.fromJson(response, type);
            }
            if (TextUtils.isEmpty(httpResult.getMsg())) {
                httpResult.setMsg("");
            }
            return gson.fromJson(gson.toJson(httpResult), type);
        }
    }

}
