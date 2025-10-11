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
    var r = try cli.AppRunner.init(std.heap.page_allocator);

    const app = cli.App{
        .command = cli.Command{
            .name = "wtmp",
            .target = cli.CommandTarget{
                // .action = cli.CommandAction{
                //     .exec = handle_main,
                // },
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

fn handle_main() !void {
    std.log.debug("main", .{});
}

fn handle_ls() !void {
    std.log.debug("ls", .{});
}
