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

class ViewController: UIViewController, ACEDrawingViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    var image: UIImage!
    // 背景画像
    @IBOutlet weak var imageView: UIImageView!
    // キャンパス
    @IBOutlet weak var drawingView: ACEDrawingView!

    // 設定画面の中心
    var centerOfSettingView: CGPoint!

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // 画像の読み込み
        self.imageView.image = image
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        drawingView.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        drawingView.layer.borderWidth = 5.0
        drawingView.layer.cornerRadius = 10
        
        drawingView.lineWidth = 5
    }

    /**
     * UIViewからUIImageに変換する関数
     * - Parameters:
     *   - view: UIImage型に変換したいview
     * - Returns: 変換されたview(UIImage型)
     */
    func getImage(_ view: UIView) -> UIImage {

        /// キャプチャする範囲 = 渡したviewの大きさ
        let rect = drawingView.bounds

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


    /// ペンの詳細設定をする関数
    func setDetailPen(toolTypeNumber: Int) {
        // 消しゴムが選択された時
        if toolTypeNumber == 3 {
            drawingView.drawTool = ACEDrawingToolTypeEraser
        } else {
            drawingView.drawTool = ACEDrawingToolTypePen
            // 蛍光ペンが選択された時
            if toolTypeNumber == 1 {
                drawingView.lineColor = UIColor.yellow
                drawingView.lineAlpha = 0.4
                drawingView.lineWidth = 10
            } else {
                drawingView.lineColor = UIColor.black
                drawingView.lineAlpha = 1
                drawingView.lineWidth = 5
            }
        }
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

    // カメラ・フォトライブラリへの遷移処理
    func cameraAction(sourceType: UIImagePickerController.SourceType) {
        // カメラ・フォトライブラリが使用可能かチェック
        if UIImagePickerController.isSourceTypeAvailable(sourceType) {

            // インスタンス化
            let cameraPicker = UIImagePickerController()
            // ソースタイプの代入
            cameraPicker.sourceType = sourceType
            // デリゲートの接続
            cameraPicker.delegate = self
            // 画面遷移
            self.present(cameraPicker, animated: true)
        }
    }

    // 写真が選択された時に呼ばれる
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // 取得できた画像情報の存在確認とUIImage型へキャスト。pickedImageという定数に格納
        if let pickedImage = info[.originalImage] as? UIImage {
            // ①投稿画面への遷移処理
            self.image = pickedImage
            picker.dismiss(animated: true, completion: nil)
        }
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

    // カメラボタン
    @IBAction func cameraButton(_ sender: Any) {
        cameraAction(sourceType: .camera)
    }

    // 画像追加ボタン
    @IBAction func addImageButton(_ sender: Any) {
        cameraAction(sourceType: .photoLibrary)
    }
}

