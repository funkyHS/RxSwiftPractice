//
//  FunkyViewController1.swift
//  RxSwiftPractice
//
//  Created by 胡晟 on 2019/1/16.
//  Copyright © 2019 Funky. All rights reserved.
//

// 表格中显示的是歌曲信息（歌名，以及歌手）,点击选中任意一个单元格，在控制台中打印出对应的歌曲信息。



import UIKit

class FunkyViewController1: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    // 歌曲列表数据源
    let musicListViewModel = MusicListViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "传统式编程"
        
    }
}

extension FunkyViewController1: UITableViewDataSource,UITableViewDelegate {
    //返回单元格数量
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.musicListViewModel.data.count
    }
    
    //返回对应的单元格
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)
        -> UITableViewCell {
            
            var cell = tableView.dequeueReusableCell(withIdentifier: "musicCell")
            if cell == nil {
                cell = UITableViewCell(style: .default, reuseIdentifier: "musicCell")
                cell?.accessoryType = .disclosureIndicator
            }
            let music = musicListViewModel.data[indexPath.row]
            cell?.textLabel?.text = music.name
            cell?.detailTextLabel?.text = music.singer
            return cell!
    }
    
    
    //单元格点击
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("你选中的歌曲信息【\(musicListViewModel.data[indexPath.row])】")
    }
}

