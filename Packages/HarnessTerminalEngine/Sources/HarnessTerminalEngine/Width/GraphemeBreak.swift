/// UAX #29 extended grapheme boundaries, pinned to the same Unicode data as cell widths.
/// No platform Unicode or String.Character segmentation participates in this decision.
enum GraphemeBreak {
    static let unicodeVersion = GraphemeBreakTable.unicodeVersion

    private enum Property: UInt8 {
        case other, cr, lf, control, extend, zwj, regional, prepend, spacingMark, l, v, t, lv, lvt

        var isControl: Bool { self == .cr || self == .lf || self == .control }
    }

    @inline(__always)
    private static func properties(_ scalar: UInt32) -> UInt8 {
        guard scalar <= 0x10FFFF else { return 0 }
        let block = Int(GraphemeBreakTable.indices[Int(scalar >> 8)])
        return GraphemeBreakTable.properties[block * 256 + Int(scalar & 255)]
    }

    static func isPrepend(_ scalar: UInt32) -> Bool {
        scalar >= 0x600 && properties(scalar) & 15 == Property.prepend.rawValue
    }

    /// Constant-space UAX #29 state. `append` returns whether a boundary precedes the scalar.
    struct State {
        private var previous: Property?
        private var oddRegionalCount = false
        private var pictographicExtend = false
        private var pictographicZWJ = false
        private var indicLinker = false

        mutating func append(_ scalar: UInt32) -> Bool {
            let bits = properties(scalar)
            let next = Property(rawValue: bits & 15)!
            let indic = (bits >> 4) & 3
            let pictographic = bits & 64 != 0
            let boundary = breaks(before: next, indic: indic, pictographic: pictographic)
            if boundary {
                oddRegionalCount = false
                pictographicExtend = false
                pictographicZWJ = false
                indicLinker = false
            }
            oddRegionalCount = next == .regional && !oddRegionalCount
            pictographicZWJ = next == .zwj && pictographicExtend
            pictographicExtend = pictographic || (next == .extend && pictographicExtend)
            if indic == 3 { indicLinker = true }
            else if indic != 2 { indicLinker = false }
            previous = next
            return boundary
        }

        private func breaks(before next: Property, indic: UInt8, pictographic: Bool) -> Bool {
            guard let previous else { return true } // GB1
            if previous == .cr && next == .lf { return false } // GB3
            if previous.isControl || next.isControl { return true } // GB4–5
            if previous == .l && (next == .l || next == .v || next == .lv || next == .lvt) { return false } // GB6
            if (previous == .lv || previous == .v) && (next == .v || next == .t) { return false } // GB7
            if (previous == .lvt || previous == .t) && next == .t { return false } // GB8
            if next == .extend || next == .zwj || next == .spacingMark { return false } // GB9–9a
            if previous == .prepend { return false } // GB9b
            if indic == 1 && indicLinker { return false } // GB9c
            if pictographic && pictographicZWJ { return false } // GB11
            if previous == .regional && next == .regional && oddRegionalCount { return false } // GB12–13
            return true // GB999
        }
    }

    static func extends(scalar previous: UInt32, with scalar: UInt32) -> Bool {
        var state = State()
        _ = state.append(previous)
        return !state.append(scalar)
    }

    static func extends(cluster: String, with scalar: UInt32) -> Bool {
        var state = State()
        for existing in cluster.unicodeScalars { _ = state.append(existing.value) }
        return !state.append(scalar)
    }

    /// One terminal cell cluster occupies the widest constituent, with emoji presentation
    /// sequences promoted to two columns. A VS16 only promotes an actual emoji base.
    static func width(of cluster: String) -> Int {
        var width = 0
        var previous: UInt32?
        var regionals = 0
        let first = cluster.unicodeScalars.first?.value
        for scalar in cluster.unicodeScalars {
            let value = scalar.value
            let bits = properties(value)
            width = max(width, CharacterWidth.width(of: value))
            if bits & 15 == Property.regional.rawValue { regionals += 1 }
            if value == 0xFE0F, let previous, properties(previous) & 128 != 0 { width = 2 }
            if value == 0x20E3, let first, first == 0x23 || first == 0x2A || (0x30...0x39).contains(first) { width = 2 }
            if regionals == 2 || (previous == 0x200D && bits & 64 != 0) { width = 2 }
            previous = value
        }
        return width
    }
}
