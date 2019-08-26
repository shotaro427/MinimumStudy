//
//  TableViewCell.swift
//  ImageShareApp
//
//  Created by 田内　翔太郎 on 2019/08/23.
//  Copyright © 2019 田内　翔太郎. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {

    // グループ画像
    @IBOutlet weak var groupImageView: UIImageView!
    // グループ名
    @IBOutlet weak var groupName: UILabel!
    // メンバー数
    @IBOutlet weak var menberCount: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        self.layer.cornerRadius = 15
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    /**
        画像の設定を行う関数
     */
    func setImage() {
        // imageViewの設定
        groupImageView.layer.cornerRadius = 45
        groupImageView.clipsToBounds = true
    }
    
}
