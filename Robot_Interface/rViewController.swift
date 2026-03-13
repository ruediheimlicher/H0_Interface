//
//  ViewController.swift
//  Digital_Power_Interface
//
//  Created by Ruedi Heimlicher on 02.11.2014.
//  Copyright (c) 2014 Ruedi Heimlicher. All rights reserved.
//
// Bridging-Header: https://stackoverflow.com/questions/24146677/swift-bridging-header-import-issue/31717280#31717280

import Cocoa
import Foundation

public var lastDataRead = Data.init(count:64)
public var boardindex = 0

var globalusbstatus = 0

class rH0Controller:NSViewController ,NSWindowDelegate
{
   
   let notokimage :NSImage = NSImage(named:NSImage.Name(rawValue: "notok_image"))!
   let okimage :NSImage = NSImage(named:NSImage.Name(rawValue: "ok_image"))!
   
   @IBOutlet weak var USBKontrolle: NSImageView!
   
   override func viewDidLoad()
   {
      super.viewDidLoad()
      view.window?.delegate = self // https://stackoverflow.com/questions/44685445/trying-to-know-when-a-window-closes-in-a-macos-document-based-application
      self.view.window?.acceptsMouseMovedEvents = true
 
   }
   override func viewDidAppear() 
   {
      print("viewDidAppear")
   } // viewDidAppear

} // class rH0Controller


class rZeigerView:NSView
{
   var zeigerpfad: NSBezierPath = NSBezierPath()
   var feld = frame
   override init(frame frameRect: NSRect) 
   {
      super.init(frame:frameRect);
      self.wantsLayer = true
      //self.layer?.backgroundColor = NSColor.red.cgColor
      let w:CGFloat = bounds.size.width
      let h:CGFloat = bounds.size.height
      let mittex:CGFloat = bounds.size.width / 2
      let mittey:CGFloat = bounds.size.height / 2
      zeigerpfad.move(to: NSMakePoint(mittex, 0)) // start point
      zeigerpfad.line(to: NSMakePoint(mittex, h))
      //    zeigerpfad.rotateAroundCenter(angle: 10)
      //zeigerpfad.stroke()
   }
   
   required init?(coder: NSCoder) {
      super.init(coder: coder)
   }
   
   func setFeld(feld: NSRect)
   {
      //   self.setBoundsOrigin(feld.origin)
      self.setBoundsOrigin(feld.origin)
      self.setBoundsSize(feld.size)
      
      
   }
   
   override func draw(_ dirtyRect: NSRect)
   {
      let blackColor = NSColor(red: 0.0, green: 0.0, blue: 1.0, alpha: 1.0)
      blackColor.set()
      //zeigerpfad.stroke()
      //  zeigerpfad.move(to: NSMakePoint(20, 75))
      /*
       var bPath: NSBezierPath = NSBezierPath(rect:dirtyRect)
       var lineDash:[CGFloat] = [20.0,5.0,5.0]
       bPath.move(to: NSMakePoint(20, 75))
       bPath.line(to: NSMakePoint(dirtyRect.size.width - 20, 75))
       bPath.lineWidth = 10.0
       bPath.setLineDash(lineDash, count: 3, phase: 0.0)
       bPath.stroke()
       
       
       var cPath: NSBezierPath = NSBezierPath(rect:dirtyRect)
       cPath.move(to: NSMakePoint(10, 10))
       cPath.curve(to: NSMakePoint(dirtyRect.size.width - 20, 25), controlPoint1: NSMakePoint(10, 10), controlPoint2: NSMakePoint(15, 20))
       cPath.lineWidth = 4.0
       
       cPath.stroke()
       */
   }
   
}


struct position
{
   var x:UInt16 = 0
   var y:UInt16 = 0
   var z:UInt16 = 0
   
}
//MARK: rServoPfad
class rServoPfad 
{
   var pfadarray = [position]()
   var delta = 1 // Abstand der Schritte
   required init?() 
   {
      //super.init()
      //Swift.print("servoPfad init")
      var startposition = position()
      startposition.x = 0
      startposition.y = 0
      startposition.z = 0
      //     pfadarray.append(startposition)
      
   }
   
   func setStartposition(x:UInt16, y:UInt16, z:UInt16)
   {
      let anz = pfadarray.count
      if (pfadarray.count > 0)
      {
         pfadarray[0].x = x
         pfadarray[0].y = y
         pfadarray[0].z = z
      }
      else
      {
         addPosition(newx: x, newy: y, newz: z)
      }
   }
   
   func addPosition(newx:UInt16, newy:UInt16, newz:UInt16)
   {
      let newposition = position(x:newx,y:newy,z:newz)
      pfadarray.append(newposition)
   }
   
   func clearPfadarray()
   {
      pfadarray.removeAll()
   }
   
   func anzahlPunkte() -> Int
   {
      return Int(pfadarray.count)
   }
   
}

//MARK: TABVIEW
class rDeviceTabViewController: NSTabViewController 
{
   
   override func tabView(_ tabView: NSTabView, didSelect tabViewItem: NSTabViewItem?) 
   {
      let identifier:String = tabViewItem?.identifier as! String
      print("DeviceTab identifier: \(String(describing: identifier)) usbstatus: \(globalusbstatus)")
      let views = self.view.subviews
      print("DeviceTab subviews: \(views)")
      // let sup = self.view.superview
      // print("DeviceTab superview: \(sup) ident: \(sup?.identifier)")
      //let supsup = self.view.superview?.superview
      //print("DeviceTab supsup: \(supsup) ident: \(supsup?.identifier)")
      //print("subviews: \(supsup?.subviews)")
      
      var userinformation:[String : Any]
      userinformation = ["message":"tabview",  "ident": identifier, ] as [String : Any]
      let nc = NotificationCenter.default
      nc.post(name:Notification.Name(rawValue:"tabview"),
              object: nil,
              userInfo: userinformation)
      
      userinformation = ["message":"usb"] as [String : Any]
      /*
       nc.post(name:Notification.Name(rawValue:"usb_status"),
       object: nil,
       userInfo: userinformation)
       */
   }
   
}

let LOK_0_ADDRESS:UInt8 = 0xA0
let LOK_0_SPEED:UInt8 = 0xB0
let LOK_0_DIR:UInt8 = 0xC0
let LOK_0_FUNKTION:UInt8 = 0xD0
let LOK_0_PAUSE:UInt8 = 0xE0

let LOK_FAKTOR0:Float = 1
let LOK0_START:UInt16 = 0  // Startwert Slider 1
let LOK0_OFFSET:UInt16 = 8 // Startwert low


// 
let LOK_1_ADDRESS:UInt8 = 0xA1
let LOK_1_SPEED:UInt8 = 0xB1
let LOK_1_DIR:UInt8 = 0xC1
let LOK_1_FUNKTION:UInt8 = 0xD1
let LOK_1_PAUSE:UInt8 = 0xE1

let LOK_1:UInt8 = 0xA1
let LOK1_START:UInt16 = 0 // Startwert Slider 1
let LOK1_OFFSET:UInt16 = 8 // Startwert low
let LOK_FAKTOR1:Float = 1


let LOK_2_ADDRESS:UInt8 = 0xA2
let LOK_2_SPEED:UInt8 = 0xB2
let LOK_2_DIR:UInt8 = 0xC2
let LOK_2_FUNKTION:UInt8 = 0xD2
let LOK_2_PAUSE:UInt8 = 0xE2

let LOK_2:UInt8 = 0xA2
let LOK2_START:UInt16 = 0 // Startwert Slider 1
let LOK2_OFFSET:UInt16 = 8 // starteinstellung
let LOK_FAKTOR2:Float = 1

let LOK_3_ADDRESS:UInt8 = 0xA3
let LOK_3_SPEED:UInt8 = 0xB3
let LOK_3_DIR:UInt8 = 0xC3
let LOK_3_FUNKTION:UInt8 = 0xD3
let LOK_3_PAUSE:UInt8 = 0xE3
let ANZLOKS:Int = 4


//MARK: ViewController
class rViewController: NSViewController,  NSWindowDelegate
{
   //@IBOutlet weak var USBKontrolle: NSTextField!
   //@IBOutlet weak var BoardFeld: NSTextField!
   
   let USBATTACHED = 5
   let USBREMOVED  = 6
   
   
   let SCAN:UInt8 = 0xF0
   
   
   
   var hintergrundfarbe = NSColor()
   
   let notokimage :NSImage = NSImage(named:NSImage.Name(rawValue: "notok_image"))!
   let okimage :NSImage = NSImage(named:NSImage.Name(rawValue: "ok_image"))!
   // Robot
   var z0:Float = 30 // Hoehe Drehpunkt 0
   var l0:Float = 1// laenge Arm 0
   var l1:Float = 1 // laenge Arm 1
   var l2:Float = 1 // laenge Arm 2
   
   var phi0:Float = 0 // Winkel Arm 0 von Senkrechte
   var phi1:Float = 0 // Winkel Arm 1
   var phi2:Float = 0 // Winkel Arm 2
   // var  myUSBController:USBController
   
