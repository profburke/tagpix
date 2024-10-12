//
//  Grid.swift
//  TagPix
//
//  Created by Matthew Burke on 10/11/24.
//

import Foundation

public struct Cell: Identifiable {
    public let id: Int
    public let value: Int
}

public class Row: Identifiable {
    public private(set) var cells: [Cell] = []

    public func add(cell: Cell) {
        cells.append(cell)
    }
}

public class Grid {
    public private(set) var rows: [Row] = []

    public func add(row: Row) {
        rows.append(row)
    }

    public func data() -> Data {
        var values: [UInt8] = []

        rows.forEach { row in
            row.cells.forEach { cell in
                print(cell.value, separator: " ", terminator: "")
                values.append(UInt8(cell.value))
            }
            print()
        }

        let buffer = values.withUnsafeBufferPointer { Data(buffer: $0) }
        print(buffer)
        print(buffer as NSData)

        return buffer
    }

    static func generate() -> Grid {
        let g = Grid()
        (0..<16).forEach { _ in
            let r = Row()
            (0..<16).forEach { i in
                let cell = Cell(id: i, value: Int.random(in: 0..<RowView.colors.count))
                r.add(cell: cell)
            }
            g.add(row: r)
        }

        return g
    }
}
