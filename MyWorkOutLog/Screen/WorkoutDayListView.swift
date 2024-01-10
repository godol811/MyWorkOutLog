//
//  WorkoutDayListView.swift
//  MyWorkOutLog
//
//  Created by 고종찬 on 2024/01/05.
//

import SwiftUI
import SwiftData

struct WorkoutDayListView: View {
    @Environment(\.modelContext) private var modelContext
    var workoutHistories: [WorkoutHistory]
    @State private var showAddWorkoutView: Bool = false
    @State private var shzowModifyWorkoutView: Bool = false
    // 날짜별로 그룹화된 운동 기록
    
    
    
    var body: some View {
        NavigationStack{
            BannerView()
                .frame(height:60)
            List {
                ForEach(workoutHistories) { history in
                    NavigationLink {
                        WorkoutDetailView(workoutHistory: history)
                    } label: {
                        HStack{
                            if !(history.media?.isEmpty ?? ![].isEmpty){
                                ScrollView(.horizontal){
                                    LazyHStack{
                                        ForEach(history.media ?? []){item in
                                            ZStack{
                                                Image(uiImage: UIImage(data: item.data)!)
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(width:100,height:100)
                                                    .background(.black)
                                                    .clipShape(RoundedRectangle(cornerRadius: 5))
                                                    .padding([.top,.trailing], 10)
                                                if item.type == .video{
                                                    Image(systemName: "video.circle.fill")
                                                        .renderingMode(.original)
                                                        .tint(Color.white)
                                                }
                                            }
                                        }
                                    }//LAZYHSTACK
                                    
                                }//SCROLLVIEW
                                .frame(maxWidth:110, maxHeight: 110)
                            }
                            HStack(alignment:.top){
                                VStack(alignment: .leading){
                                    Text(history.title)
                                        .font(.headline)
                                        .padding(.bottom)
                                    ForEach(history.hashTags ?? []){ hashTag in
                                        Text("#\(hashTag.tag)")
                                            .lineLimit(1)
                                            .truncationMode(.tail)
                                            .font(.footnote)
                                    }
                                }
                                Spacer()
                                VStack(alignment: .trailing){
                                    Text("\(history.condition.localized)")
                                        .font(.footnote)
                                        .foregroundColor(history.condition.colorForCondition())
                                    
                                    if history.workoutTime != nil || history.workoutTime != 0{
                                        Text("\(secondsToTimeString(history.workoutTime ?? 0))")
                                    }
                                }
                            }// HSTACK
                            Spacer()
                        }// HSTACK
                    }
                    
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            // 삭제 액션
                            if let index = workoutHistories.firstIndex(of: history) {
                                modelContext.delete(workoutHistories[index])
                            }
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                    //                    .fullScreenCover(isPresented: $showModifyWorkoutView){
                    //                        WorkoutModifyView(workoutHistory: history, showModifyWorkoutView: $showModifyWorkoutView)
                    //                    }
                    
                }
                
                
                
            }
            .toolbar(.hidden, for: .tabBar)
            .listRowInsets(EdgeInsets.init(top: 10, leading: 10, bottom: 10, trailing: 10))
            .listStyle(GroupedListStyle())
            .navigationTitle(dateFormattedLocalized(workoutHistories.first?.writeDate ?? Date()))
            //            .toolbar {
            //                ToolbarItem {
            //                    Button(action: addItem) {
            //                        Label("Add Item", systemImage: "plus")
            //                    }
            //                }
            //            }
            //            .fullScreenCover(isPresented: $showAddWorkoutView, content: {
            //                WorkoutAddView(showWorkoutAddView: $showAddWorkoutView)
            //            })
        }
        
    }
    
    private func addItem() {
        withAnimation {
            showAddWorkoutView.toggle()
        }
    }
    
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(workoutHistories[index])
            }
        }
    }
}
