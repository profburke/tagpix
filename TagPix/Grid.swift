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

    static func generate() -> Grid {
        let g = Grid()
        (0..<16).forEach { _ in
            let r = Row()
            (0..<16).forEach { i in
                let cell = Cell(id: i, value: Int.random(in: 0..<3))
                r.add(cell: cell)
            }
            g.add(row: r)
        }

//        print("rows: \(d.count)")
//        print("cols: \(d[0].count)")
//        let buffer = d.withUnsafeBufferPointer { Data(buffer: $0) }
//        print(buffer as NSData)

        return g
    }
}
