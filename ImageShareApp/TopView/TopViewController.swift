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

class TopViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    // コレクションセル
    @IBOutlet weak var postedImageView: UIImageView!

    @IBOutlet weak var topCollectionView: UICollectionView!
    @IBOutlet weak var plusImageButton: UIButton!

    // 投稿された情報を保管する
    var postImageInfo: [[String: Any]] = []

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

        // ナビゲーションバーの戻るボタンを消す
        self.navigationItem.hidesBackButton = true

        topCollectionView.delegate = self
        topCollectionView.dataSource = self

        // レイアウトを調整
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
        topCollectionView.collectionViewLayout = layout

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

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return postImageInfo.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TopCell", for: indexPath) as! TopCollectionViewCell // 表示するセルを登録(先程命名した"Cell")

        if postImageInfo.count != 0 {
            let dict = postImageInfo[indexPath.row]

            // 投稿画像を取得
            // 画像情報
            let imageInfo = dict["image"]
            // NSData型に変換
            let imageData = NSData(base64Encoded: imageInfo as! String, options: .ignoreUnknownCharacters)
            // UIImage型に変換
            let decordedImage = UIImage(data: imageData! as Data)
            // セルに表示
            cell.postedImageView.image = decordedImage

            // ユーザーIDを表示
            cell.postedUserLabel.text = dict["userID"] as? String

            // タイトルを表示
            cell.postedImageTitleLabel.text = dict["title"] as? String

            cell.layer.cornerRadius = 20
        }
        
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let horizontalSpace : CGFloat = 20
        let cellSize : CGFloat = self.view.bounds.width / 2 - horizontalSpace
        return CGSize(width: cellSize, height: cellSize)
    }

    // 設定ボタン
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

    // 追加ボタン
    @IBAction func tappedPlusImageButton(_ sender: Any) {
        // 遷移処理
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "Edit") as! ViewController

        // roomIDを渡す
        vc.roomID = roomID

        self.navigationController?.pushViewController(vc, animated: true)
    }

}
