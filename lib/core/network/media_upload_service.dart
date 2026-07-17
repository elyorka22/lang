/// Media upload helper — never stores files on the app server.
///
/// Flow:
/// 1. Request presigned URL from NestJS `POST /media/presign`
/// 2. PUT bytes directly to Cloudflare R2 / DigitalOcean Spaces
/// 3. Send resulting CDN URL in chat / profile payloads
class MediaUploadService {
  MediaUploadService();

  Future<String> uploadBytes({
    required List<int> bytes,
    required String contentType,
    required String folder,
  }) async {
    // Production:
    // final presign = await dio.post(ApiEndpoints.mediaPresign, data: {...});
    // await Dio().put(presign.url, data: Stream.fromIterable([bytes]), ...);
    // return presign.cdnUrl;
    throw UnimplementedError(
      'Configure R2/Spaces presign endpoint before uploading media',
    );
  }
}
