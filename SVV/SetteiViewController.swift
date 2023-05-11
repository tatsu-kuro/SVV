//
//  SetteiViewController.swift
//  SVV
//
//  Created by kuroda tatsuaki on 2019/07/20.
//  Copyright © 2019 tatsuaki.kuroda. All rights reserved.
//

import UIKit
extension UIImage {
    
//    func composite(image: UIImage) -> UIImage? {
//
//        UIGraphicsBeginImageContextWithOptions(self.size, false, 0)
//        self.draw(in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
//
//        // 画像を真ん中に重ねる
//        let rect = CGRect(x: (self.size.width - image.size.width)/2,
//                          y: (self.size.height - image.size.height)/2,
//                          width: image.size.width,
//                          height: image.size.height)
//        image.draw(in: rect)
//
//        let image = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()
//
//        return image
//    }
//
    /*
     画像をResizeするクラスメソッド.
     */
    class func ResizeÜIImage(image : UIImage,width : CGFloat, height : CGFloat)-> UIImage!{
        
        // 指定された画像の大きさのコンテキストを用意.
        UIGraphicsBeginImageContext(CGSize(width: width, height: height))
        
        // コンテキストに画像を描画する.
        image.draw(in: CGRect(x: 0, y: 0, width: width, height: height))
        
        // コンテキストからUIImageを作る.
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        
        // コンテキストを閉じる.
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    /*
     画像を合成するクラスメソッド.
     */
    class func ComposeUIImage(UIImageArray : [UIImage], width: CGFloat, height : CGFloat)->UIImage!{
        
        // 指定された画像の大きさのコンテキストを用意.
        UIGraphicsBeginImageContext(CGSize(width: width, height: height))
        
        // UIImageのある分回す.
        for image : UIImage in UIImageArray {
            
            // コンテキストに画像を描画する.
            image.draw(in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
        }
        
        // コンテキストからUIImageを作る.
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        
        // コンテキストを閉じる.
        UIGraphicsEndImageContext()
        
        return newImage
        
    }

    class ViewController: UIViewController {

   
        override func viewDidLoad() {

            // 1つ目のUIImageを作る.
            var myImage1 = UIImage(named: "sample1")!

            // リサイズする.
            myImage1 = UIImage.ResizeÜIImage(image: myImage1,width: self.view.frame.maxX, height: self.view.frame.maxY)

            // 2つ目のUIImageを作る.
            var myImage2 = UIImage(named: "sample2")!

            // リサイズする.
            myImage2 = UIImage.ResizeÜIImage(image: myImage2,width: self.view.frame.midX, height: self.view.frame.midY)

            // 画像を合成する.
            let ComposedImage = UIImage.ComposeUIImage(UIImageArray: [myImage1, myImage2], width: self.view.frame.maxX, height: self.view.frame.maxY)

            // UIImageViewに合成されたUIImageを指定する.
            let myImageView = UIImageView(image: ComposedImage)

            self.view.addSubview(myImageView)
        }
    }

}
class SetteiViewController: UIViewController {
    enum MenuType: CaseIterable {
        case SVV
        case Display
        
        var title: String {
            switch self {
            case .SVV:
                return "SVV"
            case .Display:
                return "Display"
            }
        }
    }
  
