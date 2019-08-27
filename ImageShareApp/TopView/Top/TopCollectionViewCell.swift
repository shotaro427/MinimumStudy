//
//  TopCollectionViewCell.swift
//  ImageShareApp
//
//  Created by 田内　翔太郎 on 2019/08/21.
//  Copyright © 2019 田内　翔太郎. All rights reserved.
//

import UIKit
import FirebaseFirestore

enum buttonType  {
    case nomal
    case highlighted
}

class TopCollectionViewCell: UICollectionViewCell {

    // MARK: 変数
    // MARK: - 紐付けした変数
    
    @IBOutlet weak var postedImageView: UIImageView!
    @IBOutlet weak var postedImageTitleLabel: UILabel!
    @IBOutlet weak var postedUserLabel: UILabel!
    @IBOutlet weak var postedView: UIView!
    @IBOutlet weak var starButton: UIButton!
    @IBOutlet weak var postedDateLabel: UILabel!
    @IBOutlet weak var tag1Button: UIButton!
    @IBOutlet weak var tag2Button: UIButton!

    // MARK: - 自作プロパティ、変数、定数
    /// セルの情報
    var cellInfo: [String: Any] = [:]
    /// セルのID
    var cellID: String = ""

    /// ボタンタイプ
    var type: buttonType = .nomal
    /// roomID
    var roomID: String = ""
    /// 投稿ID
    var messageID: String = ""

    /// 押されたタグのワード
    var tagWord: String = ""

    // MARK: - 関数
    // MARK: - 自作関数
    /// いいね機能
    func favImage() {
        // 星がついている時
        // 部屋までのルート
         if let email = UserDefaults.standard.string(forKey: "email") {
            let userRef: DocumentReference = db.collection("chat-room").document(roomID).collection("users").document(email)
            // DBにいいねを押した画像の情報を追加
            userRef.collection("fav-image").document(cellID).setData(cellInfo)
        }
    }

    //  /いいねを消す機能
    func deleteFavImage() {
        // 星がついている時
        // 部屋までのルート
        if let email = UserDefaults.standard.string(forKey: "email") {
            let userRef: DocumentReference = db.collection("chat-room").document(roomID).collection("users").document(email)
            // DBにいいねを押した画像の情報を追加
            userRef.collection("fav-image").document(cellID).delete()
        }

    }

    // MARK: - 紐付けした関数
    /// いいねボタンを押した時の処理
    @IBAction func tappedStarButton(_ sender: UIButton) {
        if type == .nomal {
            starButton.setImage(#imageLiteral(resourceName: "星(選択時)"), for: .normal)
            favImage()
             type = .highlighted
        } else {
            starButton.setImage(#imageLiteral(resourceName: "星(普通)"), for: .normal)
            deleteFavImage()
            type = .nomal
        }
    }
}
