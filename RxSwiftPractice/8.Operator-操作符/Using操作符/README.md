
### Using操作符

#### using
- 使用 using 操作符创建 Observable 时，同时会创建一个可被清除的资源，一旦 Observable 终止了，那么这个资源就会被清除掉了

```Swift

func using() {
    //一个无限序列（每隔0.1秒创建一个序列数 ）
    let infiniteInterval$ = Observable<Int>
        .interval(0.1, scheduler: MainScheduler.instance)
        .do(
            onNext: { print("infinite$: \($0)") },
            onSubscribe: { print("开始订阅 infinite$")},
            onDispose: { print("销毁 infinite$")}
    )
     
    //一个有限序列（每隔0.5秒创建一个序列数，共创建三个 ）
    let limited$ = Observable<Int>
        .interval(0.5, scheduler: MainScheduler.instance)
        .take(2)
        .do(
            onNext: { print("limited$: \($0)") },
            onSubscribe: { print("开始订阅 limited$")},
            onDispose: { print("销毁 limited$")}
    )
     
    //使用using操作符创建序列
    let o: Observable<Int> = Observable.using({ () -> AnyDisposable in
        return AnyDisposable(infiniteInterval$.subscribe())
    }, observableFactory: { _ in return limited$ }
    )
    o.subscribe()
}


class AnyDisposable: Disposable {
    let _dispose: () -> Void
    
    init(_ disposable: Disposable) {
        _dispose = disposable.dispose
    }
    
    func dispose() {
        _dispose()
    }
}


/**
  运行结果：
    开始订阅 infinite$
    开始订阅 limited$
    infinite$: 0
    infinite$: 1
    infinite$: 2
    infinite$: 3
    infinite$: 4
    limited$: 0
    infinite$: 5
    infinite$: 6
    infinite$: 7
    infinite$: 8
    infinite$: 9
    limited$: 1
    销毁 limited$
    销毁 infinite$
*/
```
