//
//  MotionManager.swift
//  SVV
//
//  Created by 黒田建彰 on 2025/02/02.
//  Copyright © 2025 tatsuaki.kuroda. All rights reserved.
//

import Foundation
import CoreMotion

class MotionManager {
    static let shared = MotionManager()  // シングルトンインスタンス
    let motionManager = CMMotionManager()

    private init() {} // 他の場所でインスタンスを作れないようにする
    // 加速度センサーを開始するメソッド
      func startAccelerometerUpdates(handler: @escaping (CMAcceleration) -> Void) {
          if motionManager.isAccelerometerAvailable {
              motionManager.startAccelerometerUpdates(to: OperationQueue.main) { (data, error) in
                  if let acceleration = data?.acceleration {
                      handler(acceleration)
                  }
              }
          }
      }
    // 加速度センサーを停止するメソッド
        func stopAccelerometerUpdates() {
            motionManager.stopAccelerometerUpdates()
        }
}