    @IBOutlet private weak var SVVDisplayButton: UIButton!
    private func configureMenu() {
        let actions = MenuType.allCases
            .compactMap { type in
                UIAction(
                    title: type.title,
                    state: type == selectedMenuType ? .on : .off,
                    handler: { _ in
                        self.selectedMenuType = type
                        self.configureMenu()
                    })
            }
        SVVDisplayButton.menu = UIMenu(title: "", options: .displayInline, children: actions)
        SVVDisplayButton.showsMenuAsPrimaryAction = true
        SVVDisplayButton.setTitle(selectedMenuType.title, for: .normal)
        if selectedMenuType.title=="SVV"{
            SVVorDisplay=0
            UserDefaults.standard.set(SVVorDisplay,forKey: "SVVorDisplay")
            if SVVModeType==0{
                rotationSpeedSlider.isEnabled=false
                rotationSpeedSlider.tintColor=UIColor.systemGray
            }
        }else{
            SVVorDisplay=1
            UserDefaults.standard.set(SVVorDisplay,forKey: "SVVorDisplay")
            rotationSpeedSlider.isEnabled=true
//            rotationSpeedSlider.minimumTrackTintColor
            rotationSpeedSlider.tintColor=UIColor.systemGreen
        }
        setButtons()
        setBackImages()
        print("backImageType,SVVorDisplay:",SVVModeType,SVVorDisplay)
    }
    func pasteImage(orgImg:UIImage,posx:CGFloat) -> UIImage {
        // イメージ処理の開始]
        //mailの時は直に貼り付ける
        UIGraphicsBeginImageContext(orgImg.size)
        orgImg.draw(at:CGPoint.zero)
        let drawPath = UIBezierPath()
        let str = "2sec/scale"
        str.draw(at: CGPoint(x: posx, y: 50), withAttributes: [
                    NSAttributedString.Key.foregroundColor : UIColor.black,
                    NSAttributedString.Key.font : UIFont.monospacedDigitSystemFont(ofSize: 150, weight: UIFont.Weight.regular)])
    
        drawPath.stroke()
        // イメージコンテキストからUIImageを作る
        let image = UIGraphicsGetImageFromCurrentImageContext()
        // イメージ処理の終了
        UIGraphicsEndImageContext()
        return image!
    }
    @IBOutlet weak var samplingLabel: UILabel!
    @IBOutlet weak var fpsSwitch: UISegmentedControl!
    @IBOutlet weak var depthSlider: UISlider!
    @IBOutlet weak var depthLabel: UILabel!
    @IBOutlet weak var displayModeSwitch: UISegmentedControl!
    private var selectedMenuType = MenuType.SVV
    @IBOutlet weak var stop10Switch: UISwitch!
    @IBOutlet weak var lineMovingLabel: UILabel!
    @IBOutlet weak var lineMovingSwitch: UISwitch!
    @IBOutlet weak var stop10Label: UILabel!
    @IBOutlet weak var gyroOnSwitch: UISwitch!
    @IBOutlet weak var gyroOnLabel: UILabel!
    @IBOutlet weak var speedLabel: UILabel!
    var circleDiameter:Int = 0
    var verticalLineWidth:Int = 0
    var timer: Timer!
    var directionR:Bool=true
    var time=CFAbsoluteTimeGetCurrent()
    var tempdiameter:Int=0
    var circleNumber:Int = 0
    var SVVModeType:Int = 0
    var displayModeType:Int = 0
    var tenTimesOnOff:Int = 1
    var locationX:Int = 0
    var dotsRotationSpeed:Int = 0
    var lineMovingOnOff:Int = 0
    var gyroOnOff:Int = 0
    var fps:Int = 0
    var depth3D:Int = 0
    var SVVorDisplay:Int = 0
    @IBOutlet weak var exitButton: UIButton!
    @IBOutlet weak var circleDiameterLabel: UILabel!
    @IBOutlet weak var VRLocationXSlider: UISlider!
    @IBOutlet weak var rotationSpeedSlider: UISlider!
    @IBOutlet weak var grayImage: UIImageView!
    @IBOutlet weak var randomImage1: UIImageView!
    @IBOutlet weak var randomImage2: UIImageView!
 //   @IBOutlet weak var randomImage: UIImageView!
    var backImage:UIImage!

    @IBAction func onLineMovingSwitch(_ sender: UISwitch) {
        if sender.isOn{
            lineMovingOnOff=1
        }else{
            lineMovingOnOff=0
        }
        UserDefaults.standard.set(lineMovingOnOff,forKey: "lineMovingOnOff")
    }

    @IBAction func onGyroOnSwitch(_ sender: UISwitch) {
        if sender.isOn{
            gyroOnOff=1
        }else{
            gyroOnOff=0
        }
        UserDefaults.standard.set(gyroOnOff,forKey: "gyroOnOff")
    }
    @IBAction func onFpsSwitch(_ sender: UISegmentedControl) {
        fps=sender.selectedSegmentIndex
        UserDefaults.standard.set(fps, forKey: "fps")
    }
    
