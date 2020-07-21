### 条件和布尔操作符

#### amb
- 当传入多个 Observables 到 amb 操作符时，它将取第一个发出元素或产生事件的 Observable，然后只发出它的元素。并忽略掉其他的 Observables。

```Swift
let subject1 = PublishSubject<Int>()
let subject2 = PublishSubject<Int>()
let subject3 = PublishSubject<Int>()
 
subject1
    .amb(subject2)
    .amb(subject3)
    .subscribe(onNext: { print($0) })
    .disposed(by: disposeBag)
 
subject2.onNext(1) //  subject1.onNext(20), subject3.onNext(0)  第一个发出元素或产生事件的 Observable，影响后面的发出的元素
subject1.onNext(20)
subject3.onNext(0)
subject2.onNext(2)
subject1.onNext(40)
subject2.onNext(3)
subject1.onNext(60)
subject3.onNext(0)
subject3.onNext(0)

/**
 运行结果：
    1
    2
    3
*/
```

#### skipWhile

- skipWhile 操作符可以让你忽略源 Observable 中 头几个 元素，直到元素的判定为 false 后，它才镜像源 Observable，一旦有 false 产生，后面的元素不会再进行判断。
```Swift
    Observable<Int>.of(1, 1, 1, 1, 2, 3, 4, 1, 1)
            .skipWhile({ (value) -> Bool in
                return value == 1
            })
            .subscribe(onNext: { print($0) })
            .disposed(by: disposeBag)
            
            
    /**
     运行结果：
        2
        3
        4
        1
        1
    */
```


#### skipUntil

- 源 Observable 序列事件默认会一直跳过，直到 notifier 发出值或 complete 通知。

```Swift
    let disposeBag = DisposeBag()
     
    let source = PublishSubject<Int>()
    let notifier = PublishSubject<Int>()
     
    source
        .skipUntil(notifier)
        .subscribe(onNext: { print($0) })
        .disposed(by: disposeBag)
     
    source.onNext(1)
    source.onNext(2)
    source.onNext(3)
    source.onNext(4)
    source.onNext(5)
     
    //开始接收消息
    notifier.onNext(0)
     
    source.onNext(6)
    source.onNext(7)
    source.onNext(8)
     
    //仍然接收消息
    notifier.onNext(0)
     
    source.onNext(9)
        
        
    /**
     运行结果：
        6
        7
        8
        9
    */
```


#### takeWhile

- takeWhile 操作符将镜像源 Observable 直到某个元素的判定为 false。此时，这个镜像的 Observable 将立即终止。
```Swift
Observable.of(1, 2, -1, 3, 4)
    .takeWhile({ (value) -> Bool in
        return value >= 0
    })
    .subscribe(onNext: { print($0) })
    .disposed(by: disposeBag)
    
/**
 结果是:
    1
    2
*/
```


#### takeUntil

- 除了订阅源 Observable 外，通过 takeUntil 方法还可以监视另外一个 Observable， 即 notifier。
- 如果 notifier 发出值或 complete 通知，那么源 Observable 便自动完成，停止发送事件。
```Swift

let disposeBag = DisposeBag()
 
let source = PublishSubject<String>()
let notifier = PublishSubject<String>()
 
source
    .takeUntil(notifier)
    .subscribe(onNext: { print($0) })
    .disposed(by: disposeBag)
 
source.onNext("a")
source.onNext("b")
source.onNext("c")
source.onNext("d")
 
//停止接收消息
notifier.onNext("z")
 
source.onNext("e")
source.onNext("f")
source.onNext("g")


/**
 结果是:
    a
    b
    c
    d
*/
```
