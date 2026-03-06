//
//  rWeicheView.swift
//  H0_Interface
//
//  Created by Ruedi Heimlicher on 05.03.2026.
//  Copyright © 2026 Ruedi Heimlicher. All rights reserved.
//

import Foundation
import Cocoa
import AppKit

//var numtasten:Int = 8

class rWeichenradio: NSButton 
{
   var radionummer:Int = 0
   var name:String = ""
   func configure()
   {
      self.state = .off
      self.target = self
      self.action = #selector(self.report_weichentaste)
      self.controlSize = .large
      self.title = "x"
      self.setButtonType(NSButton.ButtonType.radio)
      
   }
   override init(frame frameRect: NSRect) 
   {
      Swift.print("rWeichenradio init frame")
          super.init(frame: frameRect)
          configure()
      self.action = #selector(self.report_weichentaste)
      }
   required init?(coder  aDecoder : NSCoder) 
   {
      super.init(coder: aDecoder)
      configure()
      
      Swift.print("rWeichenradio init coder ")
      self.action = #selector(self.report_weichentaste)
   }
   
   func setValue(_ v: Int) 
   {
          self.radionummer = v
      }
   
   @objc func report_weichentaste(_ sender: NSButton)
   {
      Swift.print("report_weichentaste  ident: \(self.radionummer) name: \(self.name) tag: \(self.tag)")  
      let status = sender.state
     // let ident = self.identifier
      //let tastetag = self.tag
   }
   
   

   
}// rWeichenradio



class rWeichenradiogruppe:NSView
{
   
   var weichengruppenummer:Int = 0
   var weichen: [rWeichenradio] = []
  
   var hintergrundfarbe = NSColor()
   
   var weichenstatus:[Int] = Array(repeating: 0, count: 2) 
   var weichenstellung:UInt8 = 0;
   var radio0:rWeichenradio! 
   var radio1:rWeichenradio! 
   
   required init?(coder  aDecoder : NSCoder) 
   {
      super.init(coder: aDecoder)
      Swift.print("rWeichenradiogruppe init")
      
   }
   
   
   
   override init(frame frameRect: NSRect) 
   {
      super.init(frame: frameRect)
      /*
      self.title = "Meine Box"   // Beispiel: Titel setzen
      self.boxType = .primary     // Typ der Box
      self.borderColor = .black   // Rahmenfarbe
      self.fillColor = .lightGray //
      self.titlePosition = .noTitle
       */
      self.wantsLayer = true
      hintergrundfarbe  = NSColor.init(red: 0, 
                                       green: 1.0, 
                                       blue: 1.0, 
                                       alpha: 0.25)
      self.layer?.backgroundColor =  hintergrundfarbe.cgColor
      
      let w:CGFloat = bounds.size.width
      let h:CGFloat = bounds.size.height
      
      let tasteW:CGFloat = 20
      let tasteH:CGFloat = 20
      
      var tastenrect : NSRect = NSMakeRect(5 ,0 , tasteW,tasteH)
      var radiotaste0 = rWeichenradio(frame:tastenrect)
      
      radio0 = rWeichenradio(frame:tastenrect)
      //radio0.setValue(10)
      radio0.name = "radio0"
      
 
      addSubview(radio0)
      var tastenrect1 : NSRect = NSMakeRect(30 ,0 , tasteW,tasteH)
      radio1 = rWeichenradio(frame:tastenrect1)
      //radio1.setValue(11)
      radio1.name = "radio1"
      
      addSubview(radio1)
      
      //var gruppenrect0 : NSRect = NSMakeRect(50 ,0 , tasteW,tasteH)

      
      
   }
   
   
   
   @objc func setWeichentasten()
   {
      
      
   }
}

class rWeichenradioView:NSView
{
   var weiche:Int = 0
   
   var weichenradiogruppe0:rWeichenradiogruppe!
   var weichenradiogruppe1:rWeichenradiogruppe!
   var weichengruppenummer:Int = 0 
   var titelFeld:NSTextField!
   
   var hintergrundfarbe = NSColor()
   var weichenstatus:[Int] = Array(repeating: 0, count: numtasten) // werte der tastenstellungen
   var weichenstellung:UInt8 = 0;
   var weichenarray:[rWeichenradiogruppe] = []
   
   let n = 10
   var arr: [Int] = []
 
   
  
   @objc func setWeichentasten()
   {
      Swift.print("setWeichentasten \(self.bounds.width)") 
      
   }
   
   
   
   @IBAction func radioChanged(_ sender: NSButton) 
   {
      Swift.print("radioChanged")   
      Swift.print("tag: \(sender.tag) state \(sender.state)") 
      
      //gerade.state = (sender == gerade) ? .on : .off
   }
   
  
   
   required init?(coder  aDecoder : NSCoder) 
   {
      super.init(coder: aDecoder)
      
      Swift.print("rWeichenradioView init coder")
      self.wantsLayer = true
      hintergrundfarbe  = NSColor.init(red: 1, 
                                       green: 0.2, 
                                       blue: 0, 
                                       alpha: 0.25)
      //self.layer?.backgroundColor =  hintergrundfarbe.cgColor
      self.layer?.backgroundColor =  NSColor.red.cgColor
      let w:CGFloat = bounds.size.width
      let h:CGFloat = bounds.size.height
      var switchH = h/Double(numtasten)
      let tasteW:CGFloat = 30
      identifier = NSUserInterfaceItemIdentifier("111")
      
       
      weiche = 15
      let titelfeldrect = NSMakeRect(w-24,h-24 , 24,24)
      titelFeld = NSTextField(frame:titelfeldrect )
      
      addSubview(titelFeld)
      titelFeld.integerValue = weiche
      
      weichenarray.reserveCapacity(numtasten)
      switchH = 22
      
      for row in 0..<numtasten
      {
         let tastenrect = NSMakeRect(10 ,10 + CGFloat(row) * switchH, 2 * tasteW, switchH)
         let weichenradiogruppe = rWeichenradiogruppe(frame:(tastenrect))
         weichenradiogruppe.wantsLayer = true
         weichenradiogruppe.layer?.backgroundColor =  NSColor.gray.cgColor
         var nr = 20 + 2*row
         weichenradiogruppe.weichengruppenummer = 20 + row
         weichenradiogruppe.radio0.setValue(nr)
         weichenradiogruppe.radio0.tag = 2000+nr
         nr += 1
         weichenradiogruppe.radio1.setValue(nr)
         weichenradiogruppe.radio1.tag = 2000+nr
         addSubview(weichenradiogruppe)
         weichenarray.append(weichenradiogruppe)      
         Swift.print("rWeichenradioView row: \(row) nr: \(nr)")
      }
     
 
      
      
   }//required
   
   
 
   
   
}// rWeichenradioView
