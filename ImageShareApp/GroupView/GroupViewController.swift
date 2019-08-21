//
//  GroupViewController.swift
//  ImageShareApp
//
//  Created by 田内　翔太郎 on 2019/08/20.
//  Copyright © 2019 田内　翔太郎. All rights reserved.
//

import UIKit
import FirebaseAuth

class GroupViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    // グループ画像
    @IBOutlet weak var groupImage: UIImageView!

    @IBOutlet weak var groupTableView: UITableView!
    
    @IBOutlet weak var addMenber: UIButton!

    // 部屋のID
    var roomID: String = ""

    // 部屋に所属するユーザーIDを入れる配列
    var roomMenbers: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        groupTableView.delegate = self
        groupTableView.dataSource = self

        addMenber.layer.cornerRadius = addMenber.frame.width / 2
    }

    // セル数
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return roomMenbers.count
    }

    // セルの操作
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = groupTableView.dequeueReusableCell(withIdentifier: "GroupCell", for: indexPath)
        print("**roomMenbers[indexPath.row]: \(roomMenbers[indexPath.row])")
        cell.textLabel?.text = roomMenbers[indexPath.row]
        
        return cell
    }

    // Section数
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    // Sectioのタイトル
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "メンバー"
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
