const std = @import("std");
const pkgregistry = @import("registry.zig");

pub const TmpDir = struct {
    arena: std.heap.ArenaAllocator,
    registryPath: []u8,
    path: []u8,
    dirName: []u8,

    pub fn init(registryPath: []const u8, dirName: []const u8) !TmpDir {
        var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
        const allocator = arena.allocator();
        return TmpDir{
            .arena = arena,
            .registryPath = try allocator.dupe(u8, registryPath),
            .path = try std.fs.path.join(allocator, &.{ registryPath, dirName }),
            .dirName = try allocator.dupe(u8, dirName),
        };
    }

    pub fn deinit(self: *TmpDir) void {
        self.arena.deinit();
    }

    pub fn make(self: *TmpDir) !void {
        // see https://stackoverflow.com/questions/72709702/how-do-i-get-the-full-path-of-a-std-fs-dir
        try std.fs.makeDirAbsolute(self.path);
        std.debug.print("created: {s}\n", .{self.path});
    }

    pub fn isExist(self: *TmpDir) bool {
        return if (std.fs.accessAbsolute(self.path, .{})) |_| true else |_| false;
    }

    pub fn delete(self: *TmpDir) !void {
        try std.fs.deleteTreeAbsolute(self.path);
    }

    pub fn listFiles(self: *TmpDir) ![]u8 {
        const allocator = self.arena.allocator();
        var buf = std.array_list.Managed([]const u8).init(allocator);
        const entries = try std.fs.Dir.openDir(undefined, self.path, .{ .iterate = true });
        var it = entries.iterate();
        while (try it.next()) |entry| {
            try buf.append(entry.name);
        }
        return try std.mem.join(allocator, "\n", buf.items[0..buf.items.len]);
    }

    pub fn rename(self: *TmpDir, afterDirName: []const u8) !void {
        const allocator = self.arena.allocator();
        const afterPath = try std.fs.path.join(allocator, &.{ self.registryPath, afterDirName });
        std.debug.print("rename: {s}\n", .{afterPath});

        try std.fs.renameAbsolute(self.path, afterPath);

        self.path = try allocator.dupe(u8, afterPath);
        self.dirName = try allocator.dupe(u8, afterDirName);
    }
};

fn getTmpDirPath(allocator: std.mem.Allocator) !TmpDir {
    const registryPath = try pkgregistry.getRegistryPath(allocator);
    defer allocator.free(registryPath);
    const nowtime = try now(allocator);
    const randomString = try genRandomString(allocator);
    defer allocator.free(nowtime);
    defer allocator.free(randomString);
    const dirName = try std.fmt.allocPrint(
        allocator,
        "{s}-{s}",
        .{ nowtime, randomString },
    );
    defer allocator.free(dirName);
    return try TmpDir.init(registryPath, dirName);
}

fn genRandomString(allocator: std.mem.Allocator) ![]u8 {
    var rng = std.Random.DefaultPrng.init(@intCast(std.time.nanoTimestamp()));

    var buf = try allocator.alloc(u8, 5);
    const charset = "abcdefghijklmnopqrstuvwxyz0123456789";

    for (buf, 0..) |_, i| {
        buf[i] = charset[rng.random().int(u8) % charset.len];
    }
    return buf;
}

fn now(allocator: std.mem.Allocator) ![]u8 {
    const timestamp = std.time.timestamp();
    const jsttimestamp = timestamp + 9 * 3600;

    const epoch = std.time.epoch.EpochSeconds{ .secs = @as(u64, @intCast(jsttimestamp)) };

    const daySeconds = epoch.getDaySeconds();
    const day = epoch.getEpochDay();
    const yearDay = day.calculateYearDay();
    const monthDay = yearDay.calculateMonthDay();

    const date = try std.fmt.allocPrint(allocator, "{:04}{:02}{:02}{:02}{:02}", .{
        yearDay.year,
        monthDay.month.numeric(),
        monthDay.day_index + 1,
        daySeconds.getHoursIntoDay(),
        daySeconds.getMinutesIntoHour(),
    });
    return date;
}

pub fn make(allocator: std.mem.Allocator) !TmpDir {
    var tmpdir = try getTmpDirPath(allocator);
    try tmpdir.make();

    return tmpdir;
}

pub fn list(allocator: std.mem.Allocator) ![]TmpDir {
    const registryPath = try pkgregistry.getRegistryPath(allocator);
    defer allocator.free(registryPath);
    const registry = try std.fs.openDirAbsolute(registryPath, .{});

    var buf: std.array_list.Aligned(TmpDir, null) = .empty;
    defer buf.deinit(allocator);
    const entries = try registry.openDir(".", .{ .iterate = true });
    var it = entries.iterate();

    while (try it.next()) |entry| {
        try buf.append(allocator, try TmpDir.init(registryPath, entry.name));
    }
    return try buf.toOwnedSlice(allocator);
}

pub fn get(allocator: std.mem.Allocator, name: []const u8) !TmpDir {
    const registryPath = try pkgregistry.getRegistryPath(allocator);
    defer allocator.free(registryPath);

    var tmpdir = try TmpDir.init(registryPath, name);
    if (!tmpdir.isExist()) {
        return error.RuntimeError;
    }
    return tmpdir;
}
