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
import BetterSegmentedControl
import PMAlertController

class RoomViewController: UIViewController, UIScrollViewDelegate {

    // インスタンス化
    let db = Firestore.firestore()

    var roomID: String = ""

    // DBに登録するためのString型の画像
    var base64RoomImage: String = ""

    // インジケータの追加
    var activityIndicatorView: NVActivityIndicatorView!
    var activityIndicatorBackgroundView: UIView!

    //  ルーム名
    @IBOutlet weak var roomNameTextField: UITextField!

    // セグメント
    @IBOutlet weak var segmentedControl: BetterSegmentedControl!

    @IBOutlet weak var createButton: UIButton!
    @IBOutlet weak var requestButton: UIButton!

    @IBOutlet weak var createTextField: UITextField!
    @IBOutlet weak var requestTextField: UITextField!

    // 入力するuiview
    @IBOutlet weak var resuestView: UIView!
    @IBOutlet weak var createView: UIView!

    // スクロールビュー
    @IBOutlet weak var scrollView: UIScrollView!


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

        createView.layer.cornerRadius = 10
        resuestView.layer.cornerRadius = 10

        // セグメントコントロール
        segmentedControl.segments = LabelSegment.segments(withTitles: ["新規作成", "申請"])

        // ボタン
        createButton.layer.cornerRadius = 10
        requestButton.layer.cornerRadius = 10

        // テキストフィールド
        createTextField.addBorderBottom(height: 2, color: #colorLiteral(red: 0.2084727883, green: 1, blue: 0.8079068065, alpha: 1))
        requestTextField.addBorderBottom(height: 2, color: #colorLiteral(red: 0.2084727883, green: 1, blue: 0.8079068065, alpha: 1))

        // ルーム生成時にデフォルトで設定される画像をString型に変換する
        var roomImageData: NSData = NSData()
        // 画像のクオリティを下げる
        roomImageData = UIImage(named: "グループ画像")!.jpegData(compressionQuality: 0.1)! as NSData
        // base64Stringという形式に変換
        base64RoomImage = roomImageData.base64EncodedString(options: .lineLength64Characters) as String

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
            let intRoomID = Int.random(in: 0..<1000000)
            // DBから部屋IDを照合
            db.collection("chat-room").getDocuments(completion: { (QuerySnapshot, err) in
                if let err = err {
                    print("RoomViewController-33: \(err.localizedDescription)")
                } else {
                    // 一番最初に作られた時以外
                    if QuerySnapshot?.documents.count != 0 {
                        for document in QuerySnapshot!.documents {
                            if document.documentID != String(intRoomID) && !isCreatedRoom {
                                self.db.collection("chat-room").document("\(intRoomID)").setData([
                                    // 名前をdocumentに追加
                                    "room-name": roomName,
                                    // デフォルトで画像を設定
                                    "room-image": self.base64RoomImage,
                                    // メンバー数の項目を追加
                                    "menber-count": 1,
                                    // 総投稿数の項目の追加
                                    "post-count": 0
                                ])
                                // 部屋にユーザーIDを登録
                                self.db.collection("chat-room").document("\(intRoomID)").collection("users").document("\(userID)").setData(["userID": userID])
                                isCreatedRoom = true
                                self.roomID = String(intRoomID)
                            } else if !isCreatedRoom {
                                // 作り直し(roomIDが被ったため)
                                self.createRoom()
                            }
                        }
                    } else {
                        self.db.collection("chat-room").document("\(intRoomID)").setData([
                            // 名前をdocumentに追加
                            "room-name": roomName,
                            // デフォルトで画像を設定
                            "room-image": self.base64RoomImage,
                            // メンバー数の項目を追加
                            "menber-count": 1,
                            // 総投稿数の項目の追加
                            "post-count": 0
                            ])
                        // 部屋にユーザーIDを登録
                        self.db.collection("chat-room").document("\(intRoomID)").collection("users").document("\(userID)").setData(["userID": userID])
                        isCreatedRoom = true
                    }
                }
            })
        }
    }

    // トップ画面へ遷移する関数
    func toTop() {
        let storyboard = UIStoryboard(name: "TopLoad", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "WaittingView") as! WaittingViewController

        vc.roomID = roomID

        self.navigationController?.pushViewController(vc, animated: true)

    }

    @IBAction func selectedSegment(_ sender: BetterSegmentedControl) {
        // ボタンに対応したviewを表示させる
        if segmentedControl.index == 0 {
            self.view.bringSubviewToFront(createView)
            self.view.bringSubviewToFront(activityIndicatorBackgroundView)
            self.view.bringSubviewToFront(activityIndicatorView)
        } else {
            self.view.bringSubviewToFront(resuestView)
            self.view.bringSubviewToFront(activityIndicatorBackgroundView)
            self.view.bringSubviewToFront(activityIndicatorView)
        }
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

    // 申請ボタン
    @IBAction func tappedRequestButton(_ sender: Any) {
        // 作られたかどうか
        var isAdded = false
        // DBのWaitingというコレクションに追加する処理
        if let roomID = requestTextField.text {
            // chat-roomコレクションから該当する部屋を検索
            db.collection("chat-room").getDocuments(completion: { (QuerySnapshot, err) in
                if let err = err {
                    print("RoomViewController: \(err.localizedDescription)")
                } else {
                    print("roomID: \(roomID)")
                    for document in QuerySnapshot!.documents {
                        print("document.documentID :\(document.documentID)")
                        if String(document.documentID) == roomID && !isAdded {
                            self.addWaitingUser(roomID: roomID)
                            isAdded = true
                        }
                    }
                    if !isAdded {
                        self.showAlert(title: "エラー", description: "該当するグループIDが存在しませんでした。。\nグループIDをもう一度見直し、半角数字6桁で入力しなおしてください。", image: #imageLiteral(resourceName: "ログインエラー"))
                    }
                }
            })
        }
    }

    func showAlert(title: String, description: String, image: UIImage) {
        // アラートの表示
        let alertController = PMAlertController(title: title, description: description, image: image, style: .alert)
        let alertAction = PMAlertAction(title: "はい", style: .default)
        alertController.addAction(alertAction)
        self.present(alertController, animated: true)
    }

    // DBに申請するユーザーのIDを登録する関数
    func addWaitingUser(roomID: String) {
        db.collection("chat-room").document(roomID).getDocument(completion: { (QuerySnapshot, err) in
            if let err = err {
                print("RoomViewController-157: \(err.localizedDescription)")
                // アラートの表示
                self.showAlert(title: "エラー", description: "グループIDが正しく入力されませんでした。\nグループIDをもう一度見直し、半角数字6桁で入力しなおしてください。", image: #imageLiteral(resourceName: "ログインエラー"))
            } else {
                // ユーザーIDをDBに追加
                self.db.collection("chat-room").document(roomID).collection("waiting-users").document(UserDefaults.standard.string(forKey: "email")!).setData(["userID": UserDefaults.standard.string(forKey: "email")!], completion: { (_) in
                    self.showAlert(title: "申請完了！", description: "申請が完了しました!!", image: #imageLiteral(resourceName: "ok_man"))
                })
            }
        })
    }
    
}
