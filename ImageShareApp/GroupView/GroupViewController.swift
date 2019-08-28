//
//  GroupViewController.swift
//  ImageShareApp
//
//  Created by 田内　翔太郎 on 2019/08/20.
//  Copyright © 2019 田内　翔太郎. All rights reserved.
//

import UIKit
import FirebaseAuth
import PMAlertController
import FirebaseFirestore

class GroupViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate {

    // 編集か決定かの種類を決めるためのenum
    enum buttonTwoType {
        case change
        case ok
    }

    // MARK: 変数、定数
    // MARK: - 紐付けした変数
    // グループ画像
    @IBOutlet weak var groupImage: UIImageView!
    // グループメンバー数
    @IBOutlet weak var numberOfGroupMenber: UILabel!
    // 投稿数
    @IBOutlet weak var numberOfPost: UILabel!
    // グループ名
    @IBOutlet weak var groupName: UILabel!

    // tableView
    @IBOutlet weak var groupTableView: UITableView!

    // button
    @IBOutlet weak var addMenber: UIButton!

    // 変更ボタン
    @IBOutlet weak var changeButton: UIButton!
    // グループ名を変えるtextField
    @IBOutlet weak var renameButton: UITextField!
    // 画像を変えるボタン
    @IBOutlet weak var changeImageButton: UIButton!
    // タグのボタン X 3
    @IBOutlet weak var tagButton1: UIButton!
    @IBOutlet weak var tagButton2: UIButton!
    @IBOutlet weak var tagButton3: UIButton!

    // MARK: - 自作の変数、定数
    
    // 変更後の画像を一時的に格納する
    var changedImage: UIImage!

    // changebuttonの状態を決める
    var  buttonType: buttonTwoType = .change

    // 部屋のID
    var roomID: String = ""
    // 部屋の情報
    var roomInfo: [String: Any] = [:]
    // タグの情報
    var tagsInfo: [String] = []

    // セクションタイトル
    let titleOfSection: [String] = ["メンバー", "申請待ち"]

    // 部屋に所属するユーザーIDを入れる配列
    var roomMenbers: [String] = []
    // 申請待ちのユーザーのIDを入れる配列
    var waitingMenber: [String] = []

    // 該当するドキュメントがあるかどうか
    var exsistDocument: Bool = false

    // 上の２つの配列を組み合わせた2次元配列
    var Menbers: [[String]] = []

    // MARK: - 関数
    // MARK: - override系
    override func viewDidLoad() {
        super.viewDidLoad()

        // タグのボタンを丸くする
        tagButton1.layer.cornerRadius = 10
        tagButton2.layer.cornerRadius = 10
        tagButton3.layer.cornerRadius = 10

        // renameButtonのデリゲートを設定
        renameButton.delegate = self

        // 変更ボタンの外見
        changeButton.layer.cornerRadius = 10
        changeButton.layer.borderColor = #colorLiteral(red: 0.3139560819, green: 0.6199932098, blue: 1, alpha: 1)
        changeButton.layer.borderWidth = 2

        // textFieldを見えなくする
        renameButton.isHidden = true

        // imageViewに重なっているbutton
        changeImageButton.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.5)
        // ボタンを使えなくする
        changeImageButton.isHidden = true

        // roomIDのドキュメントがあるかどうか
        db.collection("chat-room").document("\(roomID)").getDocument(completion: { (document, err) in
            if let document = document, document.exists {
                self.exsistDocument = true
            }
        })

        // tableViewの設定
        groupTableView.delegate = self
        groupTableView.dataSource = self

        // 値の追加
        Menbers.append(roomMenbers)
        Menbers.append(waitingMenber)

        // 画像の復元
        if let imageData = roomInfo["room-image"] as? String {
            let dataImage = NSData(base64Encoded: imageData, options: .ignoreUnknownCharacters)
            // UIImage型に変換
            let decordedImage = UIImage(data: dataImage! as Data)
            // imageViewに表示
            groupImage.image = decordedImage
        }

