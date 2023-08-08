# resp-me-templates

## 初衷
程序员不停的写脚本，但很少有人能想起3个月前的脚本如何使用😂。这是时间和经历极大浪费，而且它没有对自己和别人产生什么益处，只是徒劳的无用功。

除非有一个地方可以保存你的脚本模板，以图形化的界面陈列，你只需将一个SSH的publicKey上传，接下来就可以完美再现你当初构建脚本的初衷。

## 一个例子
我需要安装一个SSL加密的Rabbitmq实列。大致需要如下步骤：

* 安装rabbitmq，配置用户、密码、插件等
* 安装nginx，配置amqp代理，rabbitmq管理界面代理
* 申请域名
* 申请证书，安装证书
* 周期性更新证书

反映在[resp.me](https://resp.me)的模板上，对应如下。

* 安装nginx，rabbitmq的模板
* 免费域名模板，like：4kxcmhz9rnrt.free-ssl.me
* 证书更新模板

其中免费域名在实例化模板时生成，将“安装nginx，rabbitmq的模板”依赖于“证书更新模板”，并且在脚本中可以控制是否全新安装或者仅仅是更新证书。

然后设置一个CRON，可以是springcron或者quartzcron或者简单计划任务。
```bash
75d,0d #表示每75天执行一次，马上开始
10h,5h #表示每10小时执行一次
# m,h,d,w,M,y
```

## 如何写一个插件

可以直接在[resp.me](https://resp.me)的web界面上传脚本，也可以在本地建一个项目，然后导入。

项目的目录结构：

```bash
template-import.json # configuration of the template's import
start.sh # name starts with start will be the entrypoint, write with any language you know it will run successfully on the target machine.
...
# and all flatten files will be part of the template.
```

## 导入插件

Using zip to zip the folder first.
```bash
zip rabbitmq-ssl.zip rabbitmq-ssl/*
```
Then to obtain an upload url from website [resp.me](https://resp.me/app/assets/), like this:

```bash
curl -H "X-TOBE-CLIENT-SECRET: 19e4p796D1C3c20VH3ry97xUOKj4CSJM3MnB3" -F file=@rabbitmq-ssl.zip https://resp.me/upload-with-secret
```

Then import the template in the template list page.
