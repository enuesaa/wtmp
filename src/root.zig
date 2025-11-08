const std = @import("std");
const pkgregistry = @import("pkg/registry.zig");
const pkgtmpdir = @import("pkg/tmpdir.zig");
const pkgshell = @import("pkg/shell.zig");
const pkglist = @import("pkg/list.zig");
const cli = @import("cli");
const config = @import("config");

// NOTE:
// Do not return values from functions in this file to normalize the interface and its memory allocation.

var cliargs = struct {
    pinFrom: []const u8 = undefined,
    pinTo: []const u8 = undefined,
}{};

pub fn launchCLI() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    // cli
    var runner = try cli.AppRunner.init(allocator);

    const app = cli.App{
        .version = config.version,
        .command = cli.Command{
            .name = "ttm",
            .description = cli.Description{
                .one_line = "A CLI tool to manage tmp dirs for throwaway work",
            },
            .target = cli.CommandTarget{
                .subcommands = try runner.allocCommands(&.{
                    cli.Command{
                        .name = "ls",
                        .description = cli.Description{
                            .one_line = "list tmp dirs",
                        },
                        .target = cli.CommandTarget{
                            .action = cli.CommandAction{
                                .exec = list,
                            },
                        },
                    },
                    cli.Command{
                        .name = "pin",
                        .description = cli.Description{
                            .one_line = "pin session",
                        },
                        .target = cli.CommandTarget{
                            .action = cli.CommandAction{
                                .positional_args = cli.PositionalArgs{
                                    .required = try runner.allocPositionalArgs(&.{
                                        .{
                                            .name = "FROM",
                                            .help = "tmpdir name",
                                            .value_ref = runner.mkRef(&cliargs.pinFrom),
                                        },
                                        .{
                                            .name = "TO",
                                            .help = "tmpdir name",
                                            .value_ref = runner.mkRef(&cliargs.pinTo),
                                        },
                                    }),
                                },
                                .exec = pin,
                            },
                        },
                    },
                }),
            },
        },
        .help_config = cli.HelpConfig{
            .color_usage = .never,
        },
    };
    defer allocator.free(cliargs.pinFrom);
    defer allocator.free(cliargs.pinTo);
    try runner.run(&app);
}

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

pub fn pin() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();
    std.debug.print("pin {s} as {s}\n", .{ cliargs.pinFrom, cliargs.pinTo });

    var tmpdir = pkgtmpdir.get(allocator, cliargs.pinFrom) catch {
        std.debug.print("tmpdir not found\n", .{});
        return;
    };
    try tmpdir.rename(cliargs.pinTo);
}
