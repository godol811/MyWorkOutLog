//
//  WorkoutModifyView.swift
//  MyWorkOutLog
//
//  Created by 고종찬 on 2024/01/03.
//

import SwiftUI
import PhotosUI

struct WorkoutDetailView: View {
    
    var workoutHistory: WorkoutHistory
    @State private var title = ""
    @State private var content = "원하는 와드를 넣어주세요"
    @State private var selectedCondition: String = "쉬움"
    @State private var hashTagText = ""
    @State private var hashTagArray: [String] = []
    
    @State private var showPhotoPicker: Bool = false
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var image: UIImage? = nil
    @State private var showMediaPreview: Bool = false
    @State private var showMediaIndex: Int = 0
    
    
    @StateObject var vm = PhotoSelectorViewModel()
    
    let maxPhotosToSelect = 10
    let conditions = ["쉬움","보통","어려움"]
    var body: some View {
        ScrollView{
            VStack{
                TextField("제목", text: $title)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .opacity(0.1)
                    )
                TextEditor(text: $content)
                    .padding(5)
                    .scrollContentBackground(.hidden) // <- Hide it
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.black.opacity(0.1)) // 여기를 변경함
                    )
                
                    .frame(minHeight: 200)
                Picker(selection: $selectedCondition, label: Text("얼마나 힘들었나요?")) {
                    ForEach(conditions, id:\.self){ condition in
                        Text(condition).tag(condition)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                ScrollView(.horizontal){
                        HStack{
                            ForEach(hashTagArray, id: \.self) { tag in
                                HStack {
                                    Text("#\(tag)")
                                        .font(.footnote)
                                    
                                }
                                .padding(8) // 적절한 패딩 값
                                .background(Color.gray) // 배경색
                                .foregroundColor(.white) // 텍스트 색상
                                .cornerRadius(20) // 코너 반경으로 캡슐 형태 만들기
                            }
                        }//HSTACK
                }// SCROLLVIEW
                .padding()
                
            } // VSTACK
            .disabled(true)
            .padding()
            
            ScrollView(.horizontal){
                LazyHStack {
                    ForEach(0..<vm.thumbnailImages.count, id: \.self) { index in
                        ZStack(alignment: .topTrailing) {
                            ZStack{
                                Image(uiImage: vm.thumbnailImages[index].image)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 300)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                if vm.thumbnailImages[index].type == .video{
                                    Image(systemName: "video.circle.fill")
                                        .renderingMode(.original)
                                        .tint(Color.white)
                                }
                                
                            }
                            .onTapGesture{
                                showMediaIndex = index
                                showMediaPreview.toggle()
                            }
                           
                        }
                        
                    }
                } // LAZYHSTACK
            } // SCROLLVIEW
            .padding(.horizontal)
            .navigationTitle(dateFormatted(workoutHistory.writeDate))
            .onChange(of: vm.selectedPhotos) { _, _ in
                vm.convertDataToImage()
            }
            .sheet(isPresented: $showMediaPreview, content: {
                MediaFullScreenViewer(medias: workoutHistory.media, index: $showMediaIndex)
            })
         
        }
        .toolbar(.hidden, for: .tabBar)
        
        .onAppear{
            title = workoutHistory.title
            content = workoutHistory.content
            selectedCondition = workoutHistory.condition
            hashTagArray = workoutHistory.hashTags?.map{ $0.tag } ?? []
            DispatchQueue.main.async{
                vm.thumbnailImages = workoutHistory.media?.map{ ThumbnailView(image: UIImage(data:$0.data)!, type: $0.type, videoData: $0.videoData) } ?? []
            }
        }
    }
}

