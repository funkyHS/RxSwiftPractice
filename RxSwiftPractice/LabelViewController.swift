//
//  LabelViewController.swift
//  RxSwiftPractice
//
//  Created by 胡晟 on 2019/2/1.
//  Copyright © 2019 Funky. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class LabelViewController: UIViewController {

    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

//        createLabelTimer1()
//        createLabelTimer2()
//        createTextField()
        
//        createTextField2()
//        createTextField3()
//        createTextField4()
        createTextView1()
    }
    

    // Label
    func createLabelTimer1() {
        let label = UILabel(frame: CGRect(x: 20, y: 40, width: 300, height: 40))
        view.addSubview(label)
        let timer = Observable<Int>.interval(0.1, scheduler: MainScheduler.instance)
        timer.map{ String(format: "%0.2d:%0.2d.%0.1d",arguments: [($0 / 600) % 600, ($0 % 600 ) / 10, $0 % 10]) }
            .bind(to: label.rx.text)
            .disposed(by: disposeBag)
    }
    func createLabelTimer2() {
        let label = UILabel(frame: CGRect(x: 20, y: 80, width: 300, height: 40))
        view.addSubview(label)
        
        let timer = Observable<Int>.interval(0.1, scheduler: MainScheduler.instance)
        timer.map(formatTimeInterval)
            .bind(to: label.rx.attributedText)
            .disposed(by: disposeBag)
        
    }
    func formatTimeInterval(ms:NSInteger) -> NSMutableAttributedString {
        let string = String(format: "%0.2d:%0.2d.%0.1d",
                            arguments: [(ms / 600) % 600, (ms % 600 ) / 10, ms % 10])
        //富文本设置
        let attributeString = NSMutableAttributedString(string: string)
        //从文本0开始6个字符字体HelveticaNeue-Bold,16号
        attributeString.addAttribute(NSAttributedString.Key.font,
                                     value: UIFont(name: "HelveticaNeue-Bold", size: 16)!,
                                     range: NSMakeRange(0, 5))
        //设置字体颜色
        attributeString.addAttribute(NSAttributedString.Key.foregroundColor,
                                     value: UIColor.white, range: NSMakeRange(0, 5))
        //设置文字背景颜色
        attributeString.addAttribute(NSAttributedString.Key.backgroundColor,
                                     value: UIColor.orange, range: NSMakeRange(0, 5))
        return attributeString
    }

    
    
    // textField
    // 1. 监听单个 textField 内容的变化
    func createTextField() {
        let textField = UITextField(frame: CGRect(x: 20, y: 120, width: 300, height: 40))
        textField.borderStyle = .roundedRect
        view.addSubview(textField)
        
        textField.rx.text.orEmpty.asObservable().subscribe(onNext: {
            print("您输入的是： \($0)")
        }).disposed(by: disposeBag)
        
    }
    
    // 2. 将内容绑定到其他控件上
    func createTextField2() {
        //创建文本输入框
        let inputField = UITextField(frame: CGRect(x:10, y:80, width:200, height:30))
        inputField.borderStyle = .roundedRect
        self.view.addSubview(inputField)
        
        //创建文本输出框
        let outputField = UITextField(frame: CGRect(x:10, y:150, width:200, height:30))
        outputField.borderStyle = .roundedRect
        self.view.addSubview(outputField)
        
        //创建文本标签
        let label = UILabel(frame:CGRect(x:20, y:190, width:300, height:30))
        self.view.addSubview(label)
        
        //创建按钮
        let button:UIButton = UIButton(type:.system)
        button.frame = CGRect(x:20, y:230, width:40, height:30)
        button.setTitle("提交", for:.normal)
        self.view.addSubview(button)
        
        
        let input = inputField.rx.text.orEmpty.asDriver().throttle(0.3)
        input.drive(outputField.rx.text).disposed(by: disposeBag)
        
        input.map{ "当前字数: \($0.count)" }
            .drive(label.rx.text).disposed(by: disposeBag)
        input.map { $0.count > 5 }
            .drive(button.rx.isEnabled).disposed(by: disposeBag)
        
        
    }
    
    // 3. 同时监听多个 textField 内容的变化
    func createTextField3() {
        
        //创建文本输入框
        let inputField = UITextField(frame: CGRect(x:10, y:80, width:200, height:30))
        inputField.borderStyle = .roundedRect
        self.view.addSubview(inputField)
        
        //创建文本输出框
        let outputField = UITextField(frame: CGRect(x:10, y:150, width:200, height:30))
        outputField.borderStyle = .roundedRect
        self.view.addSubview(outputField)
        
        //创建文本标签
        let label = UILabel(frame:CGRect(x:20, y:190, width:300, height:30))
        self.view.addSubview(label)
        
        
        let input = inputField.rx.text.orEmpty
        let output = outputField.rx.text.orEmpty
        Observable.combineLatest(input,output) { (textValue1, textValue2) -> String in
                return "你输入的号码是：\(textValue1)-\(textValue2)"
            }
            .map{$0}
            .bind(to: label.rx.text)
            .disposed(by: disposeBag)
    }
    
    // 4. 事件监听
    func createTextField4() {
        
        // editingDidBegin：开始编辑（开始输入内容）
        // editingChanged：输入内容发生改变
        // editingDidEnd：结束编辑
        // editingDidEndOnExit：按下 return 键结束编辑
        // allEditingEvents：包含前面的所有编辑相关事件
        
        //创建文本输入框
        let username = UITextField(frame: CGRect(x:10, y:80, width:200, height:30))
        username.borderStyle = .roundedRect
        self.view.addSubview(username)
        
        //创建文本输出框
        let password = UITextField(frame: CGRect(x:10, y:150, width:200, height:30))
        password.borderStyle = .roundedRect
        self.view.addSubview(password)
        
        //在用户名输入框中按下 return 键
        username.rx.controlEvent(.editingDidEndOnExit).subscribe(onNext: {
            (_) in
            password.becomeFirstResponder()
        }).disposed(by: disposeBag)
        
        //在密码输入框中按下 return 键
        password.rx.controlEvent(.editingDidEndOnExit).subscribe(onNext: {
            (_) in
            password.resignFirstResponder()
        }).disposed(by: disposeBag)
        
    }
    
    // 5. 事件监听
    func createTextView1() {
        // didBeginEditing：开始编辑
        // didEndEditing：结束编辑
        // didChange：编辑内容发生改变
        // didChangeSelection：选中部分发生变化
        
        let textView = UITextView(frame: CGRect(x: 10, y: 20, width: 300, height: 100))
        view.addSubview(textView)
        
        //开始编辑响应
        textView.rx.didBeginEditing
            .subscribe(onNext: {
                print("开始编辑")
            })
            .disposed(by: disposeBag)
        
        //结束编辑响应
        textView.rx.didEndEditing
            .subscribe(onNext: {
                print("结束编辑")
            })
            .disposed(by: disposeBag)
        
        //内容发生变化响应
        textView.rx.didChange
            .subscribe(onNext: {
                print("内容发生改变")
            })
            .disposed(by: disposeBag)
        
        //选中部分变化响应
        textView.rx.didChangeSelection
            .subscribe(onNext: {
                print("选中部分发生变化")
            })
            .disposed(by: disposeBag)
        
    }
    
    
    
    // button
    func createBtn1() {
        
        // 创建按钮
        let button:UIButton = UIButton(type:.system)
        button.frame = CGRect(x:20, y:230, width:40, height:30)
        button.setTitle("提交", for:.normal)
        view.addSubview(button)
        
        
        let timer = Observable<Int>.interval(1, scheduler: MainScheduler.instance)
        
//        timer.map(formatTimeInterval)
//            .bind(to: <#T##(Observable<NSMutableAttributedString>) -> R#>)
        
    }
    
}
