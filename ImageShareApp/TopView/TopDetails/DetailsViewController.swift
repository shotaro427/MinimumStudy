//
//  DetailsViewController.swift
//  ImageShareApp
//
//  Created by 田内　翔太郎 on 2019/08/22.
//  Copyright © 2019 田内　翔太郎. All rights reserved.
//

import UIKit
import PMAlertController

class DetailsViewController: UIViewController {

    @IBOutlet weak var postedImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var userLabel: UILabel!

    // グループID
    var roomID: String = ""

    // 遷移元からもらう
    var strTitle: String? = ""
    var user: String? = ""
    var image: UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        postedImageView.image = image
        titleLabel.text = strTitle
        userLabel.text = user

    }

    // 保存機能
    func save(image: UIImage) {

        // カメラロールに保存する
        // アラートコントローラー
        let alertController = PMAlertController(title: "保存しますか？", description: nil, image: image, style: .alert)
        // アラートアクション
        alertController.addAction(PMAlertAction(title: "はい", style: .default, action:{
            // 「はい」を押した時だけ、画像を保存する
            UIImageWriteToSavedPhotosAlbum(image, self, #selector(self.didFinishSavingImage(_: didFinishSavingWithError: contextInfo:)), nil)
        }))
        alertController.addAction(PMAlertAction(title: "いいえ", style: .cancel))
        self.present(alertController, animated: true)
    }

    // 保存を試みた結果を受け取る
    @objc func didFinishSavingImage(_ image: UIImage, didFinishSavingWithError error: NSError!, contextInfo: UnsafeMutableRawPointer) {

        // 結果によって出すアラートを変更する
        var title = "保存完了"
        var message = "カメラロールに保存しました"

        if error != nil {
            title = "エラー"
            message = "保存に失敗しました"
        }

        let alertController = PMAlertController(title: title, description: message, image: image, style: .alert)

        alertController.addAction(PMAlertAction(title: "OK", style: .default))
        self.present(alertController, animated: true)
    }

    // 保存ボタン
    @IBAction func tappedSaveButton(_ sender: Any) {
        save(image: image)
    }

    // 編集ボタン
    @IBAction func tappedEditButton(_ sender: Any) {
        // 遷移先に飛ぶ
        // 遷移処理
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "Edit") as! ViewController

        // roomIDを渡す
        vc.roomID = roomID
        vc.image = image

        self.navigationController?.pushViewController(vc, animated: true)
    }

}
