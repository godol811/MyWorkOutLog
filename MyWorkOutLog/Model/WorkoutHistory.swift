//
//  Item.swift
//  MyWorkOutLog
//
//  Created by 고종찬 on 2024/01/02.
//

import Foundation
import SwiftData
import CoreLocation


@Model
final class WorkoutHistory {
    
    @Attribute(.unique) var id = UUID()
    var title: String
    var content: String
    @Relationship(inverse: \HashTag.workoutHistory) var hashTags: [HashTag]?
    @Relationship(inverse: \Media.workoutHistory) var media: [Media]?
//    @Relationship(inverse: \Video.workoutHistory) var videos: [Video]?
    var writeDate: Date
    var condition : String
    
    init(title: String, content: String, writeDate: Date, condition: String) {
        self.title = title
        self.content = content
        self.writeDate = writeDate
        self.condition = condition
    }
    
  
}

@Model
final class Media{
    var data: Data
    var type: ThumbnailType
    var videoData: Data?
    var workoutHistory: WorkoutHistory?
    
    init(data: Data, type: ThumbnailType, videoData: Data? = nil){
        self.data = data
        self.type = type
        self.videoData = videoData
    }
}

//@Model
//final class Video{
//    var url: URL
//    var workoutHistory: WorkoutHistory?
//    
//    init(url: URL){
//        self.url = url
//    }
//    
//}

@Model
final class HashTag{
    var tag: String
    var workoutHistory: WorkoutHistory?
    
    init(tag: String){
        self.tag = tag
    }
    
}


