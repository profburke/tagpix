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

            Button("JDI") {
                grid = Grid.generate()
            }
        }
        .padding()
        .onAppear {
            grid = Grid.generate()
        }
    }
}

struct RowView: View {
    let colors = [
        Color.red, Color.blue, Color.green
    ]

    var row: Row

    var body: some View {
        HStack(spacing: 0) {
            ForEach(row.cells) { cell in
                colors[cell.value]
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
