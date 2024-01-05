import SwiftUI
import PhotosUI
import UniformTypeIdentifiers
import AVFoundation

class PhotoSelectorViewModel: ObservableObject {
    @Published var thumbnailImages = [ThumbnailView]()
    @Published var images = [UIImage]()
    @Published var videos = [URL]()
    @Published var selectedPhotos = [PhotosPickerItem]()
    
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
}

struct ThumbnailView{
    var image:UIImage
    var type: ThumbnailType
    var videoData: Data?
}

enum ThumbnailType: Codable{
    case video, photo
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
