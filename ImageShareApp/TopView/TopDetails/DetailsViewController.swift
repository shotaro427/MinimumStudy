//
//  DetailsViewController.swift
//  ImageShareApp
//
//  Created by 田内　翔太郎 on 2019/08/22.
//  Copyright © 2019 田内　翔太郎. All rights reserved.
//

import UIKit
import PMAlertController
import FirebaseFirestore
import NVActivityIndicatorView

class DetailsViewController: UIViewController, UIScrollViewDelegate {

    // MARK: - プロパティ、変数,定数
    // MARK: - storyboard状の変数
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var postedImageScrollView: UIScrollView!
    @IBOutlet weak var tag1Button: UIButton!
    @IBOutlet weak var tag2Button: UIButton!
    @IBOutlet weak var postImageInfoView: UIView!
    @IBOutlet weak var tagLabel: UILabel!
    @IBOutlet weak var tagsLabelView: UIView!
    @IBOutlet weak var titleLabelView: UIView!

    // imageView
    @IBOutlet weak var postedImageView: UIImageView!

    // MARK: - 自作プロパティ

    // ボタンの状態を表す
    enum twoButtonState {
        case up
        case down
    }

    // 投稿のdocumentID
    var postID: String = ""

    // グループID
    var roomID: String = ""

    // 遷移元からもらう
    var strTitle: String? = ""
    var user: String? = ""
    var date: String = ""
    var image: UIImage!
    var tag1: String?
    var tag2: String?

    // インジケータの追加
    var activityIndicatorView: NVActivityIndicatorView!
    var activityIndicatorBackgroundView: UIView!

    // ボタンの状態を管理
    var state: twoButtonState = .down

    // MARK: 関数
    // MARK: - override系

    override func viewDidLoad() {
        super.viewDidLoad()

        // 情報が書かれているビューの設定
        postImageInfoView.layer.cornerRadius = 10
        // 影
        postImageInfoView.layer.shadowOffset = CGSize(width: 0, height: -5)
        postImageInfoView.layer.shadowColor = UIColor.black.cgColor
        postImageInfoView.layer.shadowOpacity = 0.6
        postImageInfoView.layer.shadowRadius = 4

        // タイトルと制作者ユーザーIDを表示
        titleLabel.text = "タイトル: \(String(describing: strTitle!))"
        userLabel.text = "制作者: \(String(describing: user!))"
        dateLabel.text = "投稿日: \(date)"
        tag1Button.setTitle(tag1, for: .normal)
        tag2Button.setTitle(tag2, for: .normal)

        // デリゲート
        postedImageScrollView.delegate = self
        // ズームの最大・最小の大きさを決める
        postedImageScrollView.maximumZoomScale = 4.0
        postedImageScrollView.minimumZoomScale = 1.0
        // 外見の設定
        postedImageScrollView.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.3309610445)
        postedImageScrollView.layer.borderWidth = 2

        // imageViewにセグエで飛ばされてきた画像を設定
        postedImageView.image = image
        
        // ダブルタップ対応
        let doubleTap = UITapGestureRecognizer(target:self,action:#selector(DetailsViewController.doubleTap(gesture:)))
        doubleTap.numberOfTapsRequired = 2
        postedImageView.isUserInteractionEnabled = true
        postedImageView.addGestureRecognizer(doubleTap)

        // タグのラベルの設定
        tag1Button.layer.cornerRadius = 10
        tag2Button.layer.cornerRadius = 10
        if tag1 == "" {
            tag1Button.isHidden = true
        }
        if tag2 == "" {
            tag2Button.isHidden = true
        }

        // インジケータの設定
        setIndicator()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        print("start viewDidLayoutSubviews")
        // タグのラベルの設定
        tag1Button.layer.cornerRadius = 10
        tag2Button.layer.cornerRadius = 10
        if tag1 == "" {
            tag1Button.isHidden = true
        }
        if tag2 == "" {
            tag2Button.isHidden = true
        }
    }

