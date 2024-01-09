import SwiftUI
import PhotosUI
import UniformTypeIdentifiers
import AVFoundation
import LinkPresentation

class PhotoSelectorViewModel: ObservableObject {
    @Published var thumbnailImages = [ThumbnailView]()
    @Published var images = [UIImage]()
    @Published var videos = [URL]()
    @Published var selectedPhotos = [PhotosPickerItem]()
    @Published var shareItems: [CustomActivityItem] = []
    
    @MainActor
    func convertDataToImage() {
        if !selectedPhotos.isEmpty {
            for eachItem in selectedPhotos {
                Task {
                    
                    eachItem.loadTransferable(type: Data.self) { result in
                        switch result {
                        case .success(let data):
                            if let data = data, let image = UIImage(data: data) {
                                DispatchQueue.main.async {
                                    self.thumbnailImages.append(ThumbnailView(image: image, type: .photo))
                                    self.images.append(image)
                                }
                            } else {
                                eachItem.loadTransferable(type: Movie.self) { result in
                                    
                                    switch result {
                                    case .success(let movie):
                                        DispatchQueue.main.async { // 메인 스레드에서 실행
                                            if let url = movie?.url {
                                                self.videos.append(url)
                                                self.extractThumbnailFrom(videoUrl: url)
                                            }
                                        }
                                    case .failure(let error):
                                        print(error.localizedDescription)
                                    }
                                }
                            }
                        case .failure(let error):
                            print(error.localizedDescription)
                        }
                    }
                    
                }
            }
        }
        DispatchQueue.main.async { // 메인 스레드에서 실행
            self.selectedPhotos.removeAll()
        }
    }
    
    func removeImage(at index: Int){
        DispatchQueue.main.async{
            self.thumbnailImages.remove(at: index)
        }
    }
    
    func extractThumbnailFrom(videoUrl: URL) {
        let asset = AVAsset(url: videoUrl)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        
        let timestamp = CMTime(seconds: 1, preferredTimescale: 60)
        do {
            let imageRef = try generator.copyCGImage(at: timestamp, actualTime: nil)
            let image = UIImage(cgImage: imageRef)
            DispatchQueue.main.async {
                self.thumbnailImages.append(ThumbnailView(image: image, type: .video, videoData: loadData(from: videoUrl)))
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func prepareForShareItems() -> [CustomActivityItem] {
        // 첫째, .photo와 .video의 존재 여부를 확인합니다.
        let containsPhoto = thumbnailImages.contains { $0.type == .photo }
        let containsVideo = thumbnailImages.contains { $0.type == .video }
        let tempFileName = "\(Date().timeIntervalSince1970)_Temp.mp4"
        
        // .photo와 .video가 둘 다 존재하는 경우에는 .video만 배열에 포함합니다.
        if containsPhoto && containsVideo {
            return thumbnailImages.compactMap { item in
                if item.type == .video {
                    return item.videoData.flatMap {
                        saveDataToFile(data: $0, withFileName: tempFileName)
                    }.map { CustomActivityItem(shareObject: $0, previewImage: item.image) }
                } else {
                    return nil
                }
            }
        } else {
            // .photo만 있거나 .video만 있는 경우에는 해당 타입의 모든 항목을 포함합니다.
            return thumbnailImages.compactMap { item in
                switch item.type {
                case .photo:
                    return CustomActivityItem(shareObject: item.image, previewImage: item.image)
                case .video:
                    return item.videoData.flatMap {
                        saveDataToFile(data: $0, withFileName: tempFileName)
                    }.map { CustomActivityItem(shareObject: $0, previewImage: item.image) }
                }
            }
        }
    }
    
    
    
}




struct ThumbnailView{
    var image:UIImage
    var type: ThumbnailType
    var videoData: Data?
}

enum ThumbnailType: Codable{
    case video, photo
}

class CustomActivityItem: NSObject, UIActivityItemSource {
    private let shareObject: Any
    private let previewImage: UIImage
    
    init(shareObject: Any, previewImage: UIImage) {
        self.shareObject = shareObject
        self.previewImage = previewImage
        
        super.init()
    }
    
    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return shareObject
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        return previewImage
    }
    
    func activityViewControllerLinkMetadata(_ activityViewController: UIActivityViewController) -> LPLinkMetadata? {
        let metadata = LPLinkMetadata()
        
        metadata.iconProvider = NSItemProvider(object: previewImage)
        metadata.title = "공유하기".localized
        
        return metadata
    }
    
}



struct Movie: Transferable {
    let url: URL
    
    static var transferRepresentation: some TransferRepresentation {
        FileRepresentation(contentType: .movie) { movie in
            SentTransferredFile(movie.url)
        } importing: { receivedData in
            let fileName = receivedData.file.lastPathComponent
            let copy: URL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
            
            if FileManager.default.fileExists(atPath: copy.path) {
                try FileManager.default.removeItem(at: copy)
            }
            
            try FileManager.default.copyItem(at: receivedData.file, to: copy)
            return .init(url: copy)
        }
    }
}
