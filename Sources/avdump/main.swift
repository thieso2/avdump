import Foundation
import SwiftFFmpeg


func copy(source: String) throws {
    let fmtCtx = try AVFormatContext(url: source)
    try fmtCtx.findStreamInfo()
    fmtCtx.dumpFormat(isOutput: false)
    
    guard let istream = fmtCtx.videoStream else {
        fatalError("No video stream.")
    }
    
    let output = "/tmp/movie.mov"
    
    try? FileManager.default.removeItem(at: URL(fileURLWithPath: output))
    
    let ofmtCtx = try AVFormatContext(format: nil, filename: output)
    
    
    //let ofmtCtx = try! AVFormatContext(url: "/tmp/movie.mov", format: nil, options: ["frag_duration": "1"])
    
//    ofmtCtx.flags = .flushPackets
    guard let ostream = ofmtCtx.addStream() else {
        fatalError("Failed allocating output stream.")
    }
    
//    let codec = AVCodec.findEncoderByName("hevc_videotoolbox")
//    let codecCtx = AVCodecContext(codec: codec)
    
    
//    var codecParams = istream
    
    ostream.codecParameters.copy(from: istream.codecParameters)
//    ostream.timebase = istream.timebase
//    ostream.averageFramerate = istream.averageFramerate
    //ostream.averageFramerate = istream.averageFramerate
    //ostream.codecParameters.codecTag = 0
    
//    ofmtCtx.dumpFormat(url: output, isOutput: true)
    
    try ofmtCtx.openOutput(url: output, flags: .write)
//
    try ofmtCtx.writeHeader(options: ["frag_duration": "1"])
//    try ofmtCtx.writeHeader()
    
    let pkt = AVPacket()
    var no = 0
    
    while let _ = try? fmtCtx.readFrame(into: pkt) {
        defer { pkt.unref() }
        
        guard pkt.streamIndex == istream.index else { continue }
        
//        if no % 100 == 0 {
            print(no, pkt.pts, pkt.position, pkt.dts, pkt.duration, pkt.size, pkt.flags)
//        }
        
        pkt.position = -1
        
        try ofmtCtx.writeFrame(pkt)
        try ofmtCtx.writeFrame(nil)
        
        no += 1
    }
    
    try ofmtCtx.writeTrailer()
    
    print("Done.")
}




func dump_file(path: String) throws {
    let fmtCtx = try AVFormatContext(url: path)
    
    if ProcessInfo.processInfo.environment["DUMP_FORMAT"] == "1" {
        fmtCtx.dumpFormat(isOutput: false)
    }
    
    let showSize = ProcessInfo.processInfo.environment["SHOW_SIZE"] == "1"

    guard let istream = fmtCtx.videoStream else {
        fatalError("No video stream.")
    }
    
    let pkt = AVPacket()
    var no = 1

    if showSize {
        print("      n #     pts     dts     dur    size")
    } else {
        print("      n #     pts     dts     dur    ")
    }
    
    while let _ = try? fmtCtx.readFrame(into: pkt) {
        defer { pkt.unref() }
        
        let desc = pkt.flags.isEmpty ? "" : pkt.flags.description
        if showSize {
            print(String(format: "%7d %d %7d %7d %7d %7d \(desc)", no, pkt.streamIndex, pkt.pts, pkt.dts, pkt.duration, pkt.size))
        } else {
            print(String(format: "%7d %d %7d %7d %7d \(desc)", no, pkt.streamIndex, pkt.pts, pkt.dts, pkt.duration))

        }
        no += 1
    }
}

//AVLog.level = AVLog.Level.error

try copy(source: "/tmp/source.mov")
