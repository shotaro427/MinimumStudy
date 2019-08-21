//
//  SelectRoomTableViewController.swift
//  ImageShareApp
//
//  Created by 田内　翔太郎 on 2019/08/20.
//  Copyright © 2019 田内　翔太郎. All rights reserved.
//

import UIKit
import FirebaseAuth

class SelectRoomTableViewController: UITableViewController {

    // 選択できる部屋を入れる
    var room: [String] = []
    var roomIDs: [String] = []

    // 選択した部屋のIDを保管する変数
    let selectedRoomId: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // セルの個数
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return room.count
    }

    // セルの操作
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = room[indexPath.row]
        return cell
    }

    // セルのタップ時
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Top", bundle: nil)
        let nc = storyboard.instantiateInitialViewController() as! UINavigationController
        let vc = nc.topViewController as! TopViewController

        vc.roomID = roomIDs[indexPath.row]

        self.navigationController?.pushViewController(vc, animated: true)
    }

    @IBAction func LogOutButton(_ sender: Any) {
        // ログアウト処理
        try! Auth.auth().signOut()
        // storyboardのfileの特定
        let storyboard: UIStoryboard = UIStoryboard(name: "Login", bundle: nil)
        // 移動先のvcをインスタンス化
        let vc = storyboard.instantiateViewController(withIdentifier: "Login")
        // 遷移処理
        self.present(vc, animated: true)

    }
}
