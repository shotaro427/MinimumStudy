//
//  LoginViewController.swift
//  ImageShareApp
//
//  Created by 田内　翔太郎 on 2019/08/19.
//  Copyright © 2019 田内　翔太郎. All rights reserved.
//

import UIKit
import FirebaseAuth
import PMAlertController

class LoginViewController: UIViewController {


    @IBOutlet weak var loginView: UIView!

    @IBOutlet weak var emailTextField: UITextField!

    @IBOutlet weak var passwordTextField: UITextField!

    @IBOutlet weak var loginButton: UIButton!

    @IBOutlet weak var createAccuntButton: UIButton!
    

    override func viewDidLoad() {
        super.viewDidLoad()

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
        let vc = storyboard.instantiateViewController(withIdentifier: "RoomView")

        self.present(vc, animated: true)
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

        Auth.auth().signIn(withEmail: email, password: password, completion: { (user, err) in

            if let err = err {
                // エラーが発生した時
                self.showErrorAlert(error: err)
            } else {
                // ユーザー情報を保管
                UserDefaults.standard.set(email, forKey: "email")
                UserDefaults.standard.set(password, forKey: "password")
                // ログインに成功した時
                self.toRoomView()
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
                self.toRoomView()
            }
        })
    }
}
