//
//  SVVViewController.swift
//  SVV
//
//  Created by kuroda tatsuaki on 2019/07/03.
//  Copyright © 2019 tatsuaki.kuroda. All rights reserved.
//

import UIKit
import CoreMotion

class SVVViewController: UIViewController {
    @IBOutlet weak var randomImage: UIImageView!
    @IBOutlet weak var randomImage1: UIImageView!
    @IBOutlet weak var randomImage2: UIImageView!
    @IBOutlet weak var blackImage: UIImageView!
    
    var lastSensorDegree:Double=0
    let motionManager = CMMotionManager()
    var backImageType:Int=0
    var dotsRotationSpeed:Int=0
    var currentDotsDegree:CGFloat=0
    var cirDiameter:CGFloat = 0
    var lineWidth:Int=0
    var locationX:Int=0
    var circleNumber:Int=0
    var circleDiameter:Int=0
    var timer: Timer!
    var lbf:Bool=false
    var rbf:Bool=false
    var movingBarFlag:Bool=false
    var resultf:Bool=false
    var directionR:Bool=true
    var dateString:String=""
    var lastrand:Int=0
    var tcount: Int = 0
    var degree:Double=0.0
    var curAcc:Double=0
    var sensorArray = Array<Double>()//sensor
    var degreeArray = Array<Double>()//degree
    var svvArray = Array<Double>()//delta Subjective Visual Vertical
    var actionTimeLast=CFAbsoluteTimeGetCurrent()//tap or remoteController
    var verticalLinef:Bool=false
    var tenTimesOnOff:Int = 1
    var lineMovingOnOff:Int = 1
    var SVVorDisplay:Int = 1

