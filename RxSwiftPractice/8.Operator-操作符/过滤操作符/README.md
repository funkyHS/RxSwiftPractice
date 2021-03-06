
### 过滤操作符

#### filter
- 过滤掉某些不符合要求的事件
```Swift
    let disposeBag = DisposeBag()

    Observable.of(2, 30, 22, 5, 60, 3, 40 ,9)
        .filter {
            $0 > 10
        }
        .subscribe(onNext: { print($0) })
        .disposed(by: disposeBag)
    
    
    /**
    运行结果：
        30
        22
        60
        40
    */
```

#### distinctUntilChanged

- 过滤掉连续重复的事件
```Swift
let disposeBag = DisposeBag()
Observable.of(1, 2, 3, 1, 1, 4)
    .distinctUntilChanged()
    .subscribe(onNext: { print($0) })
    .disposed(by: disposeBag)
    
   /**
    运行结果：
        1
        2
        3
        1
        4
   */
```

#### single

- 限制只发送一次事件，或者满足条件的第一个事件
- 如果存在有多个事件或者没有事件都会发出一个 error 事件
- 如果只有一个事件，则不会发出 error 事件

```Swift

Observable.of(1, 2, 3, 4)
    .single{ $0 == 2 }
    .debug("single")
    .subscribe(onNext: { print($0) })
    .disposed(by: disposeBag)
    
   /**
    运行结果：
        single -> subscribed
        single -> Event next(2)
        2
        single -> Event completed
        single -> isDisposed
   */


Observable.of("A", "B", "C", "D")
    .single()
    .debug("single")
    .subscribe(onNext: { print($0) })
    .disposed(by: disposeBag)
    
    /**
     运行结果：
         single -> subscribed
         single -> Event next(A)
         A
         single -> Event error(Sequence contains more than one element.)
         Unhandled error happened: Sequence contains more than one element.
          subscription called from:
         single -> isDisposed
    */
    
    
```



#### elementAt

- 该方法实现只处理在指定位置的事件
```Swift
let disposeBag = DisposeBag()

Observable.of(1, 2, 3, 4)
    .elementAt(2)
    .subscribe(onNext: { print($0) })
    .disposed(by: disposeBag)
    
// 结果为 3
```

#### ignoreElements

- 该操作符可以忽略掉所有的元素，只发出 error 或 completed 事件。
- 如果我们并不关心 Observable 的任何元素，只想知道 Observable 在什么时候终止，那就可以使用 ignoreElements 操作符
```Swift
let disposeBag = DisposeBag()

Observable.of(1, 2, 3, 4)
    .ignoreElements()
    .subscribe{
        print($0)
    }
    .disposed(by: disposeBag)
    
    // 结果： completed
```


#### take

- 该方法实现仅发送 Observable 序列中的前 n 个事件，在满足数量之后会自动 .completed
```Swift
let disposeBag = DisposeBag()

Observable.of(1, 2, 3, 4)
    .take(2)
    .subscribe(onNext: { print($0) })
    .disposed(by: disposeBag)
    
// 结果是 1  2
```


#### takeLast

- 该方法实现仅发送 Observable 序列中的后 n 个事件。
```Swift
let disposeBag = DisposeBag()

Observable.of(1, 2, 3, 4)
    .takeLast(1)
    .subscribe(onNext: { print($0) })
    .disposed(by: disposeBag)
    
// 结果是 4
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





#### skip

- 该方法用于跳过源 Observable 序列发出的前 n 个事件
```Swift
let disposeBag = DisposeBag()

Observable.of(1, 2, 3, 4)
    .skip(2)
    .subscribe(onNext: { print($0) })
    .disposed(by: disposeBag)
// 结果是 3  4
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





#### Sample

- Sample 除了订阅源 Observable 外，还可以监视另外一个 Observable， 即 notifier 
- 每当收到 notifier 事件，就会从源序列取一个最新的事件并发送。而如果两次 notifier 事件之间没有源序列的事件，则不发送值

```Swift
    let disposeBag = DisposeBag()

    let source = PublishSubject<Int>()
    let notifier = PublishSubject<String>()

    source
        .sample(notifier)
        .subscribe(onNext: { print($0) })
        .disposed(by: disposeBag)

    source.onNext(1)

    //让源序列接收接收消息
    notifier.onNext("A")

    source.onNext(2)

    //让源序列接收接收消息
    notifier.onNext("B")
    notifier.onNext("C")

    source.onNext(3)
    source.onNext(4)

    //让源序列接收接收消息
    notifier.onNext("D")

    source.onNext(5)

    //让源序列接收接收消息
    notifier.onCompleted()

    // 结果是 1  2  4  5
```

#### debounce

- debounce 操作符可以用来过滤掉高频产生的元素，它只会发出这种元素：该元素产生后，一段时间内没有新元素产生。
- 换句话说就是，队列中的元素如果和下一个元素的间隔小于了指定的时间间隔，那么这个元素将被过滤掉。
- debounce 常用在用户输入的时候，不需要每个字母敲进去都发送一个事件，而是稍等一下取最后一个事件。
```Swift
import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController {

let disposeBag = DisposeBag()

override func viewDidLoad() {

    //定义好每个事件里的值以及发送的时间
    let times = [
        [ "value": 1, "time": 0.1 ],
        [ "value": 2, "time": 1.1 ],
        [ "value": 3, "time": 1.2 ],
        [ "value": 4, "time": 1.2 ],
        [ "value": 5, "time": 1.4 ],
        [ "value": 6, "time": 2.1 ]
    ]

    //生成对应的 Observable 序列并订阅
    Observable.from(times)
        .flatMap { item in
            return Observable.of(Int(item["value"]!))
            .delaySubscription(Double(item["time"]!),
            scheduler: MainScheduler.instance)
        }
        .debounce(0.5, scheduler: MainScheduler.instance) //只发出与下一个间隔超过0.5秒的元素
        .subscribe(onNext: { print($0) })
        .disposed(by: disposeBag)
    }
}

// 结果是 1  5  6
```



#### throttle
- 返回在指定连续时间窗口期间中，由源 Observable 发出的第一个和最后一个元素。这个运算符确保没有两个元素在少于 dueTime 的时间发送。

```Swift
    let subject = BehaviorSubject<Int>.init(value: 0)
    subject
        .asObserver()
        // 2秒内第一个和最后一个发出的元素
        .throttle(2, latest: true, scheduler: MainScheduler.instance)
        .subscribe({ (e) in
            print(e)
        })
        .disposed(by: disposeBag)

    subject.onNext(1)
    subject.onNext(2)
    subject.onNext(3)
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
        // 不会发送onNext(4)，因为onNext(3)在上一个2秒的窗口中，最后延迟到2秒发送出来，
        // onNext(4)是在第3秒进行发送，此时 onNext(4)的发送时间减去onNext(3)发送时间小于2，所以被忽略
        // 因为throttle会确保没有两个元素在少于dueTime的时间
        subject.onNext(4)
        subject.onNext(5)
        subject.onNext(6)
    }

    DispatchQueue.main.asyncAfter(deadline: .now() + 8.2) {
        subject.onNext(7)
    }

    DispatchQueue.main.asyncAfter(deadline: .now() + 12.2) {
        subject.onNext(8)
        subject.onNext(9)
        subject.onNext(10)
        subject.onCompleted()
    }



   /**
    运行结果：
        next(0)
        next(3)
        next(6)
        next(7)
        next(8)
        next(10)
        completed
   */
```












