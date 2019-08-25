//
//  ViewController.swift
//  ImageShareApp
//
//  Created by 田内　翔太郎 on 2019/08/18.
//  Copyright © 2019 田内　翔太郎. All rights reserved.
//

import UIKit
import Material
import ACEDrawingView
import PMAlertController
import FirebaseFirestore
import NVActivityIndicatorView
import AMColorPicker

class ViewController: UIViewController, ACEDrawingViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, AMColorPickerDelegate, UIGestureRecognizerDelegate, UITextViewDelegate {

    // textfield
    var titleTextField: UITextField!
    var tag1TextField: UITextField!
    var tag2TextField: UITextField!
    // DB
    let db = Firestore.firestore()
    // roomID
    var roomID: String = ""
    // 背景画像
    var image: UIImage!
    // 背景画像
    @IBOutlet weak var imageView: UIImageView!
    // キャンパス
    @IBOutlet weak var drawingView: ACEDrawingView!

    // 設定画面の中心
    var centerOfSettingView: CGPoint!

    // インジケータの追加
    var activityIndicatorView: NVActivityIndicatorView!
    var activityIndicatorBackgroundView: UIView!


    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // 画像の読み込み
        self.imageView.image = image

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
        let rect = drawingView.frame

        // ビットマップ画像のcontextを作成する
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        if let context: CGContext = UIGraphicsGetCurrentContext() {

            // view内の描画をcontextに複写する
            imageView.layer.render(in: context)

            drawingView.layer.render(in: context)
        }

        // contextのビットマップをUIImageとして取得する
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!

        // contextを閉じる
        UIGraphicsEndImageContext()

        return image
    }


    /// ペンの詳細設定をする関数
    func setDetailPen(toolTypeNumber: Int, penColor: UIColor) {
        // 消しゴムが選択された時
        if toolTypeNumber == 3 {
            drawingView.drawTool = ACEDrawingToolTypeEraser
        } else {
            drawingView.drawTool = ACEDrawingToolTypePen
            // 太ペンが選択された時
            if toolTypeNumber == 1 {
                drawingView.lineColor = penColor
                drawingView.lineWidth = 10
            } else {
                // 細ペンが選択された時
                drawingView.lineColor = penColor
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
            // pickerの設定
            cameraPicker.allowsEditing = true
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
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            self.image = editedImage
        } else if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            self.image = originalImage
        }

        dismiss(animated: true, completion: nil)
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
    // 投稿ボタン
    @IBAction func postImageButton(_ sender: Any) {

        // 投稿処理
        // 画像のタイトル
        var imageTitle: String = ""
        // 画像情報
        var postImageData: NSData = NSData()
        // viewをimageとして取得
        let postImage = self.getImage(view)
        // クオリティを1/10まで下げる
        postImageData = postImage.jpegData(compressionQuality: 0.1)! as NSData
        // base64Stringに変換
        let base64PostImage = postImageData.base64EncodedString(options: .lineLength64Characters) as String
        // firebaseに渡す情報(画像、タイトル、ユーザーID)

        // 投稿確認
        // アラートコントローラー
        let alertController = PMAlertController(title: "投稿しますか？", description: nil, image: postImage, style: .alert)
        // アラートアクション
        // textFieldの追加(タイトル)
        alertController.addTextField({ ( textfield ) in
            textfield?.placeholder = "タイトル"
            self.titleTextField = textfield
        })
        // textFieldの追加(タグ)
        alertController.addTextField({ (textfield) in
            textfield?.placeholder = "タグ1"
            self.tag1TextField = textfield
        })
        alertController.addTextField({ (textfield) in
            textfield?.placeholder = "タグ2"
            self.tag2TextField = textfield
        })
        // アクションの追加
        alertController.addAction(PMAlertAction(title: "はい", style: .default, action:{
            // 現在時刻の取得
            let nowDate = self.getDate()

            if self.titleTextField.text != "" {
                imageTitle = (self.titleTextField.text)!
            } else {
                imageTitle = "無題"
            }
            // messageにtagコレクションを追加
            guard let tag1 = self.tag1TextField.text, let tag2 = self.tag2TextField.text  else {
                print("textFieldの値を取得できませんでした")
                return
            }

            // messageに値をつける
            let message: NSDictionary = ["title": imageTitle, "userID": UserDefaults.standard.string(forKey: "email")!, "image": base64PostImage, "date": nowDate, "tag1": tag1, "tag2": tag2]
            self.db.collection("chat-room").document("\(self.roomID)").collection("message")
            let messageID = self.db.collection("chat-room").document("\(self.roomID)").collection("message").addDocument(data: message as! [String: Any]).documentID
            // インジケータの描画
            self.activityIndicatorView.startAnimating()
            self.activityIndicatorBackgroundView.alpha = 1

            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                // インジケータの描画
                self.activityIndicatorView.stopAnimating()
                self.activityIndicatorBackgroundView.alpha = 0
                self.showAlert()
            })
        }))

        alertController.addAction(PMAlertAction(title: "いいえ", style: .cancel))
        present(alertController, animated: true)
    }

    // 時刻をint型で格納する関数
    func getDate() -> Int {
        let nowDate = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMddHHmmss"

        let stringDate = formatter.string(from: nowDate)
        let intDate = Int(stringDate)!

        return intDate
    }

    func showAlert() {
        let alertController = PMAlertController(title: "投稿が完了しました", description: "", image: #imageLiteral(resourceName: "ok_man"), style: .alert)
        let alertAction = PMAlertAction(title: "はい", style: .default, action: {
            self.db.collection("chat-room").document(self.roomID).getDocument(completion: { (document, err) in
                if let document = document, document.exists {
                    self.db.collection("chat-room").document(self.roomID).updateData([
                        "post-count": document.data()!["post-count"] as! Int + 1
                    ])
                }
            })
        })
        alertController.addAction(alertAction)
        self.present(alertController, animated: true)
    }


    func colorPicker(_ colorPicker: AMColorPicker, didSelect color: UIColor) {
        drawingView.lineColor = color
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

    // テキストボタン
    @IBAction func tappedAddTextButton(_ sender: Any) {
        // textViewを追加
        let textView = UITextView(frame: CGRect(x: 0, y: 0, width: 100, height: 50))
        textView.backgroundColor = UIColor.clear
        textView.center = drawingView.center
        textView.text = "テストテストテスト"
        textView.delegate = self
        // Pangestureを生成
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.panView(sender:)))
        textView.addGestureRecognizer(panGesture)

        // drawingViewにtextViewを追加
        drawingView.addSubview(textView)
    }

    // hides text views
    // returnキーを押した時
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {

        if (text == "\n") {
            //あなたのテキストフィールド
            textView.resignFirstResponder()
            return false
        }
        return true
    }

    //Pan実行時のメソッド
    @objc func panView(sender: UIPanGestureRecognizer) {
        //移動量を取得
        let move:CGPoint = sender.translation(in:self.view)
        //ドラッグした部品の座標に移動量を加算
        sender.view!.center.x += move.x
        sender.view!.center.y += move.y
        //移動量を0に
        sender.setTranslation(CGPoint.zero, in: self.view)
    }
}

