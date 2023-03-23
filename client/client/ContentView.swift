//
//  ContentView.swift
//  client
//
//  Created by matheusvb on 21/03/23.
//

import SwiftUI

let WIDTH: CGFloat = 800
let HEIGHT: CGFloat = 1000

struct ContentView: View {
    @ObservedObject var service: SocketService = SocketService()
    
    @State var currentLine = Line(points: [])
    
    
    var toolbar: some View {
        HStack {
            Group{
                Spacer()
                Button(action: {}, label: {
                    Image(systemName: "pencil")
                        .foregroundColor(Color(.black))
                        .scaleEffect(4)
                })
                Spacer()
                Button(action: {}, label: {
                    Image(systemName: "eraser")
                        .foregroundColor(Color(.black))
                        .scaleEffect(4)
                })
                Spacer()
            }

            Button(action: {}, label: {
                Circle()
                    .foregroundColor(.red)
                    .scaleEffect(0.8)
            })
            Spacer()

            Button(action: {}, label: {
                Circle()
                    .foregroundColor(.blue)
                    .scaleEffect(0.8)
            })
            Spacer()

            Button(action: {}, label: {
                Circle()
                    .foregroundColor(.green)
                    .scaleEffect(0.8)
            })
            Spacer()

        }.frame(height: 120)
    }
    
    var canvas: some View {
        return Canvas { context, size in
            for line in service.lines {
                var path = Path()
                path.addLines(line.points)
                context.stroke(path, with: .color(line.color), lineWidth: line.lineWidth)
            }
        }
        .gesture(DragGesture(minimumDistance: 0, coordinateSpace: .local)
            .onChanged({ value in
                let point = value.location
                currentLine.points.append(point)
                service.lines.append(currentLine)
            })
                .onEnded({ value in
                    currentLine = Line(points: [])
                })
        )
    }
    
    var drawingScene: some View {
        ZStack {
            canvas
                .frame(width: WIDTH, height: HEIGHT)
            Image(uiImage: UIImage(data: service.image) ?? UIImage())
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: WIDTH, height: HEIGHT)
                .allowsHitTesting(false)
        }
    }
    
    var body: some View {
        VStack {
            toolbar
            drawingScene
            Button("Clear") {
                service.lines = []
            }
            .frame(height: 100)
            .onChange(of: currentLine.points) {_ in
                sendCanvas()
            }
        }
    }
    
    func sendCanvas() {

        let renderer = ImageRenderer(content: drawingScene.frame(width: WIDTH, height: HEIGHT))
        
        if let uiImage = renderer.uiImage {
            if let data = uiImage.pngData() {
                let strBase64 = data.base64EncodedString(options: .lineLength64Characters)
                service.socket.emit("upload_lines", strBase64)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
