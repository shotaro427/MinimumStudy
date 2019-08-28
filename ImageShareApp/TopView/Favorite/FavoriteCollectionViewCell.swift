//
//  FavoriteCollectionViewCell.swift
//  ImageShareApp
//
//  Created by 田内　翔太郎 on 2019/08/24.
//  Copyright © 2019 田内　翔太郎. All rights reserved.
//

import UIKit

class FavoriteCollectionViewCell: UICollectionViewCell {

    /// 投稿した画像を表示するイメージビュー
    @IBOutlet weak var postedImageView: UIImageView!
    /// 投稿した画像のタイトルを表示するラベル
    @IBOutlet weak var titleLabel: UILabel!
    /// 投稿したユーザーを表示するラベル
    @IBOutlet weak var userLabel: UILabel!
    /// 投稿を表示するビュー
    @IBOutlet weak var postView: UIView!
    /// 投稿した日付を表示するラベル
    @IBOutlet weak var postedDateLabel: UILabel!
    /// タグを表示するボタン
    @IBOutlet weak var tag1Button: UIButton!
    @IBOutlet weak var tag2Button: UIButton!

    /// セルのセットアップ
    func setupCell() {
        // 部品の設定
        self.tag1Button.layer.cornerRadius = 10
        self.tag2Button.layer.cornerRadius = 10
        self.tag2Button.isEnabled = false
        self.tag1Button.isEnabled = false
        self.postView.layer.cornerRadius = 15
        self.postedImageView.layer.cornerRadius = 15
        // 角丸の位置を設定
        self.postedImageView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        self.postView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]

        // セル自体の設定
        // 影をつける
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 3, height: 3)
        self.layer.shadowRadius = 2
        self.layer.shadowOpacity = 0.6
    }
}
