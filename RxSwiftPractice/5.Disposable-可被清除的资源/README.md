
###  Observable 的销毁（Dispose）
- 一个 Observable 序列被创建出来后它不会马上就开始被激活从而发出 Event，而是要等到它被某个人订阅了才会激活它
- 而 Observable 序列激活之后要一直等到它发出了 .error 或者 .completed 的 event 后，它才被终结

#### 1. dispose() 方法
- 使用该方法我们可以手动取消一个订阅行为
- 如果我们觉得这个订阅结束了不再需要了，就可以调用 dispose() 方法把这个订阅给销毁掉，防止内存泄漏
- 当一个订阅行为被 dispose 了，那么之后 observable 如果再发出 event，这个已经 dispose 的订阅就收不到消息了

```Swift
    let observable = Observable.of("A", "B", "C")
             
    //使用subscription常量存储这个订阅方法
    let subscription = observable.subscribe { event in
        print(event)
    }
             
    //调用这个订阅的dispose()方法
    subscription.dispose()
```

#### 2. DisposeBag
- 可以把一个 DisposeBag 对象看成一个垃圾袋，把用过的订阅行为都放进去
- 而这个 DisposeBag 就会在自己快要 dealloc 的时候，对它里面的所有订阅行为都调用 dispose() 方法
```Swift
    var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
                 
        // 第1个Observable，及其订阅
        let observable1 = Observable.of("A", "B", "C")
        observable1.subscribe { event in
            print(event)
        }.disposed(by: self.disposeBag)
         
        // 第2个Observable，及其订阅
        let observable2 = Observable.of(1, 2, 3)
        observable2.subscribe { event in
            print(event)
        }.disposed(by: self.disposeBag)
    }
```


#### 3. takeUntil

```Swift
    
    override func viewDidLoad() {
        super.viewDidLoad()
                 
        // 这将使得订阅一直持续到控制器的 dealloc 事件产生为止。
        
         _ = usernameValid
               .takeUntil(self.rx.deallocated)
               .bind(to: passwordOutlet.rx.isEnabled)
    }
    
```