   var addresscodearray = [LOK_0_ADDRESS,LOK_1_ADDRESS,LOK_2_ADDRESS,LOK_3_ADDRESS]
   var speedcodearray = [LOK_0_SPEED,LOK_1_SPEED,LOK_2_SPEED,LOK_3_SPEED]
   var dircodearray = [LOK_0_DIR,LOK_1_DIR,LOK_2_DIR,LOK_3_DIR]
   var funktioncoderray = [LOK_0_FUNKTION,LOK_1_FUNKTION,LOK_2_FUNKTION,LOK_3_FUNKTION]
   
   var addressarray = Array(repeating: Array(repeating: UInt8(0x00), count: ANZLOKS), count: 4)
   
   var speedarray:[UInt8] = [UInt8](repeating: 0x00, count: ANZLOKS)
   
   var speedautocounter = 0
   var sinarray:[UInt8] = [10,11,12,13,14,14,13,12,11,10,8,7,6,5,5,6,7,8,9]
   var pause:UInt8 = 5
   
   var stepautocounter = 0
   
   var firstrun = 1 // Task in Startloop
   
   var sourcestatus:UInt8 = 0
   
   
   var lookuptable = [String]()
   var lookupindex:Int = 0
   var lookuptableArray = [UInt8]()
   
   var startzeit:Int64 = 0
   
   
   // var usbzugang:
   var usbstatus: Int32 = 0
   
   var teensy = usb_teensy()
   
   var servoPfad = rServoPfad()
   
   var selectedDevice:String = ""
   
   var hgfarbe  = NSColor()
   
   
   
   var formatter = NumberFormatter()
   
   
   var achse0_start:UInt16  = ACHSE0_START;
   var achse0_max:UInt16   = ACHSE0_MAX;
   
   var H0_PList = UserDefaults.standard 
   
   // https://learnappmaking.com/plist-property-list-swift-how-to/
   struct Preferences: Codable {
      var webserviceURL:String
      var itemsPerPage:Int
      var backupEnabled:Bool
      var robot1_offset:Int
   }
   
   func windowWillClose(_ aNotification: Notification) {
      print("VC windowWillClose")
      let nc = NotificationCenter.default
  //    nc.post(name:Notification.Name(rawValue:"beenden"),
  //            object: nil,
  //            userInfo: nil)
      
   }
   
