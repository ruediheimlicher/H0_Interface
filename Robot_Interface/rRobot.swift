//
//  rRobot.swift
//  Robot_Interface
//
//  Created by Ruedi Heimlicher on 12.09.2019.
//  Copyright © 2019 Ruedi Heimlicher. All rights reserved.
//

import Cocoa

let LOK_0:UInt8 = 0xA0
let LOK_FAKTOR0:Float = 1
let LOK0_START:UInt16 = 0 // Startwert Slider 1
let LOK0_OFFSET:UInt16 = 8 // Startwert low


// 
let LOK_1:UInt8 = 0xA1
let LOK1_START:UInt16 = 0 // Startwert Slider 1
let LOK1_OFFSET:UInt16 = 8 // Startwert low
let LOK_FAKTOR1:Float = 1

let LOK_2:UInt8 = 0xA2
let LOK2_START:UInt16 = 0 // Startwert Slider 1
let LOK2_OFFSET:UInt16 = 8 // starteinstellung
let LOK_FAKTOR2:Float = 1

class rRobot: rViewController 
{

    @IBOutlet weak var Intervalltimer_Feld: NSTextField!
   @IBOutlet weak var Intervalltimer_Stepper: NSStepper!

   @IBOutlet weak var Pause_Feld: NSTextField!
   @IBOutlet weak var Pause_Stepper: NSStepper!
   
   
   @IBOutlet  weak var RobotarmFeld:rRobotarm!
   
   @IBOutlet  weak var DrehknopfFeld:rDrehknopfView!
   
   @IBOutlet weak var Drehknopf_Feld: NSTextField!
   @IBOutlet weak var Drehknopf_Feld_raw: NSTextField!
   
   @IBOutlet weak var Drehknopf_Stepper_H: NSStepper!
   @IBOutlet weak var Drehknopf_Stepper_L: NSStepper!
   @IBOutlet weak var Drehknopf_Stepper_L_Feld: NSTextField!
   @IBOutlet weak var Drehknopf_Stepper_H_Feld: NSTextField!
   
    
   
   @IBOutlet weak var pos0Feld: NSTextField!
   @IBOutlet weak var pos1Feld: NSTextField!
   @IBOutlet weak var pos2Feld: NSTextField!
   
   @IBOutlet weak var intpos0Feld: NSTextField!
   @IBOutlet weak var intpos1Feld: NSTextField!
   @IBOutlet weak var intpos2Feld: NSTextField!
   
   
   @IBOutlet weak var Lok_0_RichtungTaste: NSButton!
   @IBOutlet weak var Lok_1_RichtungTaste: NSButton!
   @IBOutlet weak var Lok_2_RichtungTaste: NSButton!
   
   @IBOutlet weak var a0: NSSegmentedControl!
   @IBOutlet weak var a1: NSSegmentedControl!
   @IBOutlet weak var a2: NSSegmentedControl!
   @IBOutlet weak var a3: NSSegmentedControl!

   @IBOutlet weak var b0: NSSegmentedControl!
   @IBOutlet weak var b1: NSSegmentedControl!
   @IBOutlet weak var b2: NSSegmentedControl!
   @IBOutlet weak var b3: NSSegmentedControl!

   @IBOutlet weak var c0: NSSegmentedControl!
   @IBOutlet weak var c1: NSSegmentedControl!
   @IBOutlet weak var c2: NSSegmentedControl!
   @IBOutlet weak var c3: NSSegmentedControl!
   
   var hintergrundfarbe = NSColor()
   
   var lastwinkel:CGFloat = 3272
   
   var geometrie = geom()
   
   var wegmarke:UInt16 = 0
   
    var timerintervall:UInt8 = 13
   
   var addressarray:[UInt8] = [UInt8](repeating: 0x00, count: 4)
   var speedarray:[UInt8] = [UInt8](repeating: 0x00, count: 5)
   var lokarray:[UInt8] = [UInt8](repeating: 0x00, count:16)
   
   var pause:UInt8 = 5
   
   override func viewDidAppear() 
   {
      //print ("Robot viewDidAppear selectedDevice: \(selectedDevice)")
   }
   

