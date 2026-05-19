# -*- encoding: utf-8 -*-
import sys
import requests

#定义python系统变量
JOB_URL = sys.argv[1]
JOB_NAME = sys.argv[2]



# 飞书机器人的webhook地址
url = 'https://open.larksuite.com/open-apis/bot/v2/hook/64555145-a228-4d63-8483-d37d969fa6ee'
method = 'post'
headers = {'Content-Type':'application/json'}

data = {
    "msg_type": "interactive",
    "card": {
        "config": {
                "wide_screen_mode": True,
                "enable_forward": True
        },
        "elements": [{
                "tag": "div",
                "text": {
                        "content": "打包已完成："+JOB_URL, # 这是卡片的内容，也可以添加其他的内容：比如构建分支，构建编号等
                        "tag": "lark_md"
                }
        }],
        "header": {
                "title": {
                        "content": JOB_NAME + "构建报告", # JOB_NAME 调用python定义的变量，这是卡片的标题
                        "tag": "plain_text"
                }
        }
    }
}
res= requests.request(method=method,url=url,headers=headers,json=data)
print(res)
print(res.json())