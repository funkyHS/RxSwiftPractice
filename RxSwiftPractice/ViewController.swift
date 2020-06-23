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

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    let data:[(UIViewController, String)] = [(FunkyViewController1(), "传统方式编程"),
                                             (FunkyViewController2(), "响应式编程")]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
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

