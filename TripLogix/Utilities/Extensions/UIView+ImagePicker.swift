
import Foundation
import SwiftUI
 
extension View {
    public func asUIImage() -> UIImage? {
        // Instantiate a UIHostingController with the SwiftUI view.
        let controller = UIHostingController(rootView: self)
        
        // Arbitrarily setting frame; will adjust to sizeThatFits shortly.
        controller.view.frame = CGRect(x: 0, y: 0, width: 1, height: 1)
        
        // Handle scene-based window retrieval for iOS 13 and later.
        let window: UIWindow? = UIApplication.shared.connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .compactMap { $0 as? UIWindowScene }
            .first?.windows
            .filter { $0.isKeyWindow }.first
        
        // Ensure a window is found; otherwise, return nil.
        guard let currentWindow = window else { return nil }
        
        currentWindow.rootViewController?.view.addSubview(controller.view)
        
        // Calculate the appropriate size for the view.
        let size = controller.sizeThatFits(in: UIScreen.main.bounds.size)
        controller.view.bounds = CGRect(origin: .zero, size: size)
        controller.view.sizeToFit()
        
        // Convert the UIView to UIImage.
        // Ensure you have implemented this extension on UIView.
        guard let image = controller.view.asImage() else { return nil }
        
        controller.view.removeFromSuperview()
        return image
    }
}

// Placeholder for UIView extension to convert to UIImage.
// Implement this method according to your needs.
extension UIView {
    func asImage() -> UIImage? {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { context in
            layer.render(in: context.cgContext)
        }
    }
}
 
struct ImagePicker: UIViewControllerRepresentable {
 
    @Environment(\.presentationMode)
    var presentationMode
 
    @Binding var image: Image?
 
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
 
        @Binding var presentationMode: PresentationMode
        @Binding var image: Image?
 
        init(presentationMode: Binding<PresentationMode>, image: Binding<Image?>) {
            _presentationMode = presentationMode
            _image = image
        }
 
        func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            let uiImage = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
            image = Image(uiImage: uiImage)
            presentationMode.dismiss()
 
        }
 
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            presentationMode.dismiss()
        }
 
    }
 
    func makeCoordinator() -> Coordinator {
        return Coordinator(presentationMode: presentationMode, image: $image)
    }
 
    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }
 
    func updateUIViewController(_ uiViewController: UIImagePickerController,
                                context: UIViewControllerRepresentableContext<ImagePicker>) {
 
    }
 
}
