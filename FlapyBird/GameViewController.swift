//
//  ViewController.swift
//  FlapyBird
//
//  Created by xgf on 2018/2/6.
//  Copyright © 2018年 xgf. All rights reserved.
//

import UIKit
import SpriteKit
import SnapKit

class GameViewController: UIViewController {
    private var bg = UIImageView.init()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let skv = view as! SKView
        skv.backgroundColor = .white
        
        let sence = GameScene.init(size: skv.bounds.size)
        skv.presentScene(sence)
        bg.removeFromSuperview()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        var name = "ipad"
        let size = view.bounds.size
        if size.equalTo(.init(width: 320, height: 480)) {
            name = "4s"
        }else if size.equalTo(.init(width: 320, height: 568)) {
            name = "5s"
        }else if size.equalTo(.init(width: 375, height: 667)) {
            name = "6s"
        }else if size.equalTo(.init(width: 375, height: 812)) {
            name = "x"
        }else if size.equalTo(.init(width: 414, height: 736)) {
            name = "6p"
        }
        
        view.addSubview(bg)
        let image = UIImage.init(named: name)
        bg.image = image
        bg.snp.makeConstraints({ (make) in
            make.edges.equalTo(self.view)
        })
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

