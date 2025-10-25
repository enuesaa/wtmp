const std = @import("std");
const pkgregistry = @import("pkg/registry.zig");
const pkgtmpdir = @import("pkg/tmpdir.zig");
const pkgshell = @import("pkg/shell.zig");
const pkglist = @import("pkg/list.zig");

// NOTE:
// Do not return values from functions in this file to normalize the interface and its memory allocation.

pub fn workInTmp() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    // create registry if not exist
    try pkgregistry.make(allocator);

    // create
    var tmpdir = try pkgtmpdir.make(allocator);
    defer tmpdir.deinit();

    // start shell
    try pkgshell.start(tmpdir.path);
}

pub fn list() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const action = try pkglist.list(allocator);
    var tmpdir = action.tmpdir;

    if (std.mem.eql(u8, action.name, "")) {
        return;
    }
    if (std.mem.eql(u8, action.name, "remove")) {
        std.debug.print("selected: {s}\n", .{tmpdir.path});
        try tmpdir.delete();
        return;
    }
    if (std.mem.eql(u8, action.name, "continue")) {
        std.debug.print("selected: {s}\n", .{tmpdir.path});
        try pkgshell.start(tmpdir.path);
        return;
    }
}
