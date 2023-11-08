//
//  ConfigManager.swift
//  Liushu
//
//  Created by Elliot on 2023/11/3.
//

import Foundation

class ConfigManager {
  static let shared = ConfigManager()

  func getDictPath() -> String {
    let appSupportURL = FileManager.default.urls(
      for: .applicationSupportDirectory, in: .userDomainMask
    ).first!
    let configDirURL = appSupportURL.appendingPathComponent(
      Bundle.main.bundleIdentifier ?? "com.elliot00.inputmethod.Liushu")

    try? FileManager.default.createDirectory(at: configDirURL, withIntermediateDirectories: true)

    let dictFileUrl = configDirURL.appendingPathComponent("sunman.trie")
    return dictFileUrl.path(percentEncoded: false)
  }
}