    @IBAction func onDisplayModeSwitch(_ sender: UISegmentedControl) {
        UserDefaults.standard.set(sender.selectedSegmentIndex, forKey: "displayModeType")
        displayModeType=sender.selectedSegmentIndex
        setBackImages()
    }
    @IBAction func onBackImageSwitch(_ sender: UISegmentedControl) {
        UserDefaults.standard.set(sender.selectedSegmentIndex, forKey: "SVVModeType")
        SVVModeType=sender.selectedSegmentIndex//UserDefaults.standard.integer(forKey: "backImageType")
        setBackImages()
        reDrawCirclesLines()//左行でbackImageTypeをセット
        print("SVVModeType:",SVVModeType)
        setRotationSpeedSliderOnOff()
    }
//    func setDotsRotationSpeedText(){
//        if Locale.preferredLanguages.first!.contains("ja"){
//            backImageSwitch.setTitle("背景白", forSegmentAt: 0)
//            backImageSwitch.setTitle("半玉:" + String(dotsRotationSpeed*5), forSegmentAt: 1)
//            backImageSwitch.setTitle("水玉:" + String(dotsRotationSpeed*5), forSegmentAt: 2)
//        }else{
//            backImageSwitch.setTitle("white", forSegmentAt: 0)
//            backImageSwitch.setTitle("half:" + String(dotsRotationSpeed*5), forSegmentAt: 1)
//            backImageSwitch.setTitle("dots:" + String(dotsRotationSpeed*5), forSegmentAt: 2)
//        }
//
//        rotationSpeedSlider.value=Float(dotsRotationSpeed+72)/144
//    }
//    func setSwitchSpeedText(){
//        if Locale.preferredLanguages.first!.contains("ja"){
//            backImageSwitch.setTitle("背景白", forSegmentAt: 0)
//            backImageSwitch.setTitle("半水玉", forSegmentAt: 1)
//            backImageSwitch.setTitle("水玉", forSegmentAt: 2)
//            displayModeSwitch.setTitle("水玉回転", forSegmentAt: 0)
//            displayModeSwitch.setTitle("水玉左右", forSegmentAt: 1)
//            displayModeSwitch.setTitle("帯左右", forSegmentAt: 2)
//        }else{
//            backImageSwitch.setTitle("white", forSegmentAt: 0)
//            backImageSwitch.setTitle("dotsHalf", forSegmentAt: 1)
//            backImageSwitch.setTitle("dotsAll", forSegmentAt: 2)
//            displayModeSwitch.setTitle("dots:Rota", forSegmentAt: 0)
//            displayModeSwitch.setTitle("dots:LtRt", forSegmentAt: 1)
//            displayModeSwitch.setTitle("band:LtRt", forSegmentAt: 2)
//        }
//        rotationSpeedSlider.value=Float(dotsRotationSpeed+72)/144
//    }
    @IBAction func onDepthSlider(_ sender: UISlider) {
        depth3D = Int(sender.value*20) - 10
        print("depth:",depth3D)
        UserDefaults.standard.set(depth3D, forKey: "depth3D")
//        setDotsRotationSpeedText()
        depthLabel.text="3Ddepth:" + String(depth3D)
//        d.value=Float(depth3D+10)/20
    }
    
    @IBAction func onRotationSpeedSlider(_ sender: UISlider) {
        dotsRotationSpeed = Int(sender.value*144) - 72
        print("speed:",dotsRotationSpeed)
        UserDefaults.standard.set(dotsRotationSpeed, forKey: "dotsRotationSpeed")
//        setDotsRotationSpeedText()
        speedLabel.text=String(dotsRotationSpeed*5)
//        rotationSpeedSlider.value=Float(dotsRotationSpeed+72)/144
        
    }
    @IBOutlet weak var backImageSwitch: UISegmentedControl!
    
    @IBOutlet weak var circleNumberSwitch: UISegmentedControl!
    
