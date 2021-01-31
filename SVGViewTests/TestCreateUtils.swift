import XCTest
@testable import SVGView

extension SVG12Tests {

    // uncomment to recreate all references
//    func testCreateReferences() {
//        let path = Bundle(for: type(of: self)).resourcePath!
//        for url in getContents(path) {
//            if url.pathExtension == "svg" {
//                createReference(url)
//            }
//        }
//    }

    func createReference(_ testResource: URL) {
        let testDirectory = getTestDir()
        let node = SVGParser.parse(fileURL: testResource)
        let content = Serializer.serialize(node)
        let fileName = testResource.deletingPathExtension().lastPathComponent
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
