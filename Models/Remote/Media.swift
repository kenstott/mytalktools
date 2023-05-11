//
//  Media.swift
//  test
//
//  Created by Kenneth Stott on 1/22/23.
//

import Foundation
import UIKit
import FMDB

struct UploadFileParams: Decodable, Encodable {
    var user: String
    var orientation: String?
}

class Media: ObservableObject {
    
    let encoder = JSONEncoder()
    let fileManager = FileManager.default
    let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    let orientation = [
        UIInterfaceOrientation.unknown.rawValue: "unknown",
        UIInterfaceOrientation.portrait.rawValue: "portrait",
        UIInterfaceOrientation.portraitUpsideDown.rawValue: "portrait-upside-down",
        UIInterfaceOrientation.landscapeLeft.rawValue: "landscape-left",
        UIInterfaceOrientation.landscapeRight.rawValue: "landscape-right"
    ]
    
    @Published var fileLoadingProgress = 0.0
    @Published var total = 0
    @Published var completed = 0
    @Published var directoryList: [FileListDirectory] = []
    @Published var downloading = false
    @Published var uploading = false
    
    func countMedia() -> Int {
        var total = 0
        for d in directoryList {
            total += d.FileList.count
        }
        return total;
    }
    
    static func splitFileName(str: String) -> (String, String, String) {
        let path = str as NSString
        let directory = path.deletingLastPathComponent
        
        let fileNameWithExtension = path.lastPathComponent as NSString
        let fileNameWithoutExtension = fileNameWithExtension.deletingPathExtension
        let fileExtension = fileNameWithExtension.pathExtension
        
        return (directory, fileNameWithoutExtension, fileExtension)
    }
    
    static func createLocalUrl(forImageNamed name: String) -> URL? {
        
        let fileManager = FileManager.default
        let cacheDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        let url = cacheDirectory.appendingPathComponent("\(name).png")
        
        guard fileManager.fileExists(atPath: url.path) else {
            guard
                let image = UIImage(named: name),
                let data = image.pngData()
            else { return nil }
            
            fileManager.createFile(atPath: url.path, contents: data, attributes: nil)
            return url
        }
        
        return url
    }
    
    static func getImage( _ path: String) -> UIImage {
        do {
            guard let url = getURL(path) else { return UIImage() }
            let data = try Data(contentsOf: url)
            return UIImage(data: data)!
        } catch {
            return UIImage()
        }
    }
    
    
    static func getURL(_ path: String) -> URL? {
        if path == "" {
            return nil
        }
        if (path.starts(with: "https://")) {
            return URL(string: path);
        }
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        let (dir, name, ext)  = splitFileName(str: path)
        if dir == "" && name != "" {
            let url = createLocalUrl(forImageNamed: name)
            return url
        }
        return documentsURL?
            .appendingPathComponent(dir)
            .appendingPathComponent(name)
            .appendingPathExtension(ext)
    }
    
    func updateProgress(_ progress: Double, _ uploading: Bool = false) {
        DispatchQueue.main.async {
            if self.fileLoadingProgress != progress {
                if progress >= 1 && self.downloading {
                    if (uploading) {
                        self.uploading = false
                    } else {
                        self.downloading = false
                    }
                }
                else if progress < 1 && !self.downloading {
                    if (uploading) {
                        self.uploading = true
                    } else {
                        self.downloading = true
                    }
                }
                self.fileLoadingProgress = min(progress,1)
            }
        }
    }
    
    func resetCounters(_ directoryList: [FileListDirectory]) {
        DispatchQueue.main.async {
            self.directoryList = directoryList
            self.total = self.countMedia()
            self.completed = 0
            self.downloading = false
            self.uploading = false
        }
        updateProgress(0)
    }
    
    func resetCounters(array: [Any]) {
        DispatchQueue.main.async {
            self.directoryList = []
            self.total = array.count
            self.completed = 0
            self.downloading = false
            self.uploading = false
        }
        updateProgress(0)
    }
    
    func incrementProgress(uploading: Bool = false) {
        DispatchQueue.main.async {
            self.completed += 1
            self.updateProgress(Double(self.completed) / Double(self.total), uploading)
        }
    }
    
