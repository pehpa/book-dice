// RNG injection seam — the Swift analogue of passing an explicit random.Random
// through book_dice/core.py's functions. Production code uses
// SystemRandomNumberGenerator (via the default argument); tests use
// SeededGenerator for determinism.

import Foundation

/// A small, deterministic RandomNumberGenerator for unit tests. Not intended
/// to match Python's Mersenne Twister output — only to make Swift-side tests
/// reproducible.
public struct SeededGenerator: RandomNumberGenerator {
    private var state: UInt64

    public init(seed: UInt64) {
        // Avoid an all-zero state, which would stall xorshift-style generators.
        self.state = seed == 0 ? 0x9E3779B97F4A7C15 : seed
    }

    public mutating func next() -> UInt64 {
        // SplitMix64
        state = state &+ 0x9E3779B97F4A7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58476D1CE4E5B9
        z = (z ^ (z >> 27)) &* 0x94D049BB133111EB
        return z ^ (z >> 31)
    }
}
