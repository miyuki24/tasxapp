//
//  Task.swift
//  taskapp
//
//  Created by 田中美幸 on 2020/09/22.
//  Copyright © 2020 miyuki.tanaka2. All rights reserved.
//

import RealmSwift

class Task: Object {
    
    // 管理用 ID。プライマリーキー
    @objc dynamic var id = 0

    // タイトル
    @objc dynamic var title = ""

    // 内容
    @objc dynamic var contents = ""

    // 日時
    @objc dynamic var date = Date()
    
    //category
    @objc dynamic var category: String = ""

    // id をプライマリーキーとして設定
    override static func primaryKey() -> String? {
        return "id"
    }
}
