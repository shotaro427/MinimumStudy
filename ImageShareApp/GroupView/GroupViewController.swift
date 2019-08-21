//
//  GroupViewController.swift
//  ImageShareApp
//
//  Created by 田内　翔太郎 on 2019/08/20.
//  Copyright © 2019 田内　翔太郎. All rights reserved.
//

import UIKit

class GroupViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    // グループ画像
    @IBOutlet weak var groupImage: UIImageView!

    @IBOutlet weak var groupTableView: UITableView!

    // 部屋のID
    var roomID: String = ""

    // 部屋に所属するユーザーIDを入れる配列
    var roomMenbers: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        groupTableView.delegate = self
        groupTableView.dataSource = self
    }

    // セル数
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return roomMenbers.count
    }

    // セルの操作
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = groupTableView.dequeueReusableCell(withIdentifier: "GroupCell", for: indexPath)
        print("**roomMenbers[indexPath.row]: \(roomMenbers[indexPath.row])")
        cell.textLabel?.text = roomMenbers[indexPath.row]
        
        return cell
    }

    @IBAction func allowAddMenberButton(_ sender: Any) {
    }
}
