//
//  LoginViewController.swift
//  ImageShareApp
//
//  Created by 田内　翔太郎 on 2019/08/19.
//  Copyright © 2019 田内　翔太郎. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import PMAlertController
import NVActivityIndicatorView


class LoginViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!

    @IBOutlet weak var loginView: UIView!

    @IBOutlet weak var emailTextField: UITextField!

    @IBOutlet weak var passwordTextField: UITextField!

    @IBOutlet weak var loginButton: UIButton!

    @IBOutlet weak var createAccuntButton: UIButton!

    // 所属している部屋を格納する
    var room: [String] = []
    var roomIDs: [String] = []

    let db = Firestore.firestore()

    // インジケータの追加
    var activityIndicatorView: NVActivityIndicatorView!
    var activityIndicatorBackgroundView: UIView!
    

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

        //textFieldの下線を追加
        emailTextField.addBorderBottom(height: 2, color: #colorLiteral(red: 0.2084727883, green: 1, blue: 0.8079068065, alpha: 1))
        passwordTextField.addBorderBottom(height: 2, color: #colorLiteral(red: 0.2084727883, green: 1, blue: 0.8079068065, alpha: 1))
        // viewの角を丸くする
        loginView.layer.cornerRadius = 10
        // ボタンを丸くする
        loginButton.layer.cornerRadius = 10


        emailTextField.text = "aaaa@aaaa.com"
        passwordTextField.text = "123456"
    }

    // ユーザーが所属している部屋を探す関数
    func searchRoom() {
        // ユーザーid(email)を取得
        let userID = UserDefaults.standard.string(forKey: "email")
        db.collection("chat-room").getDocuments() { (QuerySnapshot, err) in
            if let err = err { // エラー時
                print("SelectRoomTableViewController-29: \(err.localizedDescription)")
            } else { // 成功時
                // ドキュメントを取得
                for document in QuerySnapshot!.documents {
                    // ドキュメント内のuserIDとこのユーザーのuserIDと一致するかを見る
                    self.db.collection("chat-room").document("\(document.documentID)").collection("users").getDocuments() {(QuerySnapshot2, err2) in
                        if let err2 = err2 {
                            print("SelectRoomTableViewController-29: \(err2.localizedDescription)")
                        } else {
                            // ドキュメントの取得
                            for document2 in QuerySnapshot2!.documents {
                                // IDの照合
                                if document2.documentID == userID {
                                    // 部屋のIDを配列に追加
                                    let roomName = document.data()["room-name"] as! String
                                    self.room.append(roomName)
                                    self.roomIDs.append(document.documentID)
                                }
                            }
                        }
                    }
                }
            }
        }
    }


    // エラーが帰ってきた場合のアラート
    func showErrorAlert(error: Error?) {

        let alert = PMAlertController(title: "エラーです。", description: error?.localizedDescription, image: #imageLiteral(resourceName: "ログインエラー"), style: .alert)
        let okAction = PMAlertAction(title: "OK", style: .cancel)
        alert.addAction(okAction)
        // 表示
        self.present(alert, animated: true)
    }

    // 遷移処理
    func toRoomView() {
        let storyboard = UIStoryboard(name: "RoomView", bundle: nil)
        let nc = storyboard.instantiateViewController(withIdentifier: "RoomNavi") as! UINavigationController
        let vc = nc.topViewController as! SelectRoomTableViewController

        vc.room = room
        vc.roomIDs = roomIDs

        self.present(nc, animated: true)
    }

    // キーボードを閉じる処理
    // タッチされたかを判断
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // キーボードが開いていたら
        if (emailTextField.isFirstResponder) {
            // 閉じる
            emailTextField.resignFirstResponder()
        }
        if (passwordTextField.isFirstResponder) {
            passwordTextField.resignFirstResponder()
        }
    }

    // ログインボタン
    @IBAction func tappedLoginButton(_ sender: Any) {
        // textFieldの中身を確認
        guard let email = emailTextField.text, let password = passwordTextField.text else {
            print("textFieldが入力されていません")
            return
        }

        // ログインの処理
        Auth.auth().signIn(withEmail: email, password: password, completion: { (user, err) in

            if let err = err {
                // エラーが発生した時
                self.showErrorAlert(error: err)
            } else {
                // ユーザー情報を保管
                UserDefaults.standard.set(email, forKey: "email")
                UserDefaults.standard.set(password, forKey: "password")
                // 成功した時
                self.searchRoom()
                // インジケータの描画
                self.activityIndicatorView.startAnimating()
                self.activityIndicatorBackgroundView.alpha = 1
                // ユーザーの所属部屋を検索
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                    self.toRoomView()
                    self.activityIndicatorView.stopAnimating()
                    self.activityIndicatorBackgroundView.removeFromSuperview()
                }
            }
        })
    }

    // 新規作成ボタン
    @IBAction func tappedCeateAccountButton(_ sender: Any) {

        // textFieldの中身を確認
        guard let email = emailTextField.text, let password = passwordTextField.text else {
            print("textFieldが入力されていません")
            return
        }
        // 新規アカウントの作成
        Auth.auth().createUser(withEmail: email, password: password, completion: { (user, err) in
            // エラーが発生した時
            if let err = err {
                self.showErrorAlert(error: err)
            } else {
                // 成功した時
                // インジケータの描画
                self.activityIndicatorView.startAnimating()
                self.activityIndicatorBackgroundView.alpha = 1
                // ユーザーの所属部屋を検索
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                    self.toRoomView()
                    self.activityIndicatorView.stopAnimating()
                    self.activityIndicatorBackgroundView.removeFromSuperview()
                }
            }
        })
    }
}
