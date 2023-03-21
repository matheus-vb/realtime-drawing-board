//
//  SocketService.swift
//  client
//
//  Created by matheusvb on 21/03/23.
//

import Foundation
import SwiftUI
import SocketIO

final class SocketService: ObservableObject {
    let manager = SocketManager(socketURL: URL(string: "http://localhost:5050")!, config: [.log(true), .compress])
    
    @Published var socket: SocketIOClient
    @Published var lines: [Line] = []
    
    init() {
        socket = manager.defaultSocket
        
        socket.on("connect") { (data, ack) in
            print("Connected")
        }
        
        socket.on("download_lines") { (data, ack) in
            if let buffer = data[0] as? String {
                let dataDecoded : Data = Data(base64Encoded: buffer, options: .ignoreUnknownCharacters)!
                do {
                    let dataArray = try JSONSerialization.jsonObject(with: dataDecoded, options: []) as! [Line]
                    self.lines = dataArray
                } catch {
                    print(error)
                }
            }
        }
        
        socket.connect()
    }
    
    func sendLines() {
        do {
            let data = try JSONSerialization.data(withJSONObject: lines, options: [])
            let strBase64 = data.base64EncodedString(options: .lineLength64Characters)
            socket.emit("upload_images", strBase64)
        } catch {
            print(error)
        }
    }
}
