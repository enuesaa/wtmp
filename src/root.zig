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
