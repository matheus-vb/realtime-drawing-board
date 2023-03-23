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
    @State var lines: [Line] = []
    
    @State var lineColor: Color = .black
    
    var toolbar: some View {
        HStack {
            Group{
                Spacer()
                Button(action: {
                    lineColor = .black
                }, label: {
                    Image(systemName: "pencil")
                        .foregroundColor(Color(.black))
                        .scaleEffect(4)
                })
                Spacer()
                Button(action: {
                    lineColor = .white
                }, label: {
                    Image(systemName: "eraser")
                        .foregroundColor(Color(.black))
                        .scaleEffect(4)
                })
                Spacer()
            }
            
            Button(action: {
                lineColor = .red
            }, label: {
                Circle()
                    .foregroundColor(.red)
                    .scaleEffect(0.8)
            })
            Spacer()
            
            Button(action: {
                lineColor = .blue
            }, label: {
                Circle()
                    .foregroundColor(.blue)
                    .scaleEffect(0.8)
            })
            Spacer()
            
            Button(action: {
                lineColor = .green
            }, label: {
                Circle()
                    .foregroundColor(.green)
                    .scaleEffect(0.8)
            })
            Spacer()
            
        }.frame(height: 120)
    }
    
    var canvas: some View {
        return Canvas { context, size in
            for line in lines {
                var path = Path()
                path.addLines(line.points)
                context.stroke(path, with: .color(line.color), lineWidth: line.lineWidth)
            }
        }
        .gesture(DragGesture(minimumDistance: 0, coordinateSpace: .local)
            .onChanged({ value in
                let point = value.location
                
                if value.translation.width + value.translation.height == 0 {
                    lines.append(Line(points: [point], color: lineColor, lineWidth: 8))
                } else {
                    let index = lines.count - 1
                    lines[index].points.append(point)
                }
                currentLine.points.append(point)
            })
                .onEnded({ value in
                    currentLine = Line(points: [])
                })
        )
    }
    
    var drawingScene: some View {
        ZStack {
            Image(uiImage: UIImage(data: service.image) ?? UIImage())
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: WIDTH, height: HEIGHT)
                .allowsHitTesting(false)
            canvas
                .frame(width: WIDTH, height: HEIGHT)
        }
    }
    
    var body: some View {
        VStack {
            toolbar
                .scaleEffect(0.8)
                .offset(y: 20)
            drawingScene
            Button("Clear") {
                lines = []
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
