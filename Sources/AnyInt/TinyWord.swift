//
//  File.swift
//  
//
//  Created by Nickolas Pokhylets on 22/03/2024.
//

import Foundation

typealias SignedWord = Int64
typealias UnsignedWord = UInt64

struct TinyWord: Hashable, RawRepresentable {
    var a: UInt32
    var b: UInt16
    var c: UInt8
    var d: UInt7

    static var bitWidth: Int { 63 }

    static var zero: Self { .init() }

    private init() {
        a = 0
        b = 0
        c = 0
        d = .x0000000
    }

    init?(bitPattern: UnsignedWord) {
        self.init(rawValue: SignedWord(bitPattern: bitPattern))
    }

    init?(rawValue: SignedWord) {
        let maxMagnitude: Int64 = (1 << 62)
        if rawValue >= maxMagnitude || rawValue < -maxMagnitude { return nil }
        let bit63 = (rawValue & (1 << 63)) != 0
        let bit62 = (rawValue & (1 << 62)) != 0
        if bit62 != bit63 { return nil }
        a = UInt32(truncatingIfNeeded: rawValue)
        b = UInt16(truncatingIfNeeded: rawValue >> 32)
        c = UInt8(truncatingIfNeeded: rawValue >> 48)
        d = UInt7(rawValue: UInt8(truncatingIfNeeded: rawValue >> 56) & 0x7F)!
    }

    var bitWidth: Int {
        self.rawValue.usedBits
    }

    var isNegative: Bool {
        (d.rawValue & 0x40) != 0
    }

    var bitPattern: UnsignedWord {
        var bitPattern = UnsignedWord(a)
        bitPattern |= UnsignedWord(b) << 32
        bitPattern |= UnsignedWord(c) << 48
        bitPattern |= UnsignedWord(d.rawValue) << 56
        bitPattern |= UnsignedWord(d.rawValue & 0x40) << 57
        return bitPattern
    }

    var rawValue: SignedWord {
        return SignedWord(bitPattern: bitPattern)
    }

    static func == (lhs: Self, rhs: Self) -> Bool { lhs.rawValue == rhs.rawValue }
    func hash(into hasher: inout Hasher) {
        hasher.combine(rawValue)
    }

    func withWords<R>(_ body: (WordsView) throws -> R) rethrows -> R {
        try withUnsafePointer(to: bitPattern) { ptr in
            let view = WordsView(start: ptr, count: 1)
            return try body(view)
        }
    }
}

extension SignedWord {
    var usedBits: Int {
        if self > 0 {
            return Self.bitWidth - self.leadingZeroBitCount + 1
        } else {
            return Self.bitWidth - (~self).leadingZeroBitCount + 1
        }
    }
}

enum UInt7: UInt8 {
    case x0000000
    case x0000001
    case x0000010
    case x0000011
    case x0000100
    case x0000101
    case x0000110
    case x0000111
    case x0001000
    case x0001001
    case x0001010
    case x0001011
    case x0001100
    case x0001101
    case x0001110
    case x0001111
    case x0010000
    case x0010001
    case x0010010
    case x0010011
    case x0010100
    case x0010101
    case x0010110
    case x0010111
    case x0011000
    case x0011001
    case x0011010
    case x0011011
    case x0011100
    case x0011101
    case x0011110
    case x0011111
    case x0100000
    case x0100001
    case x0100010
    case x0100011
    case x0100100
    case x0100101
    case x0100110
    case x0100111
    case x0101000
    case x0101001
    case x0101010
    case x0101011
    case x0101100
    case x0101101
    case x0101110
    case x0101111
    case x0110000
    case x0110001
    case x0110010
    case x0110011
    case x0110100
    case x0110101
    case x0110110
    case x0110111
    case x0111000
    case x0111001
    case x0111010
    case x0111011
    case x0111100
    case x0111101
    case x0111110
    case x0111111
    case x1000000
    case x1000001
    case x1000010
    case x1000011
    case x1000100
    case x1000101
    case x1000110
    case x1000111
    case x1001000
    case x1001001
    case x1001010
    case x1001011
    case x1001100
    case x1001101
    case x1001110
    case x1001111
    case x1010000
    case x1010001
    case x1010010
    case x1010011
    case x1010100
    case x1010101
    case x1010110
    case x1010111
    case x1011000
    case x1011001
    case x1011010
    case x1011011
    case x1011100
    case x1011101
    case x1011110
    case x1011111
    case x1100000
    case x1100001
    case x1100010
    case x1100011
    case x1100100
    case x1100101
    case x1100110
    case x1100111
    case x1101000
    case x1101001
    case x1101010
    case x1101011
    case x1101100
    case x1101101
    case x1101110
    case x1101111
    case x1110000
    case x1110001
    case x1110010
    case x1110011
    case x1110100
    case x1110101
    case x1110110
    case x1110111
    case x1111000
    case x1111001
    case x1111010
    case x1111011
    case x1111100
    case x1111101
    case x1111110
    case x1111111
}
