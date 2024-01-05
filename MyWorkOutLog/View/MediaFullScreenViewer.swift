//
//  MediaFullScreenViewer.swift
//  MyWorkOutLog
//
//  Created by 고종찬 on 2024/01/03.
//

import SwiftUI
import AVKit

struct MediaFullScreenViewer: View {
    var medias: [Media]? // 이미지 파일 이름의 배열
    @State private var player: AVPlayer?
    @Binding var index:Int
    
    var body: some View {
        TabView {
            ForEach(medias ?? [], id: \.self) { media in
                if media.videoData != nil{
                    VideoPlayer(player: player)
                        .edgesIgnoringSafeArea(.all)
                        .tabItem { Text("\(media.id.hashValue.description)") }
                        .tag(media)
                        .onAppear{
                            if let data = media.videoData { // Data 객체
                                let fileURL = saveDataToFile(data: data, withFileName: "temp.mp4")
                                player = AVPlayer(url: fileURL ?? URL(string: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!)
                                player?.play()
                            }
                        }
                    
                }else{
                    Color.black.edgesIgnoringSafeArea(.all)
                        .overlay(
                            Image(uiImage:UIImage(data:media.data )!)
                                .resizable()
                                .scaledToFit()
                        )
                        .tabItem { Text("\(media.data )") }
                        .tag(media)
                }
                
            }
            
        }
        .tabViewStyle(PageTabViewStyle())
        
        .edgesIgnoringSafeArea(.all)
        
    }
}