    func setDate(){
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd/ HH:mm"
        let date = Date()
        dateString = dateFormatter.string(from: date)
 //       print(dateString)
    }
    @IBAction func longPress(_ sender: UILongPressGestureRecognizer) {
        //呼び出されたタイミングを確認する。
        if(sender.state == UIGestureRecognizer.State.began) {
            if sender.location(in: self.view).x<self.view.bounds.width/3{
                lbf=true
                movingBarFlag=false
           //     print("longPressBeginLeft")
             }else if sender.location(in: self.view).x>self.view.bounds.width*2/3{
                rbf=true
                movingBarFlag=false
            //    print("longPressBeginRight")
            }
        } else if (sender.state == UIGestureRecognizer.State.ended) {
            if sender.location(in: self.view).x<self.view.bounds.width/3{
          //      print("longPressEndLeft")
                lbf=false
            }else if sender.location(in: self.view).x>self.view.bounds.width*2/3{
        //        print("longPressEndRight")
                rbf=false
            }
        }
    }
    func returnMain(){
        if timer?.isValid == true {
            timer.invalidate()
        }
        let mainView = storyboard?.instantiateViewController(withIdentifier: "mainView") as! ViewController
        mainView.svvArray.removeAll()
        mainView.degreeArray.removeAll()
        mainView.sensorArray.removeAll()
        for i in 0..<degreeArray.count{
            mainView.svvArray.append(svvArray[i])
            mainView.degreeArray.append(degreeArray[i])
            mainView.sensorArray.append(sensorArray[i])
        }
        setDate()
        mainView.dateString=dateString
        if degreeArray.count>0 {
            mainView.savedFlag=false
        }
        stopAccelerometer()//version1.9で加えた
        self.present(mainView, animated: false, completion: nil)
        Globalmode=0
        return//iranasasou? <-kokotouruyo?
    }
    @IBAction func singleTap(_ sender: UITapGestureRecognizer) {
        if sender.location(in: self.view).x < self.view.bounds.width/3{
            movingBarFlag=false
            degree -= 1
        }else if sender.location(in: self.view).x < self.view.bounds.width*2/3{
            if(movingBarFlag==true){
                if (CFAbsoluteTimeGetCurrent()-actionTimeLast)<0.3{
                    returnMain()
                }
                actionTimeLast=CFAbsoluteTimeGetCurrent()
                return
            }
            movingBarFlag=true
            appendData()
            if lineMovingOnOff==0{
                degree = Double(Int.random(in: 0...400))
                if degree<200{
                    degree -= 350
                }else{
                    degree -= 50
                }
                print("singleTap:",degree/5)
            }
            if(tenTimesOnOff==1 && sensorArray.count==10){
                returnMain()
            }
        }else{
            movingBarFlag=false
            degree += 1
        }
    }
 /// 画面が閉じる直前に呼ばれる
    override func viewWillDisappear(_ animated: Bool) {
     super.viewWillDisappear(animated)

     // タイマーを停止する//二重に停止してもmainでも動く。どうして？ 
        if let workingTimer = timer{
         workingTimer.invalidate()
        }
        Globalmode=0
    }
    override func viewDidAppear(_ animated: Bool) {
        
    }
    override func viewDidDisappear(_ animated: Bool) {
        stopAccelerometer()
        Globalmode=0
  //      print("stopSensor")
    }
    func getSenserDegree()->Double{
        let s=round(curAcc*10)//shishagonyuu 90degree
        return -s/10.0
    }
    func appendData(){
        let s=round(curAcc*10)//shishagonyuu 90degree
        sensorArray.append(-s/10.0)

        degreeArray.append(degree/5.0)
        let v1 = curAcc*10.0 + degree*2.0
        let v2 = round(v1)

        svvArray.append(v2/10.0)
    }
    override func remoteControlReceived(with event: UIEvent?) {
        guard event?.type == .remoteControl else { return }
        if let event = event {
            switch event.subtype {
                
            case .remoteControlTogglePlayPause:
  //              print("TogglePlayPause")
                if(movingBarFlag==true){
                    if (CFAbsoluteTimeGetCurrent()-actionTimeLast)<0.3{
           //             print("doubleTap")
                        returnMain()
                    }
                    actionTimeLast=CFAbsoluteTimeGetCurrent()
                    return
                }
                movingBarFlag=true
                appendData()
                if(tenTimesOnOff==1 && sensorArray.count==10){
                    returnMain()
                }
 
            case .remoteControlPlay:
 //               print("Play")
                if(movingBarFlag==true){
                    if (CFAbsoluteTimeGetCurrent()-actionTimeLast)<0.3{
                         returnMain()
                    }
                    actionTimeLast=CFAbsoluteTimeGetCurrent()
                    return
                }
                movingBarFlag=true
                appendData()
                if(tenTimesOnOff==1 && sensorArray.count==10){
                    returnMain()
                }
            case .remoteControlNextTrack:
                movingBarFlag=false
                degree += 1
  //              print("NextTrack")
            case .remoteControlPreviousTrack:
                movingBarFlag=false
                degree -= 1
 //               print("PreviousTrack")
            case .remoteControlBeginSeekingBackward:
                lbf=true
                movingBarFlag=false
 //               print("BeginSeekingBackward")
            case .remoteControlEndSeekingBackward:
                lbf=false
//                print("EndSeekingBackward")
            case .remoteControlBeginSeekingForward:
                rbf=true
                movingBarFlag=false
  //              print("BeginSeekingForward")
            case .remoteControlEndSeekingForward:
                rbf=false
 //               print("EndSeekingForward")
            default:
                print("Others")
            }
        }
    }
    let KalQ1:Double = 0.0001
    let KalR1:Double = 0.001
    var KalX1:Double = 0.0
    var KalP1:Double = 0.0
    var KalK1:Double = 0.0
    func KalmeasurementUpdate1()
    {
        KalK1 = (KalP1 + KalQ1) / (KalP1 + KalQ1 + KalR1)
        KalP1 = KalR1 * (KalP1 + KalQ1) / (KalR1 + KalP1 + KalQ1)
    }
    func Kalupdate1(measurement:Double) -> Double//CGFloat) -> CGFloat
    {
        KalmeasurementUpdate1()
        let result = KalX1 + (measurement - KalX1) * KalK1
        KalX1 = result
        return result
    }
    let KalQ:Double = 0.0001
    let KalR:Double = 0.001
    var KalX:Double = 0.0
    var KalP:Double = 0.0
    var KalK:Double = 0.0
    func KalmeasurementUpdate()
    {
        KalK = (KalP + KalQ) / (KalP + KalQ + KalR)
        KalP = KalR * (KalP + KalQ) / (KalR + KalP + KalQ)
    }
    func Kalupdate(measurement:Double) -> Double//CGFloat) -> CGFloat
    {
        KalmeasurementUpdate()
        let result = KalX + (measurement - KalX) * KalK
        KalX = result
        return result
    }
 
