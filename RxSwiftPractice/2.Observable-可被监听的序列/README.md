
### Observable 介绍

#### 1. Observable<T>
- `Observable<T>` 这个类就是 Rx 框架的基础，我们可以称它为`可观察序列`。它的作用就是可以**异步地产生一系列的 Event（事件）**，即一个 `Observable<T>` 对象会随着时间推移不定期地发出 event(element : T) 这样一个东西。
- 而且这些 Event 还可以携带数据，它的泛型` <T>` 就是用来指定这个 Event 携带的数据的类型。
- 有了可观察序列，我们还需要有一个 `Observer（订阅者）`来订阅它，这样这个订阅者才能收到` Observable<T>` 不时发出的 Event。


#### 2. Event

-  Event 就是一个枚举，也就是说一个 Observable 是可以发出 3 种不同类型的 Event 事件
- `next `事件就是那个可以携带数据` <T> `的事件，可以说它就是一个“最正常”的事件。
- `error `事件表示一个错误，它可以携带具体的错误内容，一旦 Observable 发出了 error event，则这个 Observable 就等于终止了，以后它再也不会发出 event 事件了。
- `completed` 事件表示 Observable 发出的事件正常地结束了，跟 error 一样，一旦 Observable 发出了 completed event，则这个 Observable 就等于终止了，以后它再也不会发出 event 事件了。
```Swift
public enum Event<Element> {
    /// Next element is produced.
    case next(Element)
 
    /// Sequence terminated with an error.
    case error(Swift.Error)
 
    /// Sequence completed successfully.
    case completed
}
```


### 创建 Observable 可监听序列

#### 1. just() 方法
- 显式地标注出了 observable 的类型为 Observable<Int>，即指定了这个 Observable 所发出的事件携带的数据类型必须是 Int 类型的
```Swift
    let observable = Observable<Int>.just(5)
```
 
#### 2. of() 方法
- 该方法可以接受可变数量的参数（必需要是同类型的），Swift 会自动推断类型
```Swift
    let observable = Observable.of("A", "B", "C")
```

#### 3. from() 方法
- 该方法需要一个数组参数
```Swift
    let observable = Observable.from(["A", "B", "C"])
```

#### 4. empty() 方法
- 该方法创建一个空内容的 Observable 序列。
```Swift
    let observable = Observable<Int>.empty()
```

#### 5. never() 方法
- 该方法创建一个永远不会发出 Event（也不会终止）的 Observable 序列
```Swift
    let observable = Observable<Int>.never()
```

#### 6. error() 方法
- 直接发送一个错误的 Observable 序列
```Swift
    enum MyError: Error {
        case A
        case B
    }

    let observable = Observable<Int>.error(MyError.A)
```


#### 7. range() 方法
- 通过指定起始和结束数值，创建一个以这个范围内所有值作为初始值的 Observable 序列
```Swift
    // 使用range()
    let observable = Observable.range(start: 1, count: 5)
    // 使用of()
    let observable = Observable.of(1, 2, 3 ,4 ,5)
```


#### 8. repeatElement() 方法
- 创建一个可以无限发出给定元素的 Event 的 Observable 序列（永不终止）
```Swift
    let observable = Observable.repeatElement(1)
```


#### 9. generate() 方法
- 创建一个只有当提供的所有的判断条件都为 true 的时候，才会给出动作的 Observable 序列
```Swift
    // 使用generate()方法
    let observable = Observable.generate(
        initialState: 0,
        condition: { $0 <= 10 },
        iterate: { $0 + 2 }
    )
    // 使用of()方法
    let observable = Observable.of(0 , 2 ,4 ,6 ,8 ,10)
```

#### 10. create() 方法
- 该方法接受一个 block 形式的参数，任务是对每一个过来的订阅进行处理
```Swift
    // 这个block有一个回调参数observer就是订阅这个Observable对象的订阅者
    // 当一个订阅者订阅这个Observable对象的时候，就会将订阅者作为参数传入这个block来执行一些内容
    let observable = Observable<String>.create{observer in
        // 对订阅者发出了.next事件，且携带了一个数据"hangge.com"
        observer.onNext("hangge.com")
        // 对订阅者发出了.completed事件
        observer.onCompleted()
        // 因为一个订阅行为会有一个Disposable类型的返回值，所以在结尾一定要returen一个Disposable
        return Disposables.create()
    }

    //订阅测试
    observable.subscribe {
        print($0)
    }
```

#### 11. deferred() 方法
- 方法相当于是创建一个 Observable 工厂，通过传入一个 block 来执行延迟 Observable 序列创建的行为，而这个 block 里就是真正的实例化序列对象的地方
```Swift
    // 用于标记是奇数、还是偶数
    var isOdd = true

    // 使用deferred()方法延迟Observable序列的初始化，通过传入的block来实现Observable序列的初始化并且返回。
    let factory : Observable<Int> = Observable.deferred {
        
        // 让每次执行这个block时候都会让奇、偶数进行交替
        isOdd = !isOdd
        
        // 根据isOdd参数，决定创建并返回的是奇数Observable、还是偶数Observable
        if isOdd {
            return Observable.of(1, 3, 5 ,7)
        } else {
            return Observable.of(2, 4, 6, 8)
        }
    }

    // 第1次订阅测试
    factory.subscribe { event in
        print("\(isOdd)", event)
    }

    // 第2次订阅测试
    factory.subscribe { event in
        print("\(isOdd)", event)
    }
```

#### 12. interval() 方法
- 创建的 Observable 序列每隔一段设定的时间，会发出一个索引数的元素。而且它会一直发送下去
```Swift
    // 下面方法让其每 1 秒发送一次，并且是在主线程（MainScheduler）发送
    let observable = Observable<Int>.interval(1, scheduler: MainScheduler.instance)
    observable.subscribe { event in
        print(event)
    }
```


#### 13. timer() 方法
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




### 订阅 Observable

- 使用 subscribe() 订阅了一个 Observable 对象，该方法的 block 的回调参数就是被发出的 event 事件，将其直接打印出来
```Swift
    // 如果想要获取到这个事件里的数据，可以通过 event.element 得到
    let observable = Observable.of("A", "B")
    observable.subscribe { event in
        print(event)
        print(event.element)
    }
    
    /**
    
    运行结果：
        next(A)
        Optional("A")
        next(B)
        Optional("B")
        completed
        nil
    */
```

- 另一个 subscribe 方法，它可以把 event 进行分类， 同时会把 event 携带的数据直接解包出来作为参数
```Swift
    let observable = Observable.of("A", "B", "C")

    observable.subscribe(onNext: { element in
        print(element)
    }, onError: { error in
        print(error)
    }, onCompleted: {
        print("completed")
    }, onDisposed: {
        print("disposed")
    })
```


