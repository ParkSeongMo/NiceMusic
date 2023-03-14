//
//  Log.swift
//  NiceMuisc
//
//  Created by Seongmo Park on 2023/03/13.
//

import Then

struct Log {
    typealias WriteHandler = (Log.Level, String, String, Int, Any?, DispatchQueue?) -> Void
    fileprivate static let timeFormat = DateFormatter().then { $0.dateFormat = "YYYY/MM/dd-HH:mm:ss.SSS" }

    fileprivate static let consoleQueue = DispatchQueue(label: "console-log-queue")
    fileprivate static let fileoutQueue = DispatchQueue(label: "file-log-queue")

    public static let fileName = "coolstay_log.txt"
    static var isUploading = false

    fileprivate static let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        .appendingPathComponent(Log.fileName)

    fileprivate static let isEnabledConsole = true
    fileprivate static var isEnabledFile: Bool {
#if !RELEASE
        return true
#else
        return false
#endif
    }

    fileprivate static let makeFormat: (Log.Level, String, String, Int, Any?) -> String = {
        level, file, function, line, message in

        let className = file[..<file.index(file.reversed().firstIndex(of: ".")!.base, offsetBy: -1)]
        var log = String()
        if let message = message {
           log = "\(className).\(function):\(line) - \(message)"
        } else {
           log = "\(className).\(function):\(line)"
        }
        return "\(Log.timeFormat.string(from: Date())) \(level.consoleSymbol) \(log)"
    }

    fileprivate static let writeConsole: WriteHandler = { level, file, function, line, message, queue in
        let msg = makeFormat(level, file, function, line, message)
        let execute: () -> Void = {
            print(msg)
        }
        if let queue = queue {
            queue.async(execute: execute)
        } else {
            execute()
        }
        if isEnabledFile {
            writeFile(msg, fileoutQueue)
        }
    }

    fileprivate static let writeFile: (String, DispatchQueue?) -> Void = { msg, queue in
        if let queue = queue {
            queue.async {
                if !FileManager.default.fileExists(atPath: fileURL.path) {
                    FileManager.default.createFile(atPath: fileURL.path, contents: nil, attributes: nil)
                }

                let displayText = "\(msg) \n".data(using: String.Encoding.utf8)
                if let fileHandle = FileHandle(forWritingAtPath: fileURL.path) {
                    defer {
                        fileHandle.closeFile()
                    }
                    fileHandle.seekToEndOfFile()
                    fileHandle.write(displayText!)
                }
            }
        }
    }

    fileprivate enum Destination {
        case console
        case file

        func write(_ level: Log.Level, _ file: String, _ function: String, _ line: Int, _ message: Any? = nil) {
            Log.writeConsole(level, (file as NSString).lastPathComponent, function, line, message, Log.consoleQueue)
        }
    }

    enum Level {
        case verbose
        case debug
        case info
        case warning
        case error

        var consoleSymbol: String {
            switch self {
            case .verbose:  return "💬"
            case .debug:    return "ℹ️"
            case .info:     return "✅"
            case .warning:  return "⚠️"
            case .error:    return "❌"
            }
        }

        var fileSymbol: String {
            switch self {
            case .verbose:  return "V"
            case .debug:    return "D"
            case .info:     return "I"
            case .warning:  return "W"
            case .error:    return "E"
            }
        }
    }
}

extension Log {
    /// 주어진 메세지를 verbose 타입으로 출력
    ///
    /// - Parameter
    ///   - message:  출력할 메세지
    ///   - file:     파일명
    ///   - function: 함수명
    ///   - line:     라인
    static func v(_ message: @autoclosure () -> Any, _ file: String = #file, _ function: String = #function, _ line: Int = #line) {
        Log.Destination.console.write(.verbose, file, function, line, message())
    }

    /// 주어진 메세지를 debug 타입으로 출력
    ///
    /// - Parameter
    ///   - message:  출력할 메세지
    ///   - file:     파일명
    ///   - function: 함수명
    ///   - line:     라인
    static func d(_ message: @autoclosure () -> Any, _ file: String = #file, _ function: String = #function, _ line: Int = #line) {
        Log.Destination.console.write(.debug, file, function, line, message())
    }

    /// 주어진 메세지를 info 타입으로 출력
    ///
    /// - Parameter
    ///   - message:  출력할 메세지
    ///   - file:     파일명
    ///   - function: 함수명
    ///   - line:     라인
    static func i(_ message: @autoclosure () -> Any, _ file: String = #file, _ function: String = #function, _ line: Int = #line) {
        Log.Destination.console.write(.info, file, function, line, message())
    }

    /// 주어진 메세지를 warning 타입으로 출력
    ///
    /// - Parameter
    ///   - message:  출력할 메세지
    ///   - file:     파일명
    ///   - function: 함수명
    ///   - line:     라인
    static func w(_ message: @autoclosure () -> Any, _ file: String = #file, _ function: String = #function, _ line: Int = #line) {
        Log.Destination.console.write(.warning, file, function, line, message())
    }

    /// 주어진 메세지를 error 타입으로 출력
    ///
    /// - Parameter
    ///   - message:  출력할 메세지
    ///   - file:     파일명
    ///   - function: 함수명
    ///   - line:     라인
    static func e(_ message: @autoclosure () -> Any, _ file: String = #file, _ function: String = #function, _ line: Int = #line) {
        Log.Destination.console.write(.error, file, function, line, message())
    }
}

extension Log {
//    static func logAction() {
//        #if !RELEASE
//        if isUploading {
//            return
//        }
//        isUploading = true
//        //NavigationCotrollManager.shared.currentNavigation?.topViewController?.startIndicator()
//        Log.d("로그 업로드 시도")
//        let localURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent(Log.fileName)
//
//        do {
//            let now = Date()
//            let nowString = now.string(withFormat: "yyyyMMdd'_'HHmmSS", locale: Locale(identifier: "ko_KR"))
//            let readData = try Data(contentsOf: localURL)
//            FTPUpload.shared().send(data: readData, with: "coolstay" + nowString + ".txt", success: {
//                //NavigationCotrollManager.shared.currentNavigation?.topViewController?.stopIndicator()
//                if $0 {
//                    DispatchQueue.main.async {
//                        Toast("꿀스테이 로그 업로드 완료").show()
//                    }
//                    Log.removeLogFile(force: true)
//                } else {
//                    DispatchQueue.main.async {
//                        Toast("꿀스테이 로그 업로드 실패").show()
//                    }
//                }
//                isUploading = false
//            })
//        } catch let error as NSError {
//            Log.e(error)
//            //NavigationCotrollManager.shared.currentNavigation?.topViewController?.stopIndicator()
//            DispatchQueue.main.async {
//                Toast("꿀스테이 로그 업로드 실패").show()
//            }
//            isUploading = false
//        }
//
//        #endif
//    }

    static func removeLogFile(force: Bool = false) {
        // 로그 파일 10MB 이상일 경우 제거
        let localURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent(Log.fileName)
        do {
            guard let fileSize = try FileManager.default.attributesOfItem(atPath: localURL.path)[.size] as? NSNumber else {
                return
            }

            let longSize: UInt64 = fileSize.uint64Value
            if longSize > 10 * 1024 * 1024 || force {
                try FileManager.default.removeItem(at: localURL)
            }
        } catch let error as NSError {
            Log.e(error)
        }
    }
}
