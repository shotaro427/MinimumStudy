//
//  LoginViewController.swift
//  ImageShareApp
//
//  Created by 田内　翔太郎 on 2019/08/19.
//  Copyright © 2019 田内　翔太郎. All rights reserved.
//

import UIKit


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
    }

    // ログインボタン
    @IBAction func tappedLoginButton(_ sender: Any) {
    }

    // 新規作成ボタン
    @IBAction func tappedCeateAccountButton(_ sender: Any) {
    }
}
