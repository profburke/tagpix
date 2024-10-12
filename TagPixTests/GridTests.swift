//
//  GridTests.swift
//  TagPix
//
//  Created by Matthew Burke on 10/12/24.
//

@testable import TagPix
import Testing

// TODO: tests for Grid.add and Row.add

struct GridTests {
    @Test("Initializer works properly", arguments: [1, 3, 4, 10])
    func correctInitialization(size: Int) {
        let g = Grid(size: size)

        #expect(g.size == size)
        #expect(g.rows.count == 0)
    }

    @Test("Generator works properly", arguments: [1, 3, 4, 10])
    func generatorWorks(size: Int) {
        let g = Grid.generate(size: size)

        #expect(g.size == size)
        #expect(g.rows.count == size)
        (0..<size).forEach { i in
            let r = g.rows[i]
            #expect(r.cells.count == size)
        }
    }

    @Test("Sizes are correct", arguments: [1, 3, 4, 10])
    func dataConversion(size: Int) {
        let g = Grid.generate(size: size)
        let data = g.data()

        #expect(data.count == size*size+1)
    }

    @Test("Grid to data and back to grid works correctly", arguments: [1, 3, 4, 10])
    func toFromDataRoundTripOk(size: Int) {
        let g = Grid.generate(size: size)
        let data = g.data()
        let g2 = Grid(from: data)

        #expect(g == g2)
    }
}
