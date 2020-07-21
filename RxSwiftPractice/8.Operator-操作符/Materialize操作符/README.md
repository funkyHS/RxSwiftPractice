
### Materialize操作符

#### materialize
- 可以将序列产生的事件，转换成元素。
- 通常一个有限的 Observable 将产生零个或者多个 onNext 事件，最后产生一个 onCompleted 或者 onError 事件。而 materialize 操作符会将 Observable 产生的这些事件全部转换成元素，然后发送出来。
```Swift
Observable.of(1, 2, 1)
    .materialize()
    .subscribe(onNext: { print($0) })
    .disposed(by: disposeBag)
    
/**
 运行结果：
    next(1)
    next(2)
    next(1)
    completed
*/
```

#### dematerialize
- 该操作符的作用和 materialize 正好相反，它可以将 materialize 转换后的元素还原。
```Swift
Observable.of(1, 2, 1)
    .materialize()
    .dematerialize()
    .subscribe(onNext: { print($0) })
    .disposed(by: disposeBag)
    
/**
 运行结果：
    1
    2
    1
*/
```
