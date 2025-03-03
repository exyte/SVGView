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
        createReference(name: "color-prop-01-b", version: v11)
        createReference(name: "color-prop-02-f", version: v11)
        createReference(name: "color-prop-03-t", version: v11)
        createReference(name: "color-prop-04-t", version: v11)
        createReference(name: "color-prop-05-t", version: v11)
        createReference(name: "coords-coord-01-t", version: v11)
        createReference(name: "coords-coord-02-t", version: v11)
        createReference(name: "coords-trans-01-b", version: v11)
        createReference(name: "coords-trans-02-t", version: v11)
        createReference(name: "coords-trans-03-t", version: v11)
        createReference(name: "coords-trans-04-t", version: v11)
        createReference(name: "coords-trans-05-t", version: v11)
        createReference(name: "coords-trans-06-t", version: v11)
        createReference(name: "coords-trans-07-t", version: v11)
        createReference(name: "coords-trans-08-t", version: v11)
        createReference(name: "coords-trans-09-t", version: v11)
        createReference(name: "coords-trans-10-f", version: v11)
        createReference(name: "coords-trans-11-f", version: v11)
        createReference(name: "coords-trans-12-f", version: v11)
        createReference(name: "coords-trans-13-f", version: v11)
        createReference(name: "coords-trans-14-f", version: v11)
        createReference(name: "coords-transformattr-01-f", version: v11)
        createReference(name: "coords-transformattr-02-f", version: v11)
        createReference(name: "coords-transformattr-03-f", version: v11)
        createReference(name: "coords-transformattr-04-f", version: v11)
        createReference(name: "coords-transformattr-05-f", version: v11)
        createReference(name: "coords-units-02-b", version: v11)
        createReference(name: "coords-units-03-b", version: v11)
        createReference(name: "masking-opacity-01-b", version: v11)
        createReference(name: "painting-control-02-f", version: v11)
        createReference(name: "painting-control-03-f", version: v11)
        createReference(name: "painting-fill-01-t", version: v11)
        createReference(name: "painting-fill-02-t", version: v11)
        createReference(name: "painting-fill-03-t", version: v11)
        createReference(name: "painting-fill-04-t", version: v11)
        createReference(name: "painting-fill-05-b", version: v11)
        createReference(name: "painting-stroke-01-t", version: v11)
        createReference(name: "painting-stroke-02-t", version: v11)
        createReference(name: "painting-stroke-03-t", version: v11)
        createReference(name: "painting-stroke-04-t", version: v11)
        createReference(name: "painting-stroke-05-t", version: v11)
        createReference(name: "painting-stroke-07-t", version: v11)
        createReference(name: "painting-stroke-08-t", version: v11)
        createReference(name: "painting-stroke-09-t", version: v11)
        createReference(name: "paths-data-01-t", version: v11)
        createReference(name: "paths-data-02-t", version: v11)
        createReference(name: "paths-data-03-f", version: v11)
        createReference(name: "paths-data-04-t", version: v11)
        createReference(name: "paths-data-05-t", version: v11)
        createReference(name: "paths-data-06-t", version: v11)
        createReference(name: "paths-data-07-t", version: v11)
        createReference(name: "paths-data-08-t", version: v11)
        createReference(name: "paths-data-09-t", version: v11)
        createReference(name: "paths-data-10-t", version: v11)
        createReference(name: "paths-data-12-t", version: v11)
        createReference(name: "paths-data-13-t", version: v11)
        createReference(name: "paths-data-14-t", version: v11)
        createReference(name: "paths-data-15-t", version: v11)
        createReference(name: "paths-data-16-t", version: v11)
        createReference(name: "paths-data-17-f", version: v11)
        createReference(name: "paths-data-18-f", version: v11)
        createReference(name: "paths-data-19-f", version: v11)
        createReference(name: "paths-data-20-f", version: v11)
        createReference(name: "pservers-grad-01-b", version: v11)
        createReference(name: "pservers-grad-02-b", version: v11)
        createReference(name: "pservers-grad-04-b", version: v11)
        createReference(name: "pservers-grad-05-b", version: v11)
        createReference(name: "pservers-grad-07-b", version: v11)
        createReference(name: "pservers-grad-09-b", version: v11)
        createReference(name: "render-elems-01-t", version: v11)
        createReference(name: "render-elems-02-t", version: v11)
        createReference(name: "render-elems-03-t", version: v11)
        createReference(name: "shapes-circle-01-t", version: v11)
        createReference(name: "shapes-circle-02-t", version: v11)
        createReference(name: "shapes-ellipse-01-t", version: v11)
        createReference(name: "shapes-ellipse-02-t", version: v11)
        createReference(name: "shapes-ellipse-03-f", version: v11)
        createReference(name: "shapes-grammar-01-f", version: v11)
        createReference(name: "shapes-intro-01-t", version: v11)
        createReference(name: "shapes-line-01-t", version: v11)
        createReference(name: "shapes-line-02-f", version: v11)
        createReference(name: "shapes-polygon-01-t", version: v11)
        createReference(name: "shapes-polygon-02-t", version: v11)
        createReference(name: "shapes-polygon-03-t", version: v11)
        createReference(name: "shapes-polyline-01-t", version: v11)
        createReference(name: "shapes-polyline-02-t", version: v11)
        createReference(name: "shapes-rect-02-t", version: v11)
        createReference(name: "shapes-rect-04-f", version: v11)
        createReference(name: "shapes-rect-05-f", version: v11)
        createReference(name: "shapes-rect-06-f", version: v11)
        createReference(name: "struct-defs-01-t", version: v11)
        createReference(name: "struct-frag-01-t", version: v11)
        createReference(name: "struct-frag-06-t", version: v11)
        createReference(name: "struct-group-01-t", version: v11)
        createReference(name: "struct-image-01-t", version: v11)
        createReference(name: "struct-image-04-t", version: v11)
        createReference(name: "struct-use-03-t", version: v11)
        createReference(name: "styling-class-01-f", version: v11)
        createReference(name: "styling-css-01-b", version: v11)
        createReference(name: "styling-pres-01-t", version: v11)
        createReference(name: "types-basic-01-f", version: v11)

        createReference(name: "coords-trans-01-t", version: v12)
        createReference(name: "coords-trans-02-t", version: v12)
        createReference(name: "coords-trans-03-t", version: v12)
        createReference(name: "coords-trans-04-t", version: v12)
        createReference(name: "coords-trans-05-t", version: v12)
        createReference(name: "coords-trans-06-t", version: v12)
        createReference(name: "coords-trans-07-t", version: v12)
        createReference(name: "coords-trans-08-t", version: v12)
        createReference(name: "coords-trans-09-t", version: v12)
        createReference(name: "paint-color-03-t", version: v12)
        createReference(name: "paint-color-201-t", version: v12)
        createReference(name: "paint-fill-04-t", version: v12)
        createReference(name: "paint-stroke-01-t", version: v12)
        createReference(name: "paths-data-01-t", version: v12)
        createReference(name: "paths-data-02-t", version: v12)
        createReference(name: "render-elems-01-t", version: v12)
        createReference(name: "render-elems-02-t", version: v12)
        createReference(name: "render-elems-03-t", version: v12)
        createReference(name: "shapes-circle-01-t", version: v12)
        createReference(name: "shapes-ellipse-01-t", version: v12)
        createReference(name: "shapes-line-01-t", version: v12)
        createReference(name: "shapes-polygon-01-t", version: v12)
        createReference(name: "shapes-polyline-01-t", version: v12)
        createReference(name: "shapes-rect-02-t", version: v12)
        createReference(name: "struct-defs-01-t", version: v12)
        createReference(name: "struct-frag-01-t", version: v12)
        createReference(name: "struct-use-03-t", version: v12)
    }

    func createReference(name: String, version: String) {
        let bundle = Bundle.module
        let url = bundle.url(forResource: name, withExtension: "svg", subdirectory: version)!
        let versionNumber = String(version.split(separator: "/")[1])
        let testDirectory = getTestDir(version: versionNumber)
        let node = SVGParser.parse(contentsOf: url)!
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

    func getTestDir(version: String) -> URL {
        guard let documentDirectory = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) as NSURL,
              let testDirectory = documentDirectory.appendingPathComponent(testFolderName+version) else {
            XCTFail("Can't find test directory")
            return URL(string: "")!
        }
        create(testDirectory.path)
        return testDirectory
    }

}
