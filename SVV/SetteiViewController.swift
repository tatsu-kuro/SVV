//
//  SetteiViewController.swift
//  SVV
//
//  Created by kuroda tatsuaki on 2019/07/20.
//  Copyright © 2019 tatsuaki.kuroda. All rights reserved.
//

import UIKit

class SetteiViewController: UIViewController {
    var cirDiameter:CGFloat = 0
    var diameter:Int = 0
    var width:Int = 0
    var timer: Timer!
    var directionR:Bool=true
    var time=CFAbsoluteTimeGetCurrent()
    var degree:Int=0
    var tempdiameter:Int=0
    var VROnOff:Int = 0
    var tenTimesOnOff:Int = 1
    var locationX:Int = 0
    @IBOutlet weak var exitButton: UIButton!
    @IBOutlet weak var circleDiameter: UILabel!
    @IBOutlet weak var VRLocationXSlider: UISlider!
    
    @IBOutlet weak var tenTimesText: UILabel!
    @IBAction func onTenTimesSwitch(_ sender: Any) {
        if tenTimesSwitch.isOn{
            tenTimesOnOff=1
        }else{
            tenTimesOnOff=0
        }
        UserDefaults.standard.set(tenTimesOnOff, forKey: "tenTimesOnOff")
    }
    @IBOutlet weak var tenTimesSwitch: UISwitch!
//    @IBOutlet weak var VROnText: UILabel!
//    @IBOutlet weak var VROnSwitch: UISwitch!
    
    
    
    @IBOutlet weak var lineWidthSlider: UISlider!
    @IBOutlet weak var diameterSlider: UISlider!
    @IBOutlet weak var lineWidth: UILabel!
    @IBOutlet weak var useVRButton: UIButton!
    @IBAction func setDiameter(_ sender: UISlider) {
        circleDiameter.text="Diameter:" + String(Int(sender.value*10))
        diameter=Int(sender.value*10)
        if(diameter != tempdiameter){
            UserDefaults.standard.set(diameter,forKey: "circleDiameter")
//            drawBack(remove:true)
        }
        tempdiameter=diameter
    }
    func getUserDefault(str:String,ret:Int) -> Int{//getUserDefault_one
        if (UserDefaults.standard.object(forKey: str) != nil){//keyが設定してなければretをセット
            return UserDefaults.standard.integer(forKey:str)
        }else{
            UserDefaults.standard.set(ret, forKey: str)
            return ret
        }
    }
 
//    @IBAction func onVROnSwitch(_ sender: Any) {
//        if VROnSwitch.isOn == true{
//            VROnOff=1
//            VRLocationXSlider.isHidden=false
//        }else{
//            VROnOff=0
//            VRLocationXSlider.isHidden=true
//        }
//        UserDefaults.standard.set(VROnOff, forKey: "VROnOff")
//        drawBack(remove: true)
//    }
    
