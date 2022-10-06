import SwiftUI
import Charts



struct ProfileContentView: View {
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    
        var imageUrl: URL? = URL(string: "")
        
        AsyncImage(url: imageUrl) { image in
            image.resizable()
        } placeholder: {
            ProgressView()
        }
        .frame(width: 240, height: 126)
        
        .onAppear {
            imageUrl = URL(string: "https://cdn-ssl-devio-img.classmethod.jp/wp-content/uploads/2022/08/swiftui-image-from-url-eyecatch-960x504.png")
        }
    }
}

struct ProfileContentView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileContentView()
    }
}
