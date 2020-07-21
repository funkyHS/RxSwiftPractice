

### 调试操作

#### 1. debug

- 将所有的订阅者、事件、和处理等详细信息打印出来，方便开发调试。
```Swift
let disposeBag = DisposeBag()
 
Observable.of("2", "3")
    .startWith("1")
    .debug("Test Debug", trimOutput: true)  // identifier: 描述， trimOutput: 是否截取最多四十个字符
    .subscribe(onNext: { print($0) })
    .disposed(by: disposeBag)
    
    /**
    运行结果：
        Test Debug -> subscribed
        Test Debug -> Event next(1)
        1
        Test Debug -> Event next(2)
        2
        Test Debug -> Event next(3)
        3
        Test Debug -> Event completed
        Test Debug -> isDisposed    
    */
```



#### 2. do

- 可以使用 doOn 方法来监听事件的生命周期，它会在每一次事件发送前被调用
- 同时它和 subscribe 一样，可以通过不同的 block 回调处理不同类型的 event
```Swift
    let observable = Observable.of("A", "B", "C")
     
    observable
        .do(onNext: { element in
            print("Intercepted Next：", element)
        }, onError: { error in
            print("Intercepted Error：", error)
        }, onCompleted: {
            print("Intercepted Completed")
        }, onDispose: {
            print("Intercepted Disposed")
        })
        .subscribe(onNext: { element in
            print(element)
        }, onError: { error in
            print(error)
        }, onCompleted: {
            print("completed")
        }, onDisposed: {
            print("disposed")
        })
```





