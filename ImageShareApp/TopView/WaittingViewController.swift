//
//  WaittingViewController.swift
//  
//
//  Created by 田内　翔太郎 on 2019/08/21.
//

import UIKit
import FirebaseFirestore
import BAFluidView

class WaittingViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!

    // DB
    let db = Firestore.firestore()
    // 部屋のID
    var roomID: String = ""
    // 投稿された情報を保管する
    var postImageInfo: [[String: Any]] = []
    var postImageID: [String] = []
    // タグの情報を保管する
    var tagsList: [String] = []

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // ナビゲーションバーを消す
        self.navigationController?.isNavigationBarHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // ナビゲーションバーを表示する
        self.navigationController?.isNavigationBarHidden = false
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        //グラデーションの開始色
        let topColor = #colorLiteral(red: 0.1960784346, green: 0.3411764801, blue: 0.1019607857, alpha: 1).cgColor
        //グラデーションの開始色
        let bottomColor = #colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1).cgColor

        //グラデーションの色を配列で管理
        let gradientColors: [CGColor] = [topColor, bottomColor]

        //グラデーションレイヤーを作成
        let gradientLayer: CAGradientLayer = CAGradientLayer()

        //グラデーションの色をレイヤーに割り当てる
        gradientLayer.colors = gradientColors
        //グラデーションレイヤーをスクリーンサイズにする
        gradientLayer.frame = self.view.bounds

        //グラデーションレイヤーをビューの一番下に配置
        self.view.layer.insertSublayer(gradientLayer, at: 0)

        //アニメーションのViewを生成
        let animeView = BAFluidView(frame: self.view.frame)
        // 並みの速さを設定
        animeView.fillDuration = 10
        //波の高さを設定(0~1.0)
        animeView.fill(to: 1.0)
        //波の境界線の色
        animeView.strokeColor = .white
        //波の色
        animeView.fillColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
        //アニメーション開始（コメントアウトしてもアニメーションされる）
        animeView.startAnimation()
        self.view.addSubview(animeView)
        self.view.bringSubviewToFront(titleLabel)


        // ラベルに表示させる文字
        let stringAttributes: [NSAttributedString.Key : Any] = [
            NSAttributedString.Key.strokeColor : UIColor.white,
            NSAttributedString.Key.strokeWidth : 3,
            NSAttributedString.Key.foregroundColor : UIColor.clear
        ]
        let string = NSAttributedString(string: "ロード中...", attributes: stringAttributes)
        titleLabel.attributedText = string

        // DB検索
        getPostInfo()
        getTagInfo()
        // 次の表示画面
        let vc = UIStoryboard(name: "TopLoad", bundle: nil).instantiateViewController(withIdentifier: "TopView") as! TopViewController
        // 遷移処理
        DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: {
            vc.roomID = self.roomID
            vc.postImageInfo = self.postImageInfo
            vc.postImageID = self.postImageID
            vc.allPostImageInfo = self.postImageInfo
            vc.allPostImageID = self.postImageID
            vc.tagsList = self.tagsList
            self.navigationController?.pushViewController(vc, animated: true)

        })
    }

    // 投稿情報を取得する関数
    func getPostInfo() {
        // メッセージコレクションを作成
        db.collection("chat-room").document(roomID).collection("message")
        // メッセージを取得
        db.collection("chat-room").document("\(roomID)").collection("message").order(by: "date", descending: true).getDocuments() { (QuerySnapshot, err) in
            if let err = err {
                print("WaittingViewController-28: \(err.localizedDescription)")
            } else {
                for document in QuerySnapshot!.documents {
                    self.postImageInfo.append(document.data())
                    self.postImageID.append(document.documentID)
                }
            }
        }
    }

    func getTagInfo() {
        // tagのリストの初期化
        tagsList = []

        // tagsコレクションのリスナーを追加
        db.collection("tags").order(by: "used-count", descending: true).addSnapshotListener( {(QueryDocumentSnapshot, err) in
            guard let documents = QueryDocumentSnapshot?.documents else { return }
            for document in documents {
                self.tagsList.append(document.data()["tag-name"] as! String)
            }
            print(self.tagsList)
        })
    }
}
