const std = @import("std");
const wtmp = @import("wtmp");
const cli = @import("cli");
const ls = @import("ls.zig");

pub fn main() !void {
    const args = try std.process.argsAlloc(std.heap.page_allocator);
    defer std.process.argsFree(std.heap.page_allocator, args);

    // NOTE: first argument is the binary name like `wtmp`
    if (args.len == 1) {
        std.log.debug("start new tmp", .{});
        // create tmp dir here
        try wtmp.mkdir();

        // start shell
        try wtmp.shell();

        // delete tmp dir here
        try wtmp.rmdir();
        return;
    }
    var r = try cli.AppRunner.init(std.heap.page_allocator);

    const app = cli.App{
        .command = cli.Command{
            .name = "wtmp",
            .target = cli.CommandTarget{
                .subcommands = try r.allocCommands(&.{
                    cli.Command{
                        .name = "ls",
                        .description = cli.Description{
                            .one_line = "ls command",
                        },
                        .target = cli.CommandTarget{
                            .action = cli.CommandAction{
                                .exec = ls.ls,
                            },
                        },
                    },
                }),
            },
        },
    };
    return r.run(&app);
}
