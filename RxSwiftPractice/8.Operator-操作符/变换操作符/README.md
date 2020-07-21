
### 1. 变换操作（Transforming Observables）

#### buffer

- `buffer` 方法作用是缓冲组合，第一个参数是缓冲时间，第二个参数是缓冲个数，第三个参数是线程。
- 该方法简单来说就是缓存 Observable 中发出的新元素，当元素达到某个数量，或者经过了特定的时间，它就会将这个元素集合发送出来
```Swift
override func viewDidLoad() {

    let subject = PublishSubject<String>()

    //每缓存3个元素则组合起来一起发出。
    //如果1秒钟内不够3个也会发出（有几个发几个，一个都没有发空数组 []）
    subject
        .buffer(timeSpan: 1, count: 3, scheduler: MainScheduler.instance)
        .subscribe(onNext: { print($0) })
        .disposed(by: disposeBag)

    subject.onNext("a")
    subject.onNext("b")
    subject.onNext("c")

    subject.onNext("1")
    subject.onNext("2")
    subject.onNext("3")
}
```

#### window

- `window` 操作符和 buffer 十分相似。不过 buffer 是周期性的将缓存的元素集合发送出来，而 window 周期性的将元素集合以 Observable 的形态发送出来。
- 同时 buffer 要等到元素搜集完毕后，才会发出元素序列。而 window 可以实时发出元素序列。

```Swift
override func viewDidLoad() {

    let subject = PublishSubject<String>()

    //每3个元素作为一个子Observable发出。
    subject
    .window(timeSpan: 1, count: 3, scheduler: MainScheduler.instance)
    .subscribe(onNext: { [weak self]  in
        print("subscribe: \($0)")
        $0.asObservable()
            .subscribe(onNext: { print($0) })
            .disposed(by: self!.disposeBag)
    })
    .disposed(by: disposeBag)

    subject.onNext("a")
    subject.onNext("b")
    subject.onNext("c")

    subject.onNext("1")
    subject.onNext("2")
    subject.onNext("3")
}
```


#### map

- 该操作符通过传入一个函数闭包把原来的 Observable 序列转变为一个新的 Observable 序列
```Swift
    let disposeBag = DisposeBag()

    Observable.of(1, 2, 3)
        .map { $0 * 10}
        .subscribe(onNext: { print($0) })
        .disposed(by: disposeBag)
```

#### flatMap

- map 在做转换的时候容易出现“升维”的情况。即转变之后，从一个序列变成了一个序列的序列。
- 而 flatMap 操作符会对源 Observable 的每一个元素应用一个转换方法，将他们转换成 Observables。 然后将这些 Observables 的元素合并之后再发送出来。即又将其 "拍扁"（降维）成一个 Observable 序列。
- 这个操作符是非常有用的。比如当 Observable 的元素本生拥有其他的 Observable 时，我们可以将所有子 Observables 的元素发送出来。
```Swift
    let subject1 = BehaviorSubject(value: "A")
    let subject2 = BehaviorSubject(value: "1")

    let behaviorRelay = BehaviorRelay(value: subject1)

    behaviorRelay.asObservable()
        .flatMap { $0 }
        .subscribe(onNext: { print($0) })
        .disposed(by: disposeBag)

    subject1.onNext("B")
    behaviorRelay.accept(subject2)
    subject2.onNext("2")
    subject1.onNext("C")


    /**
    运行结果如下：
        A
        B
        1
        2
        C
    */

```


#### flatMapLatest

- flatMapLatest 与 flatMap 的唯一区别是：flatMapLatest 只会接收最新的 value 事件。
```Swift
    let subject1 = BehaviorSubject(value: "A")
    let subject2 = BehaviorSubject(value: "1")
    
    let behaviorRelay = BehaviorRelay(value: subject1)
    behaviorRelay.asObservable()
        .flatMapLatest { $0 }
        .subscribe(onNext: { print($0) })
        .disposed(by: disposeBag)
    
    subject1.onNext("B")
    behaviorRelay.accept(subject2)
    subject2.onNext("2")
    subject1.onNext("C")
    
    
    /**
    运行结果如下：
        A
        B
        1
        2
    */
```


#### flatMapFirst

