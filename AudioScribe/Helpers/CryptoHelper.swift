//
//  CryptoHelper.swift
//  AudioScribe
//
//  Created by Christopher Endress on 7/20/25.
//

import CryptoKit
import Foundation

enum CryptoHelper {
    // Later persist this in Keychain for prod quality
    private static let key = SymmetricKey(size: .bits256)
    
    static func encryptFile(at url: URL) throws -> URL {
        let data = try Data(contentsOf: url)
        let box = try AES.GCM.seal(data, using: key)
        let out = url.deletingPathExtension().appendingPathExtension("enc")
        try box.combined!.write(to: out)
        return out
    }
}

