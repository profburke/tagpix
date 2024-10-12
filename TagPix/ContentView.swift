//
//  ContentView.swift
//  TagPix
//
//  Created by Matthew Burke on 10/11/24.
//

import SwiftUI

struct ContentView: View {
    let size = 16
    let tm = TagManager()
    @State private var grid: Grid
    @State private var presentAlert = false
    @State private var tagErrorMessage = ""

    init() {
        self.grid = Grid.generate(size: size)
    }

    var body: some View {
        VStack {
            Spacer()

            Pix(grid: grid)

            Spacer()

            HStack {
                Button("Save to Tag") {
                    save()
                }

                Spacer()

                Button("JDI") {
                    grid = Grid.generate(size: size)
                }

                Spacer()

                Button("data") {
                    _ = grid.data()
                }
            }
            .padding([.leading, . trailing, .bottom], 40)
        }
        .padding()
        .onAppear {
            grid = Grid.generate(size: size)
        }
        .alert("Tag Error", isPresented: $presentAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(tagErrorMessage)
        }
    }

    private func save() {
        let data = grid.data()
        do {
            try tm.write(data: data)
        } catch {
            presentAlert = true
            tagErrorMessage = "Error saving image to tag: \(error.localizedDescription)"
        }
    }
}

struct RowView: View {
    // TODO: where does this belong?
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
                // TODO: nix the magic numbers
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
