const std = @import("std");

pub fn mkdir() !void {
    const cwd = std.fs.cwd();

    const alloc = std.heap.page_allocator;
    // see https://stackoverflow.com/questions/72709702/how-do-i-get-the-full-path-of-a-std-fs-dir
    const cwdpath = try cwd.realpathAlloc(alloc, ".");
    std.debug.print("cwd: {s}\n", .{cwdpath});

    try cwd.makeDir("testdir");
}

pub fn isDirExists() bool {
    const cwd = std.fs.cwd();
    return if (cwd.access("a", .{})) |_| true else |_| false;
}

pub fn add(a: i32, b: i32) i32 {
    return a + b;
}

test "basic add functionality" {
    try std.testing.expect(add(3, 7) == 10);
}
