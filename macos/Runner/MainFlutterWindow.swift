import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  /// An iPhone Pro Max screen (iPhone 16/17 Pro Max) in points, so the Mac
  /// app previews the phone layout.
  static let phoneSize = NSSize(width: 440, height: 956)

  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    self.contentViewController = flutterViewController

    // The phone's shape at full size when the screen has room, otherwise
    // scaled down to fit; resizing keeps the shape.
    var size = MainFlutterWindow.phoneSize
    if let visible = (self.screen ?? NSScreen.main)?.visibleFrame {
      let titleBar = self.frameRect(forContentRect: NSRect(origin: .zero, size: size)).height - size.height
      let scale = min(1, (visible.height - titleBar) / size.height)
      size = NSSize(width: (size.width * scale).rounded(), height: (size.height * scale).rounded())
      let frame = self.frameRect(forContentRect: NSRect(origin: .zero, size: size))
      self.setFrame(
        NSRect(x: visible.midX - frame.width / 2, y: visible.maxY - frame.height,
               width: frame.width, height: frame.height),
        display: true)
    }
    self.contentAspectRatio = MainFlutterWindow.phoneSize

    RegisterGeneratedPlugins(registry: flutterViewController)

    super.awakeFromNib()
  }
}
