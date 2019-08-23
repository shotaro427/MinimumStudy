//
//  GroupViewController.swift
//  ImageShareApp
//
//  Created by 田内　翔太郎 on 2019/08/20.
//  Copyright © 2019 田内　翔太郎. All rights reserved.
//

import UIKit
import FirebaseAuth
import PMAlertController
import FirebaseFirestore
class GroupViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    // グループ画像
    @IBOutlet weak var groupImage: UIImageView!

    @IBOutlet weak var groupTableView: UITableView!
    
    @IBOutlet weak var addMenber: UIButton!

    // DB
    let db = Firestore.firestore()

    // 部屋のID
    var roomID: String = ""

    // セクションタイトル
    let titleOfSection: [String] = ["メンバー", "申請待ち"]

    // 部屋に所属するユーザーIDを入れる配列
    var roomMenbers: [String] = []
    // 申請待ちのユーザーのIDを入れる配列
    var waitingMenber: [String] = []

    // 上の２つの配列を組み合わせた2次元配列
    var Menbers: [[String]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // tableViewの設定
        groupTableView.delegate = self
        groupTableView.dataSource = self

        // ボタンの整形
        addMenber.layer.cornerRadius = addMenber.frame.width / 2

        // 値の追加
        Menbers.append(roomMenbers)
        Menbers.append(waitingMenber)

    }

    // セクション数

    // セル数
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Menbers[section].count
    }

    // セルの操作
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = groupTableView.dequeueReusableCell(withIdentifier: "GroupCell", for: indexPath)
        cell.textLabel?.text = Menbers[indexPath.section][indexPath.row]
        
        return cell
    }

    // Section数
    func numberOfSections(in tableView: UITableView) -> Int {
        return titleOfSection.count
    }

    // Sectioのタイトル
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return titleOfSection[section]
    }

    // タップ時のアクション
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // メンバーをタップした時の処理
        if indexPath.section == 0 {

        } else { // 申請待ちの人をタップした時
            // アラートの表示
            let alertController = PMAlertController(title: "申請待ち", description: "\(Menbers[indexPath.section][indexPath.row])さんが申請しています。\n 申請を許可しますか？", image: #imageLiteral(resourceName: "津田梅子"), style: .alert)
            let OKAction = PMAlertAction(title: "はい", style: .default, action: {
                self.allowMenbers(waitingUserID: self.Menbers[indexPath.section][indexPath.row])
            })
            let NOAction = PMAlertAction(title: "いいえ", style: .cancel)
            alertController.addAction(OKAction)
            alertController.addAction(NOAction)
            present(alertController, animated: true)
        }
    }

    // 申請の許可する関数
    func allowMenbers(waitingUserID: String) {
        // waiting-usersからusersコレクションに移動
        // usersコレクションに該当ユーザーを登録
        db.collection("chat-room").document(roomID).collection("users").document(waitingUserID).setData(["userID": waitingUserID]) { err in
            if let err = err {
                print("Error removing document: \(err)")
            } else {
                print("Document successfully removed!")
            }
        }

        // waiting-usersから該当ユーザーのIDを削除
        db.collection("chat-room").document(roomID).collection("waiting-users").document(waitingUserID).delete() { err in
            if let err = err {
                print("Error removing document: \(err)")
            } else {
                print("Document successfully removed!")
            }

            // アラートの表示
            let alertController = PMAlertController(title: "完了!", description: "申請を許可しました。", image: #imageLiteral(resourceName: "津田梅子"), style: .alert)
            let okAction = PMAlertAction(title: "はい", style: .default)
            alertController.addAction(okAction)
            self.present(alertController, animated: true)
        }
    }

    // ログアウトボタン
    @IBAction func logoutButton(_ sender: Any) {
        // ログアウト処理
        try! Auth.auth().signOut()
        // storyboardのfileの特定
        let storyboard: UIStoryboard = UIStoryboard(name: "Login", bundle: nil)
        // 移動先のvcをインスタンス化
        let vc = storyboard.instantiateViewController(withIdentifier: "Login")
        // 遷移処理
        self.present(vc, animated: true)

    }

    // メンバー追加ボタン
    @IBAction func addMenberButton(_ sender: Any) {
    }

}
