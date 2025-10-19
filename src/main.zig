const std = @import("std");
const wtmp = @import("wtmp");
const cli = @import("cli");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    // start work-in-tmp
    // NOTE: first argument is the binary name like `wtmp`
    if (args.len == 1) {
        // create registry if not exist
        try wtmp.makeRegistry();

        // create tmpdir, start shell
        try wtmp.workInTmp();
        return;
    }

    // cli
    var r = try cli.AppRunner.init(allocator);

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
                                .exec = wtmp.list,
                            },
                        },
                    },
                }),
            },
        },
    };
    return r.run(&app);
}
