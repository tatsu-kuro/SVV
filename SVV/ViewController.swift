//
//  ViewController.swift
//  SVV
//
//  Created by kuroda tatsuaki on 2019/07/03.
//  Copyright © 2019 tatsuaki.kuroda. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer
import GameController
/*
extension DateFormatter {
    // テンプレートの定義(例)
    enum Template: String {
        case date = "yMd"     // 2017/1/1
        case time = "Hms"     // 12:39:22
        case full = "yMdkHms" // 2017/1/1,12:39:22
        case onlyHour = "k"   // 17時
        case era = "GG"       // "西暦" (default) or "平成" (本体設定で和暦を指定している場合)
        case weekDay = "EEEE" // 日曜日
    }
    
    func setTemplate(_ template: Template) {
        // optionsは拡張用の引数だが使用されていないため常に0
        dateFormat = DateFormatter.dateFormat(fromTemplate: template.rawValue, options: 0, locale: .current)
    }
}
*/
// テンプレートから時刻を表示
class ViewController: UIViewController {
 //let fromAppDelegate: AppDelegate = NSApplication.shared().delegate as! AppDelegate

//    let fromAppDelegate = AppDelegate()
    let dia0:Int = 7
    let width0:Int = 10
    var diameter:Int = 0
    var width:Int = 0
    var soundPlayer: AVAudioPlayer? = nil
    var sArray = Array<Double>()//sensor
    var dArray = Array<Double>()//degree
    var vArray = Array<Double>()//delta Subjective Visual Vertical
    var savedFlag:Bool = true
    var dateString:String = ""
    var idStr:String=""
    var idStr0:String=""
    var avesdStr:String=""
    var aveStr:String=""
    var sdStr:String=""
  //  var lastYvalue:Float=0.0
    @IBOutlet weak var resultView: UIImageView!
//    var vHITboxView: UIImageView?
//    var vHITlineView: UIImageView?
 //   var slowvideoAdd:String = ""
  //  var calcDate:String = ""
 //   var idNumber:Int = 0
    var idString:String = ""
    @IBOutlet weak var listButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var setteiButton: UIButton!
    @IBOutlet weak var helpButton: UIButton!
    @IBOutlet weak var titleImage: UIImageView!
    
