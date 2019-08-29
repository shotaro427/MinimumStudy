//
//  PenMenuViewController.swift
//  ImageShareApp
//
//  Created by 田内　翔太郎 on 2019/08/18.
//  Copyright © 2019 田内　翔太郎. All rights reserved.
//

import UIKit
import Material
import AMColorPicker

class PenMenuViewController: UIViewController, AMColorPickerDelegate {

    // ペンの種類を一時的に保管
    var tempToolType: Int = 1
    // ペンの色を保管
    var penColor: UIColor = UIColor.red

    // 現在選択されているボタンタグ
    var buttonTag: Int = 1

    // ペンの一覧
    @IBOutlet weak var penMenuView: UIView!
    // カラーピッカー
    @IBOutlet weak var editColorPicker: AMColorPickerTableView!
    
    @IBOutlet weak var thickPenButton: IconButton!
    @IBOutlet weak var finePenButton: IconButton!
    @IBOutlet weak var eraserButton: IconButton!
    

    override func viewDidLoad() {
        super.viewDidLoad()



        editColorPicker.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // colorPickerの設定
        editColorPicker.backgroundColor = #colorLiteral(red: 0.0006366733578, green: 0.9996278882, blue: 0.931129694, alpha: 1)

        // メニューの位置を取得する
        let menuPos = self.penMenuView.layer.position
        // 初期位置を画面の外側にするため、メニューの幅の分だけマイナスする
        self.penMenuView.layer.position.x = -self.penMenuView.frame.width
        // 表示時のアニメーションを作成する
        UIView.animate(
            withDuration: 0.5,
            delay: 0,
            options: .curveEaseOut,
            animations: {
                self.penMenuView.layer.position.x = menuPos.x
        },
            completion: { bool in
                
        })

    }

    // メニューエリア以外タップ時の処理
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        // 遷移前の画面に値を渡す
        getPresentView()

        super.touchesEnded(touches, with: event)
        for touch in touches {
            if touch.view?.tag == 1 {
                UIView.animate(
                    withDuration: 0.2,
                    delay: 0,
                    options: .curveEaseIn,
                    animations: {
                        self.penMenuView.layer.position.x = -self.penMenuView.frame.width
                },completion: { bool in
                        self.dismiss(animated: true, completion: nil)
                })
            }
        }
    }

    /// 遷移前の画面を取得する関数
    func getPresentView() {
        if self.presentingViewController is UINavigationController {
            let nc = self.presentingViewController as! UINavigationController
            let vc = nc.topViewController as! ViewController
            vc.setDetailPen(toolTypeNumber: tempToolType, penColor: penColor)
            vc.PenOrTextColor = penColor
        }
     }

    // カラーピッカーの関数
    func colorPicker(_ colorPicker: AMColorPicker, didSelect color: UIColor) {
        penColor = color
        print("selected Color!")
    }

    @IBAction func tappedToolTypeButton(_ sender: UIButton) {
        tempToolType = sender.tag

        if buttonTag != sender.tag {
            // 細ペンが選択されたとき
            if sender.tag == 1 {
                thickPenButton.setImage(#imageLiteral(resourceName: "icons8-蛍光ペン-30 (2)"), for: .normal)
                finePenButton.setImage(#imageLiteral(resourceName: "icons8-ペン-30 (1)"), for: .normal)
                eraserButton.setImage(#imageLiteral(resourceName: "icons8-消しゴム-30"), for: .normal)
                buttonTag = 1
            } else if sender.tag == 2 { // 太ペンが選択されたとき
                thickPenButton.setImage(#imageLiteral(resourceName: "icons8-蛍光ペン-30 (1)"), for: .normal)
                finePenButton.setImage(#imageLiteral(resourceName: "icons8-ペン-30"), for: .normal)
                eraserButton.setImage(#imageLiteral(resourceName: "icons8-消しゴム-30"), for: .normal)
                buttonTag = 2
            } else { // 消しゴムが選択されたとき
                thickPenButton.setImage(#imageLiteral(resourceName: "icons8-蛍光ペン-30 (2)"), for: .normal)
                finePenButton.setImage(#imageLiteral(resourceName: "icons8-ペン-30"), for: .normal)
                eraserButton.setImage(#imageLiteral(resourceName: "icons8-消しゴム-30 (1)"), for: .normal)
                buttonTag = 3
            }
        }
    }
}
