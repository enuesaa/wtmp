const std = @import("std");
const pkgtmpdir = @import("tmpdir.zig");

pub fn list(allocator: std.mem.Allocator) !void {
    const tmpdirs = try pkgtmpdir.list(allocator);
    defer allocator.free(tmpdirs);
    defer for (tmpdirs) |*td| td.deinit();

    for (tmpdirs) |tmpdir| {
        std.debug.print("{s}\n", .{tmpdir.dirName});
    }
}