    @IBOutlet weak var logoImage: UIImageView!
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("prepare")
        sound(snd:"silence")
    }
    @IBAction func saveData(_ sender: Any) {
        sound(snd:"silence")
        if vArray.count<1 {
            return
        }
        let alert = UIAlertController(title: "SVV96da", message: "Input ID without space", preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) -> Void in
            // 入力したテキストをコンソールに表示
            let textField = alert.textFields![0] as UITextField
 //           let str = textField.text?.components(separatedBy: " ")
            //print("input lengs",str?.count)
//            if str!.count>1 {
//                self.idString=""
//                for i in 0..<str!.count{
//                    self.idString += str![i]
//                }
//            }else{
                self.idString=textField.text!
//            }
            //print("\(String(describing: self.idString))")
            //print(self.idString)
            //idString=textField.text
      //      let drawImage = self.drawWaves(width:500,height:100)
            self.viewDidAppear(true)
            // イメージビューに設定する
     //       UIImageWriteToSavedPhotosAlbum(drawImage, nil, nil, nil)
            self.savedFlag = true //解析結果がsaveされた
            self.setViews()
       //     self.resultView.image=drawImage
            //self.resultView.alpha=0
            //self.titleImage.alpha=0
            //self.vArray.removeAll()
            //self.dArray.removeAll()
            //self.sArray.removeAll()
            //while self.savedFlag==false{
            //    sleep(1)
            //}
         //   self.viewDidAppear(false)

//            let file_name = "SVVdata.txt"
//            let text1:String=self.loadSVVdata(filename: "SVVdata.txt")
            var text:String=""
   //         var text:String = "12345SVV\nkurodatatsuki\nwatasino\nstring?" //保存する内容
            //let str = self.dateString.components(separatedBy: " ")
            text += self.dateString + ","//str[0] + "," + str[1] + ","
            text += self.idString + ","
            text += self.aveStr + ","
            text += self.sdStr + ","
            var dStr:String=""
            var sStr:String=""
            var vStr:String=""
            for i in 0..<10{//vArray.count{
                if(i<self.dArray.count){
                    dStr += String(format:"%.1f",self.dArray[i]) + ","
                    sStr += String(self.sArray[i]) + ","
                    if i<9 {
                        vStr += String(self.vArray[i]) + ","
                    }
                    else{
                        vStr += String(self.vArray[i])
                    }
                }else{
                    dStr += ","
                    sStr += ","
                    if i<9 {
                        vStr += ","
                    }
                }
            }
            text += dStr + sStr + vStr + "\n"
            let file_name = "SVVdata.txt"
            text += self.loadSVVdata(filename: "SVVdata.txt")

            if let dir = FileManager.default.urls( for: .documentDirectory, in: .userDomainMask ).first {

                let path_file_name = dir.appendingPathComponent( file_name )

                do {

                    try text.write( to: path_file_name, atomically: false, encoding: String.Encoding.utf8 )

                } catch {
                    print("SVVdata.txt write err")//エラー処理
                }
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default) { (action:UIAlertAction!) -> Void in
   //         self.idNumber = 1//キャンセルしてもここは通らない？
        }
        
        // UIAlertControllerにtextFieldを追加
        alert.addTextField { (textField:UITextField!) -> Void in
            textField.keyboardType = UIKeyboardType.default// .numberPad
        }
        alert.addAction(cancelAction)//この行と下の行の並びを変えるとCancelとOKの左右が入れ替わる。
        alert.addAction(saveAction)
        present(alert, animated: true, completion: nil)
    }

    func drawWaves(width w:CGFloat,height h:CGFloat) -> UIImage {
        let size = CGSize(width:w, height:h)
        // イメージ処理の開始
        UIGraphicsBeginImageContextWithOptions(size, false, 1.0)

        //var aveSd:String = ""
        if vArray.count != 0 {
            var vav:Double=0//average
            var vsd:Double=0//standard deviation
            for i in 0..<vArray.count{
                vav += vArray[i]
    //            print(vArray[i])
            }
            vav = vav/Double(vArray.count)
            for i in 0..<vArray.count {
                vsd += (vArray[i]-vav)*(vArray[i]-vav)
            }
            vsd=vsd/Double(vArray.count)
            vsd = sqrt(vsd)
            aveStr = String(format:"%.2f",vav)
            sdStr = String(format:"%.2f",vsd)
            avesdStr = "AVE:" + aveStr + "  SD:" + sdStr
        }
        idStr = "ID:" + idString + "  "
        dateString.draw(at: CGPoint(x: 25, y: 60), withAttributes: [
            NSAttributedString.Key.foregroundColor : UIColor.black,
            NSAttributedString.Key.font : UIFont.monospacedDigitSystemFont(ofSize: 15, weight: UIFont.Weight.regular)])
        idStr.draw(at: CGPoint(x: 25, y: 80), withAttributes: [
            NSAttributedString.Key.foregroundColor : UIColor.black,
            NSAttributedString.Key.font : UIFont.monospacedDigitSystemFont(ofSize: 15, weight: UIFont.Weight.regular)])
        avesdStr.draw(at: CGPoint(x: 230, y: 70), withAttributes: [
            NSAttributedString.Key.foregroundColor : UIColor.black,
            NSAttributedString.Key.font : UIFont.monospacedDigitSystemFont(ofSize: 25, weight: UIFont.Weight.regular)])
        UIColor.black.setStroke()

        var dStr:String="angle "// + String(dArray[0]) + " " + String(dArray[1])
        var sStr:String="sensor"// + String(sArray[0]) + " " + String(sArray[1])
        var vStr:String="S V V"// + String(vArray[0]) + " " + String(vArray[1])
        dStr.draw(at: CGPoint(x: 25, y: 0), withAttributes: [
            NSAttributedString.Key.foregroundColor : UIColor.black,
            NSAttributedString.Key.font : UIFont.monospacedDigitSystemFont(ofSize: 13, weight: UIFont.Weight.regular)])
        sStr.draw(at: CGPoint(x: 25, y: 20-2), withAttributes: [
            NSAttributedString.Key.foregroundColor : UIColor.black,
            NSAttributedString.Key.font : UIFont.monospacedDigitSystemFont(ofSize: 13, weight: UIFont.Weight.regular)])
        vStr.draw(at: CGPoint(x: 25, y: 40-4), withAttributes: [
            NSAttributedString.Key.foregroundColor : UIColor.black,
            NSAttributedString.Key.font : UIFont.monospacedDigitSystemFont(ofSize: 13, weight: UIFont.Weight.regular)])
        
        for i in 0..<10{//vArray.count{
            if(i<dArray.count){
                dStr=String(format:"%.1f",dArray[i])
                sStr=String(sArray[i])
                vStr=String(vArray[i])
            }else{
                dStr="---"
                sStr="---"
                vStr="---"
            }
            dStr.draw(at: CGPoint(x: 75+i*41, y: 0), withAttributes: [
                NSAttributedString.Key.foregroundColor : UIColor.black,
                NSAttributedString.Key.font : UIFont.monospacedDigitSystemFont(ofSize: 13, weight: UIFont.Weight.regular)])
            sStr.draw(at: CGPoint(x: 75+i*41, y: 20-2), withAttributes: [
                NSAttributedString.Key.foregroundColor : UIColor.black,
                NSAttributedString.Key.font : UIFont.monospacedDigitSystemFont(ofSize: 13, weight: UIFont.Weight.regular)])
            vStr.draw(at: CGPoint(x: 75+i*41, y: 40-4), withAttributes: [
                NSAttributedString.Key.foregroundColor : UIColor.black,
                NSAttributedString.Key.font : UIFont.monospacedDigitSystemFont(ofSize: 13, weight: UIFont.Weight.regular)])

        }
      // イメージコンテキストからUIImageを作る
        let image = UIGraphicsGetImageFromCurrentImageContext()
        // イメージ処理の終了
        UIGraphicsEndImageContext()
        return image!
    }
    func getUserDefault(str:String,ret:Int) -> Int{//getUserDefault_one
        if (UserDefaults.standard.object(forKey: str) != nil){//keyが設定してなければretをセット
            return UserDefaults.standard.integer(forKey:str)
        }else{
            UserDefaults.standard.set(ret, forKey: str)
            return ret
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.shared.beginReceivingRemoteControlEvents()
        self.becomeFirstResponder()
        sound(snd:"silence")
        _ = getUserDefault(str:"circleDiameter",ret:dia0)
        _ = getUserDefault(str:"lineWidth",ret:width0)
        _ = getUserDefault(str:"VROnOff",ret:0)
        _ = getUserDefault(str:"VRLocationX",ret:0)
        setupGameController()
    }
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
    override var prefersStatusBarHidden: Bool {
        return true
    }
    func loadSVVdata(filename:String)->String{
        if let dir = FileManager.default.urls( for: .documentDirectory, in: .userDomainMask ).first {

            let path_file_name = dir.appendingPathComponent( filename )

            do {

                let text = try String( contentsOf: path_file_name, encoding: String.Encoding.utf8 )
                return text

            } catch {
                print("SVVdata read error")//エラー処理
            }
        }
        return ""
    }
    // Setup: Game Controller
    func setupGameController() {
        NotificationCenter.default.addObserver(
                self, selector: #selector(self.handleControllerDidConnect),
                name: NSNotification.Name.GCControllerDidConnect, object: nil)
          
        NotificationCenter.default.addObserver(
              self, selector: #selector(self.handleControllerDidDisconnect),
              name: NSNotification.Name.GCControllerDidDisconnect, object: nil)
          
        guard let controller = GCController.controllers().first else {
              return
        }
        registerGameController(controller)
    }
    func setRight(but:UIButton){
        let ww=view.bounds.width
        let wh=view.bounds.height
        let bw=ww/6
        let bh=bw*15/44
        let sp=(ww/6)/6
        let by=wh-bh-sp*2/3
        but.frame = CGRect(x: sp*5+bw*4, y: by, width: bw, height: bh)
    }
    func setButtons(){
        let ww=view.bounds.width
        let wh=view.bounds.height
        let logoh=ww*84/1300
        let bw=ww/6
        //let bw_help=bw/2
        let bh=bw*15/44
        let sp=(ww/6)/6
        let by=wh-bh-sp*2/3
        logoImage.frame = CGRect(x:0,y:0,width:ww,height:logoh)
        listButton.frame = CGRect(x: sp, y: by, width: bw, height: bh)
        saveButton.frame = CGRect(x:sp*2+bw*1,y:by,width:bw,height:bh)
        startButton.frame = CGRect(x: sp*3+bw*2, y: by, width: bw, height: bh)//440*150
        setteiButton.frame = CGRect(x:sp*4+bw*3,y:by,width:bw,height:bh)
        helpButton.frame = CGRect(x:sp*5+bw*4,y:by,width:bw,height:bh)
        titleImage.frame = CGRect(x: 0, y: logoh, width: ww, height: wh-logoh-bh*3/2)
        listButton.layer.cornerRadius=5
        saveButton.layer.cornerRadius=5
        startButton.layer.cornerRadius=5
        setteiButton.layer.cornerRadius=5
        helpButton.layer.cornerRadius=5
    }
    func setViews(){
        if(sArray.count<1){
               titleImage.alpha=1
               resultView.alpha=0
           }else{
               if savedFlag==false{
                   titleImage.alpha=0
                   resultView.alpha=1
               }else{
                   titleImage.alpha=0.1
                   resultView.alpha=0.8
               }
               resultView.image=drawWaves(width: 500, height: 100)
           }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setButtons()
        setViews()
/*        if(sArray.count<1){
            titleImage.alpha=1
            resultView.alpha=0
        }else{
            if savedFlag==false{
                titleImage.alpha=0
                resultView.alpha=1
            }else{
                titleImage.alpha=0.1
                resultView.alpha=0.8
            }
            resultView.image=drawWaves(width: 500, height: 100)
        }*/
 //       print(savedFlag)
 //       print(sArray.count)
    }
    func sound(snd:String){
        if let soundharu = NSDataAsset(name: snd) {
            soundPlayer = try? AVAudioPlayer(data: soundharu.data)
            soundPlayer?.play() // → これで音が鳴る
        }
    }
    
    @IBAction func startSVV(_ sender: Any) {
        //print("startSVV : ",savedFlag)
        sound(snd:"silence")
        if savedFlag == false {
            //setButtons(mode: false)
            let alert = UIAlertController(
                title: "You are erasing SVV Data.",
                message: "OK ?",
                preferredStyle: .alert)
            // アラートにボタンをつける
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                //self.setButtons(mode: false)
                self.savedFlag=false
                self.startSVV()
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel,handler:{ action in
                //self.setButtons(mode: true)
                //         print("****cancel")
            }))
            // アラート表示
            self.present(alert, animated: true, completion: nil)
            //１：直ぐここと２を通る
        }else{
            //setButtons(mode: false)
            self.startSVV()
        }
        //２：直ぐここを通る
    }
    func startSVV(){
        let nextView = storyboard?.instantiateViewController(withIdentifier: "SVV") as! SVVViewController
        self.present(nextView, animated: true, completion: nil)
    }
//    @objc func viewWillEnterForeground(_ notification: Notification?) {
//        print("viewWillEnterForground")
//        sound(snd:"silence")
//    }
    override func remoteControlReceived(with event: UIEvent?) {
        guard event?.type == .remoteControl else { return }
        if let event = event {
            switch event.subtype {
                
            case .remoteControlPlay:
 //               print("Play")
                startSVV(1)
            case .remoteControlPause:
                print("Pause")
            case .remoteControlStop:
                print("Stop")
            case .remoteControlTogglePlayPause:
   //             print("TogglePlayPause")
                startSVV(1)
           case .remoteControlNextTrack:
                print("NextTrack")
            case .remoteControlPreviousTrack:
                print("PreviousTrack")
            case .remoteControlBeginSeekingBackward:
                print("BeginSeekingBackward")
            case .remoteControlEndSeekingBackward:
                print("EndSeekingBackward")
            case .remoteControlBeginSeekingForward:
                print("BeginSeekingForward")
            case .remoteControlEndSeekingForward:
                print("EndSeekingForward")
            default:
                print("Others")
            }
        }
    }
    @IBAction func returnToMe(segue: UIStoryboardSegue) {
        print("rewind")
    }
}
