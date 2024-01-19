const std = @import("std");

const c = @cImport({
    @cInclude("llvm-c/Core.h");

    @cInclude("llvm-c/ErrorHandling.h");
    @cInclude("llvm-c/DataTypes.h");
    @cInclude("llvm-c/Types.h");

    @cInclude("llvm-c/Analysis.h");
    @cInclude("llvm-c/BitWriter.h");
    @cInclude("llvm-c/BitReader.h");

    @cInclude("llvm-c/ExecutionEngine.h");
});


// LLVM equivalent of:
//--------------------
//
// int sum(int a, int b) {
//     return a + b;    
// }
// 
// void main() {
//     printf("Hello, world!\nsum(2, 3)=%d\n", sum(2, 3));
// }


//------------------------------
//  Main
//------------------------------
pub fn main() !void {

    // Initialize
    _ = c.LLVMInitializeNativeTarget();
    _ = c.LLVMInitializeNativeAsmPrinter();
    _ = c.LLVMInitializeNativeAsmParser();
    //_ = c.LLVMInitializeNativeDisassembler();
    c.LLVMLinkInMCJIT();

    // Context creation
    //const context = c.LLVMContextCreate();

    // Module creation
    const module = c.LLVMModuleCreateWithName("module");

    // Builder creation
    const builder = c.LLVMCreateBuilder();

    // The "print" built-in function
    var print_param_types = [_]c.LLVMTypeRef{
        c.LLVMPointerType(c.LLVMInt8Type(), 0)
    };
    const print_func_type = c.LLVMFunctionType(c.LLVMInt32Type(), &print_param_types, print_param_types.len, 1);
    const print_func = c.LLVMAddFunction(module, "printf", print_func_type);
    c.LLVMSetFunctionCallConv(print_func, c.LLVMCCallConv);

    // The "sum" function prototype creation
    var sum_param_types = [_]c.LLVMTypeRef{ c.LLVMInt32Type(), c.LLVMInt32Type() };
    const sum_func_type = c.LLVMFunctionType(c.LLVMInt32Type(), &sum_param_types, sum_param_types.len, 0);
    const sum_func = c.LLVMAddFunction(module, "sum", sum_func_type);
    const sum_entry = c.LLVMAppendBasicBlock(sum_func, "entry");
    c.LLVMPositionBuilderAtEnd(builder, sum_entry);
    const sum_param1 = c.LLVMGetParam(sum_func, 0);
    const sum_param2 = c.LLVMGetParam(sum_func, 1);
    const sum_binop = c.LLVMBuildAdd(builder, sum_param1, sum_param2, "res");
    _ = c.LLVMBuildRet(builder, sum_binop);

    // Build a "main" function
    const main_func_type = c.LLVMFunctionType(c.LLVMVoidType(), null, 0, 0);
    const main_func = c.LLVMAddFunction(module, "main", main_func_type);
    const main_entry = c.LLVMAppendBasicBlock(main_func, "entry");
    c.LLVMPositionBuilderAtEnd(builder, main_entry);

    // Call "printf" function with arguments
    const str = c.LLVMBuildGlobalStringPtr(builder, "Hello, world!\nsum(2, 3)=%d\n", "");
    var sum_args = [_]c.LLVMValueRef{
        c.LLVMConstInt(c.LLVMInt32Type(), 2, 0),
        c.LLVMConstInt(c.LLVMInt32Type(), 3, 0),
    };
    const res = c.LLVMBuildCall2(builder, sum_func_type, sum_func, &sum_args, sum_args.len, "");
    
    var args = [_]c.LLVMValueRef{ str, res };
    _ = c.LLVMBuildCall2(builder, print_func_type, print_func, &args, args.len, "");
    
    _ = c.LLVMBuildRetVoid(builder);
    // End of "main" function

    // Analysis module
    var err_msg: [*c]u8 = null;
    _ = c.LLVMVerifyModule(module, c.LLVMAbortProcessAction, &err_msg);
    c.LLVMDisposeMessage(err_msg);

    // Write module to file
    err_msg = null;
    _ = c.LLVMPrintModuleToFile(module, "module.ll", &err_msg);
    c.LLVMDisposeMessage(err_msg);

    // Write bitcode to file
    //_ = c.LLVMWriteBitcodeToFile(module, "module.bc");

    // Print module to string in console
    //const outs = c.LLVMPrintModuleToString(module);
    //std.debug.print("{s}\n", .{outs});
    //c.LLVMDisposeMessage(outs);

    // Dump module to stdout
    //c.LLVMDumpModule(module);

    // Execute "main" function
    err_msg = null;
    var exec: c.LLVMExecutionEngineRef = null;
    _ = c.LLVMCreateExecutionEngineForModule(&exec, module, &err_msg);
    const main_exec = c.LLVMGetNamedFunction(module, "main");
    _ = c.LLVMRunFunction(exec, main_exec, 0, null);
    c.LLVMDisposeMessage(err_msg);

    // Dispose execution engine
    c.LLVMDisposeExecutionEngine(exec);
    // Dispose the builder
    c.LLVMDisposeBuilder(builder);
    // Dispose the module
    //c.LLVMDisposeModule(module); //NOTE: module is owned and released by the execution engine
    // Dispose the context
    //c.LLVMContextDispose(context);

    // Shutdown LLVM
    c.LLVMShutdown();

}