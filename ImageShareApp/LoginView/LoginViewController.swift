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
import BetterSegmentedControl
import Dispatch
import LTMorphingLabel

class LoginViewController: UIViewController {

    // MARK: - storyboard状の変数

    // ログイン画面
    @IBOutlet weak var loginView: UIView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!

    // 新規作成画面
    @IBOutlet weak var createAccountView: UIView!
    @IBOutlet weak var newEmailTextField: UITextField!
    @IBOutlet weak var newPasswordTextField: UITextField!
    @IBOutlet weak var createAccuntButton: UIButton!

    @IBOutlet weak var segmentedViewButton: BetterSegmentedControl!
    @IBOutlet weak var loginTitleLabel: LTMorphingLabel!

    // MARK: - 自作変数

    // 所属している部屋を格納する
    var roomInfo: [[String: Any]] = []
    var roomIDs: [String] = []

    // インジケータの追加
    var activityIndicatorView: NVActivityIndicatorView!
    var activityIndicatorBackgroundView: UIView!

    // MARK: - 自作関数

    override func viewDidLoad() {
        super.viewDidLoad()

        // viewに影をつける
        loginView.layer.masksToBounds = false
        loginView.layer.shadowColor = UIColor.black.cgColor
        loginView.layer.shadowOffset = CGSize(width: 6, height: 6)
        loginView.layer.shadowRadius = 2
        loginView.layer.shadowOpacity = 0.6

        // インジケータの設定
        setIndicator()

        // セグメントコントロール
        segmentedViewButton.segments = LabelSegment.segments(withTitles: ["ログイン", "新規作成"])
        // セグメントに影をつける
        segmentedViewButton.layer.masksToBounds = false
        segmentedViewButton.layer.shadowColor = UIColor.black.cgColor
        segmentedViewButton.layer.shadowOffset = CGSize(width: 6, height: 0)
        segmentedViewButton.layer.shadowRadius = 2
        segmentedViewButton.layer.shadowOpacity = 0.6

        //textFieldの下線を追加
        emailTextField.addBorderBottom(height: 2, color: #colorLiteral(red: 0.2084727883, green: 1, blue: 0.8079068065, alpha: 1))
        passwordTextField.addBorderBottom(height: 2, color: #colorLiteral(red: 0.2084727883, green: 1, blue: 0.8079068065, alpha: 1))
        newEmailTextField.addBorderBottom(height: 2, color: #colorLiteral(red: 0.2084727883, green: 1, blue: 0.8079068065, alpha: 1))
        newPasswordTextField.addBorderBottom(height: 2, color: #colorLiteral(red: 0.2084727883, green: 1, blue: 0.8079068065, alpha: 1))
        
        // viewの角を丸くする
        loginView.layer.cornerRadius = 10
        createAccountView.layer.cornerRadius = 10
        // ボタンを丸くする
        loginButton.layer.cornerRadius = 10
        createAccuntButton.layer.cornerRadius = 10

        emailTextField.text = "aaaa@aaaa.com"
        passwordTextField.text = "123456"
    }

    // MARK: 自作関数

    /**
        インジケータの設定を行う関数
     */
    func setIndicator(){
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

    /**
    ユーザーが所属している部屋を探す関数
    */
    func searchRoom(function: @escaping () -> ()) {
        // ユーザーid(email)を取得
        guard let userID = UserDefaults.standard.string(forKey: "email") else { return }
        db.collection("chat-room").getDocuments() { (QuerySnapshot, err) in
            if let err = err { // エラー時
                print("SelectRoomTableViewController-29: \(err.localizedDescription)")
            } else { // 成功時
                // ドキュメントを取得
                for document in QuerySnapshot!.documents {
                    // ドキュメント内のuserIDと,このユーザーのuserIDと一致するかを見る
                    db.collection("chat-room").document(document.documentID).collection("users").document(userID).getDocument(completion: { (QuerySnapshot2, err2) in
                        print("second getDocument() Start")
                        if let err2 = err2 { // エラー時
                            print("login error : \(err2.localizedDescription)")
                        }
                        // userIDを持つユーザーが存在していた時
                        if QuerySnapshot2!.exists {
                            self.roomInfo.append(document.data())
                            self.roomIDs.append(document.documentID)
                        }
                        // 最後のdocumentを持ってきた時

                        if let firstDocumentID = QuerySnapshot?.documents.first?.documentID {
                            if document.documentID == firstDocumentID {
                                function()
                            }
                        }
                    })
                }
            }
        }
    }

    /**
     エラーが帰ってきた場合のアラート
    */
    func showErrorAlert(error: Error?) {
        let alert = PMAlertController(title: "エラーです。", description: error?.localizedDescription, image: #imageLiteral(resourceName: "ログインエラー"), style: .alert)
        let okAction = PMAlertAction(title: "OK", style: .cancel, action: {
            self.activityIndicatorView.stopAnimating()
            self.activityIndicatorBackgroundView.removeFromSuperview()
        })
        alert.addAction(okAction)
        // 表示
        self.present(alert, animated: true)
    }

    /**
     グループ選択画面へ移る処理
    */
    func toRoomView() {
        let storyboard = UIStoryboard(name: "RoomView", bundle: nil)
        let nc = storyboard.instantiateViewController(withIdentifier: "RoomNavi") as! UINavigationController
        let vc = nc.topViewController as! SelectRoomTableViewController

        vc.roomInfo = roomInfo
        vc.roomIDs = roomIDs

        self.present(nc, animated: true)
    }

    // MARK: - オーバーライド

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
        // キーボードが開いていたら
        if (newEmailTextField.isFirstResponder) {
            // 閉じる
            newEmailTextField.resignFirstResponder()
        }
        if (newPasswordTextField.isFirstResponder) {
            newPasswordTextField.resignFirstResponder()
        }
    }

    // MARK: - アクション

    /// ログインボタン
    @IBAction func tappedLoginButton(_ sender: UIButton) {

        // インジケータの描画
        self.activityIndicatorView.startAnimating()
        self.activityIndicatorBackgroundView.alpha = 1

        // textFieldの中身を確認
        guard let email = emailTextField.text, let password = passwordTextField.text else {
            print("textFieldが入力されていません")
            return
        }

        // ログインの処理
        Auth.auth().signIn(withEmail: email, password: password, completion: { (user, err) in
            print("Auth end")
            if let err = err {
                // エラーが発生した時
                self.showErrorAlert(error: err)
            } else {
                // ユーザー情報を保管
                UserDefaults.standard.set(email, forKey: "email")
                UserDefaults.standard.set(password, forKey: "password")
                // 成功した時
                // ユーザーの所属部屋を検索
                self.searchRoom(function: {
                    print("遷移　開始")
                    self.toRoomView()
                    self.activityIndicatorView.stopAnimating()
                    self.activityIndicatorBackgroundView.removeFromSuperview()
                })
            }
        })
    }

    // 新規作成ボタン
    @IBAction func tappedCeateAccountButton(_ sender: UIButton) {

        // textFieldの中身を確認
        guard let email = newEmailTextField.text, let password = newPasswordTextField.text else {
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
                self.toRoomView()

            }
        })
    }

    // 画面切り替えボタン
    @IBAction func segmentedViewButton(_ sender: BetterSegmentedControl) {
        // ボタンに対応したviewを表示させる
        if segmentedViewButton.index == 0 {
            self.view.bringSubviewToFront(loginView)
            self.view.bringSubviewToFront(activityIndicatorBackgroundView)
            self.view.bringSubviewToFront(activityIndicatorView)
        } else {
            self.view.bringSubviewToFront(createAccountView)
            self.view.bringSubviewToFront(activityIndicatorBackgroundView)
            self.view.bringSubviewToFront(activityIndicatorView)
        }
    }
}