- flatMapFirst 与 flatMapLatest 正好相反：flatMapFirst 只会接收最初的 value 事件
- 该操作符可以防止重复请求：比如点击一个按钮发送一个请求，当该请求完成前，该按钮点击都不应该继续发送请求。便可该使用 flatMapFirst 操作符
```Swift
    let subject1 = BehaviorSubject(value: "A")
    let subject2 = BehaviorSubject(value: "1")
    
    let behaviorRelay = BehaviorRelay(value: subject1)
    behaviorRelay.asObservable()
        .flatMapFirst { $0 }
        .subscribe(onNext: { print($0) })
        .disposed(by: disposeBag)
        
    subject1.onNext("B")
    behaviorRelay.accept(subject2)
    subject2.onNext("2")
    subject1.onNext("C")
    
    
    /**
    运行结果如下：
        A
        B
        C
    */
```


#### concatMap

- concatMap 与 flatMap 的唯一区别是：当前一个 Observable 元素发送完毕后，后一个Observable 才可以开始发出元素。或者说等待前一个 Observable 产生完成事件后，才对后一个 Observable 进行订阅。
```Swift
    let disposeBag = DisposeBag()

    let subject1 = BehaviorSubject(value: "A")
    let subject2 = BehaviorSubject(value: "1")
    let behaviorRelay = BehaviorRelay(value: subject1)

    behaviorRelay.asObservable()
        .concatMap { $0 }
        .subscribe(onNext: { print($0) })
        .disposed(by: disposeBag)

    subject1.onNext("B")
    behaviorRelay.accept(subject2)
    subject2.onNext("2")
    subject1.onNext("C")
    subject1.onCompleted() //只有前一个序列结束后，才能接收下一个序列
    
    
    /**
    运行结果如下：
        A
        B
        C
        2
    */
```


#### scan

- scan 就是先给一个初始化的数，然后不断的拿前一个结果和最新的值进行处理操作。
```Swift
        
    Observable.of(1, 2, 3, 4, 5)
        .scan(-1) { (acum, elem) -> Int in
            print("acum = \(acum), elem = \(elem)")
            return acum + elem
        }
        .debug("scan Debug", trimOutput: true)
        .subscribe(onNext: { print($0) })
        .disposed(by: disposeBag)
        
        
    /**
    运行结果如下：
        scan Debug -> subscribed
        acum = -1, elem = 1
        scan Debug -> Event next(0)
        0
        acum = 0, elem = 2
        scan Debug -> Event next(2)
        2
        acum = 2, elem = 3
        scan Debug -> Event next(5)
        5
        acum = 5, elem = 4
        scan Debug -> Event next(9)
        9
        acum = 9, elem = 5
        scan Debug -> Event next(14)
        14
        scan Debug -> Event completed
        scan Debug -> isDisposed
    */
```


#### groupBy

- groupBy 操作符将源 Observable 分解为多个子 Observable，然后将这些子 Observable 发送出来。
- 也就是说该操作符会将元素通过某个键进行分组，然后将分组后的元素序列以 Observable 的形态发送出来。
```Swift
let disposeBag = DisposeBag()

//将奇数偶数分成两组
Observable<Int>.of(0, 1, 2, 3, 4, 5)
    .groupBy(keySelector: { (element) -> String in
        return element % 2 == 0 ? "偶数" : "基数"
    })
    .subscribe { (event) in
        switch event {
        case .next(let group):
            group.asObservable().subscribe({ (event) in
                print("key：\(group.key)    event：\(event)")
            })
            .disposed(by: disposeBag)
        default:
            print("")
        }
    }
    .disposed(by: disposeBag)
    
    
    
    /**
    运行结果如下：
        key：偶数    event：next(0)
        key：基数    event：next(1)
        key：偶数    event：next(2)
        key：基数    event：next(3)
        key：偶数    event：next(4)
        key：基数    event：next(5)
        key：基数    event：completed
        key：偶数    event：completed
    */
```


#### toArray

- 将 Observable 中的单个元素转换成 Array 的数据结构的 Observable 进行发送

```Swift
Observable.of(1, 2, 3, 4, 5, 6)
        .toArray()
        .debug("Test Debug", trimOutput: true) 
        .subscribe(onNext: { print($0) })
        .disposed(by: disposeBag)
        
        
    /**
    运行结果如下：
        Test Debug -> subscribed
        Test Debug -> Event next([1, 2, 3, 4, 5, 6])
        [1, 2, 3, 4, 5, 6]
        Test Debug -> Event completed
        Test Debug -> isDisposed
    */
```