    func syncMedia(_ directoryList: [FileListDirectory], syncApproach: 	SyncApproach = .merge) async {
        
        resetCounters(directoryList)
        
        for d in directoryList {
            print(d.Name)
            let mediaDirectory = documentsURL!.appendingPathComponent(d.Name)
            var isDirectory: ObjCBool = false
            if !fileManager.fileExists(atPath: mediaDirectory.path, isDirectory: &isDirectory) {
                do {
                    try fileManager.createDirectory(at: mediaDirectory, withIntermediateDirectories: true)
                } catch let error {
                    print(error)
                }
            }
            for z in d.FileList {
                let media = mediaDirectory.appendingPathComponent(z.Name)
                var outdated: WriteApproach = .doNothing
                let exists = fileManager.fileExists(atPath: media.path, isDirectory: &isDirectory)
                if exists {
                    do {
                        let modifiedDate = try fileManager.attributesOfItem(atPath: media.path)[.modificationDate] as! Date
                        switch(syncApproach) {
                        case .overwriteLocal: outdated = z.lastWriteTimeUtc > modifiedDate ? .downloadToLocal : .doNothing
                        case .overwriteRemote: outdated = z.lastWriteTimeUtc < modifiedDate ? .downloadToLocal : .doNothing
                        case .merge: outdated = z.lastWriteTimeUtc < modifiedDate ? .uploadToRemote : (z.lastWriteTimeUtc > modifiedDate ? .downloadToLocal : .doNothing)
                        }
                        	
                    } catch { /* ignore */ }
                }
                if !exists || outdated == .downloadToLocal {
                    let urlString =
                    "https://www.mytalktools.com/dnn/UserUploads/" +
                    ("\(d.Name)\(z.Name)"
                        .replacingOccurrences(of: "\\", with: "/")
                        .addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? "")
                    guard let url = URL(string: urlString ) else {
                        incrementProgress()
                        return
                    }
                    var urlRequest = URLRequest(url: url)
                    urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")  // the request is JSON
                    urlRequest.setValue("*/*", forHTTPHeaderField: "Accept")        // the expected response is also JSON
                    urlRequest.httpMethod = "GET"
                    do {
                        let (data, responseRaw ) = try await URLSession.shared.data(for: urlRequest)
                        let response = responseRaw as! HTTPURLResponse
                        if response.statusCode == 200 {
                            do {
                                if exists {
                                    try self.fileManager.removeItem(at: media)
                                }
                                self.fileManager.createFile(atPath: media.path, contents: data)
                            } catch {
                                print ("file error: \(error)")
                            }
                        } else {
                            print(response)
                        }
                    } catch let error {
                        print(error)
                    }
                    self.incrementProgress()
                } else {
                    incrementProgress()
                }
            }
        }
    }
    
    func WriteMediaFilesToServer(username: String) async {
        do {
            let privateLibrary = documentsURL!.appendingPathComponent(username).appendingPathComponent("Private Library")
            let items = try fileManager.contentsOfDirectory(atPath: privateLibrary.path).filter({ !$0.contains(".sqlite")})
            resetCounters(array: items)
            for item in items {
                let itemPath = "\(username)/Private Library/\(item)"
                let s = BoardState.db!.executeQuery("SELECT content_url, content_url2 FROM content WHERE content_url = ? OR content_url2 = ?", withArgumentsIn: [itemPath,itemPath]);
                var found = false
                while s!.next() {
                    found = true
                }
                if !found {
                    try fileManager.removeItem(atPath: privateLibrary.appendingPathComponent(item).path)
                    print("Unused file: \(itemPath)")
                } else {
                    await sendFile(username: username, fileURL: privateLibrary.appendingPathComponent(item))
                }
                incrementProgress(uploading: true)
            }
        } catch let error {
            print(error)
        }
    }
    
    func sendFile(username: String, fileURL: URL) async {
        do {
            let url = URL(string: "https://www.mytalktools.com/dnn/UploadToLibrary.ashx")
            
            // generate boundary string using a unique string
            let boundary = UUID().uuidString
            
            // Set the URLRequest to POST and to the specified URL
            let fileData = try? Data(contentsOf: fileURL)
            
            let fileName = fileURL.lastPathComponent
            let mimetype = fileURL.mimeType()
            let paramName = "file"
            var inputData = Data()
            
            var request = URLRequest(url: url!)
            request.httpMethod = "POST"
            
            // Content-Type is multipart/form-data, this is the same as submitting form data with file upload
            // in a web browser
            request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            
            // Add the param data to the raw http request data
            inputData.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
            inputData.append("Content-Disposition: form-data; name=\"user\";".data(using: .utf8)!)
            inputData.append("Content-Type: \(mimetype)\r\n\r\n".data(using: .utf8)!)
            inputData.append(username.data(using: .utf8)!)
            
            if fileURL.path.hasSuffix(".mov") {
                inputData.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
                inputData.append("Content-Disposition: form-data; name=\"orientation\";".data(using: .utf8)!)
                inputData.append("Content-Type: \(mimetype)\r\n\r\n".data(using: .utf8)!)
                inputData.append(orientation[ImageUtility.orientationForTrack(by: fileURL)]!.data(using: .utf8)!)
            }
            
            // Add the file data to the raw http request data
            inputData.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
            inputData.append("Content-Disposition: form-data; name=\"\(paramName)\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
            inputData.append("Content-Type: \(mimetype)\r\n\r\n".data(using: .utf8)!)
            inputData.append(fileData!)
            inputData.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
            request.setValue(String(inputData.count), forHTTPHeaderField: "Content-Length")
            let (_, responseRaw) = try await URLSession.shared.upload(for: request, from: inputData)
            var response = responseRaw as! HTTPURLResponse
            if response.statusCode != 200 {
                print("Error: \(response.statusCode)")
            }
        } catch let error {
            print(error)
        }
    }
}

