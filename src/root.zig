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

pub fn genRandomString() !void {
    // const allocator = std.heap.page_allocator;
    var rng = std.Random.DefaultPrng.init(@intCast(std.time.nanoTimestamp()));
    std.debug.print("Random number: {d}\n", .{rng.random().int(u64)});
    // std.debug.print("Random u64: {d}\n", .{rng.next()});
    // std.debug.print("Random u64: {d}\n", .{rng.next()});

    // // rng.random().

    // // var buf: [16]u8 = undefined;
    // // rng.random().bytes(&buf);
    // // std.debug.print("{s}\n", .{buf});

    // var buf: [16]u8 = undefined;
    // rng.random().bytes(&buf);

    // const charset = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    // var str_buf: [16]u8 = undefined;

    // for (buf, 1..) |b, i| {
    //     str_buf[i] = charset[b % charset.len];
    // }
    // std.debug.print("Random string: {s}\n", .{str_buf});

    // // const length: usize = 16;

    // // var buf: [16]u8 = undefined;
    // // const charset = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";

    // // for (buf) |*b| {
    // //     const idx = try rng.randomInt(u32, 0, charset.len);
    // //     b.* = charset[idx];
    // // }

    // // const s = buf[0..];
    // // std.debug.print("Random string: {s}\n", .{s});
}
