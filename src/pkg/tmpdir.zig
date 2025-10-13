const std = @import("std");
const pkgregistry = @import("registry.zig");

const TmpDir = struct {
    path: []u8,

    pub fn make(self: *TmpDir) !void {
        // see https://stackoverflow.com/questions/72709702/how-do-i-get-the-full-path-of-a-std-fs-dir
        try std.fs.makeDirAbsolute(self.path);
        std.debug.print("created: {s}\n", .{self.path});
    }

    pub fn delete(self: *TmpDir) !void {
        try std.fs.deleteDirAbsolute(self.path);
    }
};

fn getTmpDirPath(allocator: std.mem.Allocator) !TmpDir {
    const registry = try pkgregistry.getRegistryPath(allocator);
    const path = try std.fs.path.join(allocator, &.{ registry, "tmp" });
    return TmpDir{ .path = path };
}

fn isTmpDirExist(tmpDirPath: []u8) bool {
    return if (std.fs.accessAbsolute(tmpDirPath, .{})) |_| true else |_| false;
}

pub fn make() !TmpDir {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var tmpdir = try getTmpDirPath(allocator);
    try tmpdir.make();

    return tmpdir;
}
