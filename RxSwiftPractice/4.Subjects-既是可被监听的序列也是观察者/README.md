

### Subjects

- 之前当我们创建一个 Observable 的时候就要预先将要发出的数据都准备好，等到有人订阅它时再将数据通过 Event 发出去。但有时我们希望 Observable 在运行时能动态地“获得”或者说“产生”出一个新的数据，再通过 Event 发送出去。比如：订阅一个输入框的输入内容，当用户每输入一个字后，这个输入框关联的 Observable 就会发出一个带有输入内容的 Event，通知给所有订阅者。这个就可以使用 Subjects 来实现。


### 1. Subjects 基本介绍

#### Subjects 既是订阅者，也是 Observable
-  说它是订阅者，是因为它能够动态地接收新的值。说它又是一个 Observable，是因为当 Subjects 有了新的值之后，就会通过 Event 将新值发出给他的所有订阅者。
- 例如：textField的当前文本。它可以看成是由用户输入，而产生的一个文本序列。也可以是由外部文本序列，来控制当前显示内容的观察者
```Swift
    // 作为可被监听的序列
    let observable = textField.rx.text
    observable.subscribe(onNext: { text in show(text: text) })
```

```Swift
    // 作为观察者
    let observer = textField.rx.text
    let text: Observable<String?> = ...
    text.bind(to: observer)
```
- 有许多 UI 控件都存在这种特性，例如：switch的开关状态，segmentedControl的选中索引号，datePicker的选中日期等等。



#### 框架中的五种Subjects
- 分别为：AsyncSubject、PublishSubject、BehaviorSubject、ReplaySubject、ControlProperty、（Variable 废弃）。他们之间既有各自的特点，也有相同之处
    - 首先他们都是 Observable，他们的订阅者都能收到他们发出的新的 Event。
    - 直到 Subject 发出 .complete 或者 .error 的 Event 后，该 Subject 便终结了，同时它也就不会再发出 .next 事件。
    - 对于那些在 Subject 终结后再订阅他的订阅者，也能收到 subject 发出的一条 .complete 或 .error 的 event，告诉这个新的订阅者它已经终结了。
    - 他们之间最大的区别只是在于：`当一个新的订阅者刚订阅它的时候，能不能收到 Subject 以前发出过的旧 Event，如果能的话又能收到多少个`

#### Subject 常用的几个方法：
- `onNext(:)`：是 on(.next(:)) 的简便写法。该方法相当于 subject 接收到一个 .next 事件。
- `onError(:)`：是 on(.error(:)) 的简便写法。该方法相当于 subject 接收到一个 .error 事件。
- `onCompleted()`：是 on(.completed) 的简便写法。该方法相当于 subject 接收到一个 .completed 事件。



### 2. AsyncSubject
- `AsyncSubject` 将在源 Observable 产生完成事件后，发出最后一个元素（仅仅只有最后一个元素）
- 如果源 Observable 没有发出任何元素，只有一个完成事件。那 AsyncSubject 也只有一个完成事件
- 如果源 Observable 因为产生了一个 error 事件而中止， AsyncSubject 就不会发出任何元素，而是将这个 error 事件发送出来
```Swift
    let disposeBag = DisposeBag()
    let subject = AsyncSubject<String>()

    subject
      .subscribe { print("Subscription: 1 Event:", $0) }
      .disposed(by: disposeBag)

    subject.onNext("1")
    subject.onNext("2")
    subject.onNext("3")
    subject.onCompleted()
    
    /**
    运行结果：
        Subscription: 1 Event: next("3")
        Subscription: 1 Event: completed    
    */
```


### 3. PublishSubject

