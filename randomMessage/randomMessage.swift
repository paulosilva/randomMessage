//
//  randomMessages.swift
//  randomMessages
//
//  Created by Paulo Silva on 24/09/2018.
//  Copyright © 2018 Paulo Silva. All rights reserved.
//

import UIKit
import Foundation

// MARK: - Codable Objects

struct messageData: Codable {
    var version: Double
    var messages: [messageItems]?
    
    enum CodingKeys: String, CodingKey {
        case version
        case messages
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        version = try values.decode(Double.self, forKey: .version)
        messages = try values.decode([messageItems].self, forKey: .messages)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(version, forKey: .version)
        try container.encode(messages, forKey: .messages)
    }
}

struct messageItems: Codable {
    var subject: String?
    var messages: [messageItem]?
    
    enum CodingKeys: String, CodingKey {
        case subject
        case messages
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        subject = try values.decode(String.self, forKey: .subject)
        messages = try values.decode([messageItem].self, forKey: .messages)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(subject, forKey: .subject)
        try container.encode(messages, forKey: .messages)
    }
}

struct messageItem: Codable {
    var index: Int?
    var localizedKey: String?
    var schedule: [String]?
    var display: Int?
    
    enum CodingKeys: String, CodingKey {
        case index
        case localizedKey
        case schedule
        case display
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        index = try values.decode(Int.self, forKey: .index)
        localizedKey = try values.decode(String.self, forKey: .localizedKey)
        schedule = try values.decode([String].self, forKey: .schedule)
        display = try values.decode(Int.self, forKey: .display)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(index, forKey: .index)
        try container.encode(localizedKey, forKey: .localizedKey)
        try container.encode(schedule, forKey: .schedule)
        try container.encode(display, forKey: .display)
    }
}

// MARK: - Random Messages Class
class randomMessage: NSObject {
    
    // MARK: - Private variables
    
    private var bundleName: String? = ""
    private var fileName: String? = "randomMessage.json"
    private let defaultsKey = "Settings.User.Messages"
    private var listOfMessages: messageData?
    private var currentItem: messageItem?
    
    // MARK: - Public properties

    
    // MARK: - Public methods

    override init() {
        super.init()
        self.initMessages()
    }
    
    /*
     getMessageForSubject("ABC")
     getMessageForSubject("CBS", schedulerFilter: "PM")
     */
    //
    public func getMessageForSubject(_ subject: String, schedulerFilter: String) -> String {
        // All Messages
        var listOfMessages = self.messagesForSubject(subject)
        
        if listOfMessages.count == 0  {
            return "No message found fot the subject: \(subject)"
        }
        
        // Filtred Messaages
        var listOfFilter = listOfMessages.filter { (item) -> Bool in
            ((item.schedule?.contains(schedulerFilter.uppercased()))! && item.display == 1)
        }
        
        // No data found so load all for the time filter
        if listOfFilter.count == 0  {
            
            // I'm empty, so reset and get all again
            self.resetDisplayMessageForSubject(subject)
            
            // Update last showed
            if self.currentItem != nil {
                self.updateDisplayForMessageIndex(self.currentItem!.index!, forSubject: subject)
            }
            
            // All Messages
            listOfMessages = self.messagesForSubject(subject)
            
            // Filtred Messaages
            listOfFilter = listOfMessages.filter { (item) -> Bool in
                ((item.schedule?.contains(schedulerFilter.uppercased()))! && item.display == 1)
            }
            
            if listOfFilter.count == 0  {
                return "No message found fot the scheduler: \(schedulerFilter)"
            }
        }
        
        // Random Index
        let randomIndexNumber = arc4random_uniform(UInt32(listOfFilter.count - 0))
        
        // Update Item
        self.currentItem = listOfFilter[Int(randomIndexNumber)]
        self.updateDisplayForMessageIndex(self.currentItem!.index!, forSubject: subject)
        
        //
        self.storeJsonData()
        
        // Return the key
        return self.currentItem!.localizedKey!
    }
    
    public func getMessageForSubject(_ subject: String) -> String {
        let dateTime = Date()
        let schedulerFilter = dateTime.toString(identifier: "en_GB", format: "a")
        return self.getMessageForSubject(subject, schedulerFilter: schedulerFilter!)
    }
    
    // MARK: - Private methods

    private func initMessages() {
        if UserDefaults.standard.existsValue(forKey: self.defaultsKey) == true {
            do {
                let jsonString = UserDefaults.standard.string(forKey: self.defaultsKey)!
                self.listOfMessages = try JSONDecoder().decode(messageData.self, from: jsonString.data(using: .utf8)!)
            } catch {
                print("Unexpected error: \(error).")
            }
        }
        
        if let renimders = self.readJSONFromFile() {
            if self.listOfMessages == nil || (self.listOfMessages?.version)! < renimders.version  {
                self.listOfMessages = renimders
                self.storeJsonData()
            }
        }
    }
    
