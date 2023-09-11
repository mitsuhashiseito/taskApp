
import UIKit
import RealmSwift

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,UITextFieldDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var categoryTextField: UITextField!
    
    let realm = try! Realm()
    var taskArray = try! Realm().objects(Task.self).sorted(byKeyPath: "date", ascending: true)
    //var taskQuery = try! Realm().objects(Task.self).where({ $0.category == "\(categoryTextField.text!)"})
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.fillerRowHeight = UITableView.automaticDimension
        tableView.delegate = self//デリゲート先＝self（ViewController）を指定。UITableViewDelegateの継承が必要
        tableView.dataSource = self
        categoryTextField.delegate = self//テキストフィールド上のイベントをselfに通知
        
    }
    // データの数（＝セルの数）を返すデリゲートメソッド
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return taskArray.count
    }
    
    // 各セルの内容を返すデリゲートメソッド
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 再利用可能な cell を得る
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let task = taskArray[indexPath.row]
        cell.textLabel?.text = task.title
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        let dateString:String = formatter.string(from: task.date)
        cell.detailTextLabel?.text = dateString
        //cell.detailTextLabel?.text = task.category
        
        return cell
    }
    
    // 各セルを選択した時に実行されるメソッド
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "cellSegue",sender: nil)
    }
    
    // セルが削除が可能なことを伝えるメソッド
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath)-> UITableViewCell.EditingStyle {
        return .delete
    }
    
    // Delete ボタンが押された時に呼ばれるメソッド
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            if editingStyle == .delete {
                // 削除するタスクを取得する
                let task = self.taskArray[indexPath.row]
                
                // ローカル通知をキャンセルする
                let center = UNUserNotificationCenter.current()
                center.removePendingNotificationRequests(withIdentifiers: [String(task.id.stringValue)])
                
                // データベースから削除する
                try! realm.write {
                    self.realm.delete(task)
                    tableView.deleteRows(at: [indexPath], with: .fade)
                }
                
                // 未通知のローカル通知一覧をログ出力
                center.getPendingNotificationRequests { (requests: [UNNotificationRequest]) in
                    for request in requests {
                        print("/---------------")
                        print(request)
                        print("---------------/")
                    }
                }
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        //改行が行われたら実行。taskArrayをテキストフィールドに入力された値で絞込み
        taskArray = try! Realm().objects(Task.self).where({ $0.category == "\(categoryTextField.text!)"})
        //tableViewをリロードして絞込みしたtaskArrayで再度tableViewデリゲートを読み出す
        tableView.reloadData()
        
        // 改行ボタンが押されたらKeyboardを閉じる処理.
        textField.resignFirstResponder()
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        let inputViewController:InputViewController = segue.destination as! InputViewController
        
        if segue.identifier == "cellSegue" {
            let indexPath = self.tableView.indexPathForSelectedRow
            inputViewController.task = taskArray[indexPath!.row]
        } else {
            inputViewController.task = Task()
        }
    }
    // 入力画面から戻ってきた時に TableView を更新させる
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
}

