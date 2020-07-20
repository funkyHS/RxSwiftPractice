
### Error Handling - 错误处理
- 一旦序列里面产出了一个 error 事件，整个序列将被终止。RxSwift 主要有两种错误处理机制：`retry - 重试`、`catch - 恢复`


#### 1. retry
- 使用该方法当遇到错误的时候，会重新订阅该序列。比如遇到网络请求失败时，可以进行重新连接。
- retry() 方法可以传入数字表示重试次数。不传的话只会重试一次
```
let disposeBag = DisposeBag()
var count = 1

let sequenceThatErrors = Observable<String>.create { observer in
    observer.onNext("a")
    observer.onNext("b")

    //让第一个订阅时发生错误
    if count == 1 {
        observer.onError(MyError.A)
        print("Error encountered")
        count += 1
    }

    observer.onNext("c")
    observer.onNext("d")
    observer.onCompleted()

    return Disposables.create()
}

sequenceThatErrors
    .retry(2)  //重试2次（参数为空则只重试一次）
    .subscribe(onNext: { print($0) })
    .disposed(by: disposeBag)
    
    
    
    /**
    
    运行结果：
        a
        b
        Error encountered
        a
        b
        c
        d
        
    */
```



#### 2. retryWhen
- 如果我们需要在发生错误时，经过一段延时后再重试
```
let disposeBag = DisposeBag()
var count = 1
let retryDelay: Double = 5  // 重试延时 5 秒
let maxRetryCount = 4       // 最多重试 4 次


let sequenceThatErrors = Observable<String>.create { observer in
    observer.onNext("a")
    observer.onNext("b")

    //让第一个订阅时发生错误
    if count == 1 {
        observer.onError(MyError.A)
        print("Error encountered")
        count += 1
    }

    observer.onNext("c")
    observer.onNext("d")
    observer.onCompleted()

    return Disposables.create()
}

sequenceThatErrors
    .retryWhen { (rxError: Observable<Error>) -> Observable<Int> in
    
        // 如果重试超过 4 次，就将错误抛出。如果错误在 4 次以内时，就等待 5 秒后重试：
        return rxError.flatMapWithIndex { (error, index) -> Observable<Int> in
        
            // flatMapWithIndex 提供错误的索引数 index
            guard index < maxRetryCount else {
                return Observable.error(error)
            }
            return Observable<Int>.timer(retryDelay, scheduler: MainScheduler.instance)
        }
    }
    .subscribe(onNext: { print($0) })
    .disposed(by: disposeBag)
    
    
    /**
    
    .retryWhen { (rxError: Observable<Error>) -> Observable<Int> in
    }
    // 返回的 Observable 发出一个元素时，就进行重试操作。当它发出一个 error 或者 completed 事件时，就不会重试，并且将这个事件传递给到后面的观察者。
    
    */
    
    
```



#### 3 catchError
- 该方法可以捕获 error，并对其进行处理。
- 同时还能返回另一个 Observable 序列进行订阅（切换到新的序列）
```
    let disposeBag = DisposeBag()

    let sequenceThatFails = PublishSubject<String>()
    let recoverySequence = Observable.of("1", "2", "3")

    sequenceThatFails
        .catchError {
            print("Error:", $0)
            return recoverySequence
        }
        .subscribe(onNext: { print($0) })
        .disposed(by: disposeBag)

    sequenceThatFails.onNext("a")
    sequenceThatFails.onNext("b")
    sequenceThatFails.onNext("c")
    sequenceThatFails.onError(MyError.A)
    sequenceThatFails.onNext("d")

    /**
        运行结果：
            a 
            b 
            c
            Error:A
            1 
            2 
            3
    */
```

#### 4 catchErrorJustReturn
- 当遇到 error 事件的时候，就返回指定的值，然后结束。
```
let disposeBag = DisposeBag()

let sequenceThatFails = PublishSubject<String>()

sequenceThatFails
    .catchErrorJustReturn("错误")
    .subscribe(onNext: { print($0) })
    .disposed(by: disposeBag)

sequenceThatFails.onNext("a")
sequenceThatFails.onNext("b")
sequenceThatFails.onNext("c")
sequenceThatFails.onError(MyError.A)
sequenceThatFails.onNext("d")

/** 
    运行结果 ：
        a  
        b  
        c  
        错误
*/
```
