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

    // MARK: - 変数、定数

    // MARK: - 紐付けした変数
    // 背景画像
    @IBOutlet weak var imageView: UIImageView!
    // キャンパス
    @IBOutlet weak var drawingView: ACEDrawingView!
    // キーボードを閉じるためのボタン
    @IBOutlet weak var closeKeyBoardButton: UIButton!

    // MARK: - 自作の変数、定数
    // 設定画面の中心
    var centerOfSettingView: CGPoint!
    // カラーピッカーの色を保管しておく変数
    var PenOrTextColor: UIColor = UIColor.black
    // インジケータの追加
    var activityIndicatorView: NVActivityIndicatorView!
    var activityIndicatorBackgroundView: UIView!

    // 現在操作しているtextView
    var currentTextView: UITextView = UITextView()
    // textfield
    var titleTextField: UITextField!
    var tag1TextField: UITextField!
    var tag2TextField: UITextField!

    // roomID
    var roomID: String = ""
    // 背景画像
    var image: UIImage!

    // MARK: - 関数

    // MARK: - オーバーライド系
    override func viewDidLoad() {
        super.viewDidLoad()

        // 編集画面の設定
        drawingView.lineWidth = 5

        // インジケータの設定
        setIndicator()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // ボタンを隠す
        closeKeyBoardButton.isHidden = true

        // 画像の読み込み
        self.imageView.image = image

    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // 現在操作しているtextViewのキーボードを閉じる
        currentTextView.resignFirstResponder()
        currentTextView.endEditing(true)
    }

    // MARK: - 自作関数

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

    /// インジケータをセットする関数
    func setIndicator() {
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

    /**
     * ペンの詳細設定をする関数
     * - Parameters:
     *   - toolTypeNumber: ペンのタイプ、(1 = 太ペン, 2 = 細ペン, 3 = 消しゴム)
     *   - penColor: ペンの色
     */
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

    /**
     * 時刻をint型で返す処理
     * - Parameters:
     *   - None:
     * - Returns: Int型の日付
     */
    func getDate() -> Int {
        // 現在時刻を取得
        let nowDate = Date()
        // フォーマットを生成
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMddHHmmss"

        // Int型に変換
        let stringDate = formatter.string(from: nowDate)
        let intDate = Int(stringDate)!

        return intDate
    }

    /// アラートを表示する関数
    func showAlert() {
        let alertController = PMAlertController(title: "投稿が完了しました", description: "", image: #imageLiteral(resourceName: "ok_man"), style: .alert)
        let alertAction = PMAlertAction(title: "はい", style: .default, action: {
            db.collection("chat-room").document(self.roomID).getDocument(completion: { (document, err) in
                if let document = document, document.exists {
                    db.collection("chat-room").document(self.roomID).updateData([
                        "post-count": document.data()!["post-count"] as! Int + 1
                        ])
                }
            })
        })
        alertController.addAction(alertAction)
        self.present(alertController, animated: true)
    }

    /**
     * DBにタグ情報を送る関数
     * - Parameters:
     *   - tag: DBに登録したいタグ名
     *   - completion: DBに登録し終わった後に実行したい処理
     */
    func postTagInfo(tag: String, completion: @escaping () -> ()) {
        // tag1をタグ用のDBにタグ情報を保管
        db.collection("tags").whereField("tag-name", isEqualTo: tag).getDocuments(completion: { (QuerySnapshot, err) in
            // ドキュメントの個数が0 ＝　該当するタグがない場合
            if let documents = QuerySnapshot?.documents {
                if documents.count == 0 {
                    db.collection("tags").addDocument(data: ["tag-name": tag, "used-count": 1])
                } else { // 該当するタグがすでに存在していた場合
                    if let documentID = documents.last?.documentID, let usedCount = documents.last?.data()["used-count"] as? Int{
                        db.collection("tags").document(documentID).updateData(["used-count": usedCount + 1])
                    }
                }
            }
            completion()
        })
    }

    // MARK: - ImagePicker
    /// カメラ・フォトライブラリへの遷移処理
    /**
     * カメラ・フォトライブラリへの遷移処理
     *  - Parameters:
     *    - sourceType: ソースタイプ、カメラかフォトライブラリ化
     */
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

    /// 写真が選択された時に呼ばれる
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
        // アラートの表示
        let alertController = PMAlertController(title: title, description: message, image: image, style: .alert)

        alertController.addAction(PMAlertAction(title: "OK", style: .default))
        self.present(alertController, animated: true)
    }

    // MARK: - ColorPicker
    /// 色を取得する処理
    func colorPicker(_ colorPicker: AMColorPicker, didSelect color: UIColor) {
        drawingView.lineColor = color
    }

    // MARK: - textView
    /// textViewの値が変わるたびに呼ばれる
    func textViewDidChange(_ textView: UITextView) {
        // 高さを取得
        let height = textView.sizeThatFits(CGSize(width: textView.frame.size.width, height: CGFloat.greatestFiniteMagnitude)).height
        // 幅を取得
        let width = textView.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: textView.frame.size.height)).width

        // 幅の上限を300に設定する
        if width <= 300 {
            textView.frame.size = CGSize(width: width, height: height)
        } else {
            textView.frame.size = CGSize(width: 300, height: height)
        }
    }

    /// textViewを編集しようとするたびに呼ばれる
    func textViewDidBeginEditing(_ textView: UITextView) {
        // 操作しているtextViewを渡す
        currentTextView = textView
        // ボタンを表示させる
        closeKeyBoardButton.isHidden = false
    }

    // MARK: - PanGesture
    /// Pan実行時のメソッド
    @objc func panView(sender: UIPanGestureRecognizer) {
        //移動量を取得
        let move:CGPoint = sender.translation(in:self.view)
        //ドラッグした部品の座標に移動量を加算
        sender.view!.center.x += move.x
        sender.view!.center.y += move.y
        //移動量を0に
        sender.setTranslation(CGPoint.zero, in: self.view)
    }

    // MARK: - 紐付けアクション
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
        textView.text = "テストテスト"
        textView.delegate = self
        textView.textColor = PenOrTextColor
        textView.isScrollEnabled = false
        textView.sizeToFit()
        // Pangestureを生成
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.panView(sender:)))
        textView.addGestureRecognizer(panGesture)

        // drawingViewにtextViewを追加
        drawingView.addSubview(textView)
    }

    // 投稿ボタン
    @IBAction func postImageButton(_ sender: Any) {
        // インジケータの描画
        self.activityIndicatorView.startAnimating()
        self.activityIndicatorBackgroundView.alpha = 1

        // dispatch
        // グループ
        let dispatchGroup = DispatchGroup()
        // 並列キューの設定
        let dispatchQueue = DispatchQueue(label: "queue", attributes: .concurrent)

        // 投稿処理
        // 画像のタイトル
        var imageTitle: String = ""
        // 画像のタグ
        var tag1: String = ""
        var tag2: String = ""
        // viewをimageとして取得
        let postImage = self.getImage(view)
        // クオリティを1/10まで下げて、NSData型として格納
        let postImageData: NSData = postImage.jpegData(compressionQuality: 0.1)! as NSData
        // base64Stringに変換
        let base64PostImage = postImageData.base64EncodedString(options: .lineLength64Characters) as String

        // 投稿確認
        // アラートコントローラー
        let alertController = PMAlertController(title: "投稿しますか？", description: nil, image: postImage, style: .alert)

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

        // アラートアクション
        // アクションの追加
        alertController.addAction(PMAlertAction(title: "はい", style: .default, action:{
            // 現在時刻の取得
            let nowDate = self.getDate()

            // タイトルを取得
            if self.titleTextField.text != "" {
                imageTitle = (self.titleTextField.text)!
            } else {
                imageTitle = "無題"
            }
            // タグを取得
            if self.tag1TextField.text != "" {
                tag1 = self.tag1TextField.text!
            }
            if self.tag2TextField.text != "" {
                tag2 = self.tag2TextField.text!
            }


            var message: NSDictionary = NSDictionary()
            // messageに値をつける
            if tag1 != tag2 {
                message = ["title": imageTitle, "userID": UserDefaults.standard.string(forKey: "email")!, "image": base64PostImage, "date": nowDate, "tag1": tag1, "tag2": tag2]
                // tag1をタグ用のDBにタグ情報を保管
                dispatchGroup.enter()
                dispatchQueue.async(group: dispatchGroup, execute: {
                    print("postTagInfo #1 started")
                    self.postTagInfo(tag: tag1, completion: {
                        print("postTagInfo #1 finished")
                        dispatchGroup.leave()
                    })
                })
                // tag2をタグ用のDBにタグ情報を保管
                dispatchGroup.enter()
                dispatchQueue.async(group: dispatchGroup, execute: {
                    print("postTagInfo #2 started")
                    self.postTagInfo(tag: tag2, completion: {
                        print("postTagInfo #2 finished")
                        dispatchGroup.leave()
                    })
                })
            } else {
                message = ["title": imageTitle, "userID": UserDefaults.standard.string(forKey: "email")!, "image": base64PostImage, "date": nowDate, "tag1": tag1, "tag2": ""]

                // タグ用のDBにタグ情報を保管
                dispatchGroup.enter()
                dispatchQueue.async(group: dispatchGroup, execute: {
                    print("postTagInfo #1 started")
                    self.postTagInfo(tag: tag1, completion: {
                        print("postTagInfo #1 finished")
                        dispatchGroup.leave()
                    })
                })
            }
            // 投稿情報をDBに送る
            dispatchQueue.async(group: dispatchGroup, execute: {
                print("post image to chat-room/message #4 started")
                db.collection("chat-room").document("\(self.roomID)").collection("message")
                db.collection("chat-room").document("\(self.roomID)").collection("message").addDocument(data: message as! [String: Any], completion: { err in
                    if let err = err {
                        print("@ViewController in postImageButton() : \(err.localizedDescription)")
                    }
                    print("post image to chat-room/message #4 finished")
                })
            })

            // dispatchGroupのすべての処理が終わった時の処理
            dispatchGroup.notify(queue: .main, execute: {
                // インジケータを止める
                self.activityIndicatorView.stopAnimating()
                self.activityIndicatorBackgroundView.alpha = 0
                // アラートを表示させる
                self.showAlert()
            })
        }))
        alertController.addAction(PMAlertAction(title: "いいえ", style: .cancel, action: {
            // インジケータを止める
            self.activityIndicatorView.stopAnimating()
            self.activityIndicatorBackgroundView.alpha = 0
        }))
        present(alertController, animated: true)
    }

    @IBAction func tappedCloseKeyboardButton(_ sender: Any) {
        // 現在操作しているtextViewのキーボードを閉じる
        currentTextView.endEditing(true)
        currentTextView.resignFirstResponder()
        // ボタンを隠す
        closeKeyBoardButton.isHidden = true
    }
}

