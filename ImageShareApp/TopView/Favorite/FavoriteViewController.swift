//
//  FavoriteViewController.swift
//  ImageShareApp
//
//  Created by 田内　翔太郎 on 2019/08/24.
//  Copyright © 2019 田内　翔太郎. All rights reserved.
//

import UIKit

class FavoriteViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout  {

    var favPostImageInfo: [[String: Any]] = []
    var favPostImageID: [String] = []
    var roomID: String = ""

    // dateFormatter
    var formatter = DateFormatter()

    @IBOutlet weak var favCollectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()

        favCollectionView.delegate = self
        favCollectionView.dataSource = self

        // レイアウトを調整
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
        favCollectionView.collectionViewLayout = layout
    }

    // int型の日付をString型の日付に直す関数
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

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let horizontalSpace : CGFloat = 20
        let cellSize : CGFloat = self.view.bounds.width - horizontalSpace
        return CGSize(width: cellSize, height: cellSize)
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return favPostImageInfo.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FavCell", for: indexPath) as! FavoriteCollectionViewCell // 表示するセルを登録(先程命名した"Cell")

//        cell.roomID = roomID
//        cell.messageID = favPostImageID[indexPath.row]
//        cell.cellInfo = favPostImageInfo[indexPath.row]
//        cell.cellID = favPostImageID[indexPath.row]

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


            cell.layer.cornerRadius = 20
            cell.postView.layer.cornerRadius = 20
            cell.tag1Button.layer.cornerRadius = 10
            cell.tag2Button.layer.cornerRadius = 10
        }

        return cell
    }

}
