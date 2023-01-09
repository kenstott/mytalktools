//
//  File.swift
//  test
//
//  Created by Kenneth Stott on 12/30/22.
//

import Foundation

func initializeBoard() {
    let nameForFile = "sample"
    let extForFile = "sqlite"
    let fileManager = FileManager.default
    let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
    let destURL = documentsURL!.appendingPathComponent(nameForFile).appendingPathExtension(extForFile)
    if fileManager.fileExists(atPath: destURL.path) {
        return;
    } else {
        guard let sourceURL = Bundle.main.url(forResource: nameForFile, withExtension: extForFile)
            else {
                print("Source File not found.")
                return
        }
        do {
            let originalContents = try Data(contentsOf: sourceURL)
            try originalContents.write(to: destURL, options: .atomic)
        } catch {
            print("Unable to write file")
        }
    }
}
