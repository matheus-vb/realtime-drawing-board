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
    @Published var image: Data = Data()
    
    init() {
        socket = manager.defaultSocket
        
        socket.on("connect") { (data, ack) in
            print("Connected")
        }
        
        socket.on("download_lines") { (data, ack) in
            if let buffer = data[0] as? String {
                let dataDecoded : Data = Data(base64Encoded: buffer, options: .ignoreUnknownCharacters)!
                self.image = dataDecoded
                
            }
        }
        
        socket.connect()
    }
}
