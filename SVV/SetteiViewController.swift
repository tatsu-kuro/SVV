//
//  SetteiViewController.swift
//  SVV
//
//  Created by kuroda tatsuaki on 2019/07/20.
//  Copyright © 2019 tatsuaki.kuroda. All rights reserved.
//

import UIKit
//
//extension UIImage {
//    func rotatedBy(degree: CGFloat) -> UIImage {
//        let radian = -degree * CGFloat.pi / 180
//        UIGraphicsBeginImageContext(self.size)
//        let context = UIGraphicsGetCurrentContext()!
//        context.translateBy(x: self.size.width / 2, y: self.size.height / 2)
//        context.scaleBy(x: 1.0, y: -1.0)
//
//        context.rotate(by: radian)
//        context.draw(self.cgImage!, in: CGRect(x: -(self.size.width / 2), y: -(self.size.height / 2), width: self.size.width, height: self.size.height))
//
//        let rotatedImage = UIGraphicsGetImageFromCurrentImageContext()!
//        UIGraphicsEndImageContext()
//        return rotatedImage
//    }
//}
class SetteiViewController: UIViewController {
    var cirDiameter:CGFloat = 0
    var diameter:Int = 0
    var width:Int = 0
    var timer: Timer!
    var directionR:Bool=true
    var time=CFAbsoluteTimeGetCurrent()
    var tempdiameter:Int=0
    var circleNumber:Int = 0
    var backImageDots:Int = 0
    var tenTimesOnOff:Int = 1
    var locationX:Int = 0
    var dotsRotationSpeed:Int = 0
    @IBOutlet weak var exitButton: UIButton!
    @IBOutlet weak var circleDiameter: UILabel!
    @IBOutlet weak var VRLocationXSlider: UISlider!
    @IBOutlet weak var rotationSpeedSlider: UISlider!
    @IBOutlet weak var grayImage: UIImageView!
    @IBOutlet weak var randomImage1: UIImageView!
    @IBOutlet weak var randomImage2: UIImageView!
    @IBOutlet weak var randomImage: UIImageView!
    @IBAction func onBackImageSwitch(_ sender: UISegmentedControl) {
        UserDefaults.standard.set(sender.selectedSegmentIndex, forKey: "backImageDots")
        backImageDots=UserDefaults.standard.integer(forKey: "backImageDots")

        reDrawCirclesLines()//左行でbackImageDotsをセット
        print("backImageDots:",backImageDots)
        setRotationSpeedSliderOnOff()
    }
    func setDotsRotationSpeedText(){
        if Locale.preferredLanguages.first!.contains("ja"){
            backImageSwitch.setTitle("水玉 : " + String(dotsRotationSpeed), forSegmentAt: 1)
        }else{
            backImageSwitch.setTitle("dots : " + String(dotsRotationSpeed), forSegmentAt: 1)
        }
        rotationSpeedSlider.value=Float(dotsRotationSpeed+3)/6.0
    }
    @IBAction func onRotationSpeedSlider(_ sender: UISlider) {
        dotsRotationSpeed = Int(sender.value*6) - 3
        print("speed:",dotsRotationSpeed)
        UserDefaults.standard.set(dotsRotationSpeed, forKey: "dotsRotationSpeed")
        setDotsRotationSpeedText()
    }
    @IBOutlet weak var backImageSwitch: UISegmentedControl!
    
    @IBOutlet weak var circleNumberSwitch: UISegmentedControl!
    