        // ラベルの表示
        // メンバー数
        numberOfGroupMenber.text = "メンバー数: \(roomMenbers.count)"
        // グループ名
        if let name = roomInfo["room-name"] as? String {
            groupName.text = "グループ名: \(name)"
        }
        // 投稿数
        if let postCount = roomInfo["post-count"] as? Int {
            numberOfPost.text = "総投稿数: \(postCount)"
        }
        // よく使われるタグの表示
        if tagsInfo.count == 3 {
            tagButton1.setTitle(tagsInfo[0], for: .normal)
            tagButton2.setTitle(tagsInfo[1], for: .normal)
            tagButton3.setTitle(tagsInfo[2], for: .normal)
        } else if tagsInfo.count == 2 {
            tagButton1.setTitle(tagsInfo[0], for: .normal)
            tagButton2.setTitle(tagsInfo[1], for: .normal)
        } else if tagsInfo.count == 1 {
            tagButton1.setTitle(tagsInfo[0], for: .normal)
        }
    }

    // MARK: - tableview

    // セル数
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Menbers[section].count
    }

    // セルの操作
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = groupTableView.dequeueReusableCell(withIdentifier: "GroupCell", for: indexPath)
        cell.textLabel?.text = Menbers[indexPath.section][indexPath.row]
        
        return cell
    }

    // Section数
    func numberOfSections(in tableView: UITableView) -> Int {
        return titleOfSection.count
    }

    // Sectioのタイトル
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return titleOfSection[section]
    }

    // タップ時のアクション
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 申請待ちの人をタップした時
        if indexPath.section == 1 {
            // アラートの表示
            let alertController = PMAlertController(title: "申請待ち", description: "\(Menbers[indexPath.section][indexPath.row])さんが申請しています。\n 申請を許可しますか？", image: #imageLiteral(resourceName: "正座"), style: .alert)
            let OKAction = PMAlertAction(title: "はい", style: .default, action: {
                self.allowMenbers(waitingUserID: self.Menbers[indexPath.section][indexPath.row])
            })
            let NOAction = PMAlertAction(title: "いいえ", style: .cancel)
            // アクションの追加
            alertController.addAction(OKAction)
            alertController.addAction(NOAction)
            // アラートを表示
            present(alertController, animated: true)
        }
    }

    // MARK: - 自作の関数
    /**
     * 申請の許可する関数
     * - Parameters:
     *   - waitingUserID: 申請しているユーザーのID
     */
    func allowMenbers(waitingUserID: String) {
        if exsistDocument {
            // waiting-usersからusersコレクションに移動
            // usersコレクションに該当ユーザーを登録
            db.collection("chat-room").document(roomID).collection("users").document(waitingUserID).setData(["userID": waitingUserID]) { err in
                if let err = err {
                    print("Error removing document: \(err)")
                } else {
                    print("Document successfully removed!")
                }
            }
            // waiting-usersから該当ユーザーのIDを削除
            db.collection("chat-room").document(roomID).collection("waiting-users").document(waitingUserID).delete() { err in
                if let err = err {
                    print("Error removing document: \(err)")
                } else {
                    print("Document successfully removed!")
                }
                // アラートの表示
                let alertController = PMAlertController(title: "完了!", description: "申請を許可しました。", image: #imageLiteral(resourceName: "ok_man"), style: .alert)
                let okAction = PMAlertAction(title: "はい", style: .default)
                alertController.addAction(okAction)
                self.present(alertController, animated: true)
            }

            // ドキュメントの総メンバー数を1つ増やす
            db.collection("chat-room").document(roomID).updateData([
                "menber-count": self.roomInfo["menber-count"] as! Int + 1
            ])
        }
    }

    /// textFieldの変更をDBとプロフィールに反映させる
    func changeGroupName() {
        if let rename = renameButton.text, renameButton.text != "" {
            // ラベルに反映
            groupName.text = "グループ名: \(rename)"
            // DBに反映
            db.collection("chat-room").document(roomID).updateData(["room-name": rename])
        }
    }

    /**
     * DBに変更後の画像を登録する
     * - Parameters:
     *   - changedImage: 変更後のグループ画像
     *   - picker: DBへの登録が終わった後に消すImagePicker
     */
    func setImage(changedImage: UIImage, picker: UIImagePickerController) {
        // NSData型に変換
        let changedImageData = changedImage.jpegData(compressionQuality: 0.1)! as NSData
        // string型に変換
        let changedImageString = changedImageData.base64EncodedString(options: .lineLength64Characters)
        // DBに登録
        db.collection("chat-room").document(roomID).updateData(["room-image": changedImageString], completion: { eer in
            picker.dismiss(animated: true, completion: nil)
        })
    }

    // MARK: - imagePicker系
    // imageViewに重なっているボタンを押した時にライブラリを開く
    /// カメラ・フォトライブラリへの遷移処理
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
            self.changedImage = editedImage
        } else if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            self.changedImage = originalImage
        }
        // 写真を反映させる
        self.groupImage.image = self.changedImage
        // DBに登録する
        setImage(changedImage: changedImage, picker: picker)
    }

    // MARK: - textView系
    // hides text views
    /// returnキーを押した時
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // キーボードを閉じる
        textField.resignFirstResponder()
        return true
    }

    // MARK: - 紐付けした関数
    // ログアウトボタン
    @IBAction func logoutButton(_ sender: Any) {
        // ログアウト処理
        try! Auth.auth().signOut()
        // storyboardのfileの特定
        let storyboard: UIStoryboard = UIStoryboard(name: "Login", bundle: nil)
        // 移動先のvcをインスタンス化
        let vc = storyboard.instantiateViewController(withIdentifier: "Login")
        // 遷移処理
        self.present(vc, animated: true)

    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

    // グループ設定変更ボタン
    @IBAction func tappedChangeButton(_ sender: UIButton) {
        if buttonType == .change {
            // 外見
            changeButton.setTitle("決定", for: .normal)
            changeButton.layer.borderColor = UIColor.white.cgColor
            changeButton.backgroundColor = #colorLiteral(red: 0.3139560819, green: 0.6199932098, blue: 1, alpha: 1)
            changeButton.setTitleColor(.white, for: .normal)
            changeImageButton.isHidden = false
            renameButton.isHidden = false
            buttonType = .ok
        } else {
            // 外見
            changeButton.setTitle("変更", for: .normal)
            changeButton.layer.borderColor = #colorLiteral(red: 0.3139560819, green: 0.6199932098, blue: 1, alpha: 1)
            changeButton.backgroundColor = UIColor.white
            changeButton.setTitleColor(#colorLiteral(red: 0.3139560819, green: 0.6199932098, blue: 1, alpha: 1), for: .normal)
            changeImageButton.isHidden = true
            renameButton.isHidden = true
            buttonType = .change

            // 処理
            changeGroupName()
        }
    }

    // 写真変更ボタンを押した時の処理
    @IBAction func tappedChangeImageButton(_ sender: Any) {
        // pickerに遷移する
        cameraAction(sourceType: .photoLibrary)
    }
}
