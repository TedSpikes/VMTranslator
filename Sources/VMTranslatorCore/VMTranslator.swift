import Foundation
import Files

public final class VMTranslator {
    private let arguments: [String]

    public init(arguments: [String] = CommandLine.arguments) { 
        self.arguments = arguments
    }

    public func run() throws {
        guard arguments.count > 1 else {
            throw Error.missingFileName
        }
        
        let codePath  = arguments[1]
        var codeFiles: [String] = []
        if codePath.hasSuffix(".vm") {
            codeFiles.append(codePath)
        } else {
            try Folder(path: codePath).files.forEach { file in
                if file.extension == "vm" { codeFiles.append(file.path) }
            }
        }
        
        try codeFiles.forEach { path in
            let fileContents = try String(contentsOfFile: path)
            guard let parsedLines = Parser.parse(text: fileContents) else { throw Error.parsedToEmtpy }
            // TODO: Process lines into assembly
            // TODO: Write the file to disk
        }
    }
}

public extension VMTranslator {
    enum Error: Swift.Error {
        case missingFileName
        case parsedToEmtpy
        case failedToCreateFile
    }
}