     func outputAccelData(acceleration: CMAcceleration){
        var ax=acceleration.x
        var ay=acceleration.y
        ax=Kalupdate(measurement: ax)
        ay=Kalupdate1(measurement: ay)
        let len=sqrt(ax*ax+ay*ay)
        var curAcc_temp=asin(ay/len)

        curAcc_temp=curAcc_temp*90.0/(Double.pi/2)
        curAcc=curAcc_temp
        if curAcc<0 && ax>0{
            curAcc = -180 - curAcc
        }else if curAcc>0 && ax>0{
            curAcc = 180 - curAcc
        }
        curAcc = -curAcc
//        print(String(format:"curAcc:%.1f,%.1f,%.1f",curAcc,ax,ay))
    }
    // センサー取得を止める場合
    func stopAccelerometer(){
        if (motionManager.isAccelerometerActive) {
            motionManager.stopAccelerometerUpdates()
        }
        print("StopMotionSensor")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        circleDiameter=UserDefaults.standard.integer(forKey: "circleDiameter")
        lineWidth=UserDefaults.standard.integer(forKey: "lineWidth")
        locationX=UserDefaults.standard.integer(forKey:"VRLocationX")
        circleNumber=UserDefaults.standard.integer(forKey:"circleNumber")
        tenTimesOnOff=UserDefaults.standard.integer(forKey:"tenTimesOnOff")
        dotsRotationSpeed=UserDefaults.standard.integer(forKey: "dotsRotationSpeed")
        lineMovingOnOff=UserDefaults.standard.integer(forKey: "lineMovingOnOff")
        SVVorDisplay=UserDefaults.standard.integer(forKey: "SVVorDisplay")

        UIApplication.shared.beginReceivingRemoteControlEvents()
        self.becomeFirstResponder()
        if motionManager.isAccelerometerAvailable {
            // intervalの設定 [sec]
           motionManager.accelerometerUpdateInterval = 0.1
            // センサー値の取得開始
            motionManager.startAccelerometerUpdates(
                to: OperationQueue.current!,
                withHandler: {(accelData: CMAccelerometerData?, errorOC: Error?) in
                    self.outputAccelData(acceleration: accelData!.acceleration)
            })
        }
        backImageType = getUserDefault(str:"backImageType",ret:0)
        if backImageType==1{
            randomImage.image=UIImage(named: "random3")
        }else if backImageType==2{
            randomImage.image=UIImage(named: "random")
        }else{
            randomImage.image=UIImage(named: "white_black")
        }
//        drawBack()
//        print("last",lastSensorDegree)
        timer = Timer.scheduledTimer(timeInterval: 1.0/60, target: self, selector: #selector(self.update), userInfo: nil, repeats: true)
        tcount=0
        movingBarFlag=true

        actionTimeLast=CFAbsoluteTimeGetCurrent()-1
        self.setNeedsStatusBarAppearanceUpdate()//
        sensorArray.removeAll()
        degreeArray.removeAll()
        Globalmode=1
        if lineMovingOnOff==0{
            degree = Double(Int.random(in: 0...400))
            if degree<200{
                degree -= 350
            }else{
                degree -= 50
            }
//            print("didload:",degree/5)
        }else{
            degree -= 1
        }
    }
    
    func getUserDefault(str:String,ret:Int) -> Int{//getUserDefault_one
        if (UserDefaults.standard.object(forKey: str) != nil){//keyが設定してなければretをセット
            return UserDefaults.standard.integer(forKey:str)
        }else{
            UserDefaults.standard.set(ret, forKey: str)
            return ret
        }
    }
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
    override var prefersStatusBarHidden: Bool {
        return true
    }
    var initUpdateFlag:Bool=true
    @objc func update(tm: Timer) {
        //        print("sublayers:",view.layer.sublayers?.count)
        // if(Globalef==true){//gamepadがない時は変化しないのでチェックせず
        currentDotsDegree += CGFloat(dotsRotationSpeed)/12.0
        if initUpdateFlag==true{
            initUpdateFlag=false
            blackImage.frame=CGRect(x:0,y:0,width: view.bounds.width,height: view.bounds.height)
            if backImageType==0{
                drawWhiteCircle()
            }
        }else{
            view.layer.sublayers?.removeLast()
            if circleNumber==1{
                view.layer.sublayers?.removeLast()
            }
        }
        if backImageType>0{
            drawDotsCircle()
        }
//        print("sublayers:",view.layer.sublayers?.count)

        degree += Double(GlobalStickXvalue)*2
        degree += Double(GlobalPadXvalue)/2
        degree += Double(GlobalButtonBvalue)/2
        degree -= Double(GlobalButtonXvalue)/2
        if(movingBarFlag==true){
            if(GlobalStickXvalue != 0.0 || GlobalPadXvalue != 0.0 || GlobalButtonBvalue != 0.0 || GlobalButtonXvalue != 0.0){
                movingBarFlag=false
            }
        }
      
        let tmpD=getSenserDegree()
        if lastSensorDegree < tmpD - 5 || lastSensorDegree > tmpD + 5{
            lastSensorDegree = tmpD
        }
        if movingBarFlag {
            if(degree > lastSensorDegree*5 + 150){
                directionR=false
            }else if(degree < lastSensorDegree*5 - 150){
                directionR=true
            }
            if lineMovingOnOff==1{
                if(directionR){
                    degree += 2
                }else{
                    degree -= 2
                }
            }
        } else{
            if (rbf) {
                degree += 1
            } else if (lbf) {
                degree -= 1
            }
            if(degree > 600){
                degree = 600
            }else if(degree < -600){
                degree = -600
            }
        }
        if(GlobalButtonAvalue == 0.0 && GlobalButtonAvalueLast != 0.0){
            GlobalButtonAvalueLast=GlobalButtonAvalue
            if movingBarFlag==true{
                if (CFAbsoluteTimeGetCurrent()-actionTimeLast)<0.3{
                    Globalmode=0
                    returnMain()
                }
                actionTimeLast=CFAbsoluteTimeGetCurrent()
                return
            }
            movingBarFlag=true
            appendData()
            if(tenTimesOnOff==1 && sensorArray.count==10){
                Globalmode=0
                GlobalButtonAvalueLast=0
                returnMain()
            }
        }
        GlobalButtonAvalueLast=GlobalButtonAvalue
        
        if(Globalmode == 1){
            if(GlobalButtonYvalue == 0.0 && GlobalButtonYvalueLast1 != 0.0){
                movingBarFlag=true
                GlobalButtonYvalueLast1 = 0.0
                Globalmode=0
                returnMain()
            }else{
                GlobalButtonYvalueLast1=GlobalButtonYvalue
            }
            
        }
        if SVVorDisplay == 0{
            drawLine(degree:Float(degree),remove:true)
        }else{
            drawLine(degree:Float(0),remove:true)
        }
        if CFAbsoluteTimeGetCurrent()-actionTimeLast>300{
            returnMain()
        }
    }

    var initFlag:Bool=true
    func drawLine(degree:Float,remove:Bool){
       //線を引く

        let ww=view.bounds.width
        let wh=view.bounds.height
        var x0=ww/2
        if circleNumber == 1{
            x0=ww*3/4 - CGFloat(locationX)
        }
        let y0=wh/2
//        let r=wh*(70+13*CGFloat(circleDiameter))/400
        
        var r=wh*(70+13*CGFloat(circleDiameter))/400
        if backImageType==1{
            r=r*0.45
        }
        
        let dd:Double=3.14159/900//3600//1800//900
        let x1=CGFloat(Double(r)*sin(Double(degree)*dd))
        let y1=CGFloat(Double(r)*cos(Double(degree)*dd))
        let shapeLayer = CAShapeLayer.init()
        let uiPath = UIBezierPath()
        uiPath.move(to:CGPoint.init(x: x0 + x1,y: y0 - y1))
        uiPath.addLine(to: CGPoint(x:x0 - x1,y:y0 + y1))
        if movingBarFlag==true {
            shapeLayer.strokeColor = UIColor.red.cgColor
        } else {
            shapeLayer.strokeColor = UIColor.blue.cgColor
        }
        shapeLayer.path = uiPath.cgPath
        shapeLayer.lineWidth=CGFloat(lineWidth)
        self.view.layer.addSublayer(shapeLayer)
        if circleNumber==1{
            x0=ww/4 + CGFloat(locationX)
            let shapeLayer1 = CAShapeLayer.init()
            let uiPath1 = UIBezierPath()
            uiPath1.move(to:CGPoint.init(x: x0 + x1,y: y0 - y1))
            uiPath1.addLine(to: CGPoint(x:x0 - x1,y:y0 + y1))
            if movingBarFlag==true {
                shapeLayer1.strokeColor = UIColor.red.cgColor
            } else {
                shapeLayer1.strokeColor = UIColor.blue.cgColor
            }
            shapeLayer1.path = uiPath1.cgPath
            shapeLayer1.lineWidth=CGFloat(lineWidth)
            self.view.layer.addSublayer(shapeLayer1)
        }
    }

    func drawWhiteCircle(){
        let ww=view.bounds.width
        let wh=view.bounds.height
        let r=wh*(70+13*CGFloat(circleDiameter))/400
        var x0=ww/2
        let y0=wh/2
        if circleNumber == 1{
            x0=ww/4+CGFloat(locationX)
        }
        randomImage1.image=UIImage(named:"white_black")
        randomImage1.frame=CGRect(x:x0-r,y:y0-r,width: r*2,height: r*2)
        self.view.bringSubviewToFront(randomImage1)
        if circleNumber == 1{
            x0=ww*3/4 - CGFloat(locationX)
            randomImage2.image=UIImage(named: "white_black")
            randomImage2.frame=CGRect(x:x0-r,y:y0-r,width: r*2,height: r*2)
            self.view.bringSubviewToFront(randomImage2)
        }
    }
  
     func drawDotsCircle(){
         let ww=view.bounds.width
         let wh=view.bounds.height
         let r=wh*(70+13*CGFloat(circleDiameter))/400
         var x0=ww/2
         let y0=wh/2
         if circleNumber == 1{
             x0=ww/4+CGFloat(locationX)
         }
         randomImage1.image=randomImage.image?.rotatedBy(degree: currentDotsDegree)
         randomImage1.frame=CGRect(x:x0-r,y:y0-r,width: r*2,height: r*2)
         self.view.bringSubviewToFront(randomImage1)
         if circleNumber == 1{
             x0=ww*3/4 - CGFloat(locationX)
             randomImage2.image=randomImage1.image//randomImage.image?.rotatedBy(degree: currentDotsDegree)
             randomImage2.frame=CGRect(x:x0-r,y:y0-r,width: r*2,height: r*2)
             self.view.bringSubviewToFront(randomImage2)
         }
     }

}
