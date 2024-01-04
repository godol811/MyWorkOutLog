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
    var hashTags: String
    @Relationship(inverse: \Picture.workoutHistory) var pictures: [Picture]?
    @Relationship(inverse: \Video.workoutHistory) var videos: [Video]?
    var writeDate: Date
    var conditions : Conditions
    
    init(title: String, content: String, hashTags: String, pictures: [Picture]? = nil, videos: [Video]? = nil, writeDate: Date, conditions: Conditions) {
        self.title = title
        self.content = content
        self.hashTags = hashTags
        self.pictures = pictures
        self.videos = videos
        self.writeDate = writeDate
        self.conditions = conditions
    }
    
  
}

@Model
final class Picture{
    var url: String
    var workoutHistory: WorkoutHistory?
    
    init(url: String){
        self.url = url
    }
}

@Model
final class Video{
    var url: String
    var workoutHistory: WorkoutHistory?
    
    init(url: String){
        self.url = url
    }
    
}

enum Conditions {
case easy, normal, hard
}
