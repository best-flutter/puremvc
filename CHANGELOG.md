# [0.0.7]

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




