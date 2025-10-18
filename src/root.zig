const pkgregistry = @import("pkg/registry.zig");
const pkgtmpdir = @import("pkg/tmpdir.zig");
const pkgshell = @import("pkg/shell.zig");
const pkglist = @import("pkg/list.zig");

pub fn makeRegistry() !void {
    try pkgregistry.make();
}

pub fn workInTmp() !void {
    // create
    var tmpdir = try pkgtmpdir.make();

    // start shell
    try pkgshell.start(tmpdir);

    // delete
    try tmpdir.delete();
}

pub fn list() !void {
    try pkglist.handle();
}

const std = @import("std");

pub fn genRandomString() ![]u8 {
    const allocator = std.heap.page_allocator;
    var rng = std.Random.DefaultPrng.init(@intCast(std.time.nanoTimestamp()));

    const charset = "abcdefghijklmnopqrstuvwxyz0123456789";
    const length: usize = 16;
    var buf = try allocator.alloc(u8, length);

    for (buf, 0..) |_, i| {
        buf[i] = charset[rng.random().int(u8) % charset.len];
    }
    std.debug.print("Random string: {s}\n", .{buf});

    return buf;
}
