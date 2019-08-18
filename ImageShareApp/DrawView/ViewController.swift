//
//  ViewController.swift
//  ImageShareApp
//
//  Created by 田内　翔太郎 on 2019/08/18.
//  Copyright © 2019 田内　翔太郎. All rights reserved.
//

import UIKit
import ACEDrawingView

class ViewController: UIViewController {

    // キャンパス
    @IBOutlet weak var drawingView: ACEDrawingView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        drawingView.loadImage(UIImage(named: "津田梅子"))
        
    }

    // クリアボタン
    @IBAction func clearButton(_ sender: Any) {
        
    }

    // キャンセルボタン
    @IBAction func cancelButton(_ sender: Any) {
    }

    // 保存ボタン
    @IBAction func saveButton(_ sender: Any) {
    }

    // ペンの変更ボタン
    @IBAction func changePenButton(_ sender: Any) {
    }
}

