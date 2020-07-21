
### 连接Observable操作符

#### multicast
- 将一个正常的序列转换成一个可连接的序列
- multicast 方法还可以传入一个 Subject，每当序列发送事件时都会触发这个 Subject 的发送。
```Swift

//创建一个Subject（后面的multicast()方法中传入）
let subject = PublishSubject<Int>()
 
//这个Subject的订阅
_ = subject
    .subscribe(onNext: { print("Subject: \($0)") })
 
//每隔1秒钟发送1个事件
let interval = Observable<Int>.interval(1, scheduler: MainScheduler.instance)
    .multicast(subject)
         
//第一个订阅者（立刻开始订阅）
_ = interval
    .subscribe(onNext: { print("订阅1: \($0)") })
 
//相当于把事件消息推迟了两秒
DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
    _ = interval.connect()
}
 
//第二个订阅者（延迟5秒开始订阅）
DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
    _ = interval
        .subscribe(onNext: { print("订阅2: \($0)") })
}

/**
  运行结果：
    Subject: 0
    订阅1: 0
    Subject: 1
    订阅1: 1
    Subject: 2
    订阅1: 2
    订阅2: 2
    Subject: 3
    订阅1: 3
    订阅2: 3
    Subject: 4
    订阅1: 4
    订阅2: 4

*/

```


#### publish
- publish 方法会将一个正常的序列转换成一个可连接的序列。同时该序列不会立刻发送事件，只有在调用 connect 之后才会开始
```Swift
//每隔1秒钟发送1个事件
let interval = Observable<Int>.interval(1, scheduler: MainScheduler.instance)
    .publish()
         
//第一个订阅者（立刻开始订阅）
_ = interval
    .subscribe(onNext: { print("订阅1: \($0)") })
 
//相当于把事件消息推迟了两秒
DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
    _ = interval.connect()
}
 
//第二个订阅者（延迟5秒开始订阅）
DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
    _ = interval
        .subscribe(onNext: { print("订阅2: \($0)") })
}



/**
  运行结果：
    订阅1: 0
    订阅1: 1
    订阅1: 2
    订阅2: 2
    订阅1: 3
    订阅2: 3
    订阅1: 4
    订阅2: 4
    订阅1: 5
    订阅2: 5
    ...

*/

```


#### refCount
- refCount 操作符可以将可被连接的 Observable 转换为普通 Observable
- 该操作符可以自动连接和断开可连接的 Observable。当第一个观察者对可连接的 Observable 订阅时，那么底层的 Observable 将被自动连接。当最后一个观察者离开时，那么底层的 Observable 将被自动断开连接。
```Swift

//每隔1秒钟发送1个事件
let interval = Observable<Int>.interval(1, scheduler: MainScheduler.instance)
    .publish()
    .refCount()
 
//第一个订阅者（立刻开始订阅）
_ = interval
    .subscribe(onNext: { print("订阅1: \($0)") })
 
//第二个订阅者（延迟5秒开始订阅）
DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
    _ = interval
        .subscribe(onNext: { print("订阅2: \($0)") })
}

/**
  运行结果：
    订阅1: 0
    订阅1: 1
    订阅1: 2
    订阅1: 3
    订阅1: 4
    订阅1: 5
    订阅2: 5
    订阅1: 6
    订阅2: 6
    订阅1: 7
    订阅2: 7
    ...
*/

```


#### replay
- 会将将一个正常的序列转换成一个可连接的序列。同时该序列不会立刻发送事件，只有在调用 connect 之后才会开始。
- replay 与 publish 不同在于：新的订阅者还能接收到订阅之前的事件消息（数量由设置的 bufferSize 决定）。
```Swift
//每隔1秒钟发送1个事件
let interval = Observable<Int>.interval(1, scheduler: MainScheduler.instance)
    .replay(5)
         
//第一个订阅者（立刻开始订阅）
_ = interval
    .subscribe(onNext: { print("订阅1: \($0)") })
 
//相当于把事件消息推迟了两秒
DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
    _ = interval.connect()
}
 
//第二个订阅者（延迟5秒开始订阅）
DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
    _ = interval
        .subscribe(onNext: { print("订阅2: \($0)") })
}



/**
  运行结果：
    订阅1: 0
    订阅1: 1
    订阅2: 0
    订阅2: 1
    订阅1: 2
    订阅2: 2
    订阅1: 3
    订阅2: 3
    订阅1: 4
    订阅2: 4
    ...
*/


```



#### shareReplay
- 使得观察者共享源 Observable，并且缓存最新的 n 个元素，将这些元素直接发送给新的观察者。
- share(relay:) 就是 replay 和 refCount 的组合。
```Swift

//每隔1秒钟发送1个事件
let interval = Observable<Int>.interval(1, scheduler: MainScheduler.instance)
                        .share(replay: 5)

//第一个订阅者（立刻开始订阅）
_ = interval.subscribe(onNext: { print("订阅1: \($0)") })

//第二个订阅者（延迟5秒开始订阅）
DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
    _ = interval.subscribe(onNext: { print("订阅2: \($0)") })
}

/**
  运行结果：
    订阅1: 0
    订阅1: 1
    订阅1: 2
    订阅1: 3
    订阅1: 4
    订阅2: 0
    订阅2: 1
    订阅2: 2
    订阅2: 3
    订阅2: 4
    订阅1: 5
    订阅2: 5
    订阅1: 6
    订阅2: 6
    ...
*/

```


