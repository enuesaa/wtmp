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

pub fn gentime() !void {
    const timestamp = std.time.timestamp();
    const jsttimestamp = timestamp + 9 * 3600;

    const epoch = std.time.epoch.EpochSeconds{ .secs = @as(u64, @intCast(jsttimestamp)) };

    const daySeconds = epoch.getDaySeconds();
    const day = epoch.getEpochDay();
    const yearDay = day.calculateYearDay();
    const monthDay = yearDay.calculateMonthDay();

    const date = try std.fmt.allocPrint(std.heap.page_allocator, "{:04}{:02}{:02}T{:02}{:02}{:02}", .{
        yearDay.year,
        monthDay.month.numeric(),
        monthDay.day_index + 1,
        daySeconds.getHoursIntoDay(),
        daySeconds.getMinutesIntoHour(),
        daySeconds.getSecondsIntoMinute(),
    });

    std.debug.print("Current time: {s}\n", .{date});
}
