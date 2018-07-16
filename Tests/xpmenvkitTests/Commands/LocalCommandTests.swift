import Basic
import Foundation
@testable import Utility
import XCTest
import xpmcore
@testable import xpmcoreTesting
@testable import xpmenvkit

final class LocalCommandTests: XCTestCase {
    var argumentParser: ArgumentParser!
    var subject: LocalCommand!
    var fileHandler: MockFileHandler!
    var tmpDir: TemporaryDirectory!
    var printer: MockPrinter!

    override func setUp() {
        super.setUp()
        argumentParser = ArgumentParser(usage: "test", overview: "overview")
        tmpDir = try! TemporaryDirectory(removeTreeOnDeinit: true)
        printer = MockPrinter()
        fileHandler = MockFileHandler()
        subject = LocalCommand(parser: argumentParser,
                               fileHandler: fileHandler,
                               printer: printer)
    }

    func test_command() {
        XCTAssertEqual(LocalCommand.command, "local")
    }

    func test_overview() {
        XCTAssertEqual(LocalCommand.overview, "Creates a .xpm-version file to pin the xpm version that should be used in the current directory.")
    }

    func test_init_registers_the_command() {
        XCTAssertEqual(argumentParser.subparsers.count, 1)
        XCTAssertEqual(argumentParser.subparsers.first?.key, LocalCommand.command)
        XCTAssertEqual(argumentParser.subparsers.first?.value.overview, LocalCommand.overview)
    }

    func test_run() throws {
        fileHandler.currentPathStub = tmpDir.path

        let result = try argumentParser.parse(["local", "3.2.1"])
        try subject.run(with: result)

        let versionPath = tmpDir.path.appending(component: Constants.versionFileName)
        let got = try String(contentsOf: URL(fileURLWithPath: versionPath.asString))
        XCTAssertEqual(got, "3.2.1")
    }

    func test_run_prints() throws {
        fileHandler.currentPathStub = tmpDir.path

        let result = try argumentParser.parse(["local", "3.2.1"])
        try subject.run(with: result)

        let versionPath = tmpDir.path.appending(component: Constants.versionFileName)

        XCTAssertEqual(printer.printArgs.count, 2)
        XCTAssertEqual(printer.printArgs.first, "Generating \(Constants.versionFileName) file with version 3.2.1.")
        XCTAssertEqual(printer.printArgs.last, "File generated at path \(versionPath.asString).")
    }
}
