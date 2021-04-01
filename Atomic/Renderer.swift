//
//  Renderer.swift
//  1 Vectors
//
//  Created by Ferran Canals on 30/03/2020.
//  Copyright © 2020 Ferran Canals. All rights reserved.
//

import MetalKit

class Renderer: NSObject {
    
    static var device: MTLDevice!
    static var commandQueue: MTLCommandQueue!
    static var library: MTLLibrary!
    
    var computePipelineState:MTLComputePipelineState!
    
    var incremental:Int32 = 0
    var incrementalBuffer:MTLBuffer!
    var incrementalPointer: UnsafeMutablePointer<Int32>!
    
    init(metalView: MTKView) {
        
        guard
            let device = MTLCreateSystemDefaultDevice(),
            let commandQueue = device.makeCommandQueue() else {
            fatalError("GPU not available")
        }
        Renderer.device = device
        Renderer.commandQueue = commandQueue
        Renderer.library = device.makeDefaultLibrary()
        metalView.device = device
        
        computePipelineState = Renderer.buildComputePipelineState()
        
        
        incrementalBuffer = Renderer.device.makeBuffer(bytes: &incremental, length: MemoryLayout<Int32>.stride)
        incrementalPointer = incrementalBuffer.contents().bindMemory(to: Int32.self, capacity: 1)
        
        super.init()
        
        metalView.delegate = self
        metalView.clearColor = MTLClearColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1)
        
    }
}

extension Renderer: MTKViewDelegate {
    
    func draw(in view: MTKView) {
        
        guard
            let commandBufferCompute = Renderer.commandQueue.makeCommandBuffer(),
            let computeCommandEncoder = commandBufferCompute.makeComputeCommandEncoder()
        else {
            return
        }
        computeCommandEncoder.setComputePipelineState(computePipelineState)
        let width = computePipelineState.threadExecutionWidth
        let threadsPerGroup = MTLSizeMake(width, 1, 1)
        let threadsPerGrid = MTLSizeMake(10, 1, 1)
        computeCommandEncoder.setBuffer(incrementalBuffer, offset: 0, index: 0)
//        computeCommandEncoder.setThreadgroupMemoryLength(16, index: 0)
        computeCommandEncoder.dispatchThreads(threadsPerGrid, threadsPerThreadgroup: threadsPerGroup)
        computeCommandEncoder.endEncoding()
        commandBufferCompute.commit()
        commandBufferCompute.waitUntilCompleted()
        
        print(incrementalPointer.pointee)
        
    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
    }
}


extension Renderer {
    
    private static func buildComputePipelineState()->MTLComputePipelineState{

        let function = Renderer.library.makeFunction(name: "compute_shader")!
        var pipelineState:MTLComputePipelineState!
        do{
            pipelineState = try Renderer.device.makeComputePipelineState(function: function)
        }catch let error{
            print(error.localizedDescription)
            fatalError()
        }
        return pipelineState
    }
    

    
}