    @IBAction func onTenTimeSwitch(_ sender: UISegmentedControl) {
        print("tentime:",sender.selectedSegmentIndex)
        tenTimesOnOff=sender.selectedSegmentIndex
        UserDefaults.standard.set(tenTimesOnOff,forKey: "tenTimesOnOff")
    }
    @IBOutlet weak var tenTimesSwitch: UISegmentedControl!
    @IBOutlet weak var lineWidthSlider: UISlider!
    @IBOutlet weak var diameterSlider: UISlider!
    @IBOutlet weak var lineWidth: UILabel!
    @IBAction func changeDiameter(_ sender: UISlider) {
        if Locale.preferredLanguages.first!.contains("ja"){
            circleDiameter.text="直径:" + String(Int(sender.value*10))
        }else{
            circleDiameter.text="Dia:" + String(Int(sender.value*10))
        }
        diameter=Int(sender.value*10)
        if(diameter != tempdiameter){
            UserDefaults.standard.set(diameter,forKey: "circleDiameter")
            reDrawCirclesLines()
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
 
    @IBAction func onChangeVRslider(_ sender: UISlider) {
        if circleNumber == 0{
            return
        }
        locationX=Int(sender.value)
        UserDefaults.standard.set(locationX,forKey: "VRLocationX")
        reDrawCirclesLines()
    }
    @IBAction func onLineWidthSlider(_ sender: UISlider) {
        if Locale.preferredLanguages.first!.contains("ja"){
            lineWidth.text="線幅:" + String(Int(sender.value*98)+1)
        }else{
            lineWidth.text="LineW:" + String(Int(sender.value*98)+1)
        }
        width=Int(sender.value*98)+1
        UserDefaults.standard.set(width,forKey: "lineWidth")
        reDrawCirclesLines()
    }
    func setRotationSpeedSliderOnOff()
    {
        if UserDefaults.standard.integer(forKey: "backImageDots")==1{
//            rotationSpeedSlider.alpha=1
            rotationSpeedSlider.isEnabled=true
            rotationSpeedSlider.tintColor=UIColor.systemGreen
//            rotationSpeedSlider.isHighlighted=true
           }else{
            rotationSpeedSlider.isEnabled=false
               rotationSpeedSlider.tintColor=UIColor.lightGray
        }

    }
    func setVRsliderOnOff(){
        if circleNumber==1{
            VRLocationXSlider.isEnabled=true
            VRLocationXSlider.tintColor=UIColor.systemGreen
           }else{
            VRLocationXSlider.isEnabled=false
               VRLocationXSlider.tintColor=UIColor.lightGray
        }
    }
    
    @IBAction func onCircleNumberSwitch(_ sender: UISegmentedControl) {
        circleNumber=sender.selectedSegmentIndex
        UserDefaults.standard.set(sender.selectedSegmentIndex, forKey: "circleNumber")
        reDrawCirclesLines()
        setVRsliderOnOff()
    }

    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func buttonsToFront(){
        self.view.bringSubviewToFront(exitButton)
        self.view.bringSubviewToFront(tenTimesSwitch)
        self.view.bringSubviewToFront(circleDiameter)
        self.view.bringSubviewToFront(lineWidth)
        self.view.bringSubviewToFront(diameterSlider)
        self.view.bringSubviewToFront(lineWidthSlider)
        self.view.bringSubviewToFront(VRLocationXSlider)
        self.view.bringSubviewToFront(circleNumberSwitch)
        self.view.bringSubviewToFront(backImageSwitch)
        self.view.bringSubviewToFront(rotationSpeedSlider)
    }
    func buttonsToBack(){
        self.view.sendSubviewToBack(exitButton)
        self.view.sendSubviewToBack(tenTimesSwitch)
        self.view.sendSubviewToBack(circleDiameter)
        self.view.sendSubviewToBack(lineWidth)
        self.view.sendSubviewToBack(diameterSlider)
        self.view.sendSubviewToBack(lineWidthSlider)
        self.view.sendSubviewToBack(VRLocationXSlider)
        self.view.sendSubviewToBack(circleNumberSwitch)
        self.view.sendSubviewToBack(backImageSwitch)
        self.view.sendSubviewToBack(rotationSpeedSlider)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        diameter=UserDefaults.standard.integer(forKey: "circleDiameter")
        width=UserDefaults.standard.integer(forKey: "lineWidth")
        locationX=UserDefaults.standard.integer(forKey:"VRLocationX")
        circleNumber=UserDefaults.standard.integer(forKey:"circleNumber")
        backImageDots=UserDefaults.standard.integer(forKey: "backImageDots")
        tenTimesOnOff=UserDefaults.standard.integer(forKey:"tenTimesOnOff")
        dotsRotationSpeed=UserDefaults.standard.integer(forKey: "dotsRotationSpeed")
        diameterSlider.value=Float(diameter)/10
        lineWidthSlider.value=Float(width-1)/98
        VRLocationXSlider.value=Float(locationX)
        if Locale.preferredLanguages.first!.contains("ja"){
            backImageSwitch.setTitle("白", forSegmentAt: 0)
//            backImageSwitch.setTitle("水玉 : -3", forSegmentAt: 1)
            tenTimesSwitch.setTitle("自動終了無し", forSegmentAt: 0)
            tenTimesSwitch.setTitle("10回で終了", forSegmentAt: 1)

            circleDiameter.text="直径:" + String(diameter)
            lineWidth.text="線幅:" + String(width)
        }else{
            backImageSwitch.setTitle("white", forSegmentAt: 0)
//            backImageSwitch.setTitle("dots : -3", forSegmentAt: 1)

            circleDiameter.text="Dia:" + String(diameter)
            lineWidth.text="lineW:" + String(width)
        }
        drawBack()
        drawLines(degree:0)
        setButtons()
        buttonsToFront()
        setVRsliderOnOff()
        setRotationSpeedSliderOnOff()
        setDotsRotationSpeedText()
        grayImage.image=UIImage(named: "gray")
        randomImage.image=UIImage(named:"random_gray")
        if backImageDots==1{
        randomImage1.image=UIImage(named: "random_gray")
        randomImage2.image=UIImage(named: "random_gray")
        }else{
            randomImage1.image=UIImage(named: "white_gray")
            randomImage2.image=UIImage(named: "white_gray")

        }
        timer = Timer.scheduledTimer(timeInterval: 1.0/60, target: self, selector: #selector(self.update), userInfo: nil, repeats: true)
     }
    func setLabelProperty(_ label:UILabel,x:CGFloat,y:CGFloat,w:CGFloat,h:CGFloat,_ color:UIColor){
        label.frame = CGRect(x:x, y:y, width: w, height: h)
        label.layer.borderColor = UIColor.black.cgColor
//        label.layer.borderWidth = 1.0
        label.layer.masksToBounds = true
        label.layer.cornerRadius = 5
        label.backgroundColor = color
    }
    func setSwitchProperty(_ label:UISegmentedControl,x:CGFloat,y:CGFloat,w:CGFloat,h:CGFloat){
        label.frame = CGRect(x:x, y:y, width: w, height: h)
        label.layer.borderColor = UIColor.black.cgColor
        label.layer.borderWidth = 1.0
//        label.layer.masksToBounds = true
//        label.layer.cornerRadius = 1
//        label.backgroundColor = UIColor.black
    }
    func setButtons(){
        
        /*
         UserDefaults.standard.set(topPadding,forKey: "topPadding")
         UserDefaults.standard.set(bottomPadding,forKey: "bottomPadding")
         UserDefaults.standard.set(leftPadding,forKey: "leftPadding")
         UserDefaults.standard.set(rightPadding,forKey: "rightPadding")

         */
        
        let leftPadding=CGFloat( UserDefaults.standard.integer(forKey:"leftPadding"))
        let rightPadding=CGFloat(UserDefaults.standard.integer(forKey:"rightPadding"))
        let topPadding=CGFloat(UserDefaults.standard.integer(forKey:"topPadding"))
        let bottomPadding=CGFloat(UserDefaults.standard.integer(forKey:"bottomPadding"))
        let ww=view.bounds.width-leftPadding-rightPadding
        let wh=view.bounds.height-topPadding-bottomPadding//topPadding is 0 anytime?
        let sp=ww/120
        let bw=(ww-sp*7)*2/15
        let bh=bw/3.5
        let by=wh-bh-sp
        let x0=leftPadding+sp
        let sliderWidth=(ww-3*bw-sp*7)/3
        VRLocationXSlider.frame =  CGRect(x:x0+sp+bw,y:by-bh-sp,width:sliderWidth,height: bh)
        setSwitchProperty(circleNumberSwitch, x: x0, y: by-bh-sp, w: bw, h: bh)
  
        setLabelProperty(lineWidth, x:x0+sp*2+sliderWidth+bw, y:by-bh-sp, w: bw, h: bh,UIColor.white)
        lineWidthSlider.frame = CGRect(x:x0+sp*3+sliderWidth+bw*2,y:by-bh-sp,width:sliderWidth,height:bh)

        diameterSlider.frame = CGRect(x:x0+sp*5+sliderWidth*2+bw*3,y:by-bh-sp,width:sliderWidth,height:bh)
        setLabelProperty(circleDiameter,x:x0+sp*4+sliderWidth*2+bw*2, y: by-bh-sp, w: bw, h: bh,UIColor.white)

        rotationSpeedSlider.frame = CGRect(x:x0+sp*2+sliderWidth+bw,y:by,width: sliderWidth,height:bh)
        setSwitchProperty(backImageSwitch, x: x0, y: by, w: sliderWidth+sp+bw, h: bh)
 
        setSwitchProperty(tenTimesSwitch, x: x0+sliderWidth*2+sp*3+bw, y: by, w: sliderWidth+sp+bw, h: bh)
        exitButton.frame = CGRect(x:x0+sp*5+sliderWidth*3+bw*2,y:by,width:bw,height: bh)
        exitButton.layer.cornerRadius=5
        circleDiameter.layer.masksToBounds = true
        circleDiameter.layer.cornerRadius = 5
        lineWidth.layer.masksToBounds = true
        lineWidth.layer.cornerRadius = 5
        tenTimesSwitch.selectedSegmentIndex=tenTimesOnOff
        circleNumberSwitch.selectedSegmentIndex=circleNumber
        backImageSwitch.selectedSegmentIndex=backImageDots
    }
 
    func reDrawCirclesLines(){
        buttonsToBack()
        self.view.layer.sublayers?.removeLast()
        print("sublayer2:",view.layer.sublayers?.count)
        drawBack()
        drawLines(degree: 0)
        buttonsToFront()
    }
    func killTimer(){
        if timer?.isValid == true {
            timer.invalidate()
        }
    }
    var currentDotsDegree:CGFloat=0
    @objc func update(tm: Timer) {
        if backImageDots==0{
            return
        }
        currentDotsDegree += 0.1*CGFloat(dotsRotationSpeed)
        reDrawCirclesLines()
    }
    func drawLines(degree:Int){//remove:Bool){
        //線を引く
        let ww=view.bounds.width
        let wh=view.bounds.height
        let x0L=ww*1/4 + CGFloat(locationX)
        let x0M=ww/2
        let x0R=ww*3/4 - CGFloat(locationX)
        let y0=wh/2
        let r=wh*(70+13*CGFloat(diameter))/400
        
        let dd:Double=3.14159/900
        let x1=CGFloat(Double(r)*sin(Double(degree)*dd))
        let y1=CGFloat(Double(r)*cos(Double(degree)*dd))
        let shapeLayer = CAShapeLayer.init()
        let uiPath = UIBezierPath()
        if circleNumber==1{
            uiPath.move(to:CGPoint.init(x: x0L+x1,y: y0 - y1))
            uiPath.addLine(to: CGPoint(x:x0L-x1,y:y0 + y1))
            uiPath.move(to:CGPoint.init(x: x0R+x1,y: y0 - y1))
            uiPath.addLine(to: CGPoint(x:x0R-x1,y:y0 + y1))
        }else{
            uiPath.move(to:CGPoint.init(x: x0M+x1,y: y0 - y1))
            uiPath.addLine(to: CGPoint(x:x0M-x1,y:y0 + y1))
        }
        uiPath.lineWidth=5.0
        shapeLayer.strokeColor = UIColor.blue.cgColor
        shapeLayer.lineWidth=CGFloat(width)/10.0
        shapeLayer.path = uiPath.cgPath
        self.view.layer.addSublayer(shapeLayer)
    }
 
    func drawCircle(x0:CGFloat,y0:CGFloat,r:CGFloat,color:CGColor){
           // --- 円を描画 ---
        let circleLayer = CAShapeLayer.init()
        let circleFrame = CGRect.init(x:x0-r,y:y0-r,width:r*2,height:r*2)
        circleLayer.frame = circleFrame
        circleLayer.strokeColor = UIColor.black.cgColor// 輪郭の色
        circleLayer.fillColor = color//UIColor.black.cgColor// 円の中の色
        circleLayer.lineWidth = 0.5// 輪郭の太さ
        circleLayer.path = UIBezierPath.init(ovalIn: CGRect.init(x: 0, y: 0, width: circleFrame.size.width, height: circleFrame.size.height)).cgPath
        self.view.layer.addSublayer(circleLayer)
    }
    var initDrawBackBackFlag:Bool=true
    
    func drawBack(){
        let ww=view.bounds.width
        let wh=view.bounds.height
        let backImageDots = getUserDefault(str:"backImageDots",ret:0)
        let circleDiameter=UserDefaults.standard.integer(forKey: "circleDiameter")
        
        // 四角形を描画
        if initDrawBackBackFlag==true{
            initDrawBackBackFlag=false
            grayImage.frame=CGRect(x:0,y:0,width: ww,height: wh)
//         }else{
//            self.view.bringSubviewToFront(grayImage!)
        }
        
        let r=wh*(70+13*CGFloat(circleDiameter))/400
        var x0=ww/2
        if circleNumber == 1{
            x0=ww/4 + CGFloat(locationX)
        }
        let y0=wh/2
        if backImageDots==0{
            
            randomImage1.image=UIImage(named: "white_gray")// randomImage.image?.rotatedBy(degree: currentDotsDegree)
            randomImage2.image=UIImage(named: "white_gray")//randomImage.image?.rotatedBy(degree: currentDotsDegree)
            randomImage1.frame=CGRect(x:x0-r,y:y0-r,width: r*2,height: r*2)
            self.view.bringSubviewToFront(randomImage1)
            if circleNumber==1{
                x0=ww*3/4 - CGFloat(locationX)
                randomImage2.frame=CGRect(x:x0-r,y:y0-r,width: r*2,height: r*2)
                self.view.bringSubviewToFront(randomImage2)
            }else{
                randomImage2.frame=CGRect(x:0,y:0,width: 0,height: 0)
            }
            
        }else{
            randomImage1.image=randomImage.image?.rotatedBy(degree: currentDotsDegree)
            randomImage2.image=randomImage1.image//randomImage.image?.rotatedBy(degree: currentDotsDegree)
            randomImage1.frame=CGRect(x:x0-r,y:y0-r,width: r*2,height: r*2)
            self.view.bringSubviewToFront(randomImage1)
            if circleNumber==1{
                x0=ww*3/4 - CGFloat(locationX)
                randomImage2.frame=CGRect(x:x0-r,y:y0-r,width: r*2,height: r*2)
                self.view.bringSubviewToFront(randomImage2)
            }else{
                randomImage2.frame=CGRect(x:0,y:0,width: 0,height: 0)
            }
        }
    }
}
