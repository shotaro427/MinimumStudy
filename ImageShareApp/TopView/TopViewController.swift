//
//  TopViewController.swift
//  ImageShareApp
//
//  Created by 田内　翔太郎 on 2019/08/21.
//  Copyright © 2019 田内　翔太郎. All rights reserved.
//

import UIKit
import FirebaseFirestore
import NVActivityIndicatorView

class TopViewController: UIViewController {

    @IBOutlet weak var plusImageButton: UIButton!
    // 部屋のID
    var roomID: String = ""

    // 部屋のユーザーのIDを格納する
    var roomMenbers: [String] = []

    // DB
    let db = Firestore.firestore()

    // インジケータの追加
    var activityIndicatorView: NVActivityIndicatorView!
    var activityIndicatorBackgroundView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()

        plusImageButton.layer.cornerRadius = plusImageButton.frame.width / 2

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

        // 遷移後の初期化
        roomMenbers = []

        // インジケータを止める
        activityIndicatorView.stopAnimating()
        activityIndicatorBackgroundView.alpha = 0
    }

    // 部屋のメンバーのIDを取ってくる関数
    func getUserInfo() {
        db.collection("chat-room").document("\(roomID)").collection("users").getDocuments(completion: { (QuerySnapshot, err) in
            if let err = err {
                print("GroupViewController-35: \(err.localizedDescription)")
            } else {
                for document in QuerySnapshot!.documents {
                    self.roomMenbers.append(document.documentID)
                }
            }
        })
    }
    
    @IBAction func tappedSettingButton(_ sender: Any) {
        // インジケータの処理
        activityIndicatorView.startAnimating()
        activityIndicatorBackgroundView.alpha = 1

        // 遷移の処理
        let storyboard = UIStoryboard(name: "Group", bundle: nil)
        // NavigationControllerを取得
        let nc = storyboard.instantiateInitialViewController() as! UINavigationController
        // ViewControllerを取得
        let vc = nc.topViewController as! GroupViewController

        // 所属しているユーザーのIDを取得
        getUserInfo()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
            // 値を渡す
            vc.roomID = self.roomID
            vc.roomMenbers = self.roomMenbers
            // 遷移
            self.navigationController?.pushViewController(vc, animated: true)
        })
    }

}
