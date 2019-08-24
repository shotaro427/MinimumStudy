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
            cell.userLabel.text = dict["userID"] as? String

            // タイトルを表示
            cell.titleLabel.text = dict["title"] as? String

            cell.layer.cornerRadius = 20
            cell.postView.layer.cornerRadius = 20
        }

        return cell
    }

}