    override func viewDidLoad() 
    {
      super.viewDidLoad()
      self.view.window?.acceptsMouseMovedEvents = true
      //let view = view[0] as! NSView
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
 //     NotificationCenter.default.addObserver(self, selector:#selector(joystickAktion(_:)),name:NSNotification.Name(rawValue: "joystick"),object:nil)
      NotificationCenter.default.addObserver(self, selector:#selector(usbstatusAktion(_:)),name:NSNotification.Name(rawValue: "usb_status"),object:nil)
      NotificationCenter.default.addObserver(self, selector:#selector(drehknopfAktion(_:)),name:NSNotification.Name(rawValue: "drehknopf"),object:nil)
      
  //    UserDefaults.standard.removeObject(forKey: "robot1_min")
  //    UserDefaults.standard.removeObject(forKey: "robot2_min")

      Pot0_Slider.integerValue = Int(LOK0_START)
      Pot0_Feld.integerValue = 0 //Int(Pot0_Slider.floatValue * LOK_FAKTOR0)
      
      let a0seg  = Int(UserDefaults.standard.string(forKey: "a0index") ?? "0")
      let a1seg  = Int(UserDefaults.standard.string(forKey: "a1index") ?? "0")
      let a2seg  = Int(UserDefaults.standard.string(forKey: "a2index") ?? "0")
      let a3seg  = Int(UserDefaults.standard.string(forKey: "a3index") ?? "0")
      
      pause = UInt8(UserDefaults.standard.string(forKey: "pause") ?? "5" ) ?? 5
      Pause_Feld.integerValue = Int(pause)
      Pause_Stepper.integerValue = Int(pause)

      
      
      timerintervall = UInt8(UserDefaults.standard.string(forKey: "timerintervall") ?? "13") ?? 13
      
      Intervalltimer_Feld.integerValue = Int((timerintervall));
      Intervalltimer_Stepper.integerValue = Int((timerintervall));
     
      
      //print("UserDefaults a0seg: \(a0seg)")
      a0.selectSegment(withTag: a0seg ?? 0)
      a1.selectSegment(withTag:  a1seg ?? 0)
      a2.selectSegment(withTag:  a2seg ?? 0)
      a3.selectSegment(withTag:  a3seg ?? 0)
      
      lokarray[0] = UInt8(a0seg ?? 0)
      addressarray[0] = UInt8(a0seg ?? 0)

      lokarray[1] = UInt8(a1seg ?? 0)
      addressarray[1] = UInt8(a1seg ?? 0)

      lokarray[2] = UInt8(a2seg ?? 0)
      addressarray[2] = UInt8(a2seg ?? 0)

      lokarray[3] = UInt8(a3seg ?? 0)
      addressarray[3] = UInt8(a3seg ?? 0)

      print("lokarray: \(lokarray)")
     
      // Lokadresse 0 schicken
      teensy.write_byteArray[8] = UInt8(a0seg ?? 0)
      teensy.write_byteArray[9] = UInt8(a1seg ?? 0)
      teensy.write_byteArray[10] = UInt8(a2seg ?? 0)
      teensy.write_byteArray[11] = UInt8(a3seg ?? 0)
      
      teensy.write_byteArray[16] = 0 // Funktion
      teensy.write_byteArray[17] = 0 // speed
      teensy.write_byteArray[18] = timerintervall // speed
      teensy.write_byteArray[19] = 5 // pause
      
      Pot1_Slider.integerValue = Int(LOK1_START)
      Pot1_Feld.integerValue = Int(Pot1_Slider.floatValue * LOK_FAKTOR1)
      
 
      
      Pot2_Slider.integerValue = Int(LOK2_START)
      Pot2_Feld.integerValue = Int(Pot2_Slider.floatValue * LOK_FAKTOR2)

       
        
       
      
      teensy.write_byteArray[0] = LOK_0 // Lok 0
   
      if (globalusbstatus > 0)
      {
         let senderfolg = teensy.send_USB()
         print("Robot viewDidLoad senderfolg: \(senderfolg)")
      }
      
      /*
       
       Pot1_Feld.integerValue = Int(UInt16(Float(ACHSE1_START) * LOK_FAKTOR1))
       */
      
      Drehknopf_Stepper_H_Feld.integerValue = Int(DrehknopfFeld.maxwinkel)
      Drehknopf_Stepper_H.integerValue = Int(DrehknopfFeld.maxwinkel)
      
      Drehknopf_Stepper_L_Feld.integerValue = Int(DrehknopfFeld.minwinkel)
      Drehknopf_Stepper_L.integerValue = Int(DrehknopfFeld.minwinkel)
      
      DrehknopfFeld.hgfarbe = hgfarbe
      print("Robot globalusbstatus: \(globalusbstatus)")
      

   }
   
   
   
   @nonobjc override func 
      windowShouldClose(_ sender: Any) 
   {
      print("Robot windowShouldClose")
      NSApplication.shared.terminate(self)
   }
   
   
   @objc func usbstatusAktion(_ notification:Notification) 
   {
      let info = notification.userInfo
      let status:Int = info?["usbstatus"] as! Int // 
     print("Robot usbstatusAktion:\t \(status) ")
      usbstatus = Int32(status)
   }
   
   @objc  func drehknopfAktion(_ notification:Notification) 
   {
      //print("Robot drehknopfAktion usbstatus:\t \(usbstatus)  globalusbstatus: \(globalusbstatus) selectedDevice: \(selectedDevice) ident: \(String(describing: self.view.identifier))")
      let sel = NSUserInterfaceItemIdentifier(selectedDevice)
      if (sel == self.view.identifier)
      {
         // print("Robot drehknopfAktion passt")
         teensy.write_byteArray[0] = DREHKNOPF
         
         let info = notification.userInfo
         
         // ident als String: s. joystickaktion
         //     let ident = Int(info?["ident"] as! String) 
         let punkt:CGPoint = info?["punkt"] as! CGPoint
         
         let winkel = (punkt.x ) // Winkel in Grad. Nullpunkt senkrecht
         
         
         let winkel2 = Int(10*(winkel + 180)) // 
         Drehknopf_Feld.integerValue = Int(winkel)
         let h = Double(Joystickfeld.bounds.size.height)
         let randbereich = abs(DrehknopfFeld.minwinkel) + abs(DrehknopfFeld.maxwinkel)
         let drehknopfnormierung = 360/(360 - randbereich )
         
         // minwinkel ist negativ von Scheitelpunkt aus
         let wert = CGFloat(Float((winkel + 180 + (DrehknopfFeld.minwinkel))*drehknopfnormierung) * DREHKNOPF_FAKTOR) // red auf 0
         Drehknopf_Feld_raw.integerValue = Int(wert)
        
         print("Robot drehknopfAktion winkel: \(winkel) wert: \(wert)")
         
         var achse0:UInt16 = 0
         if (wert > 0)
         {
            achse0 =  UInt16(wert)
            lastwinkel = wert
         }
         else
         {
            //achse0 = UInt16(lastwinkel)
         }
         
         //
         //ACHSE0_START_BYTE_H
 //        let achse0_start = 
 //        print("Robot drehknopfAktion achse0: \(achse0)")
         //print("Drehknopf winkel: \(winkel) winkel2: \(winkel2) *** normierung: \(drehknopfnormierung)   wert: \(wert) achse0: \(achse0)")
         
         teensy.write_byteArray[ACHSE0_BYTE_H] = UInt8((achse0 & 0xFF00) >> 8) // hb
         teensy.write_byteArray[ACHSE0_BYTE_L] = UInt8((achse0 & 0x00FF) & 0xFF) // lb
         
         let startint = UInt(0x680)
         teensy.write_byteArray[ACHSE0_START_BYTE_H] = UInt8((startint & 0xFF00) >> 8) // hb
         teensy.write_byteArray[ACHSE0_START_BYTE_L] = UInt8((startint & 0x00FF) & 0xFF) // lb

         if (globalusbstatus > 0)
         {
            let senderfolg = teensy.send_USB()
            print("Robot Drehknopfaktion senderfolg: \(senderfolg)")
         }         
      } // identifier passt
   }
   @objc func setDrehknopfwinkel(winkel:Float)
   {
      print("Robot setDrehknopfwinkel winkel:\t \(winkel)") 
   }
   
   // MARK joystick
   @objc override func joystickAktion(_ notification:Notification) 
   {
          print("Robot joystickAktion usbstatus:\t \(usbstatus)  selectedDevice: \(selectedDevice) ident: \(String(describing: self.view.identifier))")
      let sel = NSUserInterfaceItemIdentifier.init(selectedDevice)
      //  if (selectedDevice == self.view.identifier)
      //var ident = ""
      if (sel == self.view.identifier)
      {
         print("Robot joystickAktion passt")
         
         var ident = "13"
         let info = notification.userInfo 
         print("Robot joystickAktion info: \(info)")
         let i = info?["ident"]
         print("Robot joystickAktion i: \(i)")
         if let joystickident = info?["ident"]as? String
         {
            print("Robot joystickAktion ident da: \(joystickident)")
            ident = joystickident
         }
         else
         {
            print("Robot joystickAktion ident nicht da")
         }
         // let id = NSUserInterfaceItemIdentifier.init(rawValue:(info?["ident"] as! NSString) as String)
         
         
         //   let ident = "aa" //info["ident"] as! String 
         let punkt:CGPoint = info?["punkt"] as! CGPoint
         
         
         let wegindex:Int = info?["index"] as! Int // 
         let first:Int = info?["first"] as! Int
         
         //      print("Robot joystickAktion:\t \(punkt)")
         //      print("x: \(punkt.x) y: \(punkt.y) index: \(wegindex) first: \(first) ident: \(ident)")
         
         
         if ident == "3001" // Drehknopf
         {
            print("Drehknopf ident 2001")
            teensy.write_byteArray[0] = DREHKNOPF
            let winkel = Int(punkt.x )
            print("Drehknopf winkel: \(winkel)")
         }
         else if ident == "3000"
            
         {
            
            teensy.write_byteArray[0] = SET_ROB // Code 
            
            // Horizontal Pot0
            let w = Double(Joystickfeld.bounds.size.width) // Breite Joystickfeld
            let faktorw:Double = (Pot0_Slider.maxValue - Pot0_Slider.minValue) / w  // Normierung auf Feldbreite
            //      print("w: \(w) faktorw: \(faktorw)")
            var x = Double(punkt.x)
            if (x > w)
            {
               x = w
            }
            /*
             goto_x.integerValue = Int(Float(x*faktorw))
             joystick_x.integerValue = Int(Float(x*faktorw))
             goto_x_Stepper.integerValue = Int(Float(x*faktorw))
             */
            let achse0 = UInt16(Float(x*faktorw) * LOK_FAKTOR0)
            //print("x: \(x) achse0: \(achse0)")
            teensy.write_byteArray[ACHSE0_BYTE_H] = UInt8((achse0 & 0xFF00) >> 8) // hb
            teensy.write_byteArray[ACHSE0_BYTE_L] = UInt8((achse0 & 0x00FF) & 0xFF) // lb
            
            
            let h = Double(Joystickfeld.bounds.size.height)
            let faktorh:Double = (Pot1_Slider.maxValue - Pot1_Slider.minValue) / h  // Normierung auf Feldhoehe
            
            let faktorz = 1
            //     print("h: \(h) faktorh: \(faktorh)")
            var y = Double(punkt.y)
            if (y > h)
            {
               y = h
            }
            let z = 0
            
            /*
             goto_y.integerValue = Int(Float(y*faktorh))
             joystick_y.integerValue = Int(Float(y*faktorh))
             goto_y_Stepper.integerValue = Int(Float(y*faktorh))
             */
            
            let achse1 = UInt16(Float(y*faktorh) * LOK_FAKTOR1)
            //print("y: \(y) achse1: \(achse1)")
            teensy.write_byteArray[ACHSE1_BYTE_H] = UInt8((achse1 & 0xFF00) >> 8) // hb
            teensy.write_byteArray[ACHSE1_BYTE_L] = UInt8((achse1 & 0x00FF) & 0xFF) // lb
            
            let achse2 =  UInt16(Float(z*faktorz) * LOK_FAKTOR2)
            teensy.write_byteArray[ACHSE2_BYTE_H] = UInt8((achse2 & 0xFF00) >> 8) // hb
            teensy.write_byteArray[ACHSE2_BYTE_L] = UInt8((achse2 & 0x00FF) & 0xFF) // lb
            
            let message:String = info?["message"] as! String
            if ((message == "mousedown") && (first >= 0))// Polynom ohne mousedragged
            {
               
               teensy.write_byteArray[0] = SET_RING
               let anz:Int = servoPfad?.anzahlPunkte() ?? 0
               print("robot joystickAktion anz: \(anz)")
               if (wegindex > 1)
               {
                  print("")
                  print("robot joystickAktion cont achse0: \(achse0) achse1: \(achse1)  achse2: \(achse2) anz: \(String(describing: anz)) wegindex: \(wegindex)")
                  
                  let lastposition = servoPfad?.pfadarray.last
                  
                  let lastx:Int = Int(lastposition!.x)
                  let nextx:Int = Int(achse0)
                  let hypx:Int = (nextx - lastx) * (nextx - lastx)
                  
                  let lasty:Int = Int(lastposition!.y)
                  let nexty:Int = Int(achse1)
                  let hypy:Int = (nexty - lasty) * (nexty - lasty)
                  
                  let lastz:Int = Int(lastposition!.z)
                  let nextz:Int = Int(achse2)
                  let hypz:Int = (nextz - lastz) * (nextz - lastz)
                  
                  print("joystickAktion lastx: \(lastx) nextx: \(nextx) lasty: \(lasty) nexty: \(nexty) ***  lastz: \(lastz) nextz: \(nextz)")
                  
                  
                  let hyp:Float = (sqrt((Float(hypx + hypy + hypz)))) // Gesamter Weg ueber x,y,z
                  
    //              let anzahlsteps = hyp/schrittweiteFeld.floatValue
     //             print("Robot joystickAktion hyp: \(hyp) anzahlsteps: \(anzahlsteps) ")
                  
                  teensy.write_byteArray[HYP_BYTE_H] = UInt8((Int(hyp) & 0xFF00) >> 8) // hb
                  teensy.write_byteArray[HYP_BYTE_L] = UInt8((Int(hyp) & 0x00FF) & 0xFF) // lb
                  
  //                teensy.write_byteArray[STEPS_BYTE_H] = UInt8((Int(anzahlsteps) & 0xFF00) >> 8) // hb
  //                teensy.write_byteArray[STEPS_BYTE_L] = UInt8((Int(anzahlsteps) & 0x00FF) & 0xFF) // lb
                  
                  teensy.write_byteArray[INDEX_BYTE_H] = UInt8(((wegindex-1) & 0xFF00) >> 8) // hb // hb // Start, Index 0
                  teensy.write_byteArray[INDEX_BYTE_L] = UInt8(((wegindex-1) & 0x00FF) & 0xFF) // lb
                  
                  print("joystickAktion hypx: \(hypx) hypy: \(hypy) hypz: \(hypz) hyp: \(hyp)")
                  
               }
               else
               {
                  print("robot joystickAktion start achse0: \(achse0) achse1: \(achse1)  achse2: \(achse2) anz: \(anz) wegindex: \(wegindex)")
                  teensy.write_byteArray[HYP_BYTE_H] = 0 // hb // Start, keine Hypo
                  teensy.write_byteArray[HYP_BYTE_L] = 0 // lb
                  teensy.write_byteArray[INDEX_BYTE_H] = 0 // hb // Start, Index 0
                  teensy.write_byteArray[INDEX_BYTE_L] = 0 // lb
                  
               }
               
               servoPfad?.addPosition(newx: achse0, newy: achse1, newz: 0)
               
            }
         } // if 2000
         if (globalusbstatus > 0)
         {
            let senderfolg = teensy.send_USB()
            print("robot joystickaktion  senderfolg: \(senderfolg)")
         }
      }
      else
      {
         //         print("Robot joystickAktion passt nicht")
      }
      
      
   }
   
   //MARK Geometrie
   
   @IBAction  func report_Intervalltimer_Stepper(_ sender: NSStepper) // untere Grenze
   {
      print("report_Intervalltimer_Stepper IntVal: \(sender.integerValue)")
      teensy.write_byteArray[0] = LOK_0 
      let intpos = sender.integerValue 
      Intervalltimer_Feld.integerValue = intpos
      teensy.write_byteArray[18] = UInt8(intpos)
      timerintervall = UInt8(intpos)
      if (usbstatus > 0)
      {
         let senderfolg = teensy.send_USB()
         print("Robot report_Intervalltimer_Stepper senderfolg: \(senderfolg)")
      }

      
   }

   
   @IBAction  func report_Pause_Stepper(_ sender: NSStepper) // untere Grenze
   {
      print("report_Pause_Stepper IntVal: \(sender.integerValue)")
      teensy.write_byteArray[0] = LOK_0 
      let intpos = sender.integerValue 
      Pause_Feld.integerValue = intpos
      teensy.write_byteArray[19] = UInt8(intpos)
      pause = UInt8(intpos)
      if (usbstatus > 0)
      {
         let senderfolg = teensy.send_USB()
         print("Robot report_Pause_Stepper senderfolg: \(senderfolg)")
      }
      
      
   }
   
      
   //MARK: Slider 0
   @IBAction override func report_Slider0(_ sender: NSSlider)
   {
      teensy.write_byteArray[0] = 0xB0 // Code 
      print("Robot report_Slider0 IntVal: \(sender.intValue)")
      lokarray[12] = 0xB0
      let pos = sender.floatValue
      
      let intpos = UInt8(pos * LOK_FAKTOR0)
      let Ustring = formatter.string(from: NSNumber(value: intpos))
      var speed:UInt8 =  intpos
      print("report_Slider0 pos: \(pos) intpos: \(intpos)  speed: \(speed)")
      
 //      print("report_Slider0 speed: \(speed) richtung: \(richtung)")
      if speed > 0
      {
         speed += 1 // speed 1 ist Richtungsumschaltung
      }
      speedarray[1] = speed
      lokarray[6] = speed
      print("speedarray: \(speedarray)")
      print("lokarray: \(lokarray)")
      
  //  teensy.write_byteArray[16] = richtung // Richtung
      teensy.write_byteArray[17] = UInt8(speed) // speed

      
      // Pot0_Feld.stringValue  = Ustring!
      
      Pot0_Feld.integerValue = Int(pos)
      
 //     Pot0_Stepper_L.integerValue  = Int(sender.minValue) // Stepper min setzen
  //    Pot0_Stepper_L_Feld.integerValue = Int(sender.minValue)
//      Pot0_Stepper_H.integerValue  = Int(sender.maxValue) // Stepper max setzen
 //     Pot0_Stepper_H_Feld.integerValue = Int(sender.maxValue)
      
      print("usbstatus: \(usbstatus)")
      if (usbstatus > 0)
      {
         let senderfolg = teensy.send_USB()
         print("Robot report_Slider0 senderfolg: \(senderfolg)")
      }
 
   }
   
   @IBAction  func report_Richtung(_ sender: NSButton)
   {
      print("report_Richtung state: \(sender.state)")
      teensy.write_byteArray[0] = 0xC0 // Code 
      teensy.write_byteArray[17] = 1 // speed 1: Richtung togglen
      if (usbstatus > 0)
      {
         let senderfolg = teensy.send_USB()
         if (senderfolg < BUFFER_SIZE)
         {
            print("report_Richtung: %d",senderfolg)
         }
      }

   }
   
   @IBAction  func report_Funktion(_ sender: NSButton)
   {
      print("report_Funktion state: \(sender.state)")
      teensy.write_byteArray[0] = 0xD0 // Code 
      var funktion:UInt8 = 1
      if sender.state == .on
      {
         funktion = 0
      }
     teensy.write_byteArray[16] = funktion // Richtung
      if (usbstatus > 0)
      {
         let senderfolg = teensy.send_USB()
         if (senderfolg < BUFFER_SIZE)
         {
            print("report_Funktion: %d",senderfolg)
         }
      }

   }
   
   @IBAction override func report_set_Pot0(_ sender: NSTextField)
   {
      teensy.write_byteArray[0] = SET_0 // Code 
      
      // senden mit faktor 1000
      //let u = Pot0_Feld.floatValue 
      let Pot0_wert = Pot0_Feld.floatValue * 100
      let Pot0_intwert = UInt(Pot0_wert)
      
      let Pot0_HI = (Pot0_intwert & 0xFF00) >> 8
      let Pot0_LO = Pot0_intwert & 0x00FF
      
      print("Robot report_set_Pot0 Pot0_wert: \(Pot0_wert) Pot0 HI: \(Pot0_HI) Pot0 LO: \(Pot0_LO) ")
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
   
   @IBAction func report_Address0(_ sender: NSSegmentedControl)
   {
      teensy.write_byteArray[0] = LOK_0 // Code 
      print("Robot report_Address0 ident: \(sender.identifier!.rawValue) ")
      lokarray[12] = LOK_0
      let ident:String = ((sender.identifier)!.rawValue)
      var lok:Int = Int(ident)!
      lok /= 100
      //print("Robot report_Address0 lok A: \(lok) ")
      lok %= 10
      print("Robot report_Address0 lok B: \(lok) ")
      switch ident
      {
      case "1000":
         print("Robot report_Address0 index: \(sender.indexOfSelectedItem)")
         lokarray[0] = UInt8((sender.indexOfSelectedItem))
         addressarray[0] = UInt8((sender.indexOfSelectedItem))
         teensy.write_byteArray[8] = UInt8((sender.indexOfSelectedItem))
         break;
      case "1001":
         print("Robot report_Address0 index: \(sender.indexOfSelectedItem)")
         lokarray[1] = UInt8((sender.indexOfSelectedItem))
         addressarray[1] = UInt8((sender.indexOfSelectedItem))
         teensy.write_byteArray[9] = UInt8((sender.indexOfSelectedItem))
         break;
      case "1002":
         print("Robot report_Address0 index: \(sender.indexOfSelectedItem)")
         lokarray[2] = UInt8((sender.indexOfSelectedItem))
         addressarray[2] = UInt8((sender.indexOfSelectedItem))
         teensy.write_byteArray[10] = UInt8((sender.indexOfSelectedItem))
         break;
      case "1003":
         print("Robot report_Address0 index: \(sender.indexOfSelectedItem)")
         lokarray[3] = UInt8((sender.indexOfSelectedItem))
         addressarray[3] = UInt8((sender.indexOfSelectedItem))
         teensy.write_byteArray[11] = UInt8((sender.indexOfSelectedItem))
         break;
      default:
         break;
      }
      print("lokarray: \(lokarray)")
      print("addressarray: \(addressarray)")
      
//      teensy.write_byteArray[9] = UInt8((sender.indexOfSelectedItem))
//      teensy.write_byteArray[10] = UInt8((sender.indexOfSelectedItem))
//      teensy.write_byteArray[11] = UInt8((sender.indexOfSelectedItem))
      
//      teensy.write_byteArray[16] = 0 // Richtung
//      teensy.write_byteArray[17] = 0 // speed

      if (usbstatus > 0)
      {
         let senderfolg = teensy.send_USB()
         print("Robot report_Address0 senderfolg: \(senderfolg)")
      }
   }
   
 /*
   @IBAction  func report_x1_Slider(_ sender: NSSlider)
   {
 //     teensy.write_byteArray[0] = SET_1 // Code
      print("Robot report_x1_Slider IntVal: \(sender.intValue)")
      endx.integerValue = sender.integerValue
      
      
   }
   
   @IBAction  func report_y1_Slider(_ sender: NSSlider)
   {
 //     teensy.write_byteArray[0] = SET_1 // Code
      print("Robot report_y1_Slider IntVal: \(sender.intValue)")
      endy.integerValue = sender.integerValue
      
      
   }
   
   @IBAction  func report_z1_Slider(_ sender: NSSlider)
   {
 //     teensy.write_byteArray[0] = SET_1 // Code
      print("Robot report_z1_Slider IntVal: \(sender.intValue)")
      endz.integerValue = sender.integerValue
      
      
   }
 */  
   // MARK:Slider 1
   @IBAction override func report_Slider1(_ sender: NSSlider)
   {
      teensy.write_byteArray[0] = LOK_1 // Code
      lokarray[12] = LOK_1
 //     let name = UserDefaults.standard.string(forKey: "name")
 //     let robot1_offset = UserDefaults.standard.integer(forKey: "robot1offset")
      
   //   print(name)

 //    print("report_Slider1 float: \(sender.floatValue) min: \(sender.minValue) ")
      /*
       let pos = sender.floatValue
       Pot1_Feld_raw.integerValue = Int(pos)
       let intpos = UInt16(pos * FAKTOR1)
       //     let Istring = formatter.string(from: NSNumber(value: intpos))
       */
      let inv = Pot1_Inverse_Check.state.rawValue
      var pos:Float = 0
      if (inv == 0)
      {
         pos = sender.floatValue 
      }
      else
      {
         pos = Float(sender.maxValue) - sender.floatValue + Float(sender.minValue)
      }
      
      let intpos = UInt16(pos  * LOK_FAKTOR1)
      print("report_Slider1 pos: \(pos) intpos: \(intpos) ") 
      Pot1_Feld.integerValue  = Int(intpos)
      
      
 //     setAchse1(pos: (pos  * LOK_FAKTOR1)) // intpos
    }
   
   @IBAction func report_Address1(_ sender: NSSegmentedControl)
   {
      teensy.write_byteArray[0] = UInt8(LOK_1) // Code 
      lokarray[12] = UInt8(LOK_1)
      print("Robot report_Address0 ident: \(sender.identifier!.rawValue) ")
      
      let ident:String = ((sender.identifier)!.rawValue)
      var lok:Int = Int(ident)!
      lok /= 100
      //print("Robot report_Address0 lok A: \(lok) ")
      lok %= 10
      print("Robot report_Address0 lok B: \(lok) ")
      switch ident
      {
      case "1100":
         print("Robot report_Address1 index: \(sender.indexOfSelectedItem)")
         //lokarray[
         break;
      case "1101":
         print("Robot report_Address1 index: \(sender.indexOfSelectedItem)")
         break;
      case "1102":
         print("Robot report_Address1 index: \(sender.indexOfSelectedItem)")
         break;
      case "1103":
         print("Robot report_Address1 index: \(sender.indexOfSelectedItem)")
         break;
      default:
         break;
      }
   }
   
   
   // MARK:Slider 2
   @IBAction override func report_Slider2(_ sender: NSSlider)
   {
      UserDefaults.standard.set("Ruedi Heimlicher", forKey: "name")
      
      teensy.write_byteArray[0] = SET_2 // Code 
      print("Robot report_Slider2 IntVal: \(sender.intValue)")
      let inv = Pot2_Inverse_Check.state.rawValue
      var pos:Float = 0
      if (inv == 0)
      {
         pos = sender.floatValue
         /*
         Pot2_Stepper_L.integerValue  = Int(sender.minValue) // Stepper min setzen
         Pot2_Stepper_L_Feld.integerValue = Int(sender.minValue)
         Pot2_Stepper_H.integerValue  = Int(sender.maxValue) // Stepper max setzen
         Pot2_Stepper_H_Feld.integerValue = Int(sender.maxValue)
         */
      }
      else
      {
         pos = Float(sender.maxValue) - sender.floatValue + Float(sender.minValue)
         Pot2_Stepper_L.integerValue  = Int(sender.maxValue) // Stepper min setzen
         Pot2_Stepper_L_Feld.integerValue = Int(sender.maxValue)
         Pot2_Stepper_H.integerValue  = Int(sender.minValue) // Stepper max setzen
         Pot2_Stepper_H_Feld.integerValue = Int(sender.minValue)
         
         
      }
      let intpos = UInt16(pos * LOK_FAKTOR2)
      
      
      Pot2_Feld_raw.integerValue  = Int(pos)
      Pot2_Feld.integerValue  = Int(intpos)
      
 //     setAchse2(pos: pos * LOK_FAKTOR2)
      
   }
   
     
   
   
   @IBAction override func report_Slider3(_ sender: NSSlider)
   {
      teensy.write_byteArray[0] = SET_3 // Code 
      print("Robot report_Slider3 IntVal: \(sender.intValue)")
      
      let pos = sender.floatValue
      
      let intpos = UInt16(pos * FAKTOR3)
      let Ustring = formatter.string(from: NSNumber(value: intpos))
      
      //print("report_Slider3 pos: \(pos) intpos: \(intpos)  Ustring: \(Ustring ?? "0")")
      // Pot0_Feld.stringValue  = Ustring!
      Pot3_Feld.integerValue  = Int(intpos)
      Pot3_Stepper_L.integerValue  = Int(sender.minValue) // Stepper min setzen
      Pot3_Stepper_L_Feld.integerValue = Int(sender.minValue)
      Pot3_Stepper_H.integerValue  = Int(sender.maxValue) // Stepper max setzen
      Pot3_Stepper_H_Feld.integerValue = Int(sender.maxValue)
      
      teensy.write_byteArray[ACHSE3_BYTE_H] = UInt8((intpos & 0xFF00) >> 8) // hb
      teensy.write_byteArray[ACHSE3_BYTE_L] = UInt8((intpos & 0x00FF) & 0xFF) // lb
      
      if (globalusbstatus > 0)
      {
         let senderfolg = teensy.send_USB()
         print("report_Slider3 senderfolg: \(senderfolg)")
      }
   }
   
   
   
   @IBAction  func report_Drehknopf_Stepper_L(_ sender: NSStepper) // untere Grenze
   {
      print("report_Drehknopf_Stepper_L IntVal: \(sender.integerValue)")
      
      let intpos = sender.integerValue 
      Drehknopf_Stepper_L_Feld.integerValue = intpos
      
      DrehknopfFeld.minwinkel = CGFloat(sender.doubleValue)
      print("report_Drehknopf_Stepper_L DrehknopfFeld.minwinkel: \(DrehknopfFeld.minwinkel)")
      DrehknopfFeld.bogen.removeAllPoints()
      DrehknopfFeld.bogen.appendArc(withCenter:  DrehknopfFeld.mittelpunkt, radius: DrehknopfFeld.knopfrect.size.height/2-2, startAngle: DrehknopfFeld.minwinkel + 90, endAngle: DrehknopfFeld.maxwinkel + 90)
      
      //   abdeckpfad.fill()
      
      DrehknopfFeld.needsDisplay = true
      
   }
   
   
   
   @IBAction  func report_Drehknopf_Stepper_H(_ sender: NSStepper) // untere Grenze
   {
      print("report_Drehknopf_Stepper_H IntVal: \(sender.integerValue)")
      
      let intpos = sender.integerValue 
      Drehknopf_Stepper_H_Feld.integerValue = intpos
      
      DrehknopfFeld.maxwinkel = CGFloat(sender.doubleValue)
      print("report_Drehknopf_Stepper_H DrehknopfFeld.minwinkel: \(DrehknopfFeld.minwinkel)")
      DrehknopfFeld.bogen.removeAllPoints()
      DrehknopfFeld.bogen.appendArc(withCenter:  DrehknopfFeld.mittelpunkt, radius: DrehknopfFeld.knopfrect.size.height/2-2, startAngle: DrehknopfFeld.minwinkel + 90, endAngle: DrehknopfFeld.maxwinkel + 90)
      
      DrehknopfFeld.needsDisplay = true
      
   }
   
    @objc override func beendenAktion(_ notification:Notification) 
    {
      UserDefaults.standard.set(a0.indexOfSelectedItem, forKey: "a0index")
      UserDefaults.standard.set(a1.indexOfSelectedItem, forKey: "a1index")
      UserDefaults.standard.set(a2.indexOfSelectedItem, forKey: "a2index")
      UserDefaults.standard.set(a3.indexOfSelectedItem, forKey: "a3index")
      
      UserDefaults.standard.set(pause, forKey: "pause")
      
      UserDefaults.standard.set(timerintervall, forKey: "timerintervall")
      
           /*
      UserDefaults.standard.set(Pot1_Stepper_L.integerValue, forKey: "robot1min")
      UserDefaults.standard.set(Pot2_Stepper_L.integerValue, forKey: "robot2min")
      
      UserDefaults.standard.set(rotoffsetstepper.integerValue, forKey: "rotoffset")
      UserDefaults.standard.set(pot1offsetstepper.integerValue, forKey: "robot1offset")
      UserDefaults.standard.set(pot2offsetstepper.integerValue, forKey: "robot2offset")
   
      UserDefaults.standard.set(winkelfaktor1stepper.floatValue,forKey: "winkelfaktor1")
      UserDefaults.standard.set(winkelfaktor2stepper.floatValue,forKey: "winkelfaktor2")
      
      */
      print("Robot beendenAktion")
      
      NSApplication.shared.terminate(self)
      
   }

    
}
