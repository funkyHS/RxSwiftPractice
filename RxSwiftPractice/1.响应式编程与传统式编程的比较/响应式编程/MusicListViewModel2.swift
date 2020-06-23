//
//  MusicListViewModel2.swift
//  RxSwiftPractice
//
//  Created by 胡晟 on 2019/1/16.
//  Copyright © 2019 Funky. All rights reserved.
//

import Foundation
import RxSwift


// 将 data 属性变成一个可观察序列对象（Observable Squence）

struct MusicListViewModel2 {
    let data = Observable.just([
        MusicModel(name: "无条件", singer: "陈奕迅"),
        MusicModel(name: "你曾是少年", singer: "S.H.E"),
        MusicModel(name: "从前的我", singer: "陈洁仪"),
        MusicModel(name: "在木星", singer: "朴树"),
        ])
}
