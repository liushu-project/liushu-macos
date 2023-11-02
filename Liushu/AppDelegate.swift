//
//  AppDelegate.swift
//  Liushu
//
//  Created by Elliot on 2023/11/2.
//

import Cocoa
import InputMethodKit
import LiushuCore

// necessary to launch this app
class NSManualApplication: NSApplication {
    private let appDelegate = AppDelegate()

    override init() {
        super.init()
        self.delegate = appDelegate
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    var server = IMKServer()
    var candidatesWindow = IMKCandidates()
    var engine: Engine?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Insert code here to initialize your application
        server = IMKServer(name: Bundle.main.infoDictionary?["InputMethodConnectionName"] as? String, bundleIdentifier: Bundle.main.bundleIdentifier)
        candidatesWindow = IMKCandidates(server: server, panelType: kIMKSingleRowSteppingCandidatePanel, styleType: kIMKMain)
        let appSupportURL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let configDirURL = appSupportURL.appendingPathComponent(Bundle.main.bundleIdentifier ?? "com.elliot00.inputmethod.Liushu")
        try? FileManager.default.createDirectory(at: configDirURL, withIntermediateDirectories: true)
        let dictFileUrl = configDirURL.appendingPathComponent("sunman.trie")
        let dictPath = dictFileUrl.path(percentEncoded: false)

        do {
            engine = try Engine(dictPath: dictPath)
        } catch {
            fatalError("could not init engine")
        }
        NSLog("tried connection")
    }

    func applicationWillTerminate(_ notification: Notification) {
        // Insert code here to tear down your application
    }
}
