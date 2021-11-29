//
//  SVGRefGenerator.swift
//  SVGViewTests
//
//  Created by Yuriy Strot on 07.02.2021.
//

import XCTest
@testable import SVGView

class SVGRefGenerator: XCTestCase {

    let testFolderName = "TestOutputData"
    let v11 = "w3c/1.1F2/svg/"
    let v12 = "w3c/1.2T/svg/"

    func testCreateReferences() {
        createReference(name: "pservers-grad-09-b", version: v11)
        createReference(name: "pservers-grad-05-b", version: v11)
        createReference(name: "painting-control-02-f", version: v11)
        createReference(name: "painting-fill-02-t", version: v11)
        createReference(name: "painting-fill-03-t", version: v11)
        createReference(name: "struct-image-01-t", version: v11)
        createReference(name: "struct-image-04-t", version: v11)
        createReference(name: "color-prop-02-f", version: v11)
        createReference(name: "color-prop-03-t", version: v11)
        createReference(name: "coords-coord-01-t", version: v11)
        createReference(name: "coords-trans-01-b", version: v11)
        createReference(name: "coords-trans-02-t", version: v11)
        createReference(name: "coords-trans-03-t", version: v11)
        createReference(name: "coords-trans-04-t", version: v11)
        createReference(name: "coords-trans-05-t", version: v11)
        createReference(name: "coords-trans-06-t", version: v11)
        createReference(name: "coords-trans-07-t", version: v11)
        createReference(name: "coords-trans-08-t", version: v11)
        createReference(name: "coords-trans-09-t", version: v11)
        createReference(name: "pservers-grad-01-b", version: v11)
        createReference(name: "pservers-grad-02-b", version: v11)
        createReference(name: "pservers-grad-04-b", version: v11)
        createReference(name: "pservers-grad-07-b", version: v11)
        createReference(name: "masking-opacity-01-b", version: v11)
        createReference(name: "color-prop-01-b", version: v11)
    }

    func createReference(name: String, version: String) {
        let bundle = Bundle(for: type(of: self))
        let url = bundle.url(forResource: name, withExtension: "svg", subdirectory: version)!
        let testDirectory = getTestDir()
        let node = SVGParser.parse(fileURL: url)
        let content = Serializer.serialize(node)
        let fileName = url.deletingPathExtension().lastPathComponent
        let path = testDirectory.appendingPathComponent(fileName).appendingPathExtension("ref")
        writeToFile(content: content, fileURL: path)
        print("New reference file in \(path)")
    }

    func writeToFile(content: String?, fileURL: URL) {
        guard let content = content else {
            return
        }
        do {
            try content.write(to: fileURL, atomically: true, encoding: .utf8)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func getContents(_ path: String) -> [URL] {
        let url = URL(fileURLWithPath: path)
        var files = [URL]()
        if let enumerator = FileManager.default.enumerator(at: url, includingPropertiesForKeys: [.isRegularFileKey], options: [.skipsHiddenFiles, .skipsPackageDescendants]) {
            for case let fileURL as URL in enumerator {
                do {
                    let fileAttributes = try fileURL.resourceValues(forKeys:[.isRegularFileKey])
                    if fileAttributes.isRegularFile! {
                        files.append(fileURL)
                    }
                } catch { print(error, fileURL) }
            }
            return files
        }
        return []
    }

    func create(_ path: String) {
        do {
            try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: false, attributes: nil)
        }
        catch let error as NSError {
            print("Unable to create directory \(error.debugDescription)")
        }
    }

    func getTestDir() -> URL {
        guard let documentDirectory = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) as NSURL,
              let testDirectory = documentDirectory.appendingPathComponent(testFolderName) else {
            XCTFail("Can't find test directory")
            return URL(string: "")!
        }
        create(testDirectory.path)
        return testDirectory
    }

}
