import Foundation

struct PhotosResponse: Codable {
    let photos: [Photo]
}

struct Photo: Codable, Identifiable, Hashable {
    var id: UUID
    let imageUrl: String // The original URL from Google API
    var localFilePath: String? // Optional local file path for cached photos
    var base64Image: String? // Optional base64 representation
    let width: Int? // Optional metadata for image dimensions
    let height: Int?

    enum CodingKeys: String, CodingKey {
        case id, imageUrl = "image_url", localFilePath, base64Image, width, height
    }

    init(id: UUID = UUID(), imageUrl: String, localFilePath: String? = nil, base64Image: String? = nil, width: Int? = nil, height: Int? = nil) {
        self.id = id
        self.imageUrl = imageUrl
        self.localFilePath = localFilePath
        self.base64Image = base64Image
        self.width = width
        self.height = height
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.imageUrl = try container.decode(String.self, forKey: .imageUrl)
        self.localFilePath = try container.decodeIfPresent(String.self, forKey: .localFilePath)
        self.base64Image = try container.decodeIfPresent(String.self, forKey: .base64Image)
        self.width = try container.decodeIfPresent(Int.self, forKey: .width)
        self.height = try container.decodeIfPresent(Int.self, forKey: .height)
        self.id = (try? container.decode(UUID.self, forKey: .id)) ?? UUID()
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(imageUrl, forKey: .imageUrl)
        try container.encode(localFilePath, forKey: .localFilePath)
        try container.encode(base64Image, forKey: .base64Image)
        try container.encode(width, forKey: .width)
        try container.encode(height, forKey: .height)
    }
}
