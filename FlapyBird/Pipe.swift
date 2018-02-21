//
//  Pipe.swift
//  FlapyBird
//
//  Created by xgf on 2018/2/6.
//  Copyright © 2018年 xgf. All rights reserved.
//

import UIKit
import SpriteKit

enum PipeType {
    case top
    case bottom
}

class Pipe: SKSpriteNode {
    var type:PipeType = .top
}
