//
//  Grid.swift
//  TagPix
//
//  Created by Matthew Burke on 10/11/24.
//

import Foundation

public struct Cell: Identifiable, Equatable {
    public let id: Int
    public let value: Int // TODO: change to enum, maybe call it PixColor
}

public class Row: Identifiable, Equatable {
    public private(set) var cells: [Cell] = []

    public func add(cell: Cell) {
        cells.append(cell)
    }

    public static func ==(lhs: Row, rhs: Row) -> Bool {
        return lhs.cells == rhs.cells
    }
}

/*
 Maybe on init go ahead and allocate the rows and cells
 fill every spot with clear color; then add a method
 "draw" or "paint" to fill a spot with a color ...

 if we eventually are going to allow picture editing then
 we'll need to make the data structure mutable ...

 */
public class Grid {
    public private(set) var rows: [Row] = []
    public let size: Int

    public init(size: Int = 16) {
        self.size = size
    }

    public init?(from data: Data) {
        self.size = Int(data[0])

        guard data.count == (size*size + 1) else {
            return nil
        }

        func index(_ i: Int, _ j: Int) -> Int {
            return (i*size) + j + 1
        }

        (0..<size).forEach { i in
            let row = Row()
            (0..<size).forEach { j in
                let cell = Cell(id: j, value: Int(data[index(i, j)]))
                row.add(cell: cell)
            }
            add(row: row)
        }
    }

    public func add(row: Row) {
        rows.append(row)
    }

    public func data() -> Data {
        var values: [UInt8] = []

        rows.forEach { row in
            row.cells.forEach { cell in
                values.append(UInt8(cell.value))
            }
            print()
        }

        values.insert(UInt8(size), at: 0)
        let buffer = values.withUnsafeBufferPointer { Data(buffer: $0) }

        return buffer
    }

    static func generate(size: Int) -> Grid {
        let g = Grid(size: size)
        (0..<size).forEach { _ in
            let r = Row()
            (0..<size).forEach { i in
                let cell = Cell(id: i, value: Int.random(in: 0..<RowView.colors.count))
                r.add(cell: cell)
            }
            g.add(row: r)
        }

        return g
    }
}

extension Grid: Equatable {
    public static func ==(lhs: Grid, rhs: Grid) -> Bool {
        return lhs.rows == rhs.rows
    }
}
