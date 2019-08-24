//
//  SelectRoomTableViewController.swift
//  ImageShareApp
//
//  Created by 田内　翔太郎 on 2019/08/20.
//  Copyright © 2019 田内　翔太郎. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class SelectRoomTableViewController: UITableViewController {

    // 選択できる部屋を入れる
    var roomInfo: [[String: Any]] = []
    var roomIDs: [String] = []

    // DB
    let db = Firestore.firestore()

    // 選択した部屋のIDを保管する変数
    let selectedRoomId: String = ""

    // トップ画面へ送る情報
    var messageInfo: [String: Any] = [:]

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.backgroundView = UIImageView(image: #imageLiteral(resourceName: "loginImage"))

        // セルの登録
        self.tableView.register(UINib(nibName: "TableViewCell", bundle: nil), forCellReuseIdentifier: "Cell")
    }

    // セルの高さ
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }

    // セルの個数
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return roomInfo.count
    }

    // セルの操作
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! TableViewCell

        // 画像データの取得
        let imageString = roomInfo[indexPath.row]["room-image"] as! String
        // NSData型に変換
        let imageData = NSData(base64Encoded: imageString, options: .ignoreUnknownCharacters)
        // UIImage型に変換
        let image = UIImage(data: imageData! as Data)
        // セルに表示
        cell.groupImageView.image = image
        cell.setImage()

        if let groupName = roomInfo[indexPath.row]["room-name"] as? String, let menberCount = roomInfo[indexPath.row]["menber-count"] as? Int {
            cell.groupName.text = groupName
            cell.menberCount.text = "メンバー数: \(String(menberCount))"
        }

        return cell
    }

    // セルのタップ時
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "TopLoad", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "WaittingView") as! WaittingViewController

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
