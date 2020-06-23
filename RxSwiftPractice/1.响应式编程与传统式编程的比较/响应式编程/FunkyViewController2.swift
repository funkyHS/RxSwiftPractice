//
//  FunkyViewController2.swift
//  RxSwiftPractice
//
//  Created by 胡晟 on 2019/1/16.
//  Copyright © 2019 Funky. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class FunkyViewController2: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    // 歌曲列表数据源
    let musicListViewModel = MusicListViewModel2()
    
    //负责对象销毁
    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "响应式编程"
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "musicCell")

        //将数据源数据绑定到tableView上
        
        // rx.items(cellIdentifier:）:这是 Rx 基于 cellForRowAt 数据源方法的一个封装。传统方式中我们还要有个 numberOfRowsInSection 方法，使用 Rx 后就不再需要了（Rx 已经帮我们完成了相关工作）
        musicListViewModel.data
            .bind(to: tableView.rx.items(cellIdentifier:"musicCell")) { _, music, cell in
                cell.textLabel?.text = music.name
                cell.detailTextLabel?.text = music.singer
            }
        .disposed(by: disposeBag)
        
        // tableView点击响应
        // rx.modelSelected： 这是 Rx 基于 UITableView 委托回调方法 didSelectRowAt 的一个封装
        tableView.rx.modelSelected(MusicModel.self).subscribe(onNext: { music in
            print("你选中的歌曲信息【 \(music) 】")
        }).disposed(by: disposeBag)
    }




}
