const std = @import("std");
const pkgregistry = @import("registry.zig");

pub const TmpDir = struct {
    arena: std.heap.ArenaAllocator,
    path: []u8,
    dirName: []u8,

    pub fn init(registryPath: []const u8, dirName: []const u8) !TmpDir {
        var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
        const allocator = arena.allocator();
        return TmpDir{
            .arena = arena,
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
        try std.fs.deleteDirAbsolute(self.path);
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
};

fn getTmpDirPath(allocator: std.mem.Allocator) !TmpDir {
    const registryPath = try pkgregistry.getRegistryPath(allocator);
    defer allocator.free(registryPath);
    const dirName = try std.fmt.allocPrint(
        allocator,
        "{s}-{s}",
        .{ try now(allocator), try genRandomString(allocator) },
    );
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

pub fn make() !TmpDir {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var tmpdir = try getTmpDirPath(allocator);
    try tmpdir.make();

    return tmpdir;
}

pub fn list() ![]TmpDir {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const registryPath = try pkgregistry.getRegistryPath(allocator);
    defer allocator.free(registryPath);
    const registry = try std.fs.openDirAbsolute(registryPath, .{});

    var buf = std.array_list.Managed(TmpDir).init(allocator);
    defer buf.deinit();
    const entries = try registry.openDir(".", .{ .iterate = true });
    var it = entries.iterate();

    while (try it.next()) |entry| {
        try buf.append(try TmpDir.init(registryPath, entry.name));
    }
    return buf.toOwnedSlice();
}
