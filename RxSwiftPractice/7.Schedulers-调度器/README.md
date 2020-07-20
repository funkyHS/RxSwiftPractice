
### Schedulers - 调度器

- 调度器（Schedulers）是用于控制任务在哪个线程或队列运行
- RxSwift 内置了如下几种 Scheduler：
        - `CurrentThreadScheduler`：表示当前线程 Scheduler。（默认使用这个）
        - `MainScheduler`：表示主线程。如果我们需要执行一些和 UI 相关的任务，就需要切换到该 Scheduler 运行。
        - `SerialDispatchQueueScheduler`：封装了 GCD 的串行队列。如果我们需要执行一些串行任务，可以切换到这个 Scheduler 运行。
        - `ConcurrentDispatchQueueScheduler`：封装了 GCD 的并行队列。如果我们需要执行一些并发任务，可以切换到这个 Scheduler 运行。
        - `OperationQueueScheduler`：封装了 NSOperationQueue。


#### 使用

- 在后台发起网络请求，然后解析数据，最后在主线程刷新页面。
```Swift
let rxData: Observable<Data> = ...
 
rxData
    .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .userInitiated)) //后台构建序列
    .observeOn(MainScheduler.instance)  //主线程监听并处理序列结果
    .subscribe(onNext: { [weak self] data in
        self?.data = data
    })
    .disposed(by: disposeBag)
    
    
    // subscribeOn(): 决定数据序列的构建函数在哪个 Scheduler 上运行
    // observeOn(): 该方法决定在哪个 Scheduler 上监听这个数据序列

```
