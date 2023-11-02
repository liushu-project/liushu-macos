//
//  LiushuInputController.swift
//  Liushu
//
//  Created by Elliot on 2023/11/2.
//

import Cocoa
import InputMethodKit
import LiushuCore

@objc(LiushuInputController)
class LiushuInputController: IMKInputController {
    private var candidatesWindow: IMKCandidates { return (NSApp.delegate as! AppDelegate).candidatesWindow }
    private var engine: Engine? { return (NSApp.delegate as! AppDelegate).engine }
    private var inputs = String()
    private (set) var candidates = autoreleasepool { return [String]() }
    
    override func inputText(_ string: String!, client sender: Any!) -> Bool {
        NSLog(string)
        inputs.append(string)
        
        if candidatesWindow.isVisible() {
            if let keyValue = Int(string) {
                guard let client = sender as? IMKTextInput else {
                    return false
                }
                client.insertText(candidates[keyValue], replacementRange: NSRange(location: NSNotFound, length: NSNotFound))
                inputs = String()
                candidatesWindow.hide()
                return true
            }
        }
        
        candidatesWindow.update()
        candidatesWindow.show()
    
        return true
    }
    
    override func candidates(_ sender: Any!) -> [Any]! {
        if (inputs.isEmpty) {
            return []
        }
        let result: [String]?
        do {
            let items = try engine?.search(code: inputs)
            result = items?.map({ $0.text })
            candidates = result ?? []
        } catch {
            result = []
        }
        return result
    }
}
