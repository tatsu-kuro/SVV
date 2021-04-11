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
//    let fromAppDelegate = AppDelegate()
//    var Globalav=0.0
    var lastSensorDegree:Double=0
    let motionManager = CMMotionManager()
    var cirDiameter:CGFloat = 0
    var lineWidth:Int=0
    var locationX:Int=0
    var VROnOff:Int=0
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
    var buttonInterval=CFAbsoluteTimeGetCurrent()
    var gamepadInterval=CFAbsoluteTimeGetCurrent()
    var tapInterval=CFAbsoluteTimeGetCurrent()
    var time=CFAbsoluteTimeGetCurrent()
    var verticalLinef:Bool=false
    var tenTimesOnOff:Int = 1
//    var lastYvalue:Float=0.0
    func setDate(){
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd/HH:mm"
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
                if (CFAbsoluteTimeGetCurrent()-buttonInterval)<0.3{
                    returnMain()
                }
                buttonInterval=CFAbsoluteTimeGetCurrent()
                return
            }
            movingBarFlag=true
            appendData()
            if(tenTimesOnOff==1 && sensorArray.count==10){
                if timer?.isValid == true {
                    timer.invalidate()
                }
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
   //     vArray.append(degree*10+Int(s))
    }
    override func remoteControlReceived(with event: UIEvent?) {
        guard event?.type == .remoteControl else { return }
        if let event = event {
            switch event.subtype {
                
            case .remoteControlTogglePlayPause:
  //              print("TogglePlayPause")
                if(movingBarFlag==true){
                    if (CFAbsoluteTimeGetCurrent()-buttonInterval)<0.3{
           //             print("doubleTap")
                        returnMain()
                    }
                    buttonInterval=CFAbsoluteTimeGetCurrent()
                    return
                }
                movingBarFlag=true
                appendData()
                if(tenTimesOnOff==1 && sensorArray.count==10){
                    if timer?.isValid == true {
                        timer.invalidate()
                    }
                    returnMain()
//                    self.dismiss(animated: true, completion: nil)
                }
 
            case .remoteControlPlay:
 //               print("Play")
                if(movingBarFlag==true){
                    if (CFAbsoluteTimeGetCurrent()-buttonInterval)<0.3{
 //                       print("doubleTap")
                        returnMain()
//                        self.dismiss(animated: true, completion: nil)
                    }
                    buttonInterval=CFAbsoluteTimeGetCurrent()
                    return
                }
                movingBarFlag=true
                appendData()
                if(tenTimesOnOff==1 && sensorArray.count==10){
                    if timer?.isValid == true {
                        timer.invalidate()
                    }
                    returnMain()
//                    self.dismiss(animated: true, completion: nil)
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
 
    //  let outer5=3.0*(self.Kalupdate(measurement: CGFloat(oY.pointee) - outerdy))
    func outputAccelData(acceleration: CMAcceleration){
        var ax=acceleration.x
        var ay=acceleration.y
        ax=Kalupdate(measurement: ax)
        ay=Kalupdate1(measurement: ay)
        let len=sqrt(ax*ax+ay*ay)
        var curAcc_temp=asin(ay/len)
        if ax<0 {
            curAcc_temp = 0 - curAcc_temp
        }
        curAcc_temp=curAcc_temp*90.0/(Double.pi/2)
        curAcc=curAcc_temp
    }
    // センサー取得を止める場合
    func stopAccelerometer(){
        if (motionManager.isAccelerometerActive) {
            motionManager.stopAccelerometerUpdates()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        circleDiameter=UserDefaults.standard.integer(forKey: "circleDiameter")
        lineWidth=UserDefaults.standard.integer(forKey: "lineWidth")
        locationX=UserDefaults.standard.integer(forKey:"VRLocationX")
        VROnOff=UserDefaults.standard.integer(forKey:"VROnOff")
        tenTimesOnOff=UserDefaults.standard.integer(forKey:"tenTimesOnOff")

        //circleDiameter=getUserDefault(str: "circleDiameter", ret: dia0)
        //lineWidth=getUserDefault(str: "lineWidth", ret: width0)
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
 //       cirDiameter=view.bounds.width/26
        time=CFAbsoluteTimeGetCurrent()
        drawBack()
        print("last",lastSensorDegree)
        timer = Timer.scheduledTimer(timeInterval: 1.0/60, target: self, selector: #selector(self.update), userInfo: nil, repeats: true)
        tcount=0
        movingBarFlag=true
//        if UIApplication.shared.isIdleTimerDisabled == false{
//            UIApplication.shared.isIdleTimerDisabled = true//スリープしない
//        }
        buttonInterval=CFAbsoluteTimeGetCurrent()-1
        tapInterval=CFAbsoluteTimeGetCurrent()-1
        self.setNeedsStatusBarAppearanceUpdate()//
        //view.bounds.width
        sensorArray.removeAll()
        degreeArray.removeAll()
        Globalmode=1
        //vArray.removeAll()
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
    @objc func update(tm: Timer) {
       // if(Globalef==true){//gamepadがない時は変化しないのでチェックせず
            degree += Double(Globallx)*2
            degree += Double(Globalpx)/2
            degree += Double(Globalbv)/2
            degree -= Double(Globalxv)/2
            if(movingBarFlag==true){
                if(Globallx != 0.0 || Globalpx != 0.0 || Globalbv != 0.0 || Globalxv != 0.0){
                    movingBarFlag=false
                }
            }
      //      print("svvA:",Globalav)
      //      print("svvx:",Globallx)
      //      print("svvpx:",Globalpx)
      //  }
        let tmpD=getSenserDegree()
        if lastSensorDegree < tmpD - 5 || lastSensorDegree > tmpD + 5{
            lastSensorDegree = tmpD
        }
        if (movingBarFlag) {
            if(degree > lastSensorDegree*5 + 150){
                directionR=false
            }else if(degree < lastSensorDegree*5 - 150){
                directionR=true
            }
            if(directionR){
                degree += 2
            }else{
                degree -= 2
            }
        } else if (rbf) {
            degree += 1
        } else if (lbf) {
            degree -= 1
        }
        if(degree > 450){
            degree -= 900
        }else if(degree < -450){
            degree += 900
        }
   //     if(mbf==false){
  //           print("buttonY:",Globalyv,GlobalLastyv1,Globalmode)
        if(Globalav == 0.0 && GlobalLastav != 0.0){
            GlobalLastav=Globalav
            if movingBarFlag==true{
                if (CFAbsoluteTimeGetCurrent()-gamepadInterval)<0.3{
                //            print("doubleTap")
                    if timer?.isValid == true {
                        timer.invalidate()
                    }
                    Globalmode=0
                    returnMain()
                }
                gamepadInterval=CFAbsoluteTimeGetCurrent()
                return
            }
            movingBarFlag=true
            appendData()
            if(tenTimesOnOff==1 && sensorArray.count==10){
                 if timer?.isValid == true {
                     timer.invalidate()
                 }
                 Globalmode=0
                 GlobalLastav=0
                 returnMain()
            }//self.dismiss(animated: false, completion: nil)
        }
        GlobalLastav=Globalav
        
        if(Globalmode == 1){
            if(Globalyv == 0.0 && GlobalLastyv1 != 0.0){
                movingBarFlag=true
                GlobalLastyv1 = 0.0
                if timer?.isValid == true {
                    timer.invalidate()
                }
                Globalmode=0
                    returnMain()
            }else{
                GlobalLastyv1=Globalyv
            }
 
        }
        drawLine(degree:Float(degree),remove:true)
    }

    var initFlag:Bool=true
    func drawLine(degree:Float,remove:Bool){
        //線を引く
        if initFlag==true{
            initFlag=false
            view.layer.sublayers?.removeLast()

        }else if remove==true{
            view.layer.sublayers?.removeLast()
            if VROnOff==1{
            view.layer.sublayers?.removeLast()
            }
        }
        let ww=view.bounds.width
        let wh=view.bounds.height
        var x0=ww/2
        if VROnOff == 1{
            x0=ww*3/4 - CGFloat(locationX)
        }
        let y0=wh/2
        let r=wh*(70+13*CGFloat(circleDiameter))/400
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
        shapeLayer.lineWidth=CGFloat(lineWidth)/10.0
        self.view.layer.addSublayer(shapeLayer)
        if VROnOff==1{
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
            shapeLayer1.lineWidth=CGFloat(lineWidth)/10.0
            self.view.layer.addSublayer(shapeLayer1)
        }
    }

    func drawBack(){

        let ww=view.bounds.width
        let wh=view.bounds.height
        // 四角形を描画
        let rectangleLayer = CAShapeLayer.init()
        let rectangleFrame = CGRect.init(x: 0, y: 0, width:ww, height: wh)
        rectangleLayer.frame = rectangleFrame
        rectangleLayer.strokeColor = UIColor.black.cgColor// 輪郭の色
        rectangleLayer.fillColor = UIColor.black.cgColor// 四角形の中の色
        rectangleLayer.lineWidth = 2.5
        
        rectangleLayer.path = UIBezierPath.init(rect: CGRect.init(x: 0, y: 0, width: rectangleFrame.size.width, height: rectangleFrame.size.height)).cgPath
        self.view.layer.addSublayer(rectangleLayer)
        // --- 円を描画 ---
        let circleLayer = CAShapeLayer.init()
        let circleLayer1 = CAShapeLayer.init()
        //let r=wh*180/200
        let r=wh*(70+13*CGFloat(circleDiameter))/200
        var x0=ww/2-r/2
        if VROnOff == 1{
            x0=ww/4 + CGFloat(locationX) - r/2
        }
        let y0=wh/2-r/2
        //print(r,x0,y0)
        var circleFrame = CGRect.init(x:x0,y:y0,width:r,height:r)
        circleLayer.frame = circleFrame
        circleLayer.strokeColor = UIColor.black.cgColor// 輪郭の色
        circleLayer.fillColor = UIColor.white.cgColor// 円の中の色
        circleLayer.lineWidth = 0.5// 輪郭の太さ
        circleLayer.path = UIBezierPath.init(ovalIn: CGRect.init(x: 0, y: 0, width: circleFrame.size.width, height: circleFrame.size.height)).cgPath
        self.view.layer.addSublayer(circleLayer)
        if VROnOff == 1{
            x0=ww*3/4 - CGFloat(locationX) - r/2
            circleFrame = CGRect.init(x:x0,y:y0,width:r,height:r)
            circleLayer1.frame=circleFrame
            circleLayer1.strokeColor = UIColor.black.cgColor// 輪郭の色
            circleLayer1.fillColor = UIColor.white.cgColor// 円の中の色
            circleLayer1.lineWidth = 0.5// 輪郭の太さ
       
            circleLayer1.path = UIBezierPath.init(ovalIn: CGRect.init(x: 0, y: 0, width: circleFrame.size.width, height: circleFrame.size.height)).cgPath
            self.view.layer.addSublayer(circleLayer1)
        }
        //線を引く
        let shapeLayer = CAShapeLayer.init()
        let uiPath = UIBezierPath()
        uiPath.move(to:CGPoint.init(x: ww/2,y: wh/2-r/2))
        uiPath.addLine(to: CGPoint(x:ww/2,y:wh/2+r/2))
        shapeLayer.strokeColor = UIColor.blue.cgColor
        shapeLayer.path = uiPath.cgPath
        self.view.layer.addSublayer(shapeLayer)
    }
}
