//
//  ViewController.swift
//  RxSwiftPractice
//
//  Created by 胡晟 on 2019/1/16.
//  Copyright © 2019 Funky. All rights reserved.
//


/**

学习资料：

https://beeth0ven.github.io/RxSwift-Chinese-Documentation/

https://www.hangge.com/blog/cache/detail_1917.html

*/

import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    let data:[(UIViewController, String)] = [(FunkyViewController1(), "传统方式编程"),
                                             (FunkyViewController2(), "响应式编程")]
    
    
    let disposeBag = DisposeBag()
    
    func debug() {
        Observable.of("2", "3")
            .startWith("1")
            .debug("Test Debug", trimOutput: true)  // identifier: 描述， trimOutput: 是否截取最多四十个字符
            .subscribe(onNext: { print($0) })
            .disposed(by: disposeBag)
    }
    func toArray() {
        Observable.of(1, 2, 3, 4, 5, 6)
            .toArray()
            .debug("Test Debug", trimOutput: true)
            .subscribe(onNext: { print($0) })
            .disposed(by: disposeBag)
    }
    func scan() {
        Observable.of(1, 2, 3, 4, 5)
                .scan(-1) { (acum, elem) -> Int in
                    print("acum = \(acum), elem = \(elem)")
                    return acum + elem
                }
                .debug("scan Debug", trimOutput: true)
                .subscribe(onNext: { print($0) })
                .disposed(by: disposeBag)
    }
    func flatMap() {
         let subject1 = BehaviorSubject(value: "A")
           let subject2 = BehaviorSubject(value: "1")
        
           let behaviorRelay = BehaviorRelay(value: subject1)
        
           behaviorRelay.asObservable()
               .flatMap { $0 }
               .subscribe(onNext: { print($0) })
               .disposed(by: disposeBag)
        
           subject1.onNext("B")
        
           behaviorRelay.accept(subject2)
           subject2.onNext("2")
           subject1.onNext("C")
    }
    func flatMapFirst() {
        // flatMapFirst
        let subject1 = BehaviorSubject(value: "A")
        let subject2 = BehaviorSubject(value: "1")
        let behaviorRelay = BehaviorRelay(value: subject1)
        behaviorRelay.asObservable()
            .flatMapFirst { $0 }
            .subscribe(onNext: { print($0) })
            .disposed(by: disposeBag)
        subject1.onNext("B")
        behaviorRelay.accept(subject2)
        subject2.onNext("2")
        subject1.onNext("C")
    }
    func flatMapLatest() {
        // flatMapLatest
        let subject1 = BehaviorSubject(value: "A")
        let subject2 = BehaviorSubject(value: "1")

        let behaviorRelay = BehaviorRelay(value: subject1)
        behaviorRelay.asObservable()
            .flatMapLatest { $0 }
            .subscribe(onNext: { print($0) })
            .disposed(by: disposeBag)

        subject1.onNext("B")
        behaviorRelay.accept(subject2)
        subject2.onNext("2")
        subject1.onNext("C")
    }
    func concatMap() {
        let subject1 = BehaviorSubject(value: "A")
        let subject2 = BehaviorSubject(value: "1")
        let behaviorRelay = BehaviorRelay(value: subject1)

        behaviorRelay.asObservable()
            .concatMap { $0 }
            .subscribe(onNext: { print($0) })
            .disposed(by: disposeBag)

        subject1.onNext("B")
        behaviorRelay.accept(subject2)
        subject2.onNext("2")
        subject1.onNext("C")
        subject1.onCompleted() //只有前一个序列结束后，才能接收下一个序列
        
    }
    func throttle() {
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

    }
    func distinctUntilChanged() {
        Observable.of(1, 2, 3, 1, 1, 4)
            .distinctUntilChanged()
            .subscribe(onNext: { print($0) })
            .disposed(by: disposeBag)
    }
    func skipWhile() {
        Observable<Int>.of(1, 1, 1, 1, 2, 3, 4, 1, 1)
            .skipWhile({ (value) -> Bool in
                return value == 1
            })
            .subscribe(onNext: { print($0) })
            .disposed(by: disposeBag)
    }
    func skipUntil() {
         let observable = Observable<String>.create { (observer) -> Disposable in

                   DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                       observer.onNext("1")
                       observer.onNext("2")
                       observer.onNext("3")
                   }

                   // section 2
                   DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                       observer.onNext("4")
                       observer.onNext("5")
                       observer.onNext("6")
                   }
                   return Disposables.create()
               }

               let skipUntilObservable = Observable<Int>.create { (observer) -> Disposable in
                   DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                       print("=============== ")
                       observer.onNext(0)
                   }
                   return Disposables.create()
               }

               observable.skipUntil(skipUntilObservable)
                       .subscribe(onNext: { print($0) })
                       .disposed(by: disposeBag)
               
    }
    func takeWhile() {
        Observable.of(1, 2, -1, 3, 4)
                 .takeWhile({ (value) -> Bool in
                     return value >= 0
                 })
                 .subscribe(onNext: { print($0) })
                 .disposed(by: disposeBag)
    }
    func single() {
        Observable.of(1, 2, 3, 4)
            .single{ $0 == 2 }
            .debug("single")
            .subscribe(onNext: { print($0) })
            .disposed(by: disposeBag)

        Observable.of("A", "B", "C", "D")
            .single()
            .debug("single")
            .subscribe(onNext: { print($0) })
            .disposed(by: disposeBag)
    }
    func startWith() {
        Observable.of("2", "3")
                   .startWith("a")
                   .startWith("b")
                   .startWith("c")
                   .subscribe(onNext: { print($0) })
                   .disposed(by: disposeBag)
    }
    func merge() {
        let subject1 = PublishSubject<Int>()
       let subject2 = PublishSubject<Int>()

       Observable.of(subject1, subject2)
           .merge()
           .subscribe(onNext: { print($0) })
           .disposed(by: disposeBag)

       subject1.onNext(20)
       subject1.onNext(40)
       subject1.onNext(60)

       subject2.onNext(-1)

       subject1.onNext(80)
       subject1.onNext(100)

       subject2.onNext(-1)
    }
    func combineLatest() {
        let subject1 = PublishSubject<Int>()
        let subject2 = PublishSubject<String>()

        Observable.combineLatest(subject1, subject2) {
            "\($0)\($1)"
            }
            .subscribe(onNext: { print($0) })
            .disposed(by: disposeBag)

        subject1.onNext(1)
        subject2.onNext("A")
        subject1.onNext(2)
        subject2.onNext("B")
        subject2.onNext("C")
        subject2.onNext("D")
        subject1.onNext(3)
        subject1.onNext(4)
        subject1.onNext(5)
    }
    func withLatestFrom() {
        let subject1 = PublishSubject<String>()
        let subject2 = PublishSubject<String>()

        subject1.withLatestFrom(subject2)
            .subscribe(onNext: { print($0) })
            .disposed(by: disposeBag)

        subject1.onNext("A")
        subject2.onNext("1")
        subject1.onNext("B")
        subject1.onNext("C")
        subject2.onNext("2")
        subject1.onNext("D")
    }
    func switchLatest() {
        let disposeBag = DisposeBag()

        let subject1 = BehaviorSubject(value: "A")
        let subject2 = BehaviorSubject(value: "1")

        let behaviorRelay = BehaviorRelay(value: subject1)

        behaviorRelay.asObservable()
            .switchLatest()
            .subscribe(onNext: { print($0) })
            .disposed(by: disposeBag)

        subject1.onNext("B")
        subject1.onNext("C")

        //改变事件源
        behaviorRelay.accept(subject2)
        subject1.onNext("D")
        subject2.onNext("2")

        //改变事件源
        behaviorRelay.accept(subject1)
        subject2.onNext("3")
        subject1.onNext("E")
    }
    func amb() {
        let subject1 = PublishSubject<Int>()
        let subject2 = PublishSubject<Int>()
        let subject3 = PublishSubject<Int>()

        subject1
            .amb(subject2)
            .amb(subject3)
            .subscribe(onNext: { print($0) })
            .disposed(by: disposeBag)

        subject1.onNext(20)
        subject2.onNext(1)
        subject3.onNext(0)
        subject2.onNext(2)
        subject1.onNext(40)
        subject2.onNext(3)
        subject1.onNext(60)
        subject3.onNext(0)
        subject3.onNext(0)
    }
    func reduce() {
        Observable.of(1, 2, 3, 4, 5)
            .reduce(0, accumulator: +)
            .subscribe(onNext: { print($0) })
            .disposed(by: disposeBag)
    }
    func concat() {
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
    }
    
    func publish() {
        //每隔1秒钟发送1个事件
        let interval = Observable<Int>.interval(1, scheduler: MainScheduler.instance)
            .publish()
                 
        //第一个订阅者（立刻开始订阅）
        _ = interval
            .subscribe(onNext: { print("订阅1: \($0)") })
         
        //相当于把事件消息推迟了两秒
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            _ = interval.connect()
        }
         
        //第二个订阅者（延迟5秒开始订阅）
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            _ = interval
                .subscribe(onNext: { print("订阅2: \($0)") })
        }
    }
    func replay() {
        //每隔1秒钟发送1个事件
        let interval = Observable<Int>.interval(1, scheduler: MainScheduler.instance)
            .replay(5)
                 
        //第一个订阅者（立刻开始订阅）
        _ = interval
            .subscribe(onNext: { print("订阅1: \($0)") })
         
        //相当于把事件消息推迟了两秒
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            _ = interval.connect()
        }
         
        //第二个订阅者（延迟5秒开始订阅）
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            _ = interval
                .subscribe(onNext: { print("订阅2: \($0)") })
        }
    }
    func multicast() {
        //创建一个Subject（后面的multicast()方法中传入）
        let subject = PublishSubject<Int>()
         
        //这个Subject的订阅
        _ = subject
            .subscribe(onNext: { print("Subject: \($0)") })
         
        //每隔1秒钟发送1个事件
        let interval = Observable<Int>.interval(1, scheduler: MainScheduler.instance)
            .multicast(subject)
                 
        //第一个订阅者（立刻开始订阅）
        _ = interval
            .subscribe(onNext: { print("订阅1: \($0)") })
         
        //相当于把事件消息推迟了两秒
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            _ = interval.connect()
        }
         
        //第二个订阅者（延迟5秒开始订阅）
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            _ = interval
                .subscribe(onNext: { print("订阅2: \($0)") })
        }
    }
    func refCount() {
        //每隔1秒钟发送1个事件
        let interval = Observable<Int>.interval(1, scheduler: MainScheduler.instance)
            .publish()
            .refCount()
         
        //第一个订阅者（立刻开始订阅）
        _ = interval
            .subscribe(onNext: { print("订阅1: \($0)") })
         
        //第二个订阅者（延迟5秒开始订阅）
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            _ = interval
                .subscribe(onNext: { print("订阅2: \($0)") })
        }
    }
    func shareRelay() {
        //每隔1秒钟发送1个事件
        let interval = Observable<Int>.interval(1, scheduler: MainScheduler.instance)
                                .share(replay: 5)
        
        //第一个订阅者（立刻开始订阅）
        _ = interval.subscribe(onNext: { print("订阅1: \($0)") })
        
        //第二个订阅者（延迟5秒开始订阅）
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            _ = interval.subscribe(onNext: { print("订阅2: \($0)") })
        }
    }
    
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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // debug()
        // toArray()
        // scan()
        // flatMap()
        // flatMapFirst()
        // flatMapLatest()
        // concatMap()
        // throttle()
        // distinctUntilChanged()
        // skipWhile()
        // skipUntil()
        // takeWhile()
        // single()
        // startWith()
        // merge()
        // combineLatest()
        // withLatestFrom()
        // switchLatest()
        // amb()
        // reduce()
        // concat()
        // publish()
        // replay()
        // multicast()
        // refCount()
        // shareRelay()
        
        using()

    }


}

extension ViewController: UITableViewDataSource,UITableViewDelegate {
    //返回单元格数量
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.data.count
    }
    
    //返回对应的单元格
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)
        -> UITableViewCell {
            var cell = tableView.dequeueReusableCell(withIdentifier: "Cellid")
            if cell == nil {
                cell = UITableViewCell(style: .default, reuseIdentifier: "Cellid")
                cell?.accessoryType = .disclosureIndicator
            }
            let tuple = data[indexPath.row]
            cell?.textLabel?.text = tuple.1
            cell?.textLabel?.numberOfLines = 0
            return cell!
    }
    
    
    //单元格点击
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let tuple = data[indexPath.row]
        self.navigationController?.pushViewController(tuple.0, animated: true)

    }
}

