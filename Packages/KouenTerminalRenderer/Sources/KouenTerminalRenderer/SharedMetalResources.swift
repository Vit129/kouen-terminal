import Foundation
import Metal

/// Immutable device resources shared by live panes. Mutable atlases, textures and
/// frame-buffer rings remain owned by each renderer. Weak entries release GPU
/// resources when the last pane closes; the lock serializes construction.
final class SharedMetalResources: @unchecked Sendable {
    private struct Entry { weak var value: SharedMetalResources? }
    private static let lock = NSLock()
    nonisolated(unsafe) private static var entries: [UInt64: Entry] = [:]

    static func acquire(device: MTLDevice) -> SharedMetalResources? {
        lock.lock(); defer { lock.unlock() }
        entries = entries.filter { $0.value.value != nil }
        if let existing = entries[device.registryID]?.value { return existing }
        guard let resources = try? SharedMetalResources(device: device) else { return nil }
        entries[device.registryID] = Entry(value: resources)
        return resources
    }

    let library: MTLLibrary
    let commandQueue: MTLCommandQueue
    let bgPipeline: MTLRenderPipelineState
    let glyphPipeline: MTLRenderPipelineState
    let decoPipeline: MTLRenderPipelineState
    let imagePipeline: MTLRenderPipelineState
    let overlayPipeline: MTLRenderPipelineState?
    let sampler: MTLSamplerState

    private init(device: MTLDevice) throws {
        guard let queue = device.makeCommandQueue() else { throw Failure.unavailable }
        commandQueue = queue
        library = try device.makeLibrary(source: MetalShaders.source, options: nil)
        bgPipeline = try TerminalMetalRenderer.makePipeline(device: device, library: library,
            vertex: "bg_vertex", fragment: "bg_fragment", blending: false)
        glyphPipeline = try TerminalMetalRenderer.makePipeline(device: device, library: library,
            vertex: "glyph_vertex", fragment: "glyph_fragment", blending: true)
        decoPipeline = try TerminalMetalRenderer.makePipeline(device: device, library: library,
            vertex: "deco_vertex", fragment: "deco_fragment", blending: true)
        imagePipeline = try TerminalMetalRenderer.makePipeline(device: device, library: library,
            vertex: "image_vertex", fragment: "image_fragment", blending: true)
        overlayPipeline = try? TerminalMetalRenderer.makePipeline(device: device, library: library,
            vertex: "overlay_vertex", fragment: "overlay_fragment", blending: true)
        let descriptor = MTLSamplerDescriptor()
        descriptor.minFilter = .linear
        descriptor.magFilter = .linear
        descriptor.sAddressMode = .clampToEdge
        descriptor.tAddressMode = .clampToEdge
        guard let sampler = device.makeSamplerState(descriptor: descriptor) else { throw Failure.unavailable }
        self.sampler = sampler
    }

    private enum Failure: Error { case unavailable }
}
