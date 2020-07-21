
### Time操作符


#### delay
- 将 Observable 的所有元素都先拖延一段设定好的时间，然后才将它们发送出来。
```Swift
Observable.of(1, 2, 1)
    .delay(3, scheduler: MainScheduler.instance) //元素延迟3秒才发出
    .subscribe(onNext: { print($0) })
    .disposed(by: disposeBag)
```


#### delaySubscription
- 可以进行延时订阅。即经过所设定的时间后，才对 Observable 进行订阅操作。
```Swift
Observable.of(1, 2, 1)
    .delaySubscription(3, scheduler: MainScheduler.instance) //延迟3秒才开始订阅
    .subscribe(onNext: { print($0) })
    .disposed(by: disposeBag)
```


#### defer
- 直到订阅发生，才创建 Observable，并且为每位订阅者创建全新的 Observable


#### interval
- 创建一个 Observable 每隔一段时间，发出一个索引数
```Swift
// 下面方法让其每 1 秒发送一次，并且是在主线程（MainScheduler）发送
let observable = Observable<Int>.interval(1, scheduler: MainScheduler.instance)
observable.subscribe { event in
    print(event)
}

```


#### timer
- 这个方法有两种用法，一种是创建的 Observable 序列在经过设定的一段时间后，产生唯一的一个元素
```Swift
    //5秒种后发出唯一的一个元素0
    let observable = Observable<Int>.timer(5, scheduler: MainScheduler.instance)
    observable.subscribe { event in
        print(event)
    }
    
    /**
    
    运行结果：
        next(0)
        completed
        
    */
```
- 另一种是创建的 Observable 序列在经过设定的一段时间后，每隔一段时间产生一个元素
```Swift
    //延时5秒种后，每隔1秒钟发出一个元素
    let observable = Observable<Int>.timer(5, period: 1, scheduler: MainScheduler.instance)
    observable.subscribe { event in
        print(event)
    }
    
    /**
    
    运行结果：
        next(0)
        next(1)
        next(2)
        next(3)
        .
        .
    */
    
```


#### timeout
- 可以设置一个超时时间。如果源 Observable 在规定时间内没有发任何出元素，就产生一个超时的 error 事件。
```Swift
//定义好每个事件里的值以及发送的时间
let times = [
    [ "value": 1, "time": 0 ],
    [ "value": 2, "time": 0.5 ],
    [ "value": 3, "time": 1.5 ],
    [ "value": 4, "time": 4 ],
    [ "value": 5, "time": 5 ]
]
 
//生成对应的 Observable 序列并订阅
Observable.from(times)
    .flatMap { item in
        return Observable.of(Int(item["value"]!))
            .delaySubscription(Double(item["time"]!),
                               scheduler: MainScheduler.instance)
    }
    .timeout(2, scheduler: MainScheduler.instance) //超过两秒没发出元素，则产生error事件
    .subscribe(onNext: { element in
        print(element)
    }, onError: { error in
        print(error)
    })
    .disposed(by: disposeBag)
    
    
/**
  运行结果：
    1
    2
    3
    Sequence timeout.

*/
```
