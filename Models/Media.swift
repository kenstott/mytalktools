//
//  Media.swift
//  test
//
//  Created by Kenneth Stott on 1/22/23.
//

import Foundation
import UIKit


class Media: ObservableObject {
    
    let fileManager = FileManager.default
    let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first

    @Published var fileLoadingProgress = 0.0
    @Published var total = 0
    @Published var completed = 0
    @Published var directoryList: [FileListDirectory] = []
    @Published var downloading = false

    func countMedia() -> Int {
        var total = 0
        for d in directoryList {
            total += d.FileList.count
        }
        return total;
    }
    
    func splitFileName(str: String) -> (String, String, String) {
        let path = str as NSString
        let directory = path.deletingLastPathComponent

        let fileNameWithExtension = path.lastPathComponent as NSString
        let fileNameWithoutExtension = fileNameWithExtension.deletingPathExtension
        let fileExtension = fileNameWithExtension.pathExtension

        return (directory, fileNameWithoutExtension, fileExtension)
    }
    
    func createLocalUrl(forImageNamed name: String) -> URL? {

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
    
    func getImage( _ path: String) -> UIImage {
        do {
            let file = getURL(path)!
            var isDirectory: ObjCBool = false
            if !fileManager.fileExists(atPath: file.path, isDirectory: &isDirectory) {
                return UIImage()
            }
            let attrs = try fileManager.attributesOfItem(atPath: file.path)
            print(attrs)
            let data = try Data(contentsOf: file)
            let altImage = UIImage(contentsOfFile: file.path)
            return UIImage(data: data)!
        } catch {
            return UIImage()
        }
    }
        
    
    func getURL(_ path: String) -> URL? {
        let (dir, name, ext)  = splitFileName(str: path)
        if dir == "" {
            let url = createLocalUrl(forImageNamed: name)
            return url
        }
        return documentsURL?
            .appendingPathComponent(dir)
            .appendingPathComponent(name)
            .appendingPathExtension(ext)
    }
    
    func updateProgress(_ progress: Double) {
        DispatchQueue.main.async {
            if self.fileLoadingProgress != progress {
                if progress >= 1 && self.downloading {
                    self.downloading = false
                }
                else if progress < 1 && !self.downloading {
                    self.downloading = true
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
        }
        updateProgress(0)
    }
    
    func incrementProgress() {
        DispatchQueue.main.async {
            self.completed += 1
            self.updateProgress(Double(self.completed) / Double(self.total))
        }
    }
    
    func syncMedia(_ directoryList: [FileListDirectory]) {
        
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
                var outdated = false
                let exists = fileManager.fileExists(atPath: media.path, isDirectory: &isDirectory)
                if exists {
                    do {
                        let modifiedDate = try fileManager.attributesOfItem(atPath: media.path)[.modificationDate] as! Date
                        outdated = z.lastWriteTimeUtc > modifiedDate
                    } catch { /* ignore */ }
                }
                if !exists || outdated {
                    let urlString =
                        "https://www.mytalktools.com/dnn/UserUploads/" +
                    ("\(d.Name)\(z.Name)"
                        .replacingOccurrences(of: "\\", with: "/")
                        .addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? "")
                    guard let url = URL(string: urlString ) else {
                        incrementProgress()
                        return
                    }
                    let downloadTask = URLSession.shared.downloadTask(with: url) { [self]
                        urlOrNil, responseOrNil, errorOrNil in
                        if (errorOrNil != nil) {
                            print("file error: \(String(describing: errorOrNil))")
                            incrementProgress()
                            return
                        }
                        if (responseOrNil == nil) {
                            print("could not download: \(String(describing: urlString))")
                            incrementProgress()
                            return
                        }
                        guard let fileURL = urlOrNil else { return }
                        do {
                            if exists {
                                try self.fileManager.removeItem(at: media)
                            }
                            try self.fileManager.moveItem(at: fileURL, to: media)
                        } catch {
                            print ("file error: \(error)")
                        }
                        self.incrementProgress()
                    }
                    downloadTask.resume()
                    
                } else {
                    incrementProgress()
                }
            }
        }
    }
}