- `PublishSubject` 是最普通的 Subject，它不需要初始值就能创建。PublishSubject 的订阅者从他们开始订阅的时间点起，可以收到订阅后 Subject 发出的新 Event，而`不会收到他们在订阅前已发出的 Event`。
```Swift

    let disposeBag = DisposeBag()

    // 创建一个PublishSubject
    let subject = PublishSubject<String>()

    // 由于当前没有任何订阅者，所以这条信息不会输出到控制台
    subject.onNext("111")

    // 第1次订阅subject
    subject.subscribe(onNext: { string in
        print("第1次订阅：", string)
    }, onCompleted:{
        print("第1次订阅：onCompleted")
    }).disposed(by: disposeBag)

    // 当前有1个订阅，则该信息会输出到控制台
    subject.onNext("222")

    // 第2次订阅subject
    subject.subscribe(onNext: { string in
        print("第2次订阅：", string)
    }, onCompleted:{
        print("第2次订阅：onCompleted")
    }).disposed(by: disposeBag)

    // 当前有2个订阅，则该信息会输出到控制台
    subject.onNext("333")

    // 让subject结束
    subject.onCompleted()

    // subject完成后不会在发出.next事件了。
    subject.onNext("444")

    // subject完成后它的所有订阅（包括结束后的订阅），都能收到subject的.completed事件，
    subject.subscribe(onNext: { string in
        print("第3次订阅：", string)
    }, onCompleted:{
        print("第3次订阅：onCompleted")
    }).disposed(by: disposeBag)
    
    
    /**
    运行结果：
        第1次订阅：222
        第1次订阅：333
        第2次订阅：333
        第1次订阅：onCompleted
        第2次订阅：onCompleted
        第3次订阅：onCompleted    
    */
    

```


### 4. BehaviorSubject

- `BehaviorSubject` 需要通过一个默认初始值来创建。
- 当一个观察者来订阅它的时候，这个观察者会立即`收到 BehaviorSubjects 上一个发出的 event`。如果不存在最新的元素，就发出默认元素。
- 每当产生新的元素，都会发送给观察者。
```Swift
    let disposeBag = DisposeBag()

    //创建一个BehaviorSubject
    let subject = BehaviorSubject(value: "111")

    //第1次订阅subject
    subject.subscribe { event in
        print("第1次订阅：", event)
    }.disposed(by: disposeBag)

    //发送next事件
    subject.onNext("222")

    //发送error事件
    subject.onError(NSError(domain: "local", code: 0, userInfo: nil))

    //第2次订阅subject
    subject.subscribe { event in
        print("第2次订阅：", event)
    }.disposed(by: disposeBag)
    
    
    /**
    运行结果：
        第1次订阅：next(111)
        第1次订阅：next(222)
        第1次订阅：error(Error Domain=local Code=0 "(null)")
        第2次订阅：error(Error Domain=local Code=0 "(null)")
    */
```

### 5. ReplaySubject

- `ReplaySubject` 在创建时候需要设置一个 `bufferSize`，表示它对于它发送过的 event 的缓存个数。比如一个 ReplaySubject 的 bufferSize 设置为 2，它发出了 3 个 .next 的 event，那么它会将后两个（最近的两个）event 给缓存起来。此时如果有一个 subscriber 订阅了这个 ReplaySubject，那么这个 subscriber 就会立即收到前面缓存的两个 .next 的 event。
- 如果一个 subscriber 订阅已经结束的 ReplaySubject，除了会收到缓存的 .next 的 event 外，还会收到那个终结的 .error 或者 .complete 的 event。
```Swift
    let disposeBag = DisposeBag()

    // 缓存所有已产生的元素
    // let subject = ReplaySubject<String>.createUnbounded()
    
    // 创建一个bufferSize为2的ReplaySubject
    let subject = ReplaySubject<String>.create(bufferSize: 2)

    // 连续发送3个next事件
    subject.onNext("111")
    subject.onNext("222")
    subject.onNext("333")

    // 第1次订阅subject
    subject.subscribe { event in
        print("第1次订阅：", event)
    }.disposed(by: disposeBag)

    // 再发送1个next事件
    subject.onNext("444")

    // 第2次订阅subject
    subject.subscribe { event in
        print("第2次订阅：", event)
    }.disposed(by: disposeBag)

    // 让subject结束
    subject.onCompleted()

    // 第3次订阅subject
    subject.subscribe { event in
        print("第3次订阅：", event)
    }.disposed(by: disposeBag)
    
    
    
    /**
    运行结果：
        第1次订阅：next(222)
        第1次订阅：next(333)
        第1次订阅：next(444)
        第2次订阅：next(333)
        第2次订阅：next(444)
        第1次订阅：completed
        第2次订阅：completed
        第3次订阅：next(333)
        第3次订阅：next(444)
        第3次订阅：completed
    */
```

### 6. ControlProperty
- `ControlProperty` 专门用于描述 UI 控件属性的，它不会产生 error 事件
- 一定在 MainScheduler 订阅（主线程订阅），一定在 MainScheduler 监听（主线程监听）
- 共享状态变化


### 7. BehaviorRelay

