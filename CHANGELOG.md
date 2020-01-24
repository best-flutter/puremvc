# [0.3.0]

* 完善测试

## [0.2.1]

* bind绑定的方法返回false可不刷新widget


## [0.2.0]
* 完善setup 过程中的异常处理


## [0.1.9]
* setup 过程中的异常处理


## [0.1.8]
* Fix requestModel


## [0.1.7]
* EventListener参数改成named

## [0.1.6]

* 修正EventListener



## [0.1.5]

* 增加EventListener组件


## [0.1.4]

* 模型不一起初始化

## [0.1.3]

* 打印的日志展示模型、事件

## [0.1.2]

* PureMvc增加requestModel方法，在获取的时候判断模型有没有初始化完毕，如果没有则等待

## [0.1.1]

* 支持通配符监听事件

## [0.1.0]

* setGlobalErrorHandler 改成static

## [0.0.9]

* update返回非future数据，也可以有默认通知

## [0.0.8]

* updte中的异常可以通过 Puremv.setGlobalErrorHandler 来处理，如果未设置，则打印异常

## [0.0.7]

* 在notify的时候检查调用异常，调整函数参数个数


## [0.0.6]

* 监控update返回值，如果是Future，则通知 model/event@ok 或者 model/event@fail事件
* 在update之前发送 model/event@start事件
* 在update之后发送 model/event@end事件


## [0.0.5]

* 修复setup不返回值后出现异常的bug


## [0.0.4]

* setup重复的bug
* 等待setup完成之后发送事件

## [0.0.3]

* dispatch 后面一个参数可选


## [0.0.1] - init version

* 基本使用




