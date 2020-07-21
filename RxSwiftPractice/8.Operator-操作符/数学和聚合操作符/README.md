
### 数学和聚合操作符

#### concat
- concat 会把多个 Observable 序列合并（串联）为一个 Observable 序列。
- 并且只有当前面一个 Observable 序列发出了 completed 事件，才会开始发送下一个 Observable 序列事件。

```Swift
let disposeBag = DisposeBag()
 
let subject1 = BehaviorSubject(value: 1)
let subject2 = BehaviorSubject(value: 2)
 
let behaviorRelay = BehaviorRelay(value: subject1)
behaviorRelay.asObservable()
    .concat()
    .subscribe(onNext: { print($0) })
    .disposed(by: disposeBag)
 
subject2.onNext(2)
subject1.onNext(1)
subject1.onNext(1)
subject1.onCompleted()
 
behaviorRelay.accept(subject2)
subject2.onNext(2)
    
/** 
  结果：
    1
    1
    1
    2
    2
*/
```


#### reduce
- reduce 接受一个初始值，和一个操作符号。
- reduce 将给定的初始值，与序列里的每个值进行累计运算。得到一个最终结果，并将其作为单个值发送出去。
```Swift
Observable.of(1, 2, 3, 4, 5)
    .reduce(0, accumulator: +)
    .subscribe(onNext: { print($0) })
    .disposed(by: disposeBag)
    
// 结果： 15
```
