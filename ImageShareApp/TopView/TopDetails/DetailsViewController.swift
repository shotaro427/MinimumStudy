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
    @IBOutlet weak var tag1Label: UILabel!
    @IBOutlet weak var tag2Label: UILabel!
    
    // imageView
    @IBOutlet weak var postedImageView: UIImageView!

    // MARK: - 自作プロパティ

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

    // MARK: 関数
    override func viewDidLoad() {
        super.viewDidLoad()

        // タイトルと制作者ユーザーIDを表示
        titleLabel.text = "タイトル: \(String(describing: strTitle!))"
        userLabel.text = "制作者: \(String(describing: user!))"
        dateLabel.text = "投稿日: \(date)"
        tag1Label.text = tag1
        tag2Label.text = tag2

        // デリゲート
        postedImageScrollView.delegate = self
        // 最大・最小の大きさを決める
        postedImageScrollView.maximumZoomScale = 4.0
        postedImageScrollView.minimumZoomScale = 1.0

        // imageViewにセグエで飛ばされてきた画像を設定
        postedImageView.image = image
        
        // ダブルタップ対応
        let doubleTap = UITapGestureRecognizer(target:self,action:#selector(DetailsViewController.doubleTap(gesture:)))
        doubleTap.numberOfTapsRequired = 2
        postedImageView.isUserInteractionEnabled = true
        postedImageView.addGestureRecognizer(doubleTap)

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

    // 総投稿数を1つ減らす処理
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
            let noAction = PMAlertAction(title: "いいえ", style: .cancel)

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
}
