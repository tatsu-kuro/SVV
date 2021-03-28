//
//  GameCont.swift
//  SVV
//
//  Created by 黒田建彰 on 2019/12/29.
//  Copyright © 2019 tatsuaki.kuroda. All rights reserved.
//

import UIKit
//import AVFoundation
//import MediaPlayer
import GameController
extension ViewController {
    
    @objc
    func handleControllerDidConnect(_ notification: Notification){
       print("ゲームコントローラーの接続が通知されました")

       guard let gameController = notification.object as? GCController else {
           return
       }
       registerGameController(gameController)
   }
   
   // Notification: Disconnection
    @objc
   func handleControllerDidDisconnect(_ notification: Notification){
       print("ゲームコントローラーの切断が通知されました")
       unregisterGameController()
        //Globalef=false
   }

   // Connection
   func registerGameController(_ gameController: GCController){
       print("ゲームコントローラーが接続されました")
//       print("Name: \(gameController.vendorName!)")
       //print("Category: \(gameController.productCategory)")
       var leftThumbstick:  GCControllerDirectionPad?
       var rightThumbstick: GCControllerDirectionPad?
       var directionPad:    GCControllerDirectionPad?
       var buttonA: GCControllerButtonInput?
       var buttonB: GCControllerButtonInput?
       var buttonX: GCControllerButtonInput?
       var buttonY: GCControllerButtonInput?
       if let gamepad = gameController.extendedGamepad {
           //print("isSnapshot: \(gameController.isSnapshot)")
           //print("isAttachedToDevice: \(gameController.isAttachedToDevice)")
           directionPad    = gamepad.dpad
           leftThumbstick  = gamepad.leftThumbstick
           rightThumbstick = gamepad.rightThumbstick
           buttonA = gamepad.buttonA
           buttonB = gamepad.buttonB
           buttonX = gamepad.buttonX
           buttonY = gamepad.buttonY
       }
       leftThumbstick!.valueChangedHandler = printDirectionPadValue("leftThumbstick")
       rightThumbstick!.valueChangedHandler = printDirectionPadValue("rightThumbstick")
       directionPad!.valueChangedHandler = printDirectionPadValue("directionPad")
       buttonA!.valueChangedHandler = printButtonValue("buttonA")
       buttonB!.valueChangedHandler = printButtonValue("buttonB")
       buttonX!.valueChangedHandler = printButtonValue("buttonX")
        buttonY!.valueChangedHandler = printButtonValue("buttonY")
        //Globalef=true
   }

   // Disconnection
   func unregisterGameController() {
       print("ゲームコントローラーが切断されました")
    //Globalef=false
   }
 
   // Closure: DirectionPad
   func printDirectionPadValue(_ text:String) -> GCControllerDirectionPadValueChangedHandler {
       return {(_ dpad: GCControllerDirectionPad, _ xValue: Float, _ yValue: Float) -> Void in
        if(text=="leftThumbstick"){//左右のxだけ利用する
            Globallx=xValue;
 //           Globally=yValue;
        }
        else if(text=="rightThumbstick"){
            Globallx=xValue;
 //           Globalrx=xValue;
 //           Globalry=yValue;
         }
         else if(text=="directionPad"){
            Globalpx=xValue;
 //           Globalpy=yValue;
         }
 //        print("\(text) x:\(xValue), y:\(-yValue)")
       }
   }
 
   // Closure: Button
   func printButtonValue(_ text:String) -> GCControllerButtonValueChangedHandler {
       return {(_ button: GCControllerButtonInput, _ value: Float, _ pressed: Bool) -> Void in
        if(text=="buttonA"){
            Globalav=value
        }else if(text=="buttonB"){
            Globalbv=value
        }else if(text=="buttonX"){
            Globalxv=value
        }else if(text=="buttonY"){
            Globalyv=value
             if(Globalmode==0){
                if(Globalyv == 0.0 && GlobalLastyv0 != 0.0){
                    GlobalLastyv0=Globalyv
                    self.startSVV(1)
                }
                GlobalLastyv0=Globalyv
            }
//            print("\(text) value:\(value), pressed:\(pressed)")
        }
      
    }
   }
}

