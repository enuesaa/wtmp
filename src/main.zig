const std = @import("std");
const wtmp = @import("wtmp");

// pub fn main() !void {
//     std.debug.print("start\n", .{});

//     // create tmp dir here
//     try wtmp.mkdir();

//     // start shell
//     try wtmp.shell();

//     // delete tmp dir here
//     try wtmp.rmdir();
// }

const cli = @import("cli");

pub fn main() !void {
    const args = try std.process.argsAlloc(std.heap.page_allocator);
    defer std.process.argsFree(std.heap.page_allocator, args);

    if (args.len == 1) {
        // NOTE: first argument is the binary name like `wtmp`
        std.log.debug("main", .{});
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
                                .exec = handle_ls,
                            },
                        },
                    },
                }),
            },
        },
    };
    return r.run(&app);
}

fn handle_ls() !void {
    std.log.debug("ls", .{});
}
