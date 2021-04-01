//
//  Shaders.metal
//  1 Vectors
//


#include <metal_stdlib>
using namespace metal;

/*
 1.0
 */
//kernel void compute_shader (device int& incremental [[buffer(0)]]){
//    incremental++ ;
//}

/*
 CAROLINE
 */
//kernel void compute_shader (device atomic_int& incremental [[buffer(0)]]){
//    atomic_fetch_add_explicit(&incremental, 1, memory_order_relaxed);
//}

/*
 JUSTSOMEGUY
 Which basically means: every thread in threadgroup should add atomically 1 to local, wait until every thread is done (threadgroup_barrier) and then exactly one thread adds atomically the total local to incremental.
 */
//kernel void compute_shader (device int& incremental [[buffer(0)]], threadgroup int& local [[threadgroup(0)]], ushort lid [[thread_position_in_threadgroup]] ){
//    atomic_fetch_add_explicit(local, 1, memory_order_relaxed);
//    threadgroup_barrier(mem_flags::mem_threadgroup);
//    if(lid == 0) {
//        atomic_fetch_add_explicit(incremental, local, memory_order_relaxed);
//    }
//}

/*
 2.0
 */
//kernel void compute_shader (device metal::atomic_int& incremental [[buffer(0)]],threadgroup atomic_int& local [[threadgroup(0)]],ushort lid [[thread_position_in_threadgroup]] ){
//  atomic_fetch_add_explicit(&local, 1, memory_order_relaxed);
//  threadgroup_barrier(mem_flags::mem_threadgroup);
//  if(lid == 0) {
//    atomic_fetch_add_explicit(&incremental, (int)local, memory_order_relaxed);//ERROR
//    atomic_fetch_add_explicit(&incremental, as_type<int>(local), memory_order_relaxed);//ERROR
//  }
//}


/*
 APPLE
 */
//kernel void compute_shader (device metal::atomic_int& my_atomic_int)
//{
//    int my_thread_int = atomic_load_explicit(&my_atomic_int, memory_order_relaxed);
//    ...
//}


/*
 3.0
 */
//[[kernel]] void compute_shader (device atomic_int& incremental [[buffer(0)]],
//                                threadgroup atomic_int& local [[threadgroup(0)]],
//                                ushort lid [[thread_position_in_threadgroup]] ){
//
//
//    atomic_fetch_add_explicit(&local, 1, memory_order_relaxed);
//    threadgroup_barrier(mem_flags::mem_threadgroup);
//    if(lid == 0) {
//        int _local = atomic_load_explicit(&local, memory_order_relaxed);
//        atomic_fetch_add_explicit(&incremental, _local, memory_order_relaxed);
//    }
//}

/*
 3.1
 */

[[kernel]] void compute_shader (device atomic_int& incremental [[buffer(0)]],
                                ushort lid [[thread_position_in_threadgroup]] ){
    
    threadgroup atomic_int local_atomic {0};
    
    atomic_fetch_add_explicit(&local_atomic, 1, memory_order_relaxed);
    
    threadgroup_barrier(mem_flags::mem_threadgroup);
    
    if(lid == 0) {
        int local_non_atomic = atomic_load_explicit(&local_atomic, memory_order_relaxed);
        atomic_fetch_add_explicit(&incremental, local_non_atomic, memory_order_relaxed);
    }
}



