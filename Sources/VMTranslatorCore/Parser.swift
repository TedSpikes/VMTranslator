//
//  Parser.swift
//  Loads the code file line-by-line and prepares it for translation.
//
//  Created by Ted Kostylev on 7/14/20.
//

import Foundation

public class Parser {
    public static func parse(text: String) -> [String]? {
        var result: [String] = []
        
        text.components(separatedBy: "\n").forEach { _line in
            var line = _line
            if line.contains("//") {
                line = String(line[..<line.firstIndex(of: "/")!])
            }
            line = line.trimmingCharacters(in: .whitespacesAndNewlines)
            if !line.isEmpty { result.append(line) }
        }
        
        if result.isEmpty {
            return nil
        } else {
            return result
        }
    }
}
