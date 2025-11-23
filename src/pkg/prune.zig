const std = @import("std");
const pkgtmpdir = @import("tmpdir.zig");

pub fn prune(allocator: std.mem.Allocator) !void {
    const tmpdirs = try pkgtmpdir.list(allocator);
    defer allocator.free(tmpdirs);
    defer for (tmpdirs) |*td| td.deinit();

    for (tmpdirs) |*tmpdir| {
        if (tmpdir.isArchived()) {
            try tmpdir.delete();
            std.debug.print("remove: {s}\n", .{tmpdir.dirName});
        }
    }
}
