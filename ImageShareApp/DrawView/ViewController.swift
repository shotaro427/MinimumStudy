//
//  ViewController.swift
//  ImageShareApp
//
//  Created by 田内　翔太郎 on 2019/08/18.
//  Copyright © 2019 田内　翔太郎. All rights reserved.
//

import UIKit
import ACEDrawingView

class ViewController: UIViewController {

    // キャンパス
    @IBOutlet weak var drawingView: ACEDrawingView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        drawingView.loadImage(UIImage(named: "津田梅子"))
        
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
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(didFinishSavingImage(_: didFinishSavingWithError: contextInfo:)), nil)
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

        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
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

