class PhotoSharingViewModel: ObservableObject {
    @Published var selectedImage: UIImage?
    @Published var isShowingImagePicker = false
    @Published var isShowingCamera = false
    @Published var isUploading = false
    @Published var error: Error?
    
    func selectImage() {
        isShowingImagePicker = true
    }
    
    func takePhoto() {
        isShowingCamera = true
    }
    
    func handleSelectedImage(_ image: UIImage) {
        selectedImage = image
    }
} 