   override func viewDidLoad()
   {
      super.viewDidLoad()
      view.window?.delegate = self // https://stackoverflow.com/questions/44685445/trying-to-know-when-a-window-closes-in-a-macos-document-based-application
      self.view.window?.acceptsMouseMovedEvents = true
      
      self.view.wantsLayer = true
      hintergrundfarbe  = NSColor.init(red: 0.25, 
                                       green: 0.45, 
                                       blue: 0.45, 
                                       alpha: 0.25)
      self.view.layer?.backgroundColor =  hintergrundfarbe.cgColor
      
      formatter.maximumFractionDigits = 1
      formatter.minimumFractionDigits = 2
      formatter.minimumIntegerDigits = 1
      //formatter.roundingMode = .down
      
      
          
      //USB_OK.backgroundColor = NSColor.greenColor()
      // Do any additional setup after loading the view.
      let newdataname = Notification.Name("newdata")
      NotificationCenter.default.addObserver(self, selector:#selector(newDataAktion(_:)),name:newdataname,object:nil)
      NotificationCenter.default.addObserver(self, selector:#selector(joystickAktion(_:)),name:NSNotification.Name(rawValue: "joystick"),object:nil)
      NotificationCenter.default.addObserver(self, selector:#selector(tabviewAktion(_:)),name:NSNotification.Name(rawValue: "tabview"),object:nil)
      NotificationCenter.default.addObserver(self, selector: #selector(beendenAktion), name:NSNotification.Name(rawValue: "beenden"), object: nil)
      
      NotificationCenter.default.addObserver(self, selector:#selector(HIDInputReportReceivedAktion(_:)),name:NSNotification.Name(rawValue: "HIDInputReportReceived"),object:nil)
      
      NotificationCenter.default.addObserver(self, selector:#selector(usbattachAktion(_:)),name:NSNotification.Name(rawValue: "usb_attach"),object:nil)
      
      NotificationCenter.default.addObserver(self, selector:#selector(usbstatusAktion(_:)),name:NSNotification.Name(rawValue: "usb_status"),object:nil)
      
      NotificationCenter.default.addObserver(self, selector:#selector(weichenstatusAktion(_:)),name:NSNotification.Name(rawValue: "weichenstatus"),object:nil)
      
      
       
      let name = "John Doe"
      let robot1 = 300
      //      H0_PList.set(name, forKey: "name")
      H0_PList.set(robot1, forKey: "robot1")
      
      var preferences = Preferences(webserviceURL: "https://api.twitter.com", itemsPerPage: 12, backupEnabled: false,robot1_offset: 300)
      
      preferences.robot1_offset = 400
      
      
      let encoder = PropertyListEncoder()
      encoder.outputFormat = .xml
      
      let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("Robot/Preferences.plist")
      
      do {
         let data = try encoder.encode(preferences)
         try data.write(to: path)
      } catch {
         print(error)
      }
      
      if  let path        = Bundle.main.path(forResource: "Preferences", ofType: "plist"),
          let xml         = FileManager.default.contents(atPath: path),
          let preferences = try? PropertyListDecoder().decode(Preferences.self, from: xml)
      {
         print(preferences.webserviceURL)
      }
      
      // servoPfad
      servoPfad?.setStartposition(x: 0x800, y: 0x800, z: 0)
      
      // Pot 0
      /* 
       Pot0_Slider.integerValue = Int(ACHSE0_START)
       Pot0_Feld.integerValue = Int(ACHSE0_START)
       let intpos0 = UInt16(Float(ACHSE0_START) * FAKTOR0)
       Pot0_Feld.integerValue = Int(UInt16(Float(ACHSE0_START) * FAKTOR0))
       Pot0_Stepper_L.integerValue = 0
       Pot0_Stepper_L_Feld.integerValue = 0
       Pot0_Stepper_H.integerValue = Int(Pot0_Slider.maxValue)
       Pot0_Stepper_H_Feld.integerValue = Int(Pot0_Slider.maxValue)
       
       // Pot 1
       Pot1_Slider.integerValue = Int(ACHSE1_START)
       //Pot1_Feld.integerValue = Int(ACHSE1_START)
       let intpos1 = UInt16(Float(ACHSE1_START) * FAKTOR1)
       Pot1_Feld.integerValue = Int(UInt16(Float(ACHSE1_START) * FAKTOR1))
       //Pot1_Feld.integerValue = Int(intpos1)
       Pot1_Stepper_L.integerValue = 0
       Pot1_Stepper_L_Feld.integerValue = 0 
       Pot1_Stepper_H.integerValue = Int(Pot1_Slider.maxValue)
       Pot1_Stepper_H_Feld.integerValue = Int(Pot1_Slider.maxValue)
       print("intpos0: \(intpos0) intpos1: \(intpos1)")
       // Pot 2
       Pot2_Slider.integerValue = Int(ACHSE2_START)
       Pot2_Feld.integerValue = Int(ACHSE2_START)
       Pot2_Stepper_L.integerValue = 0
       Pot2_Stepper_L_Feld.integerValue = 0 
       Pot2_Stepper_H.integerValue = Int(Pot2_Slider.maxValue)
       Pot2_Stepper_H_Feld.integerValue = Int(Pot2_Slider.maxValue)
       
       // Pot 3
       Pot3_Slider.integerValue = Int(ACHSE3_START)
       Pot3_Feld.integerValue = Int(ACHSE3_START)
       Pot3_Stepper_L.integerValue = 0
       Pot3_Stepper_L_Feld.integerValue = 0 
       Pot3_Stepper_H.integerValue = Int(Pot3_Slider.maxValue)
       Pot3_Stepper_H_Feld.integerValue = Int(Pot3_Slider.maxValue)
       
       
       teensy.write_byteArray[ACHSE0_BYTE_H] = UInt8(((ACHSE0_START) & 0xFF00) >> 8) // hb
       teensy.write_byteArray[ACHSE0_BYTE_L] = UInt8(((ACHSE0_START) & 0x00FF) & 0xFF) // lb
       
       teensy.write_byteArray[ACHSE1_BYTE_H] = UInt8(((ACHSE1_START) & 0xFF00) >> 8) // hb
       teensy.write_byteArray[ACHSE1_BYTE_L] = UInt8(((ACHSE1_START) & 0x00FF) & 0xFF) // lb
       
       teensy.write_byteArray[0] = SET_0
       */
   }
   
   override func viewDidAppear() 
   {
      print("viewDidAppear")
      let nc = NotificationCenter.default
      var userinformation:[String : Any]
      var manufactorername = "-"
      
      self.view.window?.delegate = self // as? NSWindowDelegate 
      
      
      let h0 = NSTabViewItem(identifier: "H0") as NSTabViewItem
       let subs = h0.view?.subviews ?? []
       print("h0.view?.subviews.count: \(subs.count)")

      
      
      startHIDManager()
      var teensypresent:Int32 = 0
      teensypresent = teensy.dev_present()
      
      
      if (teensypresent == 0) // Noch nichts eingesteckt
      {
         //USBKontrolle.stringValue = "USB OFF"
         //USB_OK_Feld.image = notokimage
         let warnung = NSAlert.init()
         warnung.messageText = "USB"
         warnung.messageText = "viewDidAppear: Kein USB-Device"
         warnung.addButton(withTitle: "OK")
         warnung.runModal()
         
         
         usbstatus = Int32(0)
         globalusbstatus = 0
         //      USBKontrolle.stringValue="USB OFF"
         
         
      }
      
      //usbstatus = Int32(1)
      self.view.window?.delegate = self //as? NSWindowDelegate 
      
      
      
      self.view.window?.makeKey()
      
      /*
       userinformation = ["message":"usb", "usbstatus": usbstatus,"manufactorer": manufactorername] as [String : Any]
       nc.post(name:Notification.Name(rawValue:"usb_status"),
       object: nil,
       userInfo: userinformation)
       */
   }
   
   @objc  func weichenstatusAktion(_ notification:Notification) 
   {
      let info = notification.userInfo
      print("VC weichenstatusAktion info: \(info)")
      //guard var  weichenstatusint = notification.userInfo?["weichenstatus"]as? [Int] else {return}
      
      guard var weichendata   = notification.userInfo?["data"]as? UInt8 else 
      {
         print("weichetag tag ist nil")
         return
         
      }
      guard var weiche   = notification.userInfo?["weiche"]as? UInt8 else 
      {
         print("weiche tag ist nil")
         return
         
      }
      print("VC weichenstatusAktion weiche: \(weiche)")
      
      guard var ablenkung   = notification.userInfo?["ablenkung"]as? UInt8 else 
      {
         print("ablenkung tag ist nil")
         return
         
      }
      print("VC weichenstatusAktion ablenkung: \(ablenkung)")
      
      let weichenstatus:[UInt8] = [1,2,2,2]
      teensy.write_byteArray[0] =  0b10111111// code
      
      //loknummer = ANZLOKS-1
      
      let code = 0xBF
      
      let loknummer = ANZLOKS-1
      
      teensy.write_byteArray[20] = UInt8(code)
      teensy.write_byteArray[20] = UInt8(loknummer)
      teensy.write_byteArray[21] = 2 // sourcestatus
      
      
      
      addressarray[loknummer][0] = UInt8(weichenstatus[0])
      addressarray[loknummer][1] = UInt8(weichenstatus[1])
      addressarray[loknummer][2] = UInt8(weichenstatus[2])
      addressarray[loknummer][3] = UInt8(weichenstatus[3])
      
      teensy.write_byteArray[16] = ablenkung    // funktion
      teensy.write_byteArray[17] = weiche       // speed
      
      for i in 0...3
      {
         teensy.write_byteArray[8 + i] = addressarray[ANZLOKS-1][i]
      }
      
      print("VC  weichenstatusAktion write_byteArray: \(teensy.write_byteArray)")
      if (usbstatus > 0)
      {
         let senderfolg = teensy.send_USB()
         print("VC weichenstatusAktion senderfolg: \(senderfolg)")
      }
      
      
   }
   
   @objc func usbstatusAktion(_ notification:Notification) 
   {
      let info = notification.userInfo
      let status = info?["usbstatus"] as! Int32 // 
      let manufactorer = info?["manufactorer"] as! String
      print("VC usbstatusAktion:\t \(status) manufactorer: \(manufactorer)")
      usbstatus = Int32(status)
   }
   
   
   @objc func HIDInputReportReceivedAktion(_ notification:Notification)
   {
      print("VC HIDInputReportReceivedAktion: \(notification)")
      let produkt = notification.userInfo?["product"] as! Int
      let produktInt = Int32(produkt)
      switch (produktInt)
      {
      case TEENSY2_PID:
         print("HW HIDInputReportReceivedAktion Teensy2")
         //BoardFeld.stringValue = "Teensy2"
         boardindex = 0
         //boardnumber = 0;
         break
      case TEENSY3_PID:
         print("HW HIDInputReportReceivedAktion Teensy3")
         //BoardFeld.stringValue = "Teensy3"
         boardindex = 1
         if (teensy.read_OK.boolValue == false)
         {
            print("teensy.read_OK ist false")
            // let result = teensy.start_read_USB(true, dic:timerdic)
            // print("teensy.read_OK status ist: \(result)")
         }
         
         break
      case 0:
         print("HW HIDInputReportReceivedAktion disconnected")
         usbstatus = 0
         //BoardFeld.stringValue = "--"
      default:
         //BoardFeld.stringValue = "--"
         break
      }
      
      
      //var timerdic:[String:Any] = [String:Any]()
      //timerdic["home"] = 0
      
      
      //    let result = teensy.start_read_USB(true, dic:timerdic)
      //print("teensy.read_OK status ist: \(result)")
   }
   
   
   @objc func beendenAktion(_ notification:Notification) 
   {
      
      print("VC beendenAktion")
      
      /*
      UserDefaults.standard.set(a0.indexOfSelectedItem, forKey: "a0index")
      UserDefaults.standard.set(a1.indexOfSelectedItem, forKey: "a1index")
      UserDefaults.standard.set(a2.indexOfSelectedItem, forKey: "a2index")
      UserDefaults.standard.set(a3.indexOfSelectedItem, forKey: "a3index")
*/
     
   }
   
   
   @objc func tabviewAktion(_ notification:Notification) 
   {
      let info = notification.userInfo
      let ident:String = info?["ident"] as! String  // 
      //print("Basis tabviewAktion:\t \(ident)")
      selectedDevice = ident
   }
   
   
   
   @objc func joystickAktion(_ notification:Notification) 
   {
      let info = notification.userInfo
      let punkt:CGPoint = info?["punkt"] as! CGPoint
      let wegindex:Int = info?["index"] as! Int // 
      let first:Int = info?["first"] as! Int
      //print("xxx joystickAktion:\t \(punkt)")
      //print("x: \(punkt.x) y: \(punkt.y) index: \(wegindex) first: \(first)")
      
   }
   
   
   @objc func newDataAktion(_ notification:Notification) 
   {
      let lastData = teensy.getlastDataRead()
      //print("lastData:\t \(lastData[1])\t\(lastData[2])   ")
      var ii = 0
      while ii < 10
      {
         //print("ii: \(ii)  wert: \(lastData[ii])\t")
         ii = ii+1
      }
      return;
      let u = ((Int32(lastData[1])<<8) + Int32(lastData[2]))
      //print("hb: \(lastData[1]) lb: \(lastData[2]) u: \(u)")
      let info = notification.userInfo
      
      //print("info: \(String(describing: info))")
      //print("new Data")
      let data = notification.userInfo?["data"] as! [UInt8]
      //print("data: \(String(describing: data)) \n") // data: Optional([0, 9, 51, 0,....
      
      
      //print("lastDataRead: \(lastDataRead)   ")
      var i = 0
      while i < 10
      {
         //         print("i: \(i)  wert: \(lastDataRead[i])\t")
         i = i+1
      }
      var emitter = UInt16(data[13]) << 8  | UInt16(data[12])
      
      print("emitteradresse: \(lastDataRead[10]) emitterwerte: \(lastDataRead[12]) \(lastDataRead[13]) emitter: \(emitter)")
      //emitterFeld.integerValue = Int(emitter)
      if let d = notification.userInfo!["usbdata"]
      {
         
         //print("d: \(d)\n") // d: [0, 9, 56, 0, 0,... 
         let t = type(of:d)
         //print("typ: \(t)\n") // typ: Array<UInt8>
         
         //print("element: \(d[1])\n")
         
         //       print("d as string: \(String(describing: d))\n")
         if d != nil
         {
            //print("d not nil\n")
            var i = 0
            while i < 10
            {
               // print("i: \(i)  wert: \(d![i])\t")
               i = i+1
            }
            
         }
         
         
         //print("dic end\n")
      }
      
      //let dic = notification.userInfo as? [String:[UInt8]]
      //print("dic: \(dic ?? ["a":[123]])\n")
      
   }
   
   func tester(_ timer: Timer)
   {
      let theStringToPrint = timer.userInfo as! String
      print(theStringToPrint)
   }
   
   @IBAction func report_Slider0(_ sender: NSSlider)
   {
      teensy.write_byteArray[0] = SET_0 // Code 
      //print("report_Slider0 IntVal: \(sender.intValue)")
      
      let pos = sender.floatValue
      
      let intpos = UInt16(pos * FAKTOR0)
      let Ustring = formatter.string(from: NSNumber(value: intpos))
      
      print("report_Slider0 pos: \(pos) intpos: \(intpos)  Ustring: \(Ustring ?? "0")")
      // Pot0_Feld.stringValue  = Ustring!
      Pot0_Feld.integerValue  = Int(intpos)
      Pot0_Stepper_L.integerValue  = Int(sender.minValue) // Stepper min setzen
      Pot0_Stepper_L_Feld.integerValue = Int(sender.minValue)
      Pot0_Stepper_H.integerValue  = Int(sender.maxValue) // Stepper max setzen
      Pot0_Stepper_H_Feld.integerValue = Int(sender.maxValue)
      
      teensy.write_byteArray[ACHSE0_BYTE_H] = UInt8((intpos & 0xFF00) >> 8) // hb
      teensy.write_byteArray[ACHSE0_BYTE_L] = UInt8((intpos & 0x00FF) & 0xFF) // lb
      
      if (usbstatus > 0)
      {
         let senderfolg = teensy.send_USB()
         //print("report_Slider0 senderfolg: \(senderfolg)")
      }
   }
   /*
    @IBAction func report_goto_0(_ sender: NSButton)
    {
    print("report_goto_0")
    var x = goto_x.integerValue
    if x > Int(Pot0_Slider.maxValue)
    {
    x = Int(Pot0_Slider.maxValue)
    }
    var y = goto_y.integerValue
    if y > Int(Pot1_Slider.maxValue)
    {
    y = Int(Pot1_Slider.maxValue)
    }
    
    print("report_goto_0  x: \(x) y: \(y)")
    self.goto_0(x:Float(x),y:Float(y),z: 0)
    }
    
    
    func goto_0(x:Float, y:Float, z:Float)
    {
    teensy.write_byteArray[0] = GOTO_0
    print("goto_0 x: \(x) y: \(y)")
    // achse 0
    let intposx = UInt16(x * FAKTOR0)
    goto_x_Stepper.integerValue = Int(x) //Int(intposx)
    teensy.write_byteArray[ACHSE0_BYTE_H] = UInt8((intposx & 0xFF00) >> 8) // hb
    teensy.write_byteArray[ACHSE0_BYTE_L] = UInt8((intposx & 0x00FF) & 0xFF) // lb
    
    // Achse 1
    let intposy = UInt16(y * FAKTOR1)
    goto_y_Stepper.integerValue = Int(y)
    teensy.write_byteArray[ACHSE1_BYTE_H] = UInt8((intposy & 0xFF00) >> 8) // hb
    teensy.write_byteArray[ACHSE1_BYTE_L] = UInt8((intposy & 0x00FF) & 0xFF) // lb
    
    if (usbstatus > 0)
    {
    let senderfolg = teensy.send_USB()
    }
    
    
    }
    */
   @IBAction func report_clear_Ring(_ sender: NSButton)
   {
      print("report_clear_Ring ")
      teensy.write_byteArray[0] = CLEAR_RING
      teensy.write_byteArray[ACHSE0_BYTE_H] = UInt8(((ACHSE0_START) & 0xFF00) >> 8) // hb
      teensy.write_byteArray[ACHSE0_BYTE_L] = UInt8(((ACHSE0_START) & 0x00FF) & 0xFF) // lb
      
      teensy.write_byteArray[ACHSE1_BYTE_H] = UInt8(((ACHSE1_START) & 0xFF00) >> 8) // hb
      teensy.write_byteArray[ACHSE1_BYTE_L] = UInt8(((ACHSE1_START) & 0x00FF) & 0xFF) // lb
      
      teensy.write_byteArray[ACHSE2_BYTE_H] = UInt8(((ACHSE2_START) & 0xFF00) >> 8) // hb
      teensy.write_byteArray[ACHSE2_BYTE_L] = UInt8(((ACHSE2_START) & 0x00FF) & 0xFF) // lb
      
      teensy.write_byteArray[HYP_BYTE_H] = 0 // hb
      teensy.write_byteArray[HYP_BYTE_L] = 0 // lb
      
      teensy.write_byteArray[INDEX_BYTE_H] = 0 // hb
      teensy.write_byteArray[INDEX_BYTE_L] = 0 // lb
      Joystickfeld.clearWeg()
      servoPfad?.clearPfadarray()
      
      if (usbstatus > 0)
      {
         let senderfolg = teensy.send_USB()
      }
      
   }
   
   @IBAction func report_goto_x_Stepper(_ sender: NSStepper)
   {
      //teensy.write_byteArray[0] = SET_0 // Code 
      print("report_goto_x_Stepper IntVal: \(sender.intValue)")
      let intpos = sender.integerValue 
      goto_x.integerValue = intpos
      let intposx = UInt16(Float(intpos ) * FAKTOR0)
      teensy.write_byteArray[ACHSE0_BYTE_H] = UInt8((intposx & 0xFF00) >> 8) // hb
      teensy.write_byteArray[ACHSE0_BYTE_L] = UInt8((intposx & 0x00FF) & 0xFF) // lb
      
      let w = Double(Joystickfeld.bounds.size.width) // Breite Joystickfeld
      let invertfaktorw:Float = Float(w / (Pot0_Slider.maxValue - Pot0_Slider.minValue)) 
      
      var currpunkt:NSPoint = Joystickfeld.weg.currentPoint
      currpunkt.x = CGFloat(Float(intpos) * invertfaktorw)
      Joystickfeld.weg.line(to: currpunkt)
      Joystickfeld.needsDisplay = true 
      if (usbstatus > 0)
      {
         let senderfolg = teensy.send_USB()
      }
   }
   
   @IBAction func report_goto_y_Stepper(_ sender: NSStepper)
   {
      //teensy.write_byteArray[0] = SET_0 // Code 
      //print("report_goto_y_Stepper IntVal: \(sender.intValue)")
      let intpos = sender.integerValue 
      goto_y.integerValue = intpos
      let intposy = UInt16(Float(intpos ) * FAKTOR0)
      teensy.write_byteArray[ACHSE1_BYTE_H] = UInt8((intposy & 0xFF00) >> 8) // hb
      teensy.write_byteArray[ACHSE1_BYTE_L] = UInt8((intposy & 0x00FF) & 0xFF) // lb
      
      let h = Double(Joystickfeld.bounds.size.width) // Breite Joystickfeld
      let invertfaktorh:Float = Float(h / (Pot1_Slider.maxValue - Pot1_Slider.minValue)) 
      
      var currpunkt:NSPoint = Joystickfeld.weg.currentPoint
      currpunkt.y = CGFloat(Float(intpos) * invertfaktorh)
      Joystickfeld.weg.line(to: currpunkt)
      Joystickfeld.needsDisplay = true 
      
      if (usbstatus > 0)
      {
         let senderfolg = teensy.send_USB()
      }
   }
   
   @IBAction func report_Slider1(_ sender: NSSlider)
   {
      let loktag = sender.tag
      teensy.write_byteArray[0] = addresscodearray[loktag]// Code
      
      
      print("report_Slider1 IntVal: \(sender.intValue)")
      
      let pos = sender.floatValue
      let intpos = UInt16(pos * FAKTOR0)
      let Istring = formatter.string(from: NSNumber(value: intpos))
      print("intpos: \(intpos) IString: \(Istring)") 
      Pot1_Feld.integerValue  = Int(intpos)
      
      Pot1_Stepper_L.integerValue  = Int(sender.minValue) // Stepper min setzen
      Pot1_Stepper_L_Feld.integerValue = Int(sender.minValue)
      Pot1_Stepper_H.integerValue  = Int(sender.maxValue) // Stepper max setzen
      Pot1_Stepper_H_Feld.integerValue = Int(sender.maxValue)
      
      
      
      teensy.write_byteArray[ACHSE1_BYTE_H] = UInt8((intpos & 0xFF00) >> 8) // hb
      teensy.write_byteArray[ACHSE1_BYTE_L] = UInt8((intpos & 0x00FF) & 0xFF) // lb
      
      if (usbstatus > 0)
      {
         let senderfolg = teensy.send_USB()
      }
   }
   
   @IBAction func report_Pot1_Stepper_L(_ sender: NSStepper) // untere Grenze
   {
      print("report_Pot1_Stepper_L IntVal: \(sender.integerValue)")
      
      let intpos = sender.integerValue 
      Pot1_Stepper_L_Feld.integerValue = intpos
      
      Pot1_Slider.minValue = sender.doubleValue 
      print("report_Pot1_Stepper_L Pot1_Slider.minValue: \(Pot1_Slider.minValue)")
      
   }
   
   @IBAction func report_Pot1_Stepper_H(_ sender: NSStepper)// Obere Grenze
   {
      print("report_Pot1_Stepper_H IntVal: \(sender.integerValue)")
      
      let intpos = sender.integerValue 
      Pot1_Stepper_H_Feld.integerValue = intpos
      
      Pot1_Slider.maxValue = sender.doubleValue 
      print("report_Pot1_Stepper_H Pot1_Slider.maxValue: \(Pot1_Slider.maxValue)")
      
   }
   
   @IBAction func report_I_Stepper(_ sender: NSStepper)
   {
      //teensy.write_byteArray[0] = SET_0 // Code 
      print("report_I_Stepper IntVal: \(sender.intValue)")
      let I = Pot1_Feld.floatValue
      let intpos = sender.intValue 
      
      let pos = sender.floatValue
      let Istring = formatter.string(from: NSNumber(value: intpos))
      //     print("report_U_Stepper u: \(u) Istring: \(Istring ?? "0")")
      Pot1_Feld.stringValue  = Istring!
      
      self.Pot1_Stepper_H.floatValue = sender.floatValue
      
      teensy.write_byteArray[ACHSE1_BYTE_H] = UInt8((intpos & 0xFF00) >> 8) // hb
      teensy.write_byteArray[ACHSE1_BYTE_L] = UInt8((intpos & 0x00FF) & 0xFF) // lb
      
      if (usbstatus > 0)
      {
         let senderfolg = teensy.send_USB()
      }
   }
   
   @IBAction func report_StartSinus(_ sender: NSButton)
   {
      print("report_StartSinus ")
      let intpos0 = UInt16(Float(ACHSE0_START) * FAKTOR0)
      Pot0_Feld.integerValue = Int(UInt16(Float(ACHSE0_START) * FAKTOR0))
      
      teensy.write_byteArray[0] = SIN_START
      let intpos = UInt16(Float(ACHSE0_START) * FAKTOR0)
      let startwert = UInt16(Float(ACHSE0_START) * FAKTOR0)
      
      teensy.write_byteArray[ACHSE0_BYTE_H] = UInt8((startwert & 0xFF00) >> 8) // hb
      teensy.write_byteArray[ACHSE0_BYTE_L] = UInt8((startwert & 0x00FF) & 0xFF) // lb
      if (usbstatus > 0)
      {
         let senderfolg = teensy.send_USB()
         print("report_sinus senderfolg: \(senderfolg) startwert: \(startwert)")
      }
      
      
   }
   @IBAction func report_StopSinus(_ sender: NSButton)
   {
      print("report_StopSinus ")
      teensy.write_byteArray[0] = SIN_END
      teensy.write_byteArray[1] = SIN_END
      let startwert = ACHSE0_START
      teensy.write_byteArray[ACHSE0_BYTE_H] = UInt8((startwert & 0xFF00) >> 8) // hb
      teensy.write_byteArray[ACHSE0_BYTE_L] = UInt8((startwert & 0x00FF) & 0xFF) // lb
      if (usbstatus > 0)
      {
         let senderfolg = teensy.send_USB()
         print("report_sinus senderfolg: \(senderfolg) startwert: \(startwert)")
      }
      
      
   }
   
   @IBAction  func report_Slider(_ sender: NSSlider)
   {
      let t = sender.tag
      let loktag = sender.tag - 1000
      //     teensy.write_byteArray[0] = LOK_0_SPEED // Code 
      teensy.write_byteArray[0] = speedcodearray[loktag]
      //print("\nRobot report_Slider loktag \(loktag) IntVal: \(sender.intValue) ")
      //     lok0array[12] = LOK_0_SPEED
      //   print("report_Slider funktioncoderray: \(funktioncoderray) ")
      
      let pos = sender.floatValue
      
      //    let intpos = UInt8(pos * LOK_FAKTOR0)
      let intpos = UInt8(pos)
      //    let Ustring = formatter.string(from: NSNumber(value: intpos))
      //    var speed:UInt8 =  intpos
      var speed:UInt8 =  UInt8(sender.intValue)
      
      //print("report_Slider pos: \(pos) intpos: \(intpos)  speed: \(speed)")
      //      print("report_Slider0 speed: \(speed) richtung: \(richtung)")
      if speed > 0
      {
         speed += 1 // speed 1 ist Richtungsumschaltung
      }
      
      speedarray[loktag] = speed
      
      print("Lok: \(loktag) speedarray: \(speedarray)")
      //   print("lok0array vor loadLokAddress: \(lok0array)")
      
      loadLokAddress(lok: loktag) // lokaddress in write_byteArray
      
      
      teensy.write_byteArray[17] = speed
      
            print("teensy.write_byteArray:")
            print("\(teensy.write_byteArray[8...18])")
      
      (self.view.viewWithTag(2000 + loktag) as! NSTextField).intValue = Int32(pos)
      
      //print("report_Slider usbstatus: \(usbstatus)")
      //print("report_Slider loknummer: \(loknummer.indexOfSelectedItem) ")
      //print("report_Slider speed: \(speed)")
      //teensy.write_byteArray[20] = UInt8(loknummer.indexOfSelectedItem)
      teensy.write_byteArray[20] = UInt8(loktag)
      
      //print("lok: \(loktag) write_byteArray: \(teensy.write_byteArray)")
      if (usbstatus > 0)
      {
         let senderfolg = teensy.send_USB()
         if(senderfolg == 0)
         {
            print("Robot report_Slider senderfolg: \(senderfolg)")
         }
         //print("Robot report_Slider senderfolg: \(senderfolg)")
      }
   }
   
   @objc func loadLokAddress(lok:Int)
   {
      //print("loadLokAddress lok: \(lok)")
      for i in 0...3
      {
         teensy.write_byteArray[8 + i] = addressarray[lok][i]
         //print(addressarray[lok][i])
      }
      //print("loadLokAddress\(teensy.write_byteArray[8...11])")
   } // loadLokAddress
   
   
   @objc func loadFunktion(lok:Int)
   {
      
      let loktag = Lok_2_FunktionTaste.tag - 3000
      if loktag == lok
      {
         var funktion:UInt8 = 0
         if Lok_2_FunktionTaste.state == .on
         {
            funktion = 1
         }
         teensy.write_byteArray[16] = funktion // Richtung
      }
      
   }
   
   @objc func loadSpeed(lok:Int)
   {
      teensy.write_byteArray[20] = UInt8(loknummer.indexOfSelectedItem)
      teensy.write_byteArray[17] = speedarray[lok]
   }
   
   @IBAction  func report_Speed_auto(_ sender: NSButton)
   {
      let autospeed = sender.state.rawValue
      
      Pot0_Slider.intValue = 0
      speedautocounter = 0 
      
      startzeit = Int64(NSDate().timeIntervalSince1970)
      if autospeed == 1
      {
         let minspeed = 0
         let maxspeed = 14
         let step = 1
         let interval:Double = 2
         
         var userinformation:NSMutableDictionary = ["minspeed": minspeed, "maxspeed": maxspeed, "step": step, "speedautocounter":speedautocounter] //as! [String : Int]
         var timer : Timer? = nil
         
         timer = Timer.scheduledTimer(timeInterval: interval, target: self, selector: #selector(speed_auto(_:)), userInfo: userinformation, repeats: true)
      }
      else 
      {
         print("auto off")
      }
   }
   
   
   @objc func speed_auto(_ timer: Timer)
   {
      if (autospeedtaste.state.rawValue == 1)
      {
         // print("speed_auto : \( timer.userInfo)")
         //       if  var dic = timer.userInfo as? NSMutableDictionary
         //       {
         //print("step: \(dic["step"])")
         speedautocounter += 1
         if speedautocounter > sinarray.count - 1
         {
            speedautocounter = 0 // neu beginnen
         }
         //      var tempmin:Int = dic["minspeed"] as! Int
         //      var tempmax:Int = dic["maxspeed"] as! Int
         //       var tempspeedautocounter = dic["speedautocounter"] as! Int
         
         var       tempmin = autospeedminstepper.integerValue
         var       tempmax = autospeedmaxstepper.integerValue
         if !(tempmax > tempmin)
         {
            tempmax = tempmin + 1
         }
         
         var sinint = sinarray[speedautocounter]
         
         // https://deepbluembedded.com/map-function-embedded-c/#:~:text=The%20map%20function%20is%20commonly,certain%20domain%20to%20another%20domain.
         //return ((((IN - INmin)*(OUTmax - OUTmin))/(INmax - INmin)) + OUTmin);
         
         
         var INint = Int(sinint)
         var INmin = Int(sinarray.min() ?? 1)
         var INmax = Int(sinarray.max() ?? 2)
         
         var OUTmin = tempmin
         var OUTmax = tempmax
         
         var outint = (((INint - INmin)*(OUTmax - OUTmin)) / (INmax - INmin)) + OUTmin
         
         print("speedautocounter : \( speedautocounter) sinint: \(sinint) outint: \(outint)")
         teensy.write_byteArray[0] = speedcodearray[0]
         teensy.write_byteArray[17] = UInt8(outint)
         autospeedrandomfeld.integerValue = outint
         
         
         //return
         
         var randomInt = Int.random(in: tempmin..<tempmax)
         if randomInt > 0 
         {
            randomInt += 1
         }
         
         
         teensy.write_byteArray[0] = speedcodearray[0]
         
         /*
          if speedautocounter % 5 == 0
          {
          teensy.write_byteArray[17] = 0
          autospeedrandomfeld.integerValue = 0
          }
          else
          {
          teensy.write_byteArray[17] = UInt8(randomInt)
          autospeedrandomfeld.integerValue = randomInt
          //      dic["step"] = randomInt
          }
          */
         //      var date = Int64(NSDate().timeIntervalSince1970) - startzeit            
         
         
         //print("speed_auto : \( autospeedrandomfeld.integerValue) time: \(date)")
         
         loadLokAddress(lok: 0)
         //teensy.write_byteArray[20] = UInt8(loknummer.indexOfSelectedItem)
         if (usbstatus > 0)
         {
            let senderfolg = teensy.send_USB()
            //print("Robot report_Slider senderfolg: \(senderfolg)")
         }
         //      }
      }
      else 
      {
         timer.invalidate()
         teensy.write_byteArray[17] = 0
         loadLokAddress(lok: 0)
         //teensy.write_byteArray[20] = UInt8(loknummer.indexOfSelectedItem)
         if (usbstatus > 0)
         {
            let senderfolg = teensy.send_USB()
            //print("Robot report_Slider senderfolg: \(senderfolg)")
         }
      }
      
   }
   
   
   @IBAction func report_Slider_sin(_ sender: NSSlider)
   {
      teensy.write_byteArray[0] = SET_2 // Code 
      //print("report_Slider:sin IntVal: \(sender.intValue)")
      
      let pos = sender.floatValue
      
      let intpos = UInt16(pos * FAKTOR0)
      let Ustring = formatter.string(from: NSNumber(value: intpos))
      
      //print("report_Slider0 pos: \(pos) intpos: \(intpos)  Ustring: \(Ustring ?? "0")")
      Pot2_Feld.stringValue  = Ustring!
      Pot2_Feld.integerValue  = Int(intpos)
      Pot2_Stepper_L.integerValue  = Int(sender.minValue) // Stepper min setzen
      Pot2_Stepper_L_Feld.integerValue = Int(sender.minValue)
      Pot2_Stepper_H.integerValue  = Int(sender.maxValue) // Stepper max setzen
      Pot2_Stepper_H_Feld.integerValue = Int(sender.maxValue)
      
      teensy.write_byteArray[ACHSE2_BYTE_H] = UInt8((intpos & 0xFF00) >> 8) // hb
      teensy.write_byteArray[ACHSE2_BYTE_L] = UInt8((intpos & 0x00FF) & 0xFF) // lb
      
      if (usbstatus > 0)
      {
         let senderfolg = teensy.send_USB()
         //print("report_Slider0 senderfolg: \(senderfolg)")
      }
   }
   
   @IBAction func report_Pot0_Stepper_L(_ sender: NSStepper) // untere Grenze
   {
      print("report_Pot0_Stepper_L IntVal: \(sender.integerValue)")
      
      let intpos = sender.integerValue 
      //      Pot0_Stepper_L_Feld.integerValue = intpos
      
      //     Pot0_Slider.minValue = sender.doubleValue 
      print("report_Pot0_Stepper_L Pot0_Slider.minValue: \(Pot0_Slider.minValue)")
      
   }
   
   @IBAction func report_Pot0_Stepper_H(_ sender: NSStepper)// Obere Grenze
   {
      print("report_Pot0_Stepper_H IntVal: \(sender.integerValue)")
      
      let intpos = sender.integerValue 
      Pot0_Stepper_H_Feld.integerValue = intpos
      
      Pot0_Slider.maxValue = sender.doubleValue 
      print("report_Pot0_Stepper_H Pot0_Slider.maxValue: \(Pot0_Slider.maxValue)")
      
   }
   
   
   @IBAction func report_set_Pot0(_ sender: NSTextField)
   {
      teensy.write_byteArray[0] = SET_0 // Code 
      
      // senden mit faktor 1000
      //let u = Pot0_Feld.floatValue 
      let Pot0_wert = Pot0_Feld.floatValue * 100
      let Pot0_intwert = UInt(Pot0_wert)
      
      let Pot0_HI = (Pot0_intwert & 0xFF00) >> 8
      let Pot0_LO = Pot0_intwert & 0x00FF
      
      print("report_set_Pot0 Pot0_wert: \(Pot0_wert) Pot0 HI: \(Pot0_HI) Pot0 LO: \(Pot0_LO) ")
      let intpos = sender.intValue 
      self.Pot0_Slider.floatValue = Pot0_wert //sender.floatValue
      self.Pot0_Stepper_L.floatValue = Pot0_wert//sender.floatValue
      
      teensy.write_byteArray[ACHSE0_BYTE_H] = UInt8(Pot0_LO)
      teensy.write_byteArray[ACHSE0_BYTE_L] = UInt8(Pot0_HI)
      
      if (usbstatus > 0)
      {
         let senderfolg = teensy.send_USB()
         if (senderfolg < BUFFER_SIZE)
         {
            print("report_set_Pot0 U: %d",senderfolg)
         }
      }
   }
   
   
   @IBAction func report_Slider2(_ sender: NSSlider)
   {
      teensy.write_byteArray[0] = SET_3 // Code 
      //print("report_Slider2 IntVal: \(sender.intValue)")
      let pos = sender.floatValue
      
      let intpos = UInt16(pos * FAKTOR3)
      let Ustring = formatter.string(from: NSNumber(value: intpos))
      
      //print("report_Slider2 pos: \(pos) intpos: \(intpos)  Ustring: \(Ustring ?? "0")")
      // Pot0_Feld.stringValue  = Ustring!
      Pot2_Feld.integerValue  = Int(intpos)
      Pot2_Stepper_L.integerValue  = Int(sender.minValue) // Stepper min setzen
      Pot2_Stepper_L_Feld.integerValue = Int(sender.minValue)
      Pot2_Stepper_H.integerValue  = Int(sender.maxValue) // Stepper max setzen
      Pot2_Stepper_H_Feld.integerValue = Int(sender.maxValue)
      
      teensy.write_byteArray[ACHSE3_BYTE_H] = UInt8((intpos & 0xFF00) >> 8) // hb
      teensy.write_byteArray[ACHSE3_BYTE_L] = UInt8((intpos & 0x00FF) & 0xFF) // lb
      
      if (usbstatus > 0)
      {
         let senderfolg = teensy.send_USB()
         //print("report_Slider2 senderfolg: \(senderfolg)")
      }
   }
   @IBAction  func report_Pot2_Stepper_H(_ sender: NSStepper) // untere Grenze
   {
      print("report_Pot2_Stepper_H IntVal: \(sender.integerValue)")
   }
   @IBAction  func report_Pot2_Stepper_L(_ sender: NSStepper) // untere Grenze
   {
      print("report_Pot2_Stepper_L IntVal: \(sender.integerValue)")
      
   }
   
   @IBAction  func report_Slider3(_ sender: NSSlider)
   {
      teensy.write_byteArray[0] = SET_3 // Code 
      print("report_Slider3 IntVal: \(sender.intValue)")
   }
   
   
   @IBAction func report_set_Pot1(_ sender: AnyObject)
   {
      
   }
   
   @IBAction  func report_Pot3_Stepper_L(_ sender: NSStepper) // untere Grenze
   {
   }
   @IBAction  func report_Pot3_Stepper_H(_ sender: NSStepper)// Obere Grenze
   {
      print("report_Pot3_Stepper_H IntVal: \(sender.integerValue)")
   }
   
   //MARK: usbattachAktion
   
   @objc func usbattachAktion(_ note:Notification) //von hid attach_callback
   {
      let info = note.userInfo
      print("ViewController usbattachAktion info: \(info )")
      let status = info?["attach"] as! Int
      
      var usbattachstatus = info?["usbattachstatus"] as! Int
      
      print("ViewController usbattachAktion status: \(status) globalusbstatus: \(globalusbstatus) usbattachstatus: \(usbattachstatus)");
      
      if  (status == USBATTACHED)
      {
         //print("ViewController usbattachAktion USBATTACHED");
         print("\nViewController usbattachAktion USBATTACHED  globalusbstatus: \(globalusbstatus)")
         let product_ID = teensy.dev_present()
         print("ViewController usbattachAktion productID: \(product_ID) usbattachstatus: \(usbattachstatus)")
         
         if ((product_ID == 1) && (usbattachstatus == 0))
         {
            print("ViewController usbattachAktion usbattachstatus==0")
            //self.Attach_USB()
         }
         
         //USB_OK_Feld.image = okimage
         //USBKontrolle.stringValue = "USB ON"
         globalusbstatus = 1
         usbstatus = 1
         print("ViewController usbattachAktion USBATTACHED")
         
      }
      
      else if (status == USBREMOVED)
      {
        //USB_OK_Feld.image = notokimage
         globalusbstatus = 0
         usbstatus = 0
         //USBKontrolle.stringValue="USB OFF"
         print("\nViewController usbattachAktion USBREMOVED ")
         //       teensy.usb_free()
         
         
      }
      
   }
   
   @IBAction func report_start_read_USB(_ sender: AnyObject)
   {
      //myUSBController.startRead(1)
      if teensy.dev_present() > 0
      {
         var timerdic = [String:Any]()
         var start_read_USB_erfolg = teensy.start_read_USB(true,dic:timerdic)
         
         Start_Knopf.isEnabled = false
         Stop_Knopf.isEnabled = true
         
      }
      else
      {
         
         let warnung = NSAlert.init()
         warnung.messageText = "USB start read"
         warnung.messageText = "report_start_read_USB: Kein USB-Device"
         warnung.addButton(withTitle: "OK")
         warnung.runModal()
         
         Start_Knopf.isEnabled = false
         Stop_Knopf.isEnabled = false
      }     
   }
   
   @IBAction func check_USB(_ sender: NSButton)
   {
      return;
      /*
       let present = teensy.dev_present()
       let hidstatus = teensy.status()
       let nc = NotificationCenter.default
       var userinformation:[String : Any]
       // print("USBOpen usbstatus vor check: \(usbstatus) hidstatus: \(hidstatus) present: \(present)")
       if (usbstatus > 0) // already open
       {
       print("USB-Device ist schon da")
       let warnung = NSAlert.init()
       warnung.messageText = "USB"
       warnung.messageText = "USB-Device ist schon da"
       warnung.addButton(withTitle: "OK")
       warnung.runModal()
       return
       
       }
       let erfolg = teensy.USBOpen()
       usbstatus = erfolg
       globalusbstatus = Int(erfolg)
       print("USBOpen erfolg: \(erfolg) usbstatus: \(usbstatus)")
       
       if (rawhid_status()==1)
       {
       print("status 1")
       //USB_OK.backgroundColor = NSColor.green
       //USB_OK.stringValue = "+"
       USB_OK_Feld.image = okimage
       print("USB-Device da")
       /*
        let warnung = NSAlert.init()
        warnung.messageText = "USB"
        warnung.messageText = "USB-Device ist da"
        warnung.addButton(withTitle: "OK")
        //warnung.runModal()
        */
       let manu = get_manu()
       //println(manu) // ok, Zahl
       //         var manustring = UnsafePointer<CUnsignedChar>(manu)
       //println(manustring) // ok, Zahl
       
       let manufactorername = String(cString: UnsafePointer(manu!))
       //  print("str: ", manufactorername)
       manufactorer.stringValue = manufactorername
       
       //manufactorer.stringValue = "Manufactorer: " + teensy.manufactorer()!
       Start_Knopf.isEnabled = true
       Send_Knopf.isEnabled = true
       
       userinformation = ["message":"usb", "usbstatus": 1,"manufactorer": manufactorername] as [String : Any]
       nc.post(name:Notification.Name(rawValue:"usb_status"),
       object: nil,
       userInfo: userinformation)
       
       }
       else
       
       {
       print("status 0")
       // USB_OK.backgroundColor = NSColor.yellow
       // USB_OK.stringValue = "-"
       USB_OK_Feld.image = notokimage
       let warnung = NSAlert.init()
       warnung.messageText = "USB"
       warnung.messageText = "check_USB: Kein USB-Device"
       warnung.addButton(withTitle: "OK")
       warnung.runModal()
       userinformation = ["message":"usb", "usbstatus": 0] as [String : Any]
       nc.post(name:Notification.Name(rawValue:"usb_status"),
       object: nil,
       userInfo: userinformation)
       
       /*
        if let taste = USB_OK
        {
        //print("Taste USB_OK ist nicht nil")
        taste.backgroundColor = NSColor.red
        //USB_OK.backgroundColor = NSColor.redColor()
        
        }
        else
        {
        print("Taste USB_OK ist nil")
        }*/ 
       Start_Knopf.isEnabled = false
       Stop_Knopf.isEnabled = false
       Send_Knopf.isEnabled = false
       return
       }
       //print("antwort: \(teensy.status())")
       */
   }
   
   @IBAction func report_stop_read_USB(_ sender: AnyObject)
   {
      if teensy.dev_present() > 0
      {
         teensy.read_OK = false
         if teensy.dev_present() > 0
         {
            Start_Knopf.isEnabled = true
            Send_Knopf.isEnabled = true
         }
         else
         {
            Start_Knopf.isEnabled = false
         }
         Stop_Knopf.isEnabled = false
      }
   }
   
   @IBAction func send_USB(_ sender: AnyObject)
   {
      //NSBeep()
      if teensy.dev_present() > 0
      {
         var senderfolg = teensy.send_USB()
      }
      else
      {
         let warnung = NSAlert.init()
         warnung.messageText = "USB"
         warnung.messageText = "send_USB: Kein USB-Device"
         warnung.addButton(withTitle: "OK")
         warnung.runModal()
         Send_Knopf.isEnabled = false
         
      }
      
      //println("send_USB senderfolg: \(senderfolg)")
      
      
      /*
       var USB_Zugang = USBController()
       USB_Zugang.setKontrollIndex(5)
       
       Counter.intValue = USB_Zugang.kontrollIndex()
       
       // var  out  = 0
       
       //USB_Zugang.Alert("Hoppla")
       
       var x = getX()
       Counter.intValue = x
       
       var    out = rawhid_open(1, 0x16C0, 0x0480, 0xFFAB, 0x0200)
       
       println("send_USB out: \(out)")
       
       if (out <= 0)
       {
       usbstatus = 0
       Anzeige.stringValue = "not OK"
       println("kein USB-Device")
       }
       else
       {
       usbstatus = 1
       println("USB-Device da")
       var manu = get_manu()
       //println(manu) // ok, Zahl
       var manustring = UnsafePointer<CUnsignedChar>(manu)
       //println(manustring) // ok, Zahl
       
       let manufactorername = String.fromCString(UnsafePointer(manu))
       println("str: %s", manufactorername!)
       manufactorer.stringValue = manufactorername!
       
       /*
        var strA = ""
        strA.append(Character("d"))
        strA.append(UnicodeScalar("e"))
        println(strA)
        
        let x = manu
        let s = "manufactorer"
        println("The \(s) is \(manu)")
        var pi = 3.14159
        NSLog("PI: %.7f", pi)
        let avgTemp = 66.844322156
        println(NSString(format:"AAA: %.2f", avgTemp))
        */
       }
       */
      
   }
   
   override var acceptsFirstResponder : Bool {
          return true
   }

   // https://nabtron.com/quit-cocoa-app-window-close/
   
   @nonobjc func windowShouldClose(_ sender: Any) 
   {
      print("windowShouldClose")
      
      NSApplication.shared.terminate(self)
   }
   
   override var representedObject: Any? 
   {
      didSet {
         // Update the view, if already loaded.
      }
   }
   
   func getPlist(withName name: String) -> [String]?
   {
      // https://learnappmaking.com/plist-property-list-swift-how-to/
      if  let path = Bundle.main.path(forResource: name, ofType: "plist"),
          let xml = FileManager.default.contents(atPath: path)
      {
         return (try? PropertyListSerialization.propertyList(from: xml, options: .mutableContainersAndLeaves, format: nil)) as? [String]
      }
      
      return nil
   }
   
   
   //MARK: Konstanten
   // const fuer USB
   let SET_0:UInt8 = 0xA1
   let SET_1:UInt8 = 0xB1
   
   let SET_2:UInt8 = 0xC1
   let SET_3:UInt8 = 0xD1
   
   let SET_ROB:UInt8 = 0xA2
   
   let SET_P:UInt8 = 0xA3
   let GET_P:UInt8 = 0xB3
   
   let SIN_START:UInt8 = 0xE0
   let SIN_END:UInt8 = 0xE1
   
   let U_DIVIDER:Float = 9.8
   let ADC_REF:Float = 3.26
   
   let ACHSE0_BYTE_H = 4
   let ACHSE0_BYTE_L = 5
   let ACHSE0_START_BYTE_H = 6
   let ACHSE0_START_BYTE_L = 7
   
   
   let ACHSE1_BYTE_H = 11
   let ACHSE1_BYTE_L = 12
   let ACHSE1_START_BYTE_H = 13
   let ACHSE1_START_BYTE_L = 14
   
   let ACHSE2_BYTE_H = 17
   let ACHSE2_BYTE_L = 18
   let ACHSE2_START_BYTE_H = 19
   let ACHSE2_START_BYTE_L = 20
   
   let ACHSE3_BYTE_H = 23
   let ACHSE3_BYTE_L = 24
   let ACHSE3_START_BYTE_H = 25
   let ACHSE3_START_BYTE_L = 26
   
   let HYP_BYTE_H = 32 // Hypotenuse
   let HYP_BYTE_L = 33
   
   let INDEX_BYTE_H = 34
   let INDEX_BYTE_L = 35
   
   let STEPS_BYTE_H = 36
   let STEPS_BYTE_L = 37
   
   
   
   
   
   //MARK:      Outlets 
   @IBOutlet weak var Device: NSTabView!
   @IBOutlet weak var manufactorer: NSTextField!
   @IBOutlet weak var Counter: NSTextField!
   
   @IBOutlet weak var Start_Knopf: NSButton!
   @IBOutlet weak var Stop_Knopf: NSButton!
   @IBOutlet weak var Send_Knopf: NSButton!
   @IBOutlet weak var Start_Read_Knopf: NSButton!
   
   @IBOutlet weak var Anzeige: NSTextField!
   
   //@IBOutlet weak var USB_OK: NSTextField!
   @IBOutlet weak var USB_OK_Feld: NSImageView!
   
   @IBOutlet weak var check_USB_Knopf: NSButton!
   
   
   //@IBOutlet weak var start_read_USB_Knopf: NSButtonCell!
   
   @IBOutlet weak var codeFeld: NSTextField!
   
   @IBOutlet weak var dataFeld: NSTextField!
   
   @IBOutlet weak var schrittweiteFeld: NSTextField!
   
   @IBOutlet weak var pos0Feld: NSTextField!
   @IBOutlet weak var pos1Feld: NSTextField!
   @IBOutlet weak var pos2Feld: NSTextField!
   
   @IBOutlet weak var intpos0Feld: NSTextField!
   @IBOutlet weak var intpos1Feld: NSTextField!
   @IBOutlet weak var intpos2Feld: NSTextField!
   
   @IBOutlet weak var TeensyPot0Feld: NSTextField!
   @IBOutlet weak var TeensyPot1Feld: NSTextField!
   @IBOutlet weak var TeensyPot2Feld: NSTextField!
   @IBOutlet weak var TeensyPot3Feld: NSTextField!
   
   @IBOutlet weak var reverscountFeld: NSTextField!
   
   @IBOutlet weak var LocalTaste: NSButton!
   
   @IBOutlet weak var Lok_0_RichtungTaste: NSButton!
   @IBOutlet weak var Lok_1_RichtungTaste: NSButton!
   @IBOutlet weak var Lok_2_RichtungTaste: NSButton!
   
   @IBOutlet weak var Lok_0_FunktionTaste: NSButton!
   @IBOutlet weak var Lok_1_FunktionTaste: NSButton!
   @IBOutlet weak var Lok_2_FunktionTaste: NSButton!
   
   @IBOutlet weak var Weiche0_Slider: NSSliderCell!

   
   @IBOutlet weak var Pot0_Feld: NSTextField!
   @IBOutlet weak var Pot0_Slider: NSSlider!
   @IBOutlet weak var Pot0_Stepper_H: NSStepper!
   @IBOutlet weak var Pot0_Stepper_L: NSStepper!
   @IBOutlet weak var Pot0_Stepper_L_Feld: NSTextField!
   @IBOutlet weak var Pot0_Stepper_H_Feld: NSTextField!
   @IBOutlet weak var Pot0_Inverse_Check: NSButton!
   
   @IBOutlet weak var joystick_x: NSTextField!
   @IBOutlet weak var joystick_y: NSTextField!
   
   @IBOutlet weak var goto_x: NSTextField!
   //   @IBOutlet weak var goto_x_Stepper: NSStepper!
   @IBOutlet weak var goto_y: NSTextField!
   @IBOutlet weak var goto_y_Stepper: NSStepper!
   
   @IBOutlet weak var Pot1_Feld_raw: NSTextField!
   @IBOutlet weak var Pot1_Feld: NSTextField!
   @IBOutlet weak var Pot1_Slider: NSSlider!
   @IBOutlet weak var Pot1_Stepper_H: NSStepper!
   @IBOutlet weak var Pot1_Stepper_L: NSStepper!
   @IBOutlet weak var Pot1_Stepper_L_Feld: NSTextField!
   @IBOutlet weak var Pot1_Stepper_H_Feld: NSTextField!
   @IBOutlet weak var Pot1_Inverse_Check: NSButton!
   
   @IBOutlet weak var Pot2_Feld_raw: NSTextField!
   @IBOutlet weak var Pot2_Feld: NSTextField!
   @IBOutlet weak var Pot2_Slider: NSSlider!
   @IBOutlet weak var Pot2_Stepper: NSStepper!
   @IBOutlet weak var Pot2_Stepper_H: NSStepper!
   @IBOutlet weak var Pot2_Stepper_L: NSStepper!
   @IBOutlet weak var Pot2_Stepper_L_Feld: NSTextField!
   @IBOutlet weak var Pot2_Stepper_H_Feld: NSTextField!
   @IBOutlet weak var Pot2_Inverse_Check: NSButton!
   
   @IBOutlet weak var Pot3_Feld_raw: NSTextField!
   @IBOutlet weak var Pot3_Feld: NSTextField!
   @IBOutlet weak var Pot3_Slider: NSSlider!
   @IBOutlet weak var Pot3_Stepper: NSStepper!
   @IBOutlet weak var Pot3_Stepper_H: NSStepper!
   @IBOutlet weak var Pot3_Stepper_L: NSStepper!
   @IBOutlet weak var Pot3_Stepper_L_Feld: NSTextField!
   @IBOutlet weak var Pot3_Stepper_H_Feld: NSTextField!
   @IBOutlet weak var Pot3_Inverse_Check: NSButton!
   
   @IBOutlet weak var Joystickfeld: rJoystickView!
   
   @IBOutlet weak var clear_Ring: NSButton!
   @IBOutlet weak var emitterFeld: NSTextField!
   @IBOutlet weak var loknummer: NSSegmentedControl!
   @IBOutlet weak var autospeedtaste: NSButton!
   @IBOutlet weak var autospeedmaxstepper: NSStepper!
   @IBOutlet weak var autospeedmaxfeld: NSTextField!
   @IBOutlet weak var autospeedminstepper: NSStepper!
   @IBOutlet weak var autospeedminfeld: NSTextField!
   @IBOutlet weak var autospeedrandomfeld: NSTextField!
   @IBOutlet weak var lookuptablepop: NSPopUpButton!
   @IBOutlet weak var lookupindexFeld: NSTextField!
   
   @IBOutlet weak var autoscantaste: NSButton!
   
   @IBOutlet weak var Drehknopf_Feld: NSTextField!
   @IBOutlet weak var Drehknopf_Feld_raw: NSTextField!
   
   @IBOutlet weak var Drehknopf_Stepper_H: NSStepper!
   @IBOutlet weak var Drehknopf_Stepper_L: NSStepper!
   @IBOutlet weak var Drehknopf_Stepper_L_Feld: NSTextField!
   @IBOutlet weak var Drehknopf_Stepper_H_Feld: NSTextField!
   
   @IBOutlet weak var Intervalltimer_Feld: NSTextField!
   @IBOutlet weak var Intervalltimer_Stepper: NSStepper!
   
   @IBOutlet weak var Pause_Feld: NSTextField!
   @IBOutlet weak var Pause_Stepper: NSStepper!
   
   @IBOutlet  weak var RobotarmFeld:rRobotarm!

   
   var scanautocounter:Int = 0
   var scanstartzeit:Int64 = 0
   

   
}

extension NSBezierPath
{
   func rotateAroundCenter(angle: CGFloat)
   {
      let midh = NSMidX(self.bounds)/2
      let midv = NSMidY(self.bounds)/2
      let center = NSMakePoint(midh, midv)
      var transform = NSAffineTransform()
      //     transform.rotate(byDegrees: angle)
      //     self.transform(using: transform as AffineTransform)
      
      let originBounds:NSRect = NSMakeRect(NSZeroPoint.x, NSZeroPoint.y , self.bounds.size.width, self.bounds.size.height )
      Swift.print("rotateAround bounds vor rotate origin x: \(self.bounds.origin.x) y: \(self.bounds.origin.y) size h: \(self.bounds.height) w: \(self.bounds.width)")
      
      transform = NSAffineTransform()
      transform.translateX(by: +(NSWidth(originBounds) / 2 ), yBy: +(NSHeight(originBounds) / 2))
      transform.rotate(byDegrees: angle)
      transform.translateX(by: -(NSWidth(originBounds) / 2 ), yBy: -(NSHeight(originBounds) / 2))
      
      //   transform = transform.rotated(by: angle)
      //   transform = transform.translatedBy(x: -center.x, y: -center.y)
      self.transform(using:transform as AffineTransform)
      
      Swift.print("rotateAround bounds nach rotate origin x: \(self.bounds.origin.x) y: \(self.bounds.origin.y) size h: \(self.bounds.height) w: \(self.bounds.width)")
      
   }
   
   
   
   // https://stackoverflow.com/questions/50012606/how-to-rotate-uibezierpath-around-center-of-its-own-bounds
   func rotateAroundCenterB(angle: CGFloat)
   {
      let midh = NSMidX(self.bounds)
      let midv = NSMidY(self.bounds)
      let center = NSMakePoint(midh, midv)
      
      var transform = NSAffineTransform()
      transform.translateX(by: center.x, yBy: center.y)
      transform.rotate(byDegrees: angle)
      transform.translateX(by: -center.x, yBy: -center.y)
      self.transform(using:transform as AffineTransform)
   }
   
   func rotateAroundCenter(center: NSPoint, angle: CGFloat)
   {
      let midh = center.x
      let midv = center.y
      let center = NSMakePoint(midh, midv)
      
      var transform = NSAffineTransform()
      transform.translateX(by: center.x, yBy: center.y)
      transform.rotate(byDegrees: angle)
      transform.translateX(by: -center.x, yBy: -center.y)
      self.transform(using:transform as AffineTransform)
   }
   
   
}
