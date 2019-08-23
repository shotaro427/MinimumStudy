//
//  DetailsViewController.swift
//  ImageShareApp
//
//  Created by 田内　翔太郎 on 2019/08/22.
//  Copyright © 2019 田内　翔太郎. All rights reserved.
//

import UIKit
import PMAlertController

class DetailsViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var postedImageScrollView: UIScrollView!

    // imageView
    var postedImageView: UIImageView!

    // グループID
    var roomID: String = ""

    // 遷移元からもらう
    var strTitle: String? = ""
    var user: String? = ""
    var image: UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // タイトルと制作者ユーザーIDを表示
        titleLabel.text = strTitle
        userLabel.text = user

        // デリゲート
        postedImageScrollView.delegate = self
        // 最大・最小の大きさを決める
        postedImageScrollView.maximumZoomScale = 4.0
        postedImageScrollView.minimumZoomScale = 1.0

        // imageViewを生成
        postedImageView = UIImageView()
        postedImageView.frame = postedImageScrollView.frame
        postedImageScrollView.addSubview(postedImageView)

        // imageViewにセグエで飛ばされてきた画像を設定
        postedImageView.image = image
        postedImageView.contentMode = UIView.ContentMode.scaleAspectFit

        // ダブルタップ対応
        let doubleTap = UITapGestureRecognizer(target:self,action:#selector(DetailsViewController.doubleTap(gesture:)))
        doubleTap.numberOfTapsRequired = 2
        postedImageView.isUserInteractionEnabled = true
        postedImageView.addGestureRecognizer(doubleTap)
    }

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