    @IBAction func onStop10Switch(_ sender: UISwitch) {
        if sender.isOn{
            tenTimesOnOff=1
        }else{
            tenTimesOnOff=0
        }
        UserDefaults.standard.set(tenTimesOnOff,forKey: "tenTimesOnOff")
    }
    @IBOutlet weak var lineWidthSlider: UISlider!
    @IBOutlet weak var diameterSlider: UISlider!
    @IBOutlet weak var lineWidthLabel: UILabel!
    @IBAction func changeDiameter(_ sender: UISlider) {
        if Locale.preferredLanguages.first!.contains("ja"){
            circleDiameterLabel.text="直径:" + String(1+Int(sender.value*49))
        }else{
            circleDiameterLabel.text="Dia:" + String(1+Int(sender.value*49))
        }
        circleDiameter=Int(sender.value*49)
        radius=wh*(70+13*CGFloat(circleDiameter)/5)/400
        x0Right=ww/4 + CGFloat(locationX)
        x0Left=ww*3/4 - CGFloat(locationX)

        if(circleDiameter != tempdiameter){
            UserDefaults.standard.set(circleDiameter,forKey: "circleDiameter")
            reDrawCirclesLines()
        }
        tempdiameter=circleDiameter
   
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
        radius=wh*(70+13*CGFloat(circleDiameter)/5)/400
        x0Right=ww/4 + CGFloat(locationX)
        x0Left=ww*3/4 - CGFloat(locationX)

        UserDefaults.standard.set(locationX,forKey: "VRLocationX")
        reDrawCirclesLines()
    }
    @IBAction func onLineWidthSlider(_ sender: UISlider) {
        if Locale.preferredLanguages.first!.contains("ja"){
            lineWidthLabel.text="線幅:" + String(Int(sender.value*9))
        }else{
            lineWidthLabel.text="LineW:" + String(Int(sender.value*9))
        }
        verticalLineWidth=Int(sender.value*9)
        UserDefaults.standard.set(verticalLineWidth,forKey: "lineWidth")
        reDrawCirclesLines()
    }
    func setRotationSpeedSliderOnOff()
    {
        if SVVModeType>0 || SVVorDisplay==1{
            rotationSpeedSlider.isEnabled=true
            rotationSpeedSlider.tintColor=UIColor.systemGreen
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
        if circleNumber==0{
            randomImage2.isHidden=true
        }else{
            randomImage2.isHidden=false
        }
//        randomImage.isHidden=true

    }

    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func buttonsToFront(){
        self.view.bringSubviewToFront(fpsSwitch)
        self.view.bringSubviewToFront(exitButton)
        self.view.bringSubviewToFront(circleDiameterLabel)
        self.view.bringSubviewToFront(lineWidthLabel)
        self.view.bringSubviewToFront(stop10Label)
        self.view.bringSubviewToFront(stop10Switch)
        self.view.bringSubviewToFront(lineMovingSwitch)
        self.view.bringSubviewToFront(lineMovingLabel)
        self.view.bringSubviewToFront(SVVDisplayButton)
        self.view.bringSubviewToFront(diameterSlider)
        self.view.bringSubviewToFront(lineWidthSlider)
        self.view.bringSubviewToFront(VRLocationXSlider)
        self.view.bringSubviewToFront(circleNumberSwitch)
        self.view.bringSubviewToFront(backImageSwitch)
        self.view.bringSubviewToFront(rotationSpeedSlider)
        self.view.bringSubviewToFront(displayModeSwitch)
        self.view.bringSubviewToFront(speedLabel)
        self.view.bringSubviewToFront(gyroOnSwitch)
        self.view.bringSubviewToFront(gyroOnLabel)
        self.view.bringSubviewToFront(depthLabel)
        self.view.bringSubviewToFront(depthSlider)
        self.view.bringSubviewToFront(samplingLabel)
     }
    func buttonsToBack(){
        self.view.sendSubviewToBack(exitButton)
        self.view.sendSubviewToBack(circleDiameterLabel)
        self.view.sendSubviewToBack(lineWidthLabel)
        self.view.sendSubviewToBack(stop10Label)
        self.view.sendSubviewToBack(stop10Switch)
        self.view.sendSubviewToBack(lineMovingSwitch)
        self.view.sendSubviewToBack(lineMovingLabel)
        self.view.sendSubviewToBack(SVVDisplayButton)
        self.view.sendSubviewToBack(diameterSlider)
        self.view.sendSubviewToBack(lineWidthSlider)
        self.view.sendSubviewToBack(VRLocationXSlider)
        self.view.sendSubviewToBack(circleNumberSwitch)
        self.view.sendSubviewToBack(backImageSwitch)
        self.view.sendSubviewToBack(rotationSpeedSlider)
        self.view.sendSubviewToBack(displayModeSwitch)
        self.view.sendSubviewToBack(gyroOnSwitch)
        self.view.sendSubviewToBack(gyroOnLabel)
        self.view.sendSubviewToBack(speedLabel)
        self.view.sendSubviewToBack(depthLabel)
        self.view.sendSubviewToBack(depthSlider)
        self.view.sendSubviewToBack(fpsSwitch)
        self.view.sendSubviewToBack(samplingLabel)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        circleDiameter=UserDefaults.standard.integer(forKey: "circleDiameter")
        verticalLineWidth=UserDefaults.standard.integer(forKey: "lineWidth")
        locationX=UserDefaults.standard.integer(forKey:"VRLocationX")
        circleNumber=UserDefaults.standard.integer(forKey:"circleNumber")
        SVVModeType=UserDefaults.standard.integer(forKey: "SVVModeType")
        tenTimesOnOff=UserDefaults.standard.integer(forKey:"tenTimesOnOff")
        lineMovingOnOff=UserDefaults.standard.integer(forKey: "lineMovingOnOff")
        SVVorDisplay=UserDefaults.standard.integer(forKey: "SVVorDisplay")
        dotsRotationSpeed=UserDefaults.standard.integer(forKey: "dotsRotationSpeed")
        gyroOnOff=UserDefaults.standard.integer(forKey: "gyroOnOff")
        fps=UserDefaults.standard.integer(forKey: "fps")
        depth3D=UserDefaults.standard.integer(forKey: "depth3D")
        displayModeType=UserDefaults.standard.integer(forKey: "displayModeType")
        diameterSlider.value=Float(circleDiameter)/49
        lineWidthSlider.value=Float(verticalLineWidth)/9
        VRLocationXSlider.value=Float(locationX)
        if Locale.preferredLanguages.first!.contains("ja"){
            backImageSwitch.setTitle("背景白", forSegmentAt: 0)
            stop10Label.text="10回で終了"
            circleDiameterLabel.text="直径:" + String(circleDiameter+1)
            lineWidthLabel.text="線幅:" + String(verticalLineWidth)
            lineMovingLabel.text="垂直線：動く"
            backImageSwitch.setTitle("背景白", forSegmentAt: 0)
            backImageSwitch.setTitle("半水玉", forSegmentAt: 1)
            backImageSwitch.setTitle("水玉", forSegmentAt: 2)
            displayModeSwitch.setTitle("水玉回転", forSegmentAt: 0)
            displayModeSwitch.setTitle("水玉水平", forSegmentAt: 1)
            displayModeSwitch.setTitle("水玉上下", forSegmentAt: 2)
            displayModeSwitch.setTitle("白帯水平", forSegmentAt: 3)
            displayModeSwitch.setTitle("白帯垂直", forSegmentAt: 4)

        }else{
            backImageSwitch.setTitle("back white", forSegmentAt: 0)
            stop10Label.text="stop at 10 times"
            circleDiameterLabel.text="Dia:" + String(circleDiameter+1)
            lineWidthLabel.text="lineW:" + String(verticalLineWidth)
            lineMovingLabel.text="line : moving"
            backImageSwitch.setTitle("white", forSegmentAt: 0)
            backImageSwitch.setTitle("dotsHalf", forSegmentAt: 1)
            backImageSwitch.setTitle("dotsAll", forSegmentAt: 2)
            displayModeSwitch.setTitle("dots:R.", forSegmentAt: 0)
            displayModeSwitch.setTitle("dots:H.", forSegmentAt: 1)
            displayModeSwitch.setTitle("dots:V.", forSegmentAt: 2)
            displayModeSwitch.setTitle("band:H.", forSegmentAt: 3)
            displayModeSwitch.setTitle("band:V.", forSegmentAt: 4)
        }
        if SVVorDisplay==0{
            selectedMenuType=MenuType.SVV
        }else{
            selectedMenuType=MenuType.Display
        }
        configureMenu()
 //        setButtons()
        buttonsToFront()
        setVRsliderOnOff()
        setRotationSpeedSliderOnOff()
//        setDotsRotationSpeedText()
        speedLabel.text=String(dotsRotationSpeed*5)
        rotationSpeedSlider.value=Float(dotsRotationSpeed+72)/144
        depthLabel.text="3Ddepth:" + String(depth3D)
        depthSlider.value=Float(depth3D+10)/20
        setBackImages()
        
        ww=view.bounds.width
        wh=view.bounds.height
        radius=wh*(70+13*CGFloat(circleDiameter)/5)/400
        x0Right=ww/4 + CGFloat(locationX)
        x0Left=ww*3/4 - CGFloat(locationX)
        image3D=UIImage(named: "white_black562")
        image3DLeft=image3D
        image3DRight=image3D

  //      image3D=pasteImage(orgImg:image3Ds!,posx:50)
  
        drawBack()
        drawLines(degree:0)

        
        timer = Timer.scheduledTimer(timeInterval: 1.0/60, target: self, selector: #selector(self.update), userInfo: nil, repeats: true)
        
    }
    func setBackImages(){
        if SVVorDisplay==1{
            if displayModeType==0{
//                backImage = UIImage.ResizeÜIImage(image: UIImage(named:"random")!,width: 562, height:562)
                backImage=UIImage(named: "random")
            }else if displayModeType==1{
                backImage=UIImage(named: "dots690")
            }else if displayModeType==2{
                backImage=UIImage(named:"dots690t")
            }else if displayModeType==3{
                backImage=UIImage(named: "band770")
            }else{
                backImage=UIImage(named:"band770t")
            }
        }else{
            if SVVModeType==2{
                backImage=UIImage(named: "random")
            }else if SVVModeType==1{
                backImage=UIImage(named: "randoms")
            }else{
//                backImage = UIImage.ResizeÜIImage(image: UIImage(named:"white_black")!,width: 562, height:562)
                backImage=UIImage(named: "white_black")
            }
        }
    }

    func setLabelProperty(_ label:UILabel,x:CGFloat,y:CGFloat,w:CGFloat,h:CGFloat,_ color:UIColor){
        label.frame = CGRect(x:x, y:y, width: w, height: h)
        label.layer.borderColor = UIColor.black.cgColor
        label.layer.masksToBounds = true
        label.layer.cornerRadius = 5
        label.backgroundColor = color
    }
    func setSwitchProperty(_ label:UISegmentedControl,x:CGFloat,y:CGFloat,w:CGFloat,h:CGFloat){
        label.frame = CGRect(x:x, y:y, width: w, height: h)
//        label.layer.borderColor = UIColor.black.cgColor
//        label.layer.borderWidth = 1.0
    }
    func setButtons(){
    
        let leftPadding=CGFloat( UserDefaults.standard.integer(forKey:"leftPadding"))
        let rightPadding=CGFloat(UserDefaults.standard.integer(forKey:"rightPadding"))
        let topPadding=CGFloat(UserDefaults.standard.integer(forKey:"topPadding"))
        let bottomPadding=CGFloat(UserDefaults.standard.integer(forKey:"bottomPadding"))
        let ww=view.bounds.width-leftPadding-rightPadding
        let wh=view.bounds.height-topPadding-bottomPadding//topPadding is 0 anytime?
        let sp=ww/120
        let bw=(ww-sp*7)*2/15
        let bh=bw/2.5
        let by=wh-bh-sp
        let x0=leftPadding+sp
        let sliderWidth=(ww-3*bw-sp*7)/3
        VRLocationXSlider.frame =  CGRect(x:x0+sp*5+sliderWidth*2+bw*3,y:by-bh-sp,width:sliderWidth,height: bh)
        setSwitchProperty(circleNumberSwitch, x: x0+sp*4+sliderWidth*2+bw*2, y: by-bh-sp, w: bw, h: bh)

        setLabelProperty(lineWidthLabel, x:x0+sp*2+sliderWidth+bw, y:by-bh-sp, w: bw, h: bh,UIColor.white)
        lineWidthSlider.frame = CGRect(x:x0+sp*3+sliderWidth+bw*2,y:by-bh-sp,width:sliderWidth,height:bh)
        diameterSlider.frame = CGRect(x:x0+sp+bw,y:by-bh-sp,width:sliderWidth,height:bh)
        setLabelProperty(circleDiameterLabel,x:x0, y: by-bh-sp, w: bw, h: bh,UIColor.white)
        stop10Switch.frame=CGRect(x:x0,y:sp*2,width: 50,height: 20)
        let switchWidth=stop10Switch.frame.width
        let switchHeight=stop10Switch.frame.height
        let delta=bh/2-switchHeight/2
        stop10Switch.frame=CGRect(x:x0,y:sp*2+delta,width: switchWidth,height: switchHeight)
        setLabelProperty(stop10Label, x: x0+sp+switchWidth, y: sp*2, w: 150, h: bh, UIColor.white)
        gyroOnSwitch.frame=CGRect(x:x0,y:sp+stop10Label.frame.maxY+delta,width: switchWidth,height: bh)
        lineMovingSwitch.frame=CGRect(x:x0,y:sp+delta+stop10Label.frame.maxY,width:switchWidth,height:bh)
        setLabelProperty(lineMovingLabel,x:x0+sp+switchWidth,y:sp+stop10Label.frame.maxY,w:150,h:bh,UIColor.white)
        setLabelProperty(gyroOnLabel, x: x0+sp+switchWidth, y: sp+stop10Label.frame.maxY, w: 150, h: bh, UIColor.white)
        let exitX=x0+sp*5+sliderWidth*3+bw*2
        exitButton.frame = CGRect(x:exitX,y:by,width:bw,height: bh)
        exitButton.layer.cornerRadius=5
    //       let backImageSwitchW=lineWidthLabel.frame.minX-sp-x0
        let dispSwitchW=lineWidthLabel.frame.maxX-x0
        setSwitchProperty(backImageSwitch, x: x0, y: by, w:dispSwitchW, h: bh)
        setSwitchProperty(displayModeSwitch, x: x0, y: by, w:dispSwitchW, h: bh)
        setLabelProperty(speedLabel, x:lineWidthLabel.frame.maxX+sp, y: by, w: bw/2, h: bh, UIColor.white)
        let speedSliderW=exitX-speedLabel.frame.maxX-sp*2
        rotationSpeedSlider.frame = CGRect(x:speedLabel.frame.maxX+sp,y:by,width:speedSliderW,height:bh)
        fpsSwitch.frame=CGRect(x:x0+bw+sp,y:2*sp,width:lineWidthLabel.frame.maxX-x0-bw-sp,height:bh)
        setLabelProperty(samplingLabel, x: x0, y: 2*sp, w: bw,h:bh,UIColor.white)
        depthLabel.frame=CGRect(x:speedLabel.frame.minX,y:samplingLabel.frame.minY,width:bw,height: bh)
        depthLabel.layer.masksToBounds=true
        depthLabel.layer.cornerRadius=5
        depthSlider.frame=CGRect(x:depthLabel.frame.maxX+sp,y:samplingLabel.frame.minY,width:exitButton.frame.minX-depthLabel.frame.maxX-2*sp,height: bh)
        SVVDisplayButton.frame = CGRect(x:exitX,y:samplingLabel.frame.minY,width:bw,height:bh)
        SVVDisplayButton.layer.cornerRadius=5
        circleDiameterLabel.layer.masksToBounds = true
        circleDiameterLabel.layer.cornerRadius = 5
        lineWidthLabel.layer.masksToBounds = true
        lineWidthLabel.layer.cornerRadius = 5
        circleNumberSwitch.selectedSegmentIndex=circleNumber
        backImageSwitch.selectedSegmentIndex=SVVModeType
        displayModeSwitch.selectedSegmentIndex=displayModeType
        fpsSwitch.selectedSegmentIndex=fps
        if tenTimesOnOff==1{
            stop10Switch.isOn=true
        }else{
            stop10Switch.isOn=false
        }
        if lineMovingOnOff==1{
            lineMovingSwitch.isOn=true
        }else{
            lineMovingSwitch.isOn=false
        }
        if gyroOnOff==0{
            gyroOnSwitch.isOn=false
        }else{
            gyroOnSwitch.isOn=true
        }
        if SVVorDisplay==0{
            lineMovingLabel.isHidden=false
            lineMovingSwitch.isHidden=false
            stop10Label.isHidden=false
            stop10Switch.isHidden=false
            backImageSwitch.isHidden=false
            displayModeSwitch.isHidden=true
            gyroOnLabel.isHidden=true
            gyroOnSwitch.isHidden=true
            fpsSwitch.isHidden=true
            samplingLabel.isHidden=true
        }else{
            lineMovingLabel.isHidden=true
            lineMovingSwitch.isHidden=true
            stop10Label.isHidden=true
            stop10Switch.isHidden=true
            backImageSwitch.isHidden=true
            displayModeSwitch.isHidden=false
            gyroOnLabel.isHidden=false
            gyroOnSwitch.isHidden=false
            fpsSwitch.isHidden=false
            samplingLabel.isHidden=false
        }
    }
 
    func reDrawCirclesLines(){
        buttonsToBack()
        self.view.layer.sublayers?.removeLast()
        drawBack()
        drawLines(degree: 0)
        buttonsToFront()
    }
    func killTimer(){
        if timer?.isValid == true {
            timer.invalidate()
        }
    }
    var mainTime=CFAbsoluteTimeGetCurrent()
    var currentDotsDegree:CGFloat=0
    @objc func update(tm: Timer) {//1/60sec
        if SVVModeType==0 && SVVorDisplay==0{
//            return
        }
        currentDotsDegree=(CFAbsoluteTimeGetCurrent()-mainTime)*CGFloat(dotsRotationSpeed)*5

//        currentDotsDegree += CGFloat(dotsRotationSpeed)/12.0
        reDrawCirclesLines()
//        print("dotsRotationSpeed",dotsRotationSpeed)
    }
    func drawLines(degree:Int){//remove:Bool){
        //線を引く
        let ww=view.bounds.width
        let wh=view.bounds.height
        let x0L=ww*1/4 + CGFloat(locationX)
        let x0M=ww/2
        let x0R=ww*3/4 - CGFloat(locationX)
        let y0=wh/2
        var r=wh*(70+13*CGFloat(circleDiameter)/5)/400
        if SVVModeType==1 && SVVorDisplay==0{
            r=r*0.35
        }
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
        shapeLayer.lineWidth=CGFloat(verticalLineWidth)//+0.5
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
    var initDrawBackFlag:Bool=true
    //1542*562
    @IBAction func onTapGesture(_ sender: UITapGestureRecognizer) {
        let loc=sender.location(in: self.view)
        if loc.x < rotationSpeedSlider.frame.maxX && loc.x>rotationSpeedSlider.frame.minX && loc.y>rotationSpeedSlider.frame.minY && loc.y<rotationSpeedSlider.frame.maxY{
            
            print("tapGesture")
            dotsRotationSpeed = 0//Int(sender.value*144) - 72
            rotationSpeedSlider.value=0.5
//            print("speed:",dotsRotationSpeed)
            UserDefaults.standard.set(dotsRotationSpeed, forKey: "dotsRotationSpeed")
            //        setDotsRotationSpeedText()
            speedLabel.text=String(dotsRotationSpeed*5)
        }
    }
    func trimmingImage(_ image: UIImage,_ trimmingArea: CGRect) -> UIImage {
        let imgRef = image.cgImage?.cropping(to: trimmingArea)
        let trimImage = UIImage(cgImage: imgRef!, scale: image.scale, orientation: image.imageOrientation)
        return trimImage
    }
    var ww:CGFloat=0
    var wh:CGFloat=0
    var radius:CGFloat=0
    var x0Right:CGFloat=0
    var x0Left:CGFloat=0
    var image3D:UIImage?
    var image3DLeft:UIImage?
    var image3DRight:UIImage?

    var image1:UIImage?

    func drawBack(){//_ angle:CGFloat){
        if initDrawBackFlag==true{
            initDrawBackFlag=false
            grayImage.frame=CGRect(x:0,y:0,width:ww,height:wh)
        }
        let y0=wh/2
        if SVVorDisplay==0 {
            if SVVModeType==0{
                randomImage1.image=backImage
            }else{
                randomImage1.image=backImage?.rotatedBy(degree: currentDotsDegree)
            }
            randomImage2.image=randomImage1.image
            if circleNumber==0{
                randomImage1.frame=CGRect(x:ww/2-radius,y:y0-radius,width: radius*2,height: radius*2)
                self.view.bringSubviewToFront(randomImage1)
            }else{
                randomImage1.frame=CGRect(x:x0Right-radius,y:y0-radius,width: radius*2,height: radius*2)
                //右合成
                self.view.bringSubviewToFront(randomImage1)
                randomImage2.frame=CGRect(x:x0Left-radius,y:y0-radius,width: radius*2,height: radius*2)
                //左合成
                self.view.bringSubviewToFront(randomImage2)
            }
        }else{//Display
            if displayModeType==0{
                image1=backImage?.rotatedBy(degree: currentDotsDegree)
            }else{
                var imgxy=CGFloat(Int(currentDotsDegree*5)%770)
                if imgxy<0{
                    imgxy += 770
                }
                if displayModeType==1 || displayModeType==3{//horizontal
                    image1=trimmingImage(backImage!,CGRect(x:imgxy,y:0,width: 690,height: 690))
                }else{//vertical
                    image1=trimmingImage(backImage!,CGRect(x:0,y:imgxy,width: 690,height: 690))
                }
            }
            if circleNumber==0{
                randomImage1.image=UIImage.ComposeUIImage(UIImageArray: [image1!,image3D!], width: 690, height: 690)
                randomImage1.frame=CGRect(x:ww/2-radius,y:y0-radius,width: radius*2,height: radius*2)
                self.view.bringSubviewToFront(randomImage1)
            }else{
                randomImage1.image=UIImage.ComposeUIImage(UIImageArray: [image1!,image3DRight!], width: 690, height: 690)
                randomImage1.frame=CGRect(x:x0Right-radius,y:y0-radius,width: radius*2,height: radius*2)
                self.view.bringSubviewToFront(randomImage1)
                randomImage2.image=UIImage.ComposeUIImage(UIImageArray: [image1!,image3DLeft!], width: 690, height: 690)
                randomImage2.frame=CGRect(x:x0Left-radius,y:y0-radius,width: radius*2,height: radius*2)
                self.view.bringSubviewToFront(randomImage2)
            }
        }
    }
  /*  func drawBack1(){
        // 四角形を描画
        if initDrawBackFlag==true{
            initDrawBackFlag=false
            grayImage.frame=CGRect(x:0,y:0,width:view.bounds.width,height:view.bounds.height)
        }
        var x0=ww/2
        if circleNumber == 1{
            x0=ww/4 + CGFloat(locationX)
        }
        let y0=wh/2
        if SVVorDisplay==1{
            if displayModeType>0{//dot:
                var imgxy=CGFloat(Int(currentDotsDegree*5)%770)
                if imgxy<0{
                    imgxy += 770
                }
                if displayModeType==1 || displayModeType==3{
                    let image1=trimmingImage(backImage!,CGRect(x:imgxy,y:0,width: 562,height: 562))
                    // 画像を合成する.
                    randomImage1.image = UIImage.ComposeUIImage(UIImageArray: [image1,image3D!], width: 562, height: 562)
                }else{
                    let image1=trimmingImage(backImage!,CGRect(x:0,y:imgxy,width: 562,height: 562))
                    // 画像を合成する.
                    randomImage1.image = UIImage.ComposeUIImage(UIImageArray: [image1,image3D!], width: 562, height: 562)
                }
            }else{
                randomImage1.image=backImage?.rotatedBy(degree: currentDotsDegree)
            }
            randomImage2.image=randomImage1.image
            randomImage1.frame=CGRect(x:x0-radius,y:y0-radius,width: radius*2,height: radius*2)
            self.view.bringSubviewToFront(randomImage1)
            if circleNumber==1{
                x0=ww*3/4 - CGFloat(locationX)
                randomImage2.frame=CGRect(x:x0-radius,y:y0-radius,width: radius*2,height: radius*2)
                self.view.bringSubviewToFront(randomImage2)
            }else{
                randomImage2.frame=CGRect(x:0,y:0,width: 0,height: 0)
            }
        }else if SVVModeType==0{
            randomImage1.image=backImage//UIImage(named: "white_black")
            randomImage2.image=backImage//UIImage(named: "white_black")
            randomImage1.frame=CGRect(x:x0-radius,y:y0-radius,width: radius*2,height: radius*2)
            self.view.bringSubviewToFront(randomImage1)
            if circleNumber==1{
                x0=ww*3/4 - CGFloat(locationX)
                randomImage2.frame=CGRect(x:x0-radius,y:y0-radius,width: radius*2,height: radius*2)
                self.view.bringSubviewToFront(randomImage2)
            }else{
                randomImage2.frame=CGRect(x:0,y:0,width: 0,height: 0)
            }
        }else{//dot:rotation
            randomImage1.image=backImage?.rotatedBy(degree: currentDotsDegree)
            randomImage2.image=randomImage1.image
            randomImage1.frame=CGRect(x:x0-radius,y:y0-radius,width: radius*2,height: radius*2)
            self.view.bringSubviewToFront(randomImage1)
            if circleNumber==1{
                x0=ww*3/4 - CGFloat(locationX)
                randomImage2.frame=CGRect(x:x0-radius,y:y0-radius,width: radius*2,height: radius*2)
                self.view.bringSubviewToFront(randomImage2)
            }else{
                randomImage2.frame=CGRect(x:0,y:0,width: 0,height: 0)
            }
        }
    }*/
}