- `BehaviorRelay` 是作为 Variable 的替代者出现的。它的本质其实也是对 BehaviorSubject 的封装，所以它也必须要通过一个默认的初始值进行创建。
- BehaviorRelay 具有 BehaviorSubject 的功能，能够向它的订阅者发出上一个 event 以及之后新创建的 event。
- 与 BehaviorSubject 不同的是，不需要也不能手动给 BehaviorReply 发送 completed 或者 error 事件来结束它（BehaviorRelay 会在销毁时也不会自动发送 .complete 的 event）。
- BehaviorRelay 有一个 value 属性，我们通过这个属性可以获取最新值。而通过它的 accept() 方法可以对值进行修改。

```Swift
import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let disposeBag = DisposeBag()

        // 创建一个初始值为111的BehaviorRelay
        let subject = BehaviorRelay<String>(value: "111")

        // 修改value值
        subject.accept("222")

        // 第1次订阅
        subject.asObservable().subscribe {
            print("第1次订阅：", $0)
        }.disposed(by: disposeBag)

        // 修改value值
        subject.accept("333")

        // 第2次订阅
        subject.asObservable().subscribe {
            print("第2次订阅：", $0)
        }.disposed(by: disposeBag)

        // 修改value值
        subject.accept("444")
    }
    
    
    
    /**
    运行结果：
        第1次订阅：next(222)
        第1次订阅：next(333)
        第2次订阅：next(333)
        第1次订阅：next(444)
        第2次订阅：next(444)
    */
}
```
- 如果想将新值合并到原值上，可以通过 accept() 方法与 value 属性配合来实现。（这个常用在表格上拉加载功能上，BehaviorRelay 用来保存所有加载到的数据）
```
override func viewDidLoad() {
    super.viewDidLoad()

    let disposeBag = DisposeBag()

    //创建一个初始值为包含一个元素的数组的BehaviorRelay
    let subject = BehaviorRelay<[String]>(value: ["1"])

    //修改value值
    subject.accept(subject.value + ["2", "3"])

    //第1次订阅
    subject.asObservable().subscribe {
        print("第1次订阅：", $0)
    }.disposed(by: disposeBag)

    //修改value值
    subject.accept(subject.value + ["4", "5"])

    //第2次订阅
    subject.asObservable().subscribe {
        print("第2次订阅：", $0)
    }.disposed(by: disposeBag)

    //修改value值
    subject.accept(subject.value + ["6", "7"])
}
```

### 6. Variable

（注意：由于 Variable 在之后版本中将被废弃，建议使用 Varible 的地方都改用下面介绍的 BehaviorRelay 作为替代。）

- Variable 其实就是对 BehaviorSubject 的封装，所以它也必须要通过一个默认的初始值进行创建。
- Variable 具有 BehaviorSubject 的功能，能够向它的订阅者发出上一个 event 以及之后新创建的 event。
- 不同的是，Variable 还把会把当前发出的值保存为自己的状态。同时它会在销毁时自动发送 .complete 的 event，不需要也不能手动给 Variables 发送 completed 或者 error 事件来结束它。
- 简单地说就是 Variable 有一个 value 属性，我们改变这个 value 属性的值就相当于调用一般 Subjects 的 onNext() 方法，而这个最新的 onNext() 的值就被保存在 value 属性里了，直到我们再次修改它。
- Variables 本身没有 subscribe() 方法，但是所有 Subjects 都有一个 asObservable() 方法。我们可以使用这个方法返回这个 Variable 的 Observable 类型，拿到这个 Observable 类型我们就能订阅它了。
- 由于 Variable 对象在 viewDidLoad() 方法内初始化，所以它的生命周期就被限制在该方法内。当这个方法执行完毕后，这个 Variable 对象就会被销毁，同时它也就自动地向它的所有订阅者发出 .completed 事件
```
override func viewDidLoad() {
    super.viewDidLoad()

    let disposeBag = DisposeBag()

    //创建一个初始值为111的Variable
    let variable = Variable("111")

    //修改value值
    variable.value = "222"

    //第1次订阅
    variable.asObservable().subscribe {
        print("第1次订阅：", $0)
    }.disposed(by: disposeBag)

    //修改value值
    variable.value = "333"

    //第2次订阅
    variable.asObservable().subscribe {
        print("第2次订阅：", $0)
    }.disposed(by: disposeBag)

    //修改value值
    variable.value = "444"
}

```
