//
//  ViewController.swift
//  taskapp
//
//  Created by 田中美幸 on 2020/09/19.
//  Copyright © 2020 miyuki.tanaka2. All rights reserved.
//

import UIKit

import RealmSwift

//ユーザの通知
import UserNotifications

class ViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate{
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var testsearchBar: UISearchBar!
    
    let realm = try! Realm()
    
    // データベース内のタスクが格納されるリスト
    // 日付の近い順でソート：昇順
    // 以降内容をアップデートするとリスト内は自動的に更新される
    var taskArray = try! Realm().objects(Task.self).sorted(byKeyPath: "date", ascending: true)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //ViewControllerをデリゲートとして実装を任せた
        tableView.delegate = self
        tableView.dataSource = self
        testsearchBar.delegate = self
    }
    
    //セルの数を返す
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        //taskArrayの要素数を返す
        return taskArray.count
    }
    
    //各セルの内容を返すメソッド
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //再利用可能な cell を得る
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        //Cellに値を表示させる
        let task = taskArray[indexPath.row]
        cell.textLabel?.text = task.title
        
        //日付を変換する
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        //cellに時間を表示させる
        let dateString:String = formatter.string(from: task.date)
        cell.detailTextLabel?.text = dateString
        
        return cell
    }
    
    //セルをタップした時にタスク入力画面に遷移させるメソッド
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //segueのID（＝cellSegue）を指定して遷移させる
        performSegue(withIdentifier: "cellSegue",sender: nil)
    }
    
    //セルが削除が可能なことを伝えるメソッド
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath)-> UITableViewCell.EditingStyle {
        
        //Deleteが有効
        return .delete
    }
    
    //Deleteボタンが押された時に呼ばれるメソッド
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            //削除するタスクを得る
            let task = self.taskArray[indexPath.row]
            
            //通知をキャンセルする
            let center = UNUserNotificationCenter.current()
            center.removePendingNotificationRequests(withIdentifiers: [String(task.id)])
            
            // データベースから削除する
            try! realm.write {
                self.realm.delete(self.taskArray[indexPath.row])
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            
            //未通知の通知一覧をログ出力
            center.getPendingNotificationRequests { (requests: [UNNotificationRequest]) in
                for request in requests {
                    print("/---------------")
                    print(request)
                    print("---------------/")
                }
            }
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        let predicate = NSPredicate(format: "%@")
        taskArray = realm.objects(Task.self).filter(predicate)
        searchBar.resignFirstResponder()
    }
    
    //検索ボタンが押された時に呼ばれるメソッド
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
            
        let searchText = searchBar.text!
        
        let predicate = NSPredicate(format: "category CONTAINS %@", searchText)
        taskArray = realm.objects(Task.self).filter(predicate)
        
        //再読み込みする
        tableView.reloadData()
    }
    
    //画面遷移するときに呼ばれる
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        let inputViewController:InputViewController = segue.destination as! InputViewController

        //もしidentifierがcellSegueの時（すでに作成済みのタスクを編集するとき）
        if segue.identifier == "cellSegue" {
            
            //taskArrayからTaskクラスのインスタンスを取り出してinputViewControllerのtaskプロパティに設定する
            let indexPath = self.tableView.indexPathForSelectedRow
            inputViewController.task = taskArray[indexPath!.row]
            
        //+ボタンを押した時
        } else {
            
            //Taskクラスのインスタンスを生成する
            let task = Task()

            //すでに存在しているタスクのidのうち最大のものを取得し、1を足す
            let allTasks = realm.objects(Task.self)
            if allTasks.count != 0 {
                task.id = allTasks.max(ofProperty: "id")! + 1
            }

            inputViewController.task = task
        }
    }
    
    //入力画面から戻ってきた時にTableView を更新させる
    //画面が表示される前に呼び出されるメソッド・画面遷移後に1度呼ばれ、他の画面に遷移して戻ってきたときにも呼ばれる
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
}
