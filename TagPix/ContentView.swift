//
//  ContentView.swift
//  TagPix
//
//  Created by Matthew Burke on 10/11/24.
//

import SwiftUI

struct ContentView: View {
    @State private var grid: Grid

    init() {
        self.grid = Grid.generate()
    }

    var body: some View {
        VStack {
            Spacer()

            Pix(grid: grid)

            Spacer()

            HStack {
                Button("JDI") {
                    grid = Grid.generate()
                }

                Spacer()

                Button("data") {
                    _ = grid.data()
                }
            }
        }
        .padding()
        .onAppear {
            grid = Grid.generate()
        }
    }
}

struct RowView: View {
    static let colors = [
        Color.red, Color.blue, Color.green, Color.orange,
        Color.yellow, Color.cyan, Color.indigo, Color.mint,
        Color.teal, Color.pink, Color.purple, Color.brown
    ]

    var row: Row

    var body: some View {
        HStack(spacing: 0) {
            ForEach(row.cells) { cell in
                RowView.colors[cell.value]
                    .frame(width: 20, height: 20)
            }
        }
    }
}

struct Pix: View {
    let grid: Grid

    var body: some View {
        VStack(spacing: 0) {
            ForEach(grid.rows) { row in
                RowView(row: row)
            }
        }
    }
}

#Preview {
    ContentView()
}
