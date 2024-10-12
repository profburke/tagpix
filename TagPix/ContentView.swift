//
//  ContentView.swift
//  TagPix
//
//  Created by Matthew Burke on 10/11/24.
//

import SwiftUI

struct ContentView: View {
    @State private var grid: [[Int]] = []

    var body: some View {
        VStack {
            Spacer()

            Pix(grid: grid)

            Spacer()

            Button("JDI") {
                grid = generate()
            }
        }
        .padding()
        .onAppear {
            grid = generate()
        }
    }

    func generate() -> [[Int]] {
        var d: [[Int]] = []
        (0..<16).forEach { _ in
            var r: [Int] = []
            (0..<16).forEach { _ in
                r.append(Int.random(in: 0..<3))
            }
            d.append(r)
        }

        print("rows: \(d.count)")
        print("cols: \(d[0].count)")
        let buffer = d.withUnsafeBufferPointer { Data(buffer: $0) }
        print(buffer as NSData)

        return d
    }
}

struct Row: View {
    let colors = [
        Color.red, Color.blue, Color.green
    ]

    var row: [Int]

    var body: some View {
        HStack(spacing: 0) {
            ForEach(row, id: \.self) { cell in
                colors[cell]
                    .frame(width: 20, height: 20)
            }
        }
    }
}

struct Pix: View {
    let grid: [[Int]]

    var body: some View {
        VStack(spacing: 0) {
            ForEach(grid, id: \.self) { row in
                Row(row: row)
            }
        }
    }
}

#Preview {
    ContentView()
}