    @IBAction func onChangeVRslider(_ sender: UISlider) {
        if VROnOff == 0{
            return
        }
        locationX=Int(sender.value)
        UserDefaults.standard.set(locationX,forKey: "VRLocationX")
//        view.layer.sublayers?.removeLast()
//        drawBack(remove:true)
    }
    @IBAction func setWidth(_ sender: UISlider) {
        lineWidth.text="LineWidth:" + String(Int(sender.value*98)+1)
        width=Int(sender.value*98)+1
        UserDefaults.standard.set(width,forKey: "lineWidth")
    }
    @IBAction func onUseVRButton(_ sender: Any) {
        if VROnOff==0{
            VROnOff=1
            VRLocationXSlider.isEnabled=true// isHidden=false
            VRLocationXSlider.isHighlighted=true
        }else{
            VROnOff=0
            VRLocationXSlider.isEnabled=false// isHidden=true
            VRLocationXSlider.isHighlighted=false
        }
        UserDefaults.standard.set(VROnOff, forKey: "VROnOff")
//        drawBack(remove: true)

        VRLocationXSlider.isHighlighted=true
        
        
        
 /*       locationX=UserDefaults.standard.integer(forKey:"VRLocationX")
        if VROnOff == 0{
            diameter=7
            width=15
        }else{
            locationX=15
            VRLocationXSlider.value=Float(15)
            diameter=5
            width=15
        }
//        tenTimesSwitch.isOn=true
//        tenTimesOnOff=1
//        UserDefaults.standard.set(tenTimesOnOff,forKey: "tenTimesOnOff")
        UserDefaults.standard.set(diameter,forKey: "circleDiameter")
        UserDefaults.standard.set(width,forKey: "lineWidth")
        UserDefaults.standard.set(locationX,forKey: "VRLocationX")
        diameterSlider.value=Float(diameter)/10
        circleDiameter.text="Diameter:" + String(diameter)
        lineWidthSlider.value=Float(width-1)/98
        lineWidth.text="LineWidth:" + String(width)
        drawBack(remove:true)*/
    }

    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
    override var prefersStatusBarHidden: Bool {
        return true
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        diameter=UserDefaults.standard.integer(forKey: "circleDiameter")
        width=UserDefaults.standard.integer(forKey: "lineWidth")
        locationX=UserDefaults.standard.integer(forKey:"VRLocationX")
        VROnOff=UserDefaults.standard.integer(forKey:"VROnOff")
        tenTimesOnOff=UserDefaults.standard.integer(forKey:"tenTimesOnOff")
        diameterSlider.value=Float(diameter)/10
        lineWidthSlider.value=Float(width-1)/98
        VRLocationXSlider.value=Float(locationX)
        circleDiameter.text="Diameter:" + String(diameter)
        lineWidth.text="lineWidth:" + String(width)
        time=CFAbsoluteTimeGetCurrent()
        drawBackCircles()
        drawLine()
//        timer = Timer.scheduledTimer(timeInterval: 1.0/60, target: self, selector: #selector(self.update), userInfo: nil, repeats: true)
//        drawBack(remove: false)
        setButtons()
        self.view.bringSubviewToFront(useVRButton)
        self.view.bringSubviewToFront(exitButton)
        self.view.bringSubviewToFront(tenTimesText)
        self.view.bringSubviewToFront(tenTimesSwitch)
        self.view.bringSubviewToFront(circleDiameter)
        self.view.bringSubviewToFront(lineWidth)
        self.view.bringSubviewToFront(diameterSlider)
        self.view.bringSubviewToFront(lineWidthSlider)
//        self.view.bringSubviewToFront(VROnText)
        self.view.bringSubviewToFront(VRLocationXSlider)
    }
    func setButtons(){
        let leftPadding=CGFloat( UserDefaults.standard.integer(forKey:"leftPadding"))
        let rightPadding=CGFloat(UserDefaults.standard.integer(forKey:"rightPadding"))
        let topPadding=CGFloat(UserDefaults.standard.integer(forKey:"topPadding"))
        let bottomPadding=CGFloat(UserDefaults.standard.integer(forKey:"bottomPadding"))
        let ww=view.bounds.width-leftPadding-rightPadding
        let wh=view.bounds.height-topPadding-bottomPadding//topPadding is 0 anytime?
        let sp=ww/120
        let bw=(ww-sp*6)/5
        let bh=bw/3.5
        let by=wh-bh-sp
        let x0=leftPadding+sp
        let xCenter=view.bounds.width/2
//        let y0=topPadding+sp
        tenTimesSwitch.frame = CGRect(x:xCenter,y:by,width:bw/3,height: bh)
        //switchの大きさは規定されているので、作ってみてそのサイズを得て、再設定
        let switchWidth=tenTimesSwitch.frame.width
        let switchHeight=tenTimesSwitch.frame.height
        let d=(bh-switchHeight)/2
        tenTimesSwitch.frame = CGRect(x:xCenter+sp,y:by+d,width:switchWidth,height: bh)
        tenTimesText.frame = CGRect(x:xCenter+sp+switchWidth,y:by,width:x0+sp*2+bw*4-xCenter-switchWidth,height:bh)
//        VROnSwitch.frame = CGRect(x:leftPadding+sp,y:by-bh-sp,width:bw/3,height: bh)
//        VROnText.frame = CGRect(x:x0+sp*2+bw*2,y:by,width:bw,height:bh)
        VRLocationXSlider.frame = CGRect(x:x0,y:by,width:xCenter-bw-sp-x0,height: bh)
        circleDiameter.frame = CGRect(x:x0+sp*4+bw*4, y: by-bh-sp, width: bw, height: bh)
        diameterSlider.frame = CGRect(x:xCenter+sp,y:by-bh-sp,width:xCenter-bw-sp-x0,height:bh)
        lineWidth.frame = CGRect(x:xCenter-bw, y:by-bh-sp, width: bw, height: bh)
        lineWidthSlider.frame = CGRect(x:x0, y: by-bh-sp, width: xCenter-bw-sp-x0, height: bh)

//        logoImage.frame = CGRect(x:leftPadding+0,y:0,width:ww,height:logoh)
//        listButton.frame = CGRect(x:leftPadding+sp, y: by, width: bw, height: bh)
//        saveButton.frame = CGRect(x:leftPadding+sp*2+bw*1,y:by,width:bw,height:bh)
//        startButton.frame = CGRect(x:leftPadding+sp*3+bw*2, y: by, width: bw, height: bh)//440*150
        useVRButton.frame = CGRect(x:xCenter-bw,y:by,width:bw,height:bh)
        exitButton.frame = CGRect(x:x0+sp*4+bw*4,y:by,width:bw,height:bh)
//        titleImage.frame = CGRect(x:leftPadding+0, y: logoh, width: ww, height: wh-logoh-bh*3/2)
//        listButton.layer.cornerRadius=5
//        saveButton.layer.cornerRadius=5
//        startButton.layer.cornerRadius=5
        useVRButton.layer.cornerRadius=5
        exitButton.layer.cornerRadius=5
        tenTimesText.text="stop after 10"
        tenTimesText.layer.cornerRadius=5
        tenTimesText.layer.borderWidth = 1.0
        tenTimesText.layer.masksToBounds = true
        tenTimesText.layer.cornerRadius = 5
        if VROnOff==0{
            VRLocationXSlider.isEnabled=false// isHidden=true
//            VROnSwitch.isOn=false
        }else{
            VRLocationXSlider.isEnabled=true// isHidden=false
//            VROnSwitch.isOn=true
        }
        if tenTimesOnOff==0{
            tenTimesSwitch.isOn=false
        }else{
            tenTimesSwitch.isOn=true
        }
    }
    func setButton_sold(){
//        let left=CGFloat( UserDefaults.standard.integer(forKey:"leftPadding"))
//        let right=CGFloat(UserDefaults.standard.integer(forKey:"rightPadding"))
//        let top=CGFloat(UserDefaults.standard.integer(forKey:"topPadding"))
//        let bottom=CGFloat(UserDefaults.standard.integer(forKey:"bottomPadding"))
//        let ww=view.bounds.width - left - right
//        let wh=view.bounds.height - top - bottom

        let ww=view.bounds.width
        let wh=view.bounds.height
        let x0=(ww/2+wh/2)+(ww-ww/2-wh/2)/10
        let bw=(ww-ww/2-wh/2)*8/10
        let bh=wh/10
        let sp=bh/11
        
//        VROnSwitch.frame = CGRect(x:x0,y:sp*3,width:bw/3,height: bh)
//        VROnText.frame = CGRect(x:x0+bw/2,y:sp*3,width:bw/2,height:bh)
        VRLocationXSlider.frame = CGRect(x:x0,y:bh*1+sp,width:bw,height: bh)
        tenTimesSwitch.frame = CGRect(x:x0,y:bh*2+sp*3,width:bw/3,height: bh)
        tenTimesText.frame = CGRect(x:x0+bw/2,y:bh*2+sp*3,width:bw/2,height:bh)
        circleDiameter.frame = CGRect(x:x0, y: bh*3+sp*5, width: bw, height: bh)
        diameterSlider.frame = CGRect(x:x0,y:bh*4+sp*3,width:bw,height:bh)
        lineWidth.frame = CGRect(x:x0, y:bh*5+sp*7, width: bw, height: bh)
        lineWidthSlider.frame = CGRect(x:x0, y: bh*6+sp*5, width: bw, height: bh)
        useVRButton.frame = CGRect(x:x0, y: bh*7+sp*7, width: bw, height: bh)
        exitButton.frame = CGRect(x:x0,y:bh*8+sp*8,width:bw,height:bh)
        exitButton.layer.cornerRadius=5
        useVRButton.layer.cornerRadius=5
        if VROnOff==0{
            VRLocationXSlider.isHidden=true
//            VROnSwitch.isOn=false
        }else{
            VRLocationXSlider.isHidden=false
//            VROnSwitch.isOn=true
        }
        if tenTimesOnOff==0{
            tenTimesSwitch.isOn=false
        }else{
            tenTimesSwitch.isOn=true
        }
    }
    @objc func update(tm: Timer) {
        if(degree>100){
            directionR=false
        }else if(degree < -100){
            directionR=true
        }
        if(directionR){
            degree += 2
        }else{
            degree -= 2
        }
        drawLine()
    }
    
