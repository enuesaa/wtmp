const std = @import("std");
const pkgregistry = @import("registry.zig");

pub const TmpDir = struct {
    path: []u8,

    pub fn make(self: *TmpDir) !void {
        // see https://stackoverflow.com/questions/72709702/how-do-i-get-the-full-path-of-a-std-fs-dir
        try std.fs.makeDirAbsolute(self.path);
        std.debug.print("created: {s}\n", .{self.path});
    }

    pub fn isExist(self: *TmpDir) bool {
        return if (std.fs.accessAbsolute(self.path, .{})) |_| true else |_| false;
    }

    pub fn delete(self: *TmpDir) !void {
        try std.fs.deleteDirAbsolute(self.path);
    }
};

fn getTmpDirPath(allocator: std.mem.Allocator) !TmpDir {
    const registry = try pkgregistry.getRegistryPath(allocator);
    const dirName = try genRandomString(allocator);
    const path = try std.fs.path.join(allocator, &.{ registry, dirName });
    return TmpDir{ .path = path };
}

fn genRandomString(allocator: std.mem.Allocator) ![]u8 {
    var rng = std.Random.DefaultPrng.init(@intCast(std.time.nanoTimestamp()));

    var buf = try allocator.alloc(u8, 16);
    const charset = "abcdefghijklmnopqrstuvwxyz0123456789";

    for (buf, 0..) |_, i| {
        buf[i] = charset[rng.random().int(u8) % charset.len];
    }
    return buf;
}

pub fn make() !TmpDir {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var tmpdir = try getTmpDirPath(allocator);
    try tmpdir.make();

    return tmpdir;
}
