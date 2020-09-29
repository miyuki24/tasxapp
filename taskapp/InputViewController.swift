//
//  InputViewController.swift
//  taskapp
//
//  Created by 田中美幸 on 2020/09/21.
//  Copyright © 2020 miyuki.tanaka2. All rights reserved.
//

import UIKit
import RealmSwift
import UserNotifications

class InputViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contentsTextView: UITextView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var categoryTextFiled: UITextField!
    

    let realm = try! Realm()
    var task: Task!
    
    //画面遷移後一度だけ呼ばれるメソッド
    override func viewDidLoad() {
        super.viewDidLoad()

        // 背景をタップしたらdismissKeyboardメソッドを呼ぶ
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(dismissKeyboard))
        self.view.addGestureRecognizer(tapGesture)

        titleTextField.text = task.title
        contentsTextView.text = task.contents
        datePicker.date = task.date
        categoryTextFiled.text = task.category
    }
    
    //キーボードを閉じるためのメソッド
    @objc func dismissKeyboard(){
        view.endEditing(true)
    }
    
    //遷移する際、画面が非表示になるとき呼ばれるメソッド
    override func viewWillDisappear(_ animated: Bool) {
        try! realm.write {
            
            self.task.title = self.titleTextField.text!
            self.task.contents = self.contentsTextView.text
            self.task.date = self.datePicker.date
            self.task.category = self.categoryTextFiled.text!
            self.realm.add(self.task, update: .modified)
        }
        setNotification(task: task)

        super.viewWillDisappear(animated)
    }

    //通知をセット
    func setNotification(task: Task) {
    let content = UNMutableNotificationContent()
    
    // タイトルと内容を設定
    if task.title == "" {
        content.title = "(タイトルなし)"
    } else {
        content.title = task.title
    }
    if task.contents == "" {
        content.body = "(内容なし)"
    } else {
        content.body = task.contents
    }
    content.sound = UNNotificationSound.default

    //通知が発動する日付（trigger）を作成
    let calendar = Calendar.current
    let dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: task.date)
    let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
    
    //通知を作成（identifierが同じだとローカル通知を上書き保存）
    let request = UNNotificationRequest(identifier: String(task.id), content: content, trigger: trigger)

        //通知を登録
        let center = UNUserNotificationCenter.current()
        center.add(request) { (error) in
            
            //error が nil なら"ローカル通知登録 OK"がログに表示される
            print(error ?? "ローカル通知登録 OK")
        }

        // 未通知の通知一覧をログ出力
        center.getPendingNotificationRequests { (requests: [UNNotificationRequest]) in
            for request in requests {
                print("/---------------")
                print(request)
                print("---------------/")
            }
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