    // MARK: - ズーム機能系の関数
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.postedImageView
    }

    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        print("end zoom")
    }

    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        print("start zoom")
    }

    @objc func doubleTap(gesture:UITapGestureRecognizer) -> Void {
        if(self.postedImageScrollView.zoomScale < 3){
            let newScale:CGFloat = self.postedImageScrollView.zoomScale*3
            let zoomRect:CGRect = self.zoomForScale(scale:newScale, center:gesture.location(in:gesture.view))
            self.postedImageScrollView.zoom(to:zoomRect, animated: true)
        } else {
            self.postedImageScrollView.setZoomScale(1.0, animated: true)
        }
    }

    func zoomForScale(scale:CGFloat, center: CGPoint) -> CGRect{
        var zoomRect: CGRect = CGRect()
        zoomRect.size.height = self.postedImageScrollView.frame.size.height / scale
        zoomRect.size.width = self.postedImageScrollView.frame.size.width  / scale
        zoomRect.origin.x = center.x - zoomRect.size.width / 2.0
        zoomRect.origin.y = center.y - zoomRect.size.height / 2.0

        return zoomRect
    }

    // MARK: - 自作関数

    /// ViewとScrollViewの大きさを調整する関数
    func changeViewSize() {
        // ボタンの状態が.downの時 = viewを下げたい時
        if state == .down{
            UIView.animate(withDuration: 0.5, animations: {
                self.dateLabel.isHidden = true
                self.userLabel.isHidden = true
                self.tag1Button.isHidden = true
                self.tag2Button.isHidden = true
                self.tagLabel.isHidden = true
                self.tagsLabelView.isHidden = true
            })
        } else {
            UIView.animate(withDuration: 0.5, animations: {
                self.dateLabel.isHidden = false
                self.userLabel.isHidden = false
                self.tag1Button.isHidden = false
                self.tag2Button.isHidden = false
                self.tagLabel.isHidden = false
                self.tagsLabelView.isHidden = false
            })
        }
    }

    /// インジケータを設定する関数
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
     * 保存機能
     * - Parameters:
     *   - image: 保存したい画像
     */
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
        // アラートの作成
        let alertController = PMAlertController(title: title, description: message, image: image, style: .alert)
        alertController.addAction(PMAlertAction(title: "OK", style: .default))
        self.present(alertController, animated: true)
    }

    /// 該当の投稿をmessageコレクションから削除する機能
    func deletePostFromMessage(completion: @escaping () -> ()) {
        // messageコレクションから削除
        db.collection("chat-room").document(roomID).collection("message").document(postID).delete() { err in
            if let err = err {
                print("投稿の削除に失敗しました: \(err.localizedDescription)")
            }
            completion()
        }
    }

    /// 該当の投稿をfav-imageコレクションから削除する機能
    func deletePostFormFavImage(completion: @escaping () -> ()) {
        // fav-imageコレクションから削除
        db.collection("chat-room").document(roomID).collection("users").document(UserDefaults.standard.string(forKey: "email")!).collection("fav-image").document(postID).delete() { err in
            if let err = err {
                print("お気に入りリストからの削除に失敗しました: \(err.localizedDescription)")
            }
            completion()
        }
    }

    /// 総投稿数を1つ減らす処理
    func changeAllPostsCount(completion: @escaping () -> ()) {
        db.collection("chat-room").document(roomID).getDocument(completion: { (QuerySnapshot, err) in
            if let err = err {
                print("@DetailsViewController -> \(err.localizedDescription)")
            } else {
                if let postCount = QuerySnapshot?.data()!["post-count"] as? Int {
                    db.collection("chat-room").document(self.roomID).updateData(["post-count": postCount - 1], completion: { err2 in
                        if let err2 = err2 {
                            print("@DetailsViewController -> \(err2.localizedDescription)")
                        }
                        completion()
                    })
                }
            }
        })
    }

    /// アラートを表示する関数
    func showAlert() {
        let finishedAlert = PMAlertController(title: "完了", description: "投稿の削除が完了しました。", image: #imageLiteral(resourceName: "ok_man"), style: .alert)
        let yesAction = PMAlertAction(title: "はい", style: .default, action: {
            // トップ画面に戻す
            self.navigationController?.popViewController(animated: true)

        })
        finishedAlert.addAction(yesAction)
        present(finishedAlert, animated: true)
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

    /// 削除ボタン
    @IBAction func tappedTrashButton(_ sender: Any) {
        // インジケータの表示
        activityIndicatorView.startAnimating()
        activityIndicatorBackgroundView.alpha = 1

        // dispatchの設定
        let dispatchGroup = DispatchGroup()
        let dispatchQueue = DispatchQueue(label: "queue", attributes: .concurrent)

        // 制作者とユーザーが同じだった時に削除できるようにする
        if user == UserDefaults.standard.string(forKey: "email") {
            // アラートの表示
            let alertController = PMAlertController(title: "投稿の削除", description: "この投稿を本当に削除しますか ?", image: #imageLiteral(resourceName: "ゴミ箱"), style: .alert)
            let okAction = PMAlertAction(title: "はい", style: .default, action: {
                // キューにタスクを追加
                dispatchGroup.enter()
                dispatchQueue.async(group: dispatchGroup, execute: {
                    print("deletePostFromMessage started")
                    self.deletePostFromMessage(completion: {
                        print("deletePostFromMessage finished")
                        dispatchGroup.leave()
                    })
                })

                // キューにタスクを追加
                dispatchGroup.enter()
                dispatchQueue.async(group: dispatchGroup, execute: {
                    print("deletePostFormFavImage started")
                    self.deletePostFormFavImage(completion: {
                        print("deletePostFormFavImage finished")
                        dispatchGroup.leave()
                    })
                })

                // キューにタスクを追加
                dispatchGroup.enter()
                dispatchQueue.async(group: dispatchGroup, execute: {
                    print("changeAllPostsCount started")
                    self.changeAllPostsCount(completion: {
                        print("changeAllPostsCount finished")
                        dispatchGroup.leave()
                    })
                })

                // すべての処理が終わった時の処理
                dispatchGroup.notify(queue: .main, execute: {
                    print("all task finished -> next main task start")
                    self.showAlert()
                    self.activityIndicatorBackgroundView.alpha = 0
                    self.activityIndicatorView.stopAnimating()
                })
            })
            let noAction = PMAlertAction(title: "いいえ", style: .cancel, action: {
                self.activityIndicatorBackgroundView.alpha = 0
                self.activityIndicatorView.stopAnimating()
            })

            // アラートアクションの追加
            alertController.addAction(okAction)
            alertController.addAction(noAction)
            present(alertController, animated: true)

        } else {
            // アラートの表示
            let alertController = PMAlertController(title: "削除ができませんでした。", description: "制作者以外の方は削除することができません。", image: #imageLiteral(resourceName: "NG"), style: .alert)
            let okAction = PMAlertAction(title: "はい", style: .default)
            alertController.addAction(okAction)
            present(alertController, animated: true)
        }
    }

    @IBAction func tappedViewDownButton(_ sender: UIButton) {
        // ボタンが下の時
        if state == .down {
            print(state)
            // viewを調整する
            changeViewSize()
            // ボタンの状態を上にする
            state = .up
            // ボタンの画像を変える
            sender.setImage(#imageLiteral(resourceName: "icons8-上-25"), for: .normal)
        } else { // ボタンが上の時
            // viewを調整する
            changeViewSize()
            // ボタンの状態を下にする
            state = .down
            // ボタンの画像を変える
            sender.setImage(#imageLiteral(resourceName: "icons8-下-25"), for: .normal)
        }
    }
}
