//
//  FavoriteViewController.swift
//  ImageShareApp
//
//  Created by 田内　翔太郎 on 2019/08/24.
//  Copyright © 2019 田内　翔太郎. All rights reserved.
//

import UIKit

class FavoriteViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout  {
    
    // MARK: - 変数、定数
    // MARK: - outlet
    // いいねした投稿を表示させるコレクションビュー
    @IBOutlet weak var favCollectionView: UICollectionView!

    // MARK: - 自作変数、定数
    var favPostImageInfo: [[String: Any]] = []
    var favPostImageID: [String] = []
    var roomID: String = ""

    // dateFormatter
    var formatter = DateFormatter()

    // MARK: - 関数

    override func viewDidLoad() {
        super.viewDidLoad()
        // デリゲートの設定
        favCollectionView.delegate = self
        favCollectionView.dataSource = self

        // レイアウトを調整
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
        favCollectionView.collectionViewLayout = layout

        // タイトルの設定
        self.navigationItem.title = "お気に入りリスト"
    }

    /**
     * int型の日付をString型の日付に直す関数
     * - Parameters:
     *   - intDate: Int型の日付
     */
    func printDate(intDate: Int) -> String {
        // int型のdateをString型に変換
        let stringDate = String(intDate)
        // yyyyMMdd型でフォーマット
        formatter.dateFormat = "yyyyMMddHHmmss"
        // date型の日付を生成
        if let nowDate = formatter.date(from: stringDate) {
            // フォーマットの変換
            formatter.dateFormat = "yyyy年MM月dd日"
            return formatter.string(from: nowDate)
        } else {
            return "??"
        }
    }

    // MARK: - collectionView
    // コレクションビューのレイアウト
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let horizontalSpace : CGFloat = 20
        let cellSize : CGFloat = self.view.bounds.width - horizontalSpace
        return CGSize(width: cellSize, height: cellSize)
    }

    // セルの数
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return favPostImageInfo.count
    }

    // セルの設定
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FavCell", for: indexPath) as! FavoriteCollectionViewCell // 表示するセルを登録(先程命名した"Cell")

        // セルのセットアップ
        cell.setupCell()

        if favPostImageInfo.count != 0 {
            let dict = favPostImageInfo[indexPath.row]

            // 投稿画像を取得
            // 画像情報
            let imageInfo = dict["image"]
            // NSData型に変換
            let imageData = NSData(base64Encoded: imageInfo as! String, options: .ignoreUnknownCharacters)
            // UIImage型に変換
            let decordedImage = UIImage(data: imageData! as Data)
            // セルに表示
            cell.postedImageView.image = decordedImage

            // ユーザーIDを表示
            cell.userLabel.text = "制作者: \(dict["userID"] as! String)"

            // タイトルを表示
            cell.titleLabel.text = dict["title"] as? String

            // 日付の表示
            let date = printDate(intDate: dict["date"] as! Int)
            cell.postedDateLabel.text = "投稿日: \(date)"

            // タグの表示
            if dict["tag1"] as? String == "" || dict["tag1"] == nil{
                cell.tag1Button.isHidden = true
            } else {
                cell.tag1Button.isHidden = false
                cell.tag1Button.setTitle(dict["tag1"] as? String, for: .normal)
            }

            if dict["tag2"] as? String == "" || dict["tag2"] == nil{
                cell.tag2Button.isHidden = true
            } else {
                cell.tag2Button.isHidden = false
                cell.tag2Button.setTitle(dict["tag2"] as? String, for: .normal)
            }
        }
        return cell
    }

    // セルタップ時
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // 遷移先の画面のインスタンスを生成
        let storyboard = UIStoryboard(name: "TopDetails", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "DetailsView") as! DetailsViewController

        // それぞれの値を取得
        if favPostImageInfo.count != 0 {
            let dict = favPostImageInfo[indexPath.row]

            // 投稿画像を取得
            // 画像情報
            let imageInfo = dict["image"]
            // NSData型に変換
            let imageData = NSData(base64Encoded: imageInfo as! String, options: .ignoreUnknownCharacters)
            // UIImage型に変換
            if let decordedImage: UIImage = UIImage(data: imageData! as Data) {

                // ユーザーIDを表示
                let user = dict["userID"] as? String

                // タイトルを表示
                let title = dict["title"] as? String

                // 投稿日を表示
                let date = printDate(intDate: dict["date"] as! Int)

                // タグを表示
                let tag1 = dict["tag1"] as? String
                let tag2 = dict["tag2"] as? String

                // 値を渡す
                vc.image = decordedImage
                vc.strTitle = title
                vc.user = user!
                vc.date = date
                vc.tag1 = tag1
                vc.tag2 = tag2

            } else {
                vc.image = #imageLiteral(resourceName: "イメージ画像のアイコン素材 その3")
            }
        }
        vc.roomID = roomID
        vc.postID = favPostImageID[indexPath.row]

        self.navigationController?.pushViewController(vc, animated: true)
    }
}
