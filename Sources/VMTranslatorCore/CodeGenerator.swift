//
//  CodeGenerator.swift
//  
//
//  Created by Ted Kostylev on 7/14/20.
//

import Foundation

public class CodeGenerator {
    public static func assemble(vmCode: [String]) throws -> [String]  {
        var result:[String] = []
        
        // Prepend with setup code
        result += initializationCode
        
        try vmCode.forEach { line in
            result.append("// " + line)
            let splitLine = line.components(separatedBy: " ")
            switch splitLine[0] {
            case "pop",
                 "push":
                result += try generateCode(forMemoryCommand: splitLine[0], arguments: Array(splitLine[1...]))
            case "add":
                result += try generateCode(forArithmeticCommand: splitLine[0], arguments: Array(splitLine[1...]))
            default:
                throw Error.invalidCommand
            }
        }
        
        // Finish with an infinite loop
        result += infiniteLoop
        return result
    }
    
    private static let initializationCode: [String] = [
        "// Set up stack pointer",
        "@256",
        "D=A",
        "@R0",
        "M=D"
    ]
    
    private static let infiniteLoop: [String] = [
        "(END)",
        "@END",
        "0;JMP"
    ]
    
    private static func generateCode(forMemoryCommand command: String, arguments: [String]) throws -> [String]  {
        var result: [String] = []
        switch command {
        case "push":
            switch arguments[0] {
//            case "argument":
//            case "local":
//            case "static":
            case "constant":
                result += [
                    "@\(arguments[1])",
                    "D=A",
                    "@R0",
                    "A=M",
                    "M=D",
                    "@R0",
                    "M=M+1"
                ]
//            case "this":
//            case "that":
//            case "pointer":
//            case "temp":
            default:
                throw Error.invalidMemorySegment
            }
        case "pop":
            print()
        default:
            throw Error.invalidCommand
        }
        return result
    }
    
    private static func generateCode(forArithmeticCommand command: String, arguments: [String]) throws -> [String] {
        var result: [String] = []
        switch command {
        case "add":
            result += [
                "@R0",
                "M=M-1",
                "A=M",
                "D=M",
                "@R0",
                "M=M-1",
                "A=M",
                "D=D+M",
                "M=D",
                "@R0",
                "M=M+1"
            ]
        default:
            throw Error.invalidCommand
        }
        return result
    }
}



public extension CodeGenerator {
    enum Error: Swift.Error {
        case invalidCommand
        case invalidMemorySegment
    }
}
