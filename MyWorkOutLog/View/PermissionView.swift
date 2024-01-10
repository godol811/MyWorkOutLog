import SwiftUI


struct PermissionView: View {
    
    @EnvironmentObject var permissionViewModel: PermissionViewModel

    var body: some View {
        VStack {
            
            permissionView
            
            ZStack {
                HStack {
                    Text("•")
                        .font(Font.footnote)
                        .foregroundColor(Color.teal)
                        .frame(maxHeight: .infinity, alignment: .top)
                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 25.0, trailing: 0))
                    
                    Spacer().frame(width: 5)
                    
                    Text("해당 기능을 이용하실 때 접근 권한 요청을 드리며, \n접근 권한에 대해 허용하지 않아도 기본 서비스의 이용은 가능합니다.")
                        .font(Font.footnote)
                        .foregroundColor(Color.cyan)
                        .frame(maxHeight: .infinity, alignment: .top)
                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 25.0, trailing: 0))
                }
            }
            .frame(height: 80)

            Spacer().frame(height: 20)

            Button(action: {
                permissionViewModel.requestPermission()
            }, label: {
                RoundedRectangle(cornerRadius: 10)
                    .overlay(
                        Text("권한 추가")
                            .foregroundColor(.white)
                    )
                    .foregroundColor(.mint)
            })
            .frame(width: 200, height: 50)

            Spacer().frame(height: 10)

            Button(action: {
                permissionViewModel.complete()
            }, label: {
                RoundedRectangle(cornerRadius: 10)
                    .overlay(
                        Text("무시하기")
                            .foregroundColor(.white)
                    )
                    .foregroundColor(.gray)
            })
            .frame(width: 200, height: 50)
        }
        .padding()
    }
    
    var permissionView: some View {
        VStack {
            HStack(spacing: 10) {
                PermissionDetailView(icon: "icon_outline_camera", title: "카메라(선택)".localized, description: "운동 기록용 사진".localized, bgColor: Color.clear)
            }.padding([.horizontal, .top], 20)
            
            Spacer().frame(height: 10)
            
            HStack(spacing: 20) {
                PermissionDetailView(icon: "icon_outline_picture", title: "사진/미디어/파일(선택)".localized, description: "운동 기록용 사진".localized, bgColor: Color.clear)
            }.padding([.horizontal, .bottom], 20)
            
            Spacer().frame(height: 10)
            
            HStack(spacing: 20) {
                PermissionDetailView(icon: "icon_outline_alert", title: "알람(선택)".localized, description: "운동 기록 유도".localized, bgColor: Color.clear)
            }.padding([.horizontal, .bottom], 20)
            
            Spacer().frame(height: 10)
            
            HStack(spacing: 20) {
                PermissionDetailView(icon: "icon_outline_alert", systemIcon: "figure.walk", title: "피트니스(선택)".localized, description: "운동 기록 추적".localized, bgColor: Color.clear)
            }.padding([.horizontal, .bottom], 20)
            
        }
        .background(Color.white)
        .cornerRadius(20)
    }
    
}

struct PermissionDetailView : View {
    
    var icon : String
    var systemIcon : String?
    var title : String
    var description : String
    var bgColor : Color
    
    private struct sizeInfo {
        static let padding: CGFloat = 10.0
        static let textPadding: CGFloat = 5.0
        static let height: CGFloat = 50.0
        static let cornerRadius: CGFloat = 20.0
        static let iconSize: CGSize = CGSize(width: 50, height: 50)
        static let iconCornerRadius: CGFloat = 25.0
        static let lineWidth: CGFloat = 0.5
    }
    
    var body: some View {
        HStack(spacing: sizeInfo.padding) {
            if let icon = systemIcon{
                Image(systemName: icon)
                    .renderingMode(.template)
                    .resizable()
                    .padding(sizeInfo.padding)
                    .foregroundColor(Color.gray)
                    .clipShape(Circle())
                    .frame(width: sizeInfo.iconSize.width, height: sizeInfo.iconSize.height)
                    .background(Color.white)
                    .overlay(
                        Circle().strokeBorder(Color.gray, lineWidth: sizeInfo.lineWidth)
                    )
                    .cornerRadius(sizeInfo.iconCornerRadius)
            }else{
                Image(icon)
                    .renderingMode(.template)
                    .resizable()
                    .padding(sizeInfo.padding)
                    .foregroundColor(Color.gray)
                    .clipShape(Circle())
                    .frame(width: sizeInfo.iconSize.width, height: sizeInfo.iconSize.height)
                    .background(Color.white)
                    .overlay(
                        Circle().strokeBorder(Color.gray, lineWidth: sizeInfo.lineWidth)
                    )
                    .cornerRadius(sizeInfo.iconCornerRadius)
    //                .padding(.all, 10)
            }
            
  
                
            
            VStack(alignment: .leading, spacing: 0){
                Divider().opacity(0)
                Rectangle().frame(height: 0)
                Text(title)
                    .kerning(0.3)
//                    .fontWeight(.bold)
                    .font(Font.title)
                    .foregroundColor(Color.gray)
                
                Spacer().frame(height: sizeInfo.textPadding)
                
                Text(description)
                    .foregroundColor(Color.teal)
                    .font(Font.title3)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .background(bgColor)
        .cornerRadius(sizeInfo.cornerRadius)
    }
}
