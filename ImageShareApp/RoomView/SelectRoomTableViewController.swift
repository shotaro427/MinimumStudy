//
//  SelectRoomTableViewController.swift
//  ImageShareApp
//
//  Created by 田内　翔太郎 on 2019/08/20.
//  Copyright © 2019 田内　翔太郎. All rights reserved.
//

import UIKit
import FirebaseFirestore

class SelectRoomTableViewController: UITableViewController {

    // 選択できる部屋を入れる
    var room: [String] = []
    // DB
    let db = Firestore.firestore()

    override func viewDidLoad() {
        super.viewDidLoad()
//        searchRoom()
    }

//    // ユーザーが所属している部屋を探す関数
//    func searchRoom() {
//        // ユーザーid(email)を取得
//        let userID = UserDefaults.standard.string(forKey: "email")
//        db.collection("chat-room").getDocuments() { (QuerySnapshot, err) in
//            if let err = err { // エラー時
//                print("SelectRoomTableViewController-29: \(err.localizedDescription)")
//            } else { // 成功時
//                // ドキュメントを取得
//                for document in QuerySnapshot!.documents {
//                    // ドキュメント内のuserIDとこのユーザーのuserIDと一致するかを見る
//                    self.db.collection("chat-room").document("\(document.documentID)").collection("users").getDocuments() {(QuerySnapshot2, err2) in
//                        if let err2 = err2 {
//                            print("SelectRoomTableViewController-29: \(err2.localizedDescription)")
//                        } else {
//                            // ドキュメントの取得
//                            for document2 in QuerySnapshot2!.documents {
//                                // IDの照合
//                                if document2.documentID == userID {
//                                    // 部屋のIDを配列に追加
//                                    let roomName = document.data()["room-name"] as! String
//                                    self.room.append(roomName)
//                                    print("**room.count = \(self.room.count)")
//                                }
//                            }
//                        }
//                    }
//                }
//            }
//        }
//    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        print("room.count = \(room.count)")
        return room.count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = room[indexPath.row]
        return cell
    }


    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
