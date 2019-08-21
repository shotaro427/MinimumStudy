//
//  RoomViewController.swift
//  ImageShareApp
//
//  Created by 田内　翔太郎 on 2019/08/20.
//  Copyright © 2019 田内　翔太郎. All rights reserved.
//

import UIKit
import FirebaseFirestore
import NVActivityIndicatorView

class RoomViewController: UIViewController {

    // インスタンス化
    let db = Firestore.firestore()

    // インジケータの追加
    var activityIndicatorView: NVActivityIndicatorView!
    var activityIndicatorBackgroundView: UIView!

    //  ルーム名
    @IBOutlet weak var roomNameTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        // インジケータ
        // インジケータの追加
        activityIndicatorView = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 100, height: 100), type: NVActivityIndicatorType.orbit, color: #colorLiteral(red: 0.5725490451, green: 0, blue: 0.2313725501, alpha: 1), padding: 0)
        activityIndicatorView.center = self.view.center // 位置を中心に設定

        // インジケータの背景
        activityIndicatorBackgroundView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
        activityIndicatorBackgroundView.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.5)
        activityIndicatorBackgroundView.alpha = 0
        self.view.addSubview(activityIndicatorBackgroundView)
        self.view.addSubview(activityIndicatorView)

    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        activityIndicatorView.stopAnimating()
        activityIndicatorBackgroundView.alpha = 1
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
        let nc = storyboard.instantiateInitialViewController() as! UINavigationController
        let vc = nc.topViewController as! TopViewController

        self.navigationController?.pushViewController(vc, animated: true)

    }

    // 作成ボタン
    @IBAction func creatRoomButton(_ sender: Any) {
        activityIndicatorView.startAnimating()
        activityIndicatorBackgroundView.alpha = 1
        // 部屋を作成
        createRoom()
        DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: {
            self.toTop()
        })
    }
}
