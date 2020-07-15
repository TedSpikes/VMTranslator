//
//  CodeGenerator.swift
//  
//
//  Created by Ted Kostylev on 7/14/20.
//

import Foundation

public class CodeGenerator {
    private static var labelCount = 0
    
    public static func assemble(vmCode: [String]) throws -> [String]  {
        var result:[String] = []
        
        // Prepend with setup code
        result += initializationCode
        
        try vmCode.forEach { line in
            result.append("\n" + "// " + line)
            let splitLine = line.components(separatedBy: " ")
            switch splitLine[0] {
            case "pop",
                 "push":
                result += try generateCode(forMemoryCommand: splitLine[0], arguments: Array(splitLine[1...]))
            case "add",
                 "sub",
                 "and",
                 "or",
                 "neg",
                 "not",
                 "eq",
                 "lt",
                 "gt":
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
        let jumpsForComparisons = [
            "eq": "JEQ",
            "lt": "JLT",
            "gt": "JGT"
        ]
        let operatorMap = [
            "add": "+",
            "sub": "-",
            "and": "&",
            "or" : "|"
        ]
        let loadOperandsToRegisters = [
            "@R0",
            "M=M-1",
            "A=M",
            "D=M",
            "@R0",
            "M=M-1",
            "A=M"
        ]
        
        switch command {
        case "add",
             "sub",
             "and",
             "or":
            result += loadOperandsToRegisters
            result += [
                "D=M\(operatorMap[command]!)D",
                "M=D",
            ]
        case "neg":
            result += [
                "@R0",
                "M=M-1",
                "A=M",
                "M=-M"
            ]
        case "not":
            result += [
                "@R0",
                "M=M-1",
                "A=M",
                "M=!M"
            ]
        case "eq",
             "lt",
             "gt":
            result += loadOperandsToRegisters
            result += [
                "A=M", // Load second value to A, we don't need M right now
                "D=A-D",
                "@TRUE\(labelCount)",
                "D;\(jumpsForComparisons[command]!)",
                "@FALSE\(labelCount)",
                "0;JMP",
                "(TRUE\(labelCount))",
                "@R0",
                "A=M",
                "M=-1",
                "@OUT\(labelCount)",
                "0;JMP",
                "(FALSE\(labelCount))",
                "@R0",
                "A=M",
                "M=0",
                "(OUT\(labelCount))",
            ]
            labelCount += 1
        default:
            throw Error.invalidCommand
        }
        result += [  // Advance the stack pointer
            "@R0",
            "M=M+1"
        ]
        return result
    }
}



public extension CodeGenerator {
    enum Error: Swift.Error {
        case invalidCommand
        case invalidMemorySegment
    }
}
