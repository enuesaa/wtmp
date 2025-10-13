const std = @import("std");
const pkgregistry = @import("registry.zig");

fn getTmpDirPath(allocator: std.mem.Allocator) ![]u8 {
    const registry = try pkgregistry.getRegistryPath(allocator);

    return try std.fs.path.join(allocator, &.{ registry, "tmp" });
}

fn isTmpDirExist(tmpDirPath: []u8) bool {
    return if (std.fs.accessAbsolute(tmpDirPath, .{})) |_| true else |_| false;
}

fn makeTmpDir(allocator: std.mem.Allocator) !void {
    const tmpdir = try getTmpDirPath(allocator);
    // see https://stackoverflow.com/questions/72709702/how-do-i-get-the-full-path-of-a-std-fs-dir
    try std.fs.makeDirAbsolute(tmpdir);
    std.debug.print("created: {s}\n", .{tmpdir});
}

pub fn make() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    try makeTmpDir(allocator);
}
