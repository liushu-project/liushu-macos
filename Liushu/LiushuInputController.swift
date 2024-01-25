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
  private var isActived = true
  private var prevKeyIsShift = false
  private var candidatesWindow: IMKCandidates {
    return (NSApp.delegate as! AppDelegate).candidatesWindow
  }
  private var engineAgent: InputMethodEngineAgent? {
    return (NSApp.delegate as! AppDelegate).engineAgent
  }
  private var inputs = String()
  private(set) var candidates = autoreleasepool { return [String]() }
  private(set) var candidateSelection: NSAttributedString? = autoreleasepool {
    return NSAttributedString()
  }

  // TODO: extract to engine
  private let fullShapePunctuationMap: [UInt16: String] = [
    KeyCode.period: "。",
    KeyCode.comma: "，",
    KeyCode.semicolon: "；",
    KeyCode.leftBracket: "（",
    KeyCode.rightBracket: "）",
  ]

  override func handle(_ event: NSEvent!, client sender: Any!) -> Bool {
    NSLog("\(String(describing: event))")

    if event.type == .flagsChanged && event.keyCode == KeyCode.shift {
      if prevKeyIsShift {
        prevKeyIsShift = false
        toggleInputMethod()
      } else {
        prevKeyIsShift = true
      }
      return true
    } else {
      prevKeyIsShift = false
    }

    if !isActived {
      return false
    }

    if event.type != .keyDown {
      return false
    }

    guard let client = sender as? IMKTextInput else {
      return false
    }

    switch event.keyCode {
    case KeyCode.a, KeyCode.b, KeyCode.c, KeyCode.d, KeyCode.e, KeyCode.f, KeyCode.g, KeyCode.h,
      KeyCode.i, KeyCode.j, KeyCode.k, KeyCode.l, KeyCode.m, KeyCode.n, KeyCode.o, KeyCode.p,
      KeyCode.q, KeyCode.r, KeyCode.s, KeyCode.t, KeyCode.u, KeyCode.v, KeyCode.w, KeyCode.x,
      KeyCode.y, KeyCode.z:

      if let char = event.characters {
        NSLog("char is \(char)")
        return handleAnsiKey(char, client)
      }
    case KeyCode.delete:
      return handleDelete()
    case KeyCode.one:
      return handleNumberKey(index: 0, client)
    case KeyCode.two:
      return handleNumberKey(index: 1, client)
    case KeyCode.three:
      return handleNumberKey(index: 2, client)
    case KeyCode.four:
      return handleNumberKey(index: 3, client)
    case KeyCode.five:
      return handleNumberKey(index: 4, client)
    case KeyCode.six:
      return handleNumberKey(index: 5, client)
    case KeyCode.seven:
      return handleNumberKey(index: 6, client)
    case KeyCode.eight:
      return handleNumberKey(index: 7, client)
    case KeyCode.nine:
      return handleNumberKey(index: 8, client)
    case KeyCode.space:
      return handleSpaceKey(client)
    case KeyCode.escape:
      return handleEscape(client)
    default:
      if let punctuation = fullShapePunctuationMap[event.keyCode] {
        commit(punctuation, client)
        return true
      }
      NSLog("unhandled")
    }

    return false
  }

  func handleAnsiKey(_ char: String, _ client: IMKTextInput) -> Bool {
    inputs.append(char)
    updateComposition()
    candidates = engineAgent?.translate(code: inputs).map({ $0.text }) ?? []
    candidatesWindow.update()
    candidatesWindow.show()
    return true
  }

  func handleDelete() -> Bool {
    if inputs.isEmpty {
      return false
    }
    inputs.removeLast()
    updateComposition()
    candidates = engineAgent?.translate(code: inputs).map({ $0.text }) ?? []
    candidatesWindow.update()
    candidatesWindow.show()
    return true
  }

  func handleNumberKey(index num: Int, _ client: IMKTextInput) -> Bool {
    if num > candidates.count - 1 {
      return false
    }
    commit(candidates[num], client)
    return true
  }

  func handleSpaceKey(_ client: IMKTextInput) -> Bool {
    if let selectedString = candidateSelection?.string {
      commit(selectedString, client)
      return true
    }

    return false
  }

  func handleEscape(_ client: IMKTextInput) -> Bool {
    clearInputState()
    updateComposition()
    isActived = false
    return true
  }

  override func candidates(_ sender: Any!) -> [Any]! {
    return self.candidates
  }

  override func candidateSelectionChanged(_ candidateString: NSAttributedString!) {
    NSLog("current selection changed \(String(describing: candidateString))")
    candidateSelection = candidateString
  }

  override func recognizedEvents(_ sender: Any!) -> Int {
    let events: NSEvent.EventTypeMask = [.keyDown, .flagsChanged]
    return Int(events.rawValue)
  }

  override func composedString(_ sender: Any!) -> Any! {
    autoreleasepool {
      NSLog("composed string called")
      let attributes: [NSAttributedString.Key: Any] = [
        .underlineStyle: NSUnderlineStyle.single.rawValue
      ]
      return NSAttributedString(string: self.inputs, attributes: attributes)
    }
  }

  override func originalString(_ sender: Any!) -> NSAttributedString! {
    autoreleasepool {
      NSLog("original string called")
      return NSAttributedString(string: self.inputs)
    }
  }

  override func updateComposition() {
    let client = self.client()
    client?.setMarkedText(
      self.composedString(client), selectionRange: NSMakeRange(0, self.inputs.count),
      replacementRange: NSMakeRange(NSNotFound, NSNotFound))
  }

  override func cancelComposition() {
    clearInputState()
  }

  override func deactivateServer(_ sender: Any!) {
    NSLog("server deactive")
  }

  private func commit(_ string: Any!, _ client: IMKTextInput) {
    client.insertText(string, replacementRange: NSRange(location: NSNotFound, length: NSNotFound))
    clearInputState()
  }

  private func toggleInputMethod() {
    if isActived {
      isActived = false
      clearInputState()
    } else {
      isActived = true
    }
  }

  private func clearInputState() {
    self.inputs = ""
    self.candidates.removeAll()
    self.candidatesWindow.hide()
    self.candidateSelection = nil
  }
}