    private func messagesForSubject(_ subject: String) -> [messageItem] {
        for _item in self.listOfMessages!.messages! {
            if _item.subject?.lowercased().range(of: subject.lowercased()) != nil {
                return _item.messages!
            }
        }
        return [messageItem]()
    }
    
    private func resetDisplayMessageForSubject(_ subject: String) {
        for (msgIndex, msgItem) in self.listOfMessages!.messages!.enumerated() {
            if msgItem.subject?.lowercased().range(of: subject.lowercased()) != nil {
                for (messageIdx, _) in msgItem.messages!.enumerated() {
                    self.listOfMessages!.messages![msgIndex].messages![messageIdx].display = 1
                }
            }
        }
    }
    
    private func updateDisplayForMessageIndex(_ index: Int, forSubject subject: String) {
        for (msgIndex, msgItem) in self.listOfMessages!.messages!.enumerated() {
            if msgItem.subject?.lowercased().range(of: subject.lowercased()) != nil {
                for (messageIdx, _message) in msgItem.messages!.enumerated() {
                    if _message.index == index {
                        self.listOfMessages!.messages![msgIndex].messages![messageIdx].display = 0
                    }
                }
            }
        }
    }
    
    private func storeJsonData() {
        let jsonEncoder = JSONEncoder()
        do {
            let jsonData = try jsonEncoder.encode(self.listOfMessages)
            UserDefaults.standard.set(String(data: jsonData, encoding: .utf8), forKey: self.defaultsKey)
            UserDefaults.standard.synchronize()
        } catch {
            print("Unexpected error: \(error).")
        }
    }
    
    private func readJSONFromFile() -> messageData? {
        let _bundlePath = self.getBundlePath(self.bundleName!)
        let _filePath = self.getFilePath(_bundlePath + self.fileName!)
        if !_filePath.isEmpty {
            do {
                let filedata = try! Data(contentsOf: URL(fileURLWithPath: _filePath))
                return try JSONDecoder().decode(messageData.self, from: filedata)
            } catch {
                print("Unexpected error: \(error).")
            }
        }
        return nil
    }
    
    private func getBundlePath(_ name: String) -> String {
        // the bundle
        if name.isEmpty {
            return Bundle.main.bundlePath + "/"
        } else {
            if let _bundlePath = Bundle.main.path(forResource: name, ofType: "bundle") {
                return _bundlePath
            }
        }
        return ""
    }
    
    private func getFilePathInDocuments(_ name: String) -> String {
        let fileManager = FileManager.default
        do {
            let documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
            let fileURL = documentDirectory.appendingPathComponent(name)
            return fileURL.absoluteString
        } catch {
            print("Unexpected error: \(error).")
        }
        return ""
    }
    
    private func getFilePath(_ filename: String) -> String {
        // the file
        if (self.fileExists(filename)) {
            return filename
        }
        return ""
    }
    
    private func fileExists(_ path: String) -> Bool {
        let url = NSURL(fileURLWithPath: path)
        if let filePath = url.path {
            let fileManager = FileManager.default
            if fileManager.fileExists(atPath: filePath) {
                // FILE AVAILABLE
                return true
            } else {
                // FILE NOT AVAILABLE
                return false
            }
        } else {
            // FILE PATH NOT AVAILABLE
            return false
        }
    }
}

// MARK: - Some necessary extensions, move to a different file if necessary
extension UserDefaults {
    func existsValue(forKey key: String) -> Bool {
        return nil != object(forKey: key)
    }
}

extension DateFormatter {
    convenience init (format: String) {
        self.init()
        locale = Locale.current
        dateFormat = format
    }
    
    convenience init (identifier: String, format: String = "yyyy/MM/dd", secondsFromGMT: Int = 0) {
        self.init()
        locale = Locale(identifier: identifier) // en_US_POSIX, pt_PT, en_UK, en_GB
        timeZone = TimeZone(secondsFromGMT: secondsFromGMT)
        amSymbol = Locale.current.calendar.amSymbol
        pmSymbol = Locale.current.calendar.pmSymbol
        dateFormat = format
    }
}

extension Date {
    func toString (format: String) -> String? {
        return DateFormatter(format: format).string(from: self)
    }
    
    func toString (identifier: String, format: String = "yyyy/MM/dd") -> String? {
        return DateFormatter(identifier: identifier, format: format).string(from: self)
    }
}

