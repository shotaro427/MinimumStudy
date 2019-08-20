//
//  RoomViewController.swift
//  ImageShareApp
//
//  Created by 田内　翔太郎 on 2019/08/20.
//  Copyright © 2019 田内　翔太郎. All rights reserved.
//

import UIKit
import FirebaseFirestore

class RoomViewController: UIViewController {

    // インスタンス化
    let db = Firestore.firestore()

    //  ルーム名
    @IBOutlet weak var roomNameTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // ルームを作成する関数
    func createRoom() {
        // 部屋がすでに作られたかどうか
        var isCreatedRoom: Bool = false
        // textFieldから部屋の名前とユーザーIDを取得
        if let roomName = roomNameTextField.text, let userID = UserDefaults.standard.string(forKey: "email") {
            // 部屋IDを割り振り
            let roomID = Int.random(in: 0..<1000000)
            // DBから部屋IDを照合
            db.collection("chat-room").getDocuments(completion: { (QuerySnapshot, err) in
                if let err = err {
                    print("RoomViewController-33: \(err.localizedDescription)")
                } else {
                    // 一番最初に作られた時以外
                    if QuerySnapshot?.documents.count != 0 {
                        for document in QuerySnapshot!.documents {
                            if document.documentID != String(roomID) && !isCreatedRoom {
                                self.db.collection("chat-room").document("\(roomID)").setData([
                                    // 名前をdocumentに追加
                                    "room-name": roomName
                                ])
                                // 部屋にユーザーIDを登録
                                self.db.collection("chat-room").document("\(roomID)").collection("users").document("\(userID)").setData(["userID": userID])
                                isCreatedRoom = true
                            } else if !isCreatedRoom {
                                // 作り直し(roomIDが被ったため)
                                self.createRoom()
                            }
                        }
                    } else {
                        self.db.collection("chat-room").document("\(roomID)").setData([
                            // 名前をdocumentに追加
                            "room-name": roomName
                            ])
                        // 部屋にユーザーIDを登録
                        self.db.collection("chat-room").document("\(roomID)").collection("users").document("\(userID)").setData(["userID": userID])
                        isCreatedRoom = true
                    }
                }
            })
        }
    }

    // トップ画面へ遷移する関数
    func toTop() {
        let storyboard = UIStoryboard(name: "Top", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "TopView")

        self.present(vc, animated: true)
        
    }

    // 作成ボタン
    @IBAction func creatRoomButton(_ sender: Any) {
        // 部屋を作成
        createRoom()
        // 部屋へ遷移
        toTop()
    }
}
