//
//  ContentView.swift
//  client
//
//  Created by matheusvb on 21/03/23.
//

import SwiftUI

struct Line {
    var points = [CGPoint]()
    var color: Color = .red
    var lineWidth: Double = 8.0
}

struct ContentView: View {
    @State var currentLine = Line()
    @State var lines: [Line] = []
    
    var canvas: some View {
        return Canvas { context, size in
            for line in lines {
                var path = Path()
                path.addLines(line.points)
                context.stroke(path, with: .color(line.color), lineWidth: line.lineWidth)
            }
        }.gesture(DragGesture(minimumDistance: 0, coordinateSpace: .local)
            .onChanged({ value in
                            let point = value.location
                            currentLine.points.append(point)
                            lines.append(currentLine)
                        })
            .onEnded({ value in
                currentLine = Line(color: .red)
             })
          )
    }
    
    var body: some View {
        VStack {
            canvas
            Button("Clear") {
                lines = []
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