    func drawLine(){//remove:Bool){
        //線を引く
//        if remove==true{
//            view.layer.sublayers?.removeLast()
//        }
        let ww=view.bounds.width
        let wh=view.bounds.height
        let x0M=ww/2
        let x0L=ww*1/4 + CGFloat(locationX)
        let x0R=ww*3/4 - CGFloat(locationX)
        let y0=wh/2
        let r=wh*(70+13*CGFloat(diameter))/400
        let shapeLayer = CAShapeLayer.init()
        let uiPath = UIBezierPath()
        if VROnOff==1{
        uiPath.move(to:CGPoint.init(x: x0L,y: y0 - r))
        uiPath.addLine(to: CGPoint(x:x0L,y:y0 + r))
//        uiPath.move(to:CGPoint.init(x: x0M,y: y0 - r))
//        uiPath.addLine(to: CGPoint(x:x0M,y:y0 + r))
        uiPath.move(to:CGPoint.init(x: x0R,y: y0 - r))
        uiPath.addLine(to: CGPoint(x:x0R,y:y0 + r))
        }else{
            uiPath.move(to:CGPoint.init(x: x0M,y: y0 - r))
            uiPath.addLine(to: CGPoint(x:x0M,y:y0 + r))

        }
        uiPath.lineWidth=5.0
        shapeLayer.strokeColor = UIColor.blue.cgColor
        shapeLayer.lineWidth=CGFloat(width)/10.0
        shapeLayer.path = uiPath.cgPath
        self.view.layer.addSublayer(shapeLayer)
    }
    func drawBackCircles(){//remove:Bool){
//        if remove==true{
//            view.layer.sublayers?.removeLast()
//         }
        let ww=view.bounds.width
        let wh=view.bounds.height
        // 四角形を描画
        let rectangleLayer = CAShapeLayer.init()
        let rectangleFrame = CGRect.init(x: 0, y: 0, width:ww/*/2+wh/2*/, height: wh)
        rectangleLayer.frame = rectangleFrame
        rectangleLayer.strokeColor = UIColor.black.cgColor// 輪郭の色
        rectangleLayer.fillColor = UIColor.black.cgColor// 四角形の中の色
        rectangleLayer.lineWidth = 2.5
        
        rectangleLayer.path = UIBezierPath.init(rect: CGRect.init(x: 0, y: 0, width: rectangleFrame.size.width, height: rectangleFrame.size.height)).cgPath
        self.view.layer.addSublayer(rectangleLayer)
        // --- 円を描画 ---
        if VROnOff==1{
            draw1circle(lmr: 1, isWhite: false)
            draw1circle(lmr: 0, isWhite: true)
            draw1circle(lmr: 2, isWhite: true)
        }else{
            draw1circle(lmr: 0, isWhite: false)
            draw1circle(lmr: 2, isWhite: false)
            draw1circle(lmr: 1, isWhite: true)
        }
   /*     let circleLayerL = CAShapeLayer.init()
        let circleLayerM = CAShapeLayer.init()
        let circleLayerR = CAShapeLayer.init()
        let r=wh*(70+13*CGFloat(diameter))/200
        let x0M=ww/2-r/2
        let x0L=ww/4 + CGFloat(locationX) - r/2
        let x0R=ww*3/4 - CGFloat(locationX) - r/2
        let y0=wh/2-r/2
        //print(r,x0,y0)
        var circleFrame = CGRect.init(x:x0L,y:y0,width:r,height:r)
        circleLayerL.frame = circleFrame
        circleLayerL.strokeColor = UIColor.black.cgColor// 輪郭の色
        if VROnOff==1{
            circleLayerL.fillColor = UIColor.white.cgColor// 円の中の色
        }else{
            circleLayerL.fillColor = UIColor.black.cgColor// 円の中の色
        }
        circleLayerL.lineWidth = 0.5// 輪郭の太さ
        circleLayerL.path = UIBezierPath.init(ovalIn: CGRect.init(x: 0, y: 0, width: circleFrame.size.width, height: circleFrame.size.height)).cgPath
        self.view.layer.addSublayer(circleLayerL)
        circleFrame = CGRect.init(x:x0M,y:y0,width:r,height:r)
        circleLayerM.frame = circleFrame
        circleLayerM.strokeColor = UIColor.black.cgColor// 輪郭の色
        if VROnOff==1{
        circleLayerM.fillColor = UIColor.black.cgColor// 円の中の色
        }else{
            circleLayerM.fillColor = UIColor.white.cgColor// 円の中の色
        }
        circleLayerM.lineWidth = 0.5// 輪郭の太さ
        circleLayerM.path = UIBezierPath.init(ovalIn: CGRect.init(x: 0, y: 0, width: circleFrame.size.width, height: circleFrame.size.height)).cgPath
        self.view.layer.addSublayer(circleLayerM)
        circleFrame = CGRect.init(x:x0R,y:y0,width:r,height:r)
        circleLayerR.frame = circleFrame
        circleLayerR.strokeColor = UIColor.black.cgColor// 輪郭の色
        if VROnOff==1{
            circleLayerR.fillColor = UIColor.white.cgColor// 円の中の色
        }else{
            circleLayerR.fillColor = UIColor.black.cgColor// 円の中の色
        }
        circleLayerR.lineWidth = 0.5// 輪郭の太さ
        circleLayerR.path = UIBezierPath.init(ovalIn: CGRect.init(x: 0, y: 0, width: circleFrame.size.width, height: circleFrame.size.height)).cgPath
        self.view.layer.addSublayer(circleLayerR)
*/
        //線を引く
//        let shapeLayer = CAShapeLayer.init()
//        self.view.layer.addSublayer(shapeLayer)
    }
    func draw1circle(lmr:Int,isWhite:Bool){
        let ww=view.bounds.width
        let wh=view.bounds.height
        let circleLayer = CAShapeLayer.init()
        let r=wh*(70+13*CGFloat(diameter))/200
        var x0:CGFloat=0
        if lmr==0{//left
            x0=ww/4 + CGFloat(locationX) - r/2
        }else if lmr==1{//mid
            x0=ww/2-r/2
        }else{//right
            x0=ww*3/4 - CGFloat(locationX) - r/2
        }
//        let x0M=ww/2-r/2
//        let x0L=ww/4 + CGFloat(locationX) - r/2
//        let x0R=ww*3/4 - CGFloat(locationX) - r/2
        let y0=wh/2-r/2
        //print(r,x0,y0)
        let circleFrame = CGRect.init(x:x0,y:y0,width:r,height:r)
        circleLayer.frame = circleFrame
        circleLayer.strokeColor = UIColor.black.cgColor// 輪郭の色
        if isWhite{
            circleLayer.fillColor = UIColor.white.cgColor// 円の中の色
        }else{
            circleLayer.fillColor = UIColor.black.cgColor// 円の中の色
        }
        circleLayer.lineWidth = 0.5// 輪郭の太さ
        circleLayer.path = UIBezierPath.init(ovalIn: CGRect.init(x: 0, y: 0, width: circleFrame.size.width, height: circleFrame.size.height)).cgPath
        self.view.layer.addSublayer(circleLayer)
    }

}
