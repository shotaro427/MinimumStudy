//
//  ViewController.swift
//  ImageShareApp
//
//  Created by 田内　翔太郎 on 2019/08/18.
//  Copyright © 2019 田内　翔太郎. All rights reserved.
//

import UIKit
import ACEDrawingView
import PMAlertController

class ViewController: UIViewController {

    // キャンパス
    @IBOutlet weak var drawingView: ACEDrawingView!


    // 設定画面
//    @IBOutlet weak var settingContainerView: UIView!

    // 設定画面の中心
    var centerOfSettingView: CGPoint!

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // 設定画面の中心を保存
//        settingContainerView.center = CGPoint(x: self.view.center.x * 0.6, y: self.view.center.y)
//        centerOfSettingView = settingContainerView.center

        // ペンの設定背景をずらす
//        settingContainerView.center = CGPoint(x: centerOfSettingView.x - settingContainerView.frame.width, y: centerOfSettingView.y)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        drawingView.loadImage(#imageLiteral(resourceName: "津田梅子"))

        drawingView.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        drawingView.layer.borderWidth = 5.0
        drawingView.layer.cornerRadius = 10
        drawingView.layer.masksToBounds = true

    }

    /**
     * UIViewからUIImageに変換する関数
     * - Parameters:
     *   - view: UIImage型に変換したいview
     * - Returns: 変換されたview(UIImage型)
     */
    func getImage(_ view: UIView) -> UIImage {

        /// キャプチャする範囲 = 渡したviewの大きさ
        let rect = view.bounds

        // ビットマップ画像のcontextを作成する
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        let context: CGContext = UIGraphicsGetCurrentContext()!

        // view内の描画をcontextに複写する
        view.layer.render(in: context)

        // contextのビットマップをUIImageとして取得する
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!

        // contextを閉じる
        UIGraphicsEndImageContext()

        return image
    }

    /// viewをimageに変換してカメラロールに保存する
    func save() {

        // viewをimageとして取得
        let image = self.getImage(view)

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


    // クリアボタン
    @IBAction func clearButton(_ sender: Any) {
        drawingView.clear()
        drawingView.loadImage(UIImage(named: "津田梅子"))

    }

    // 戻るボタン
    @IBAction func undoButton(_ sender: Any) {
        if drawingView.canUndo() {
            drawingView.undoLatestStep()
        }
    }

    // 進むボタン
    @IBAction func redoButton(_ sender: Any) {
        drawingView.redoLatestStep()
    }

    // 保存ボタン
    @IBAction func saveButton(_ sender: Any) {
        save()
    }

    // ペンの変更ボタン
    @IBAction func changePenButton(_ sender: Any) {

    }
}

