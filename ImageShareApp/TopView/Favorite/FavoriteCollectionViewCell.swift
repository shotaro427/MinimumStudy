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
        self.postView.layer.cornerRadius = 20
        self.tag1Button.layer.cornerRadius = 10
        self.tag2Button.layer.cornerRadius = 10
        self.tag2Button.isEnabled = false
        self.tag1Button.isEnabled = false
        self.postView.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.7613441781)
        self.postView.layer.borderWidth = 2

        // セル自体の設定
        self.layer.borderWidth = 2
        self.layer.borderColor = UIColor.black.cgColor
    }
}
