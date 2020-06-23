

#### 观察者（Observer）介绍

##### 观察者（Observer）的作用就是监听事件，然后对这个事件做出响应。或者说任何响应事件的行为都是观察者
    >当我们点击按钮，弹出一个提示框。那么这个“弹出一个提示框”就是观察者 Observer<Void>
    >当我们请求一个远程的 json 数据后，将其打印出来。那么这个“打印 json 数据”就是观察者 Observer<JSON>



#### 直接在 subscribe、bind 方法中创建观察者

##### 1，在 subscribe 方法中创建
    >创建观察者最直接的方法就是在 Observable 的 subscribe 方法后面描述当事件发生时，需要如何做出响应
    >比如下面的样例，观察者就是由后面的 onNext，onError，onCompleted 这些闭包构建出来的
    ```
    let observable = Observable.of("A", "B", "C")
    
    observable.subscribe(onNext: { element in
        print(element)
    }, onError: { error in
        print(error)
    }, onCompleted: {
        print("completed")
    })
    ```

##### 2，在 bind 方法中创建
    >创建一个定时生成索引数的 Observable 序列，并将索引数不断显示在 label 标签上
    ```
    //Observable序列（每隔1秒钟发出一个索引数）
    let observable = Observable<Int>.interval(1, scheduler: MainScheduler.instance)
    
    observable
        .map { "当前索引数：\($0 )"}
        .bind { [weak self](text) in
            //收到发出的索引数后显示到label上
            self?.label.text = text
        }
        .disposed(by: disposeBag)
    ```


#### 使用 AnyObserver 创建观察者
    >AnyObserver 可以用来描叙任意一种观察者
    

##### 1，配合 subscribe 方法使用
    ```
    //观察者
    let observer: AnyObserver<String> = AnyObserver { (event) in
        switch event {
        case .next(let data):
            print(data)
        case .error(let error):
            print(error)
        case .completed:
            print("completed")
        }
    }
    
    let observable = Observable.of("A", "B", "C")
    observable.subscribe(observer)
    ```

##### 2，配合 bindTo 方法使用

    ```
    //观察者
    let observer: AnyObserver<String> = AnyObserver { [weak self] (event) in
        switch event {
        case .next(let text):
            //收到发出的索引数后显示到label上
            self?.label.text = text
        default:
            break
        }
    }
    
    //Observable序列（每隔1秒钟发出一个索引数）
    let observable = Observable<Int>.interval(1, scheduler: MainScheduler.instance)
    observable
        .map { "当前索引数：\($0 )"}
        .bind(to: observer)
        .disposed(by: disposeBag)
    ```



#### 使用 Binder 创建观察者

##### 1，基本介绍
    >相较于 AnyObserver 的大而全，Binder 更专注于特定的场景
    >不会处理错误事件
    >确保绑定都是在给定 Scheduler 上执行（默认 MainScheduler）
    >一旦产生错误事件，在调试环境下将执行 fatalError，在发布环境下将打印错误信息
    
##### 2，使用样例
    ```
    //观察者
    let observer: Binder<String> = Binder(label) { (view, text) in
        //收到发出的索引数后显示到label上
        view.text = text
    }
    
    //Observable序列（每隔1秒钟发出一个索引数）
    let observable = Observable<Int>.interval(1, scheduler: MainScheduler.instance)
    observable
        .map { "当前索引数：\($0 )"}
        .bind(to: observer)
        .disposed(by: disposeBag)
    ```




#### Binder 在 RxCocoa 中的应用

- 其实 RxCocoa 在对许多 UI 控件进行扩展时，就利用 Binder 将控件属性变成观查者，比如 UIControl+Rx.swift 中的 isEnabled 属性便是一个 observer
```
import RxSwift
import UIKit

extension Reactive where Base: UIControl {

    /// Bindable sink for `enabled` property.
    public var isEnabled: Binder<Bool> {
        return Binder(self.base) { control, value in
            control.isEnabled = value
        }
    }
}
```


- 因此我们可以将序列直接绑定到它上面。比如下面样例，button 会在可用、不可用这两种状态间交替变换（每隔一秒）
```
//Observable序列（每隔1秒钟发出一个索引数）
let observable = Observable<Int>.interval(1, scheduler: MainScheduler.instance)
observable
    .map { $0 % 2 == 0 }
    .bind(to: button.rx.isEnabled)
    .disposed(by: disposeBag)
```


#### 自定义可绑定属性

- 对 UI 类进行扩展
```
import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController {

    @IBOutlet weak var label: UILabel!

    let disposeBag = DisposeBag()

    override func viewDidLoad() {

        //Observable序列（每隔0.5秒钟发出一个索引数）
        let observable = Observable<Int>.interval(0.5, scheduler: MainScheduler.instance)
        observable
            .map { CGFloat($0) }
            .bind(to: label.fontSize) //根据索引数不断变放大字体
            .disposed(by: disposeBag)
    }
}

extension UILabel {
    public var fontSize: Binder<CGFloat> {
        return Binder(self) { label, fontSize in
            label.font = UIFont.systemFont(ofSize: fontSize)
            }
    }
}

```

#### 对 Reactive 类进行扩展

```
import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController {

    @IBOutlet weak var label: UILabel!

    let disposeBag = DisposeBag()

    override func viewDidLoad() {

        //Observable序列（每隔0.5秒钟发出一个索引数）
        let observable = Observable<Int>.interval(0.5, scheduler: MainScheduler.instance)
        observable
            .map { CGFloat($0) }
            .bind(to: label.rx.fontSize) //根据索引数不断变放大字体
            .disposed(by: disposeBag)
    }
}

extension Reactive where Base: UILabel {
    public var fontSize: Binder<CGFloat> {
        return Binder(self.base) { label, fontSize in
            label.font = UIFont.systemFont(ofSize: fontSize)
        }
    }
}

```
