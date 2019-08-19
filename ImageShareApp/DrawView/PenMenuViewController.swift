//
//  PenMenuViewController.swift
//  ImageShareApp
//
//  Created by 田内　翔太郎 on 2019/08/18.
//  Copyright © 2019 田内　翔太郎. All rights reserved.
//

import UIKit

class PenMenuViewController: UIViewController {

    var sliderVal: CGFloat!

    @IBOutlet weak var textField: UITextField!
    // ペンの一覧
    @IBOutlet weak var penMenuView: UIView!

    // 透明度のスライダー
//    @IBOutlet weak var opacitySlider: UISlider!
//    @IBOutlet weak var opacityLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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

//    // 透明度スライダーの処理
//    @IBAction func opacityMoveSlider(_ sender: UISlider) {
//        opacityLabel.text = String(Int(opacitySlider.value))
//        sliderVal = CGFloat(opacitySlider.value)
//    }

}
