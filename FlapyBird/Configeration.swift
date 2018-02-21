//
//  Configeration.swift
//  FlapyBird
//
//  Created by xgf on 2018/2/7.
//  Copyright © 2018年 xgf. All rights reserved.
//

import Foundation
import CoreGraphics

let  SKSpriteNodeBitMaskBack:  UInt32  =  (0x1 << 0)
let  SKSpriteNodeBitMaskBird:  UInt32  =  (0x1 << 1)
let  SKSpriteNodeBitMaskFloor: UInt32  =  (0x1 << 2)
let  SKSpriteNodeBitMaskPipe:  UInt32  =  (0x1 << 3)

let kPipeSpeed      = CGFloat(2.0)
let kBackSpeed      = CGFloat(1.0)
let kFloorSpeed     = CGFloat(1.0)
let kPipeGapx       = CGFloat(130.0)
let kMinPipeHeight  = CGFloat(60.0)
//上下两个管道之间的空白距离
let kPipeVoidGap    = CGFloat(120.0)
