
import SwiftUI

struct ImageToFlightView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject var chatAPIViewModel: ChatAPIViewModel = ChatAPIViewModel()
    @State var showImagePicker: Bool = false
    @State var selectedImage: Image? = nil

    private func dismiss() {
        presentationMode.wrappedValue.dismiss()
    }
    
    private func submitImageUrl(_ imageUrl: String) {
        chatAPIViewModel.getChatGPTContent(qType: QCategory.textFromImageUrl(imageUrl: imageUrl))
    }
    
    var body: some View {
        ScrollView {
            VStack {
                BannerWithDismiss(
                    dismiss: dismiss,
                    headline: "Add Flights to Trip".uppercased(),
                    subHeadline: "Add your flight reservation screenshot"
                )
                .padding()
                .padding(.top, 10)
                
                VStack {
                    Text("Upload Itinerary image".uppercased())
                        .font(.custom("Gilroy-Bold", size: 18))
                        .foregroundColor(.gray)
                        .onTapGesture {
                            self.showImagePicker = true
                        }
                    
                    Button(action: {
                        
                        //self.isLoading.toggle()
                        
                        let uiImage: UIImage? = self.selectedImage?.asUIImage()
                        let imageData: Data? = uiImage?.jpegData(compressionQuality: 0.1) ?? Data()
                        let imageString: String? = imageData?.base64EncodedString()
                        
                        guard let url: URL = URL(string: "https://palamana.com/TripLogixTempImages/uploadTempImage.php?id=\(UUID().uuidString)"), let imageString = imageString else { return }
                        
                        let paramStr: String = "image=\(imageString)"
                        let paramData: Data = paramStr.data(using: .utf8) ?? Data()
                        
                        var urlRequest: URLRequest = URLRequest(url: url)
                        urlRequest.httpMethod = "POST"
                        urlRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Cpntent-Type")
                        urlRequest.httpBody = paramData
                        
                        URLSession.shared.dataTask(with: urlRequest, completionHandler: { data, response, error in
                            guard let data = data else { return }
                            
                            let responseStr: String = String(data: data, encoding: .utf8) ?? ""
//                                SDImageCache.shared.clearMemory()
//                                SDImageCache.shared.clearDisk()
                            print("[Debug] \(responseStr)")
                            submitImageUrl(responseStr)
                            //self.isLoading.toggle()
                            self.selectedImage = nil
                        })
                            .resume()
                        
                    }) {
                        Text("Add Flight Photo")
                            .font(.largeTitle)
                    }
                    Divider()
                    self.selectedImage?.resizable().scaledToFit()
                    
                    Divider()
                    Text("Response: \(chatAPIViewModel.textFromImage)")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                }
                .padding()
                //.cardStyle(.white)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .center)
            .sheet(isPresented: $showImagePicker, content: {
                ImagePicker(image: self.$selectedImage)
            })
        }
    }
}

