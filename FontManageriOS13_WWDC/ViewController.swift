//
//  ViewController.swift
//  FontManageriOS13_WWDC
//
//  Created by Do Trinh on 2021/07/07.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var trcSau: UILabel!
    @IBOutlet weak var deleteFont: UIButton!
    private var resourceRequest: NSBundleResourceRequest?
    let myFontname: String = "Lora-Bold"
    @IBOutlet weak var applyBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        applyBtn.contentEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        applyBtn.layer.cornerRadius = 5
        deleteFont.contentEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        deleteFont.layer.cornerRadius = 5
        let fontList = [myFontname] as CFArray
        let assetList: Set<String> = ["Font"]
        requestFont(tags: assetList, fonts: fontList)
    }
    
    func requestFont(tags: Set<String>, fonts: CFArray) {
        resourceRequest = NSBundleResourceRequest(tags: tags)
        resourceRequest?.conditionallyBeginAccessingResources { [weak self] isAvailable in
            if isAvailable {
                debugPrint("is available")
                self?.installFont(fonts: fonts)
            } else {
                debugPrint("is not available")
                self?.accessFont(fonts: fonts)
            }
        }
    }
    
    func accessFont(fonts: CFArray) {
        resourceRequest?.beginAccessingResources { [weak self] error in
            if error == nil {
                self?.installFont(fonts: fonts)
            } else {
                debugPrint("failure", error?.localizedDescription ?? "")
            }
            self?.resourceRequest?.endAccessingResources()
        }
    }
    
    func installFont(fonts: CFArray) {
        CTFontManagerRegisterFontsWithAssetNames(fonts, CFBundleGetMainBundle(), .persistent, true) { errors, _ -> Bool in
            if 1 <= CFArrayGetCount(errors) {
                debugPrint("font install failure: \(unsafeBitCast(CFArrayGetValueAtIndex(errors, 0), to: CFError.self).localizedDescription)")
                return false
            } else {
                debugPrint("font install success")
                return true
            }
        }
    }
    
    @IBAction func UninstallBtn(_ sender: Any) {
        let fontList = [myFontname]
        let fontDescriptors = fontList.compactMap { $0.fontDescriptor }
        
        CTFontManagerUnregisterFontDescriptors(fontDescriptors as CFArray, .persistent) { errors, _ -> Bool in
            if 1 <= CFArrayGetCount(errors) {
                debugPrint("font uninstall failure: \(unsafeBitCast(CFArrayGetValueAtIndex(errors, 0), to: CFError.self).localizedDescription)")
                return false
            } else {
                debugPrint("font uninstall success")
                return true
            }
        }
    }
    
    
    @IBOutlet weak var demoFont: UILabel!
    
    @IBAction func getFonts(_ sender: Any) {
        let descriptors = CTFontManagerCopyRegisteredFontDescriptors(.persistent, true) as? [CTFontDescriptor]
        //        print(descriptors ?? [])
        guard let loraBoldDescriptor = descriptors?.first else { return }
        demoFont.font = UIFont(descriptor: loraBoldDescriptor, size: 20.0)
        
        for itemfamily in UIFont.familyNames {
            print(itemfamily);
        }
        trcSau.text = "after"
    }
}

extension String {
    
    var fontDescriptor: CTFontDescriptor? {
        return (CTFontManagerCopyRegisteredFontDescriptors(.persistent, true) as? [CTFontDescriptor])?.first {
            CTFontDescriptorCopyAttribute($0, kCTFontNameAttribute) as? String == self
        }
    }
}
