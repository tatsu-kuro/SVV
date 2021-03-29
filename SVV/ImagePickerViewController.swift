//
//  ImagePickerViewController.swift
//  SVV
//
//  Created by kuroda tatsuaki on 2019/07/07.
//  Copyright © 2019 tatsuaki.kuroda. All rights reserved.
//

import UIKit
import MessageUI

class ImagePickerViewController: UIViewController, MFMailComposeViewControllerDelegate{
    @IBOutlet weak var changeButton: UIButton!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var gomiButton: UIButton!
    @IBOutlet weak var mailButton: UIButton!
    @IBOutlet weak var exitButton: UIButton!
    var type:Int=0
    @IBAction func typeButton(_ sender: Any) {
        let text=loadSVVdata(filename: "SVVdata.txt")
        if text.count<10 {
            return
        }
        let str = text.components(separatedBy: "\n")
        var strView:String=""
        if(type%3<2){
            for i in 0..<str.count-1{
                let str1 = str[i].components(separatedBy:",")
                var n:Int=0
                for j in 4..<14{
                    if str1[j] != ""{
                        n += 1
                    }
                }
                strView += str1[0] + " ID:" + str1[1] +  " AVE:" + str1[2] + " SD:" + str1[3] +  " (\(n))" + "\n"
                if type%3==1{
                    strView += "angle:"
                    for j in 4..<14{
                        if str1[j] != ""{
                        strView += str1[j] + ","
                        }
                    }
                    strView += "\n"
                    strView += "sensor:"
                    for j in 14..<24{
                        if str1[j] != ""{
                            strView += str1[j] + ","
                        }
                    }
                    strView += "\n"
                    strView += "SVV:"
                    for j in 24..<34{
                        if str1[j] != ""{
                            strView += str1[j] + ","
                        }
                    }
                    strView += "\n\n"
                }
            }
        }
        else if(type%3==2){
            strView=text
        }
        textView.text=strView
        type += 1
 //       print(type%3)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setButtons_init()
        typeButton(1)
    }
    func loadSVVdata(filename:String)->String{
        if let dir = FileManager.default.urls( for: .documentDirectory, in: .userDomainMask ).first {
            let path_file_name = dir.appendingPathComponent( filename )
            do {
                let text = try String( contentsOf: path_file_name, encoding: String.Encoding.utf8 )
                return text//print( "SVVdata:",text )
            } catch {
                print("SVVdata read error")//エラー処理
            }
        }
        return ""
    }
    func setButtons_init(){
        let ww=view.bounds.width
        let wh=view.bounds.height
        let bw=ww/6
        let bh=bw*15/44
        var sp=(ww/6)/6
        let by=wh-bh-sp*2/3
        changeButton.frame = CGRect(x: sp, y: by, width: bw, height: bh)
        mailButton.frame = CGRect(x:sp*2+bw*1,y:by,width:bw,height:bh)
        gomiButton.frame = CGRect(x: sp*3+bw*2, y: by, width: bw, height: bh)//440*150
        exitButton.frame = CGRect(x:sp*5+bw*4, y: by, width:bw, height: bh)
        changeButton.layer.cornerRadius=5
        mailButton.layer.cornerRadius=5
        gomiButton.layer.cornerRadius=5
        exitButton.layer.cornerRadius=5
        sp = sp/2
        self.textView.frame = CGRect(x:sp,y:sp,width:ww-2*sp,height:wh-4*sp-bh)
        let text:String=loadSVVdata(filename: "SVVdata.txt")
        self.textView.text=text
    }

    @IBAction func mailOne(_ sender: Any) {
        let mailViewController = MFMailComposeViewController()
        mailViewController.mailComposeDelegate = self
        mailViewController.setSubject("SVV")
        //let text:String=loadSVVdata(filename: "SVVdata.txt")
        mailViewController.setMessageBody(textView.text, isHTML: false)
        present(mailViewController, animated: true, completion: nil)
    }
 
    @IBAction func deleOne(_ sender: Any) {
        let alert = UIAlertController(
            title: "Erasing all Data of SVV !!.",
            message: "OK ?",
            preferredStyle: .alert)
        // アラートにボタンをつける
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            let file_name = "SVVdata.txt"
            let text = ""//self.loadSVVdata(filename: "SVVdata.txt")

            if let dir = FileManager.default.urls( for: .documentDirectory, in: .userDomainMask ).first {
                self.textView.text=""
                let path_file_name = dir.appendingPathComponent( file_name )

                do {
                    try text.write( to: path_file_name, atomically: false, encoding: String.Encoding.utf8 )

                } catch {
                    print("SVVdata.txt write err")//エラー処理
                }
            }
            //self.setButtons(mode: false)
            //self.savedFlag=false
            //self.startSVV()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel,handler:{ action in
            //self.setButtons(mode: true)
            //         print("****cancel")
        }))
        // アラート表示
        self.present(alert, animated: true, completion: nil)
        //１：直ぐここと２を通る

    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {//errorの時に通る
        
        switch result {
        case .cancelled:
            print("cancel")
        case .saved:
            print("save")
        case .sent:
            print("send")
        case .failed:
            print("fail")
        default:
            print("error")
        }
        self.dismiss(animated: true, completion: nil)
    }
}
