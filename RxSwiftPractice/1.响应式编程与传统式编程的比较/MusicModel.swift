//
//  MusicModel.swift
//  RxSwiftPractice
//
//  Created by 胡晟 on 2019/1/16.
//  Copyright © 2019 Funky. All rights reserved.
//

import Foundation

struct MusicModel {
    
    let name: String //歌名
    let singer: String //演唱者
    
    init(name: String, singer: String) {
        self.name = name
        self.singer = singer
    }
}

//实现 CustomStringConvertible 协议，方便输出调试
extension MusicModel: CustomStringConvertible {
    var description: String {
        return "name：\(name) singer：\(singer)"
    }
}
