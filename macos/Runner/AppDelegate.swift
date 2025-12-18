import Cocoa
import FlutterMacOS
import AVFoundation

@main
class AppDelegate: FlutterAppDelegate {
  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return true
  }

  override func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
    return true
  }

  override func applicationDidFinishLaunching(_ notification: Notification) {
    let controller : FlutterViewController = mainFlutterWindow?.contentViewController as! FlutterViewController
    let channel = FlutterMethodChannel(name: "com.example.videoFrameExtractor/macos",
                                       binaryMessenger: controller.engine.binaryMessenger)
    
    channel.setMethodCallHandler({
      (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
      if ("extractFrame" == call.method) {
        self.extractFrame(call: call, result: result)
      } else {
        result(FlutterMethodNotImplemented)
      }
    })
    
    super.applicationDidFinishLaunching(notification)
  }

  private func extractFrame(call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let args = call.arguments as? [String: Any],
          let path = args["path"] as? String,
          let positionMs = args["position"] as? Double else {
      result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
      return
    }

    let quality = args["quality"] as? Int ?? 100
    let format = args["format"] as? String ?? "png"

    let asset = AVURLAsset(url: URL(fileURLWithPath: path))
    let generator = AVAssetImageGenerator(asset: asset)
    generator.appliesPreferredTrackTransform = true
    generator.requestedTimeToleranceBefore = .zero
    generator.requestedTimeToleranceAfter = .zero

    let time = CMTime(seconds: positionMs / 1000.0, preferredTimescale: 600)

    DispatchQueue.global(qos: .userInitiated).async {
      do {
        let imageRef = try generator.copyCGImage(at: time, actualTime: nil)
        let bitmap = NSBitmapImageRep(cgImage: imageRef)
        
        var fileType: NSBitmapImageRep.FileType = .png
        var properties: [NSBitmapImageRep.PropertyKey: Any] = [:]

        if format.lowercased() == "jpeg" || format.lowercased() == "jpg" {
             fileType = .jpeg
             properties[.compressionFactor] = Float(quality) / 100.0
        }

        if let data = bitmap.representation(using: fileType, properties: properties) {
            result(FlutterStandardTypedData(bytes: data))
        } else {
            result(FlutterError(code: "ENCODING_ERROR", message: "Failed to encode image", details: nil))
        }
      } catch {
        result(FlutterError(code: "EXTRACTION_ERROR", message: error.localizedDescription, details: nil))
      }
    }
  }
}
