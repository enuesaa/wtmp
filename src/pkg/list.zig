const std = @import("std");
const vaxis = @import("vaxis");
const vxfw = vaxis.vxfw;
const pkgtmpdir = @import("tmpdir.zig");

const Model = struct {
    split: vxfw.SplitView,
    lhs: vxfw.Text,
    rhs: vxfw.Text,
    header: vxfw.Text,
    children: [2]vxfw.SubSurface = undefined,
    menu: []pkgtmpdir.TmpDir = undefined,
    action: []const u8 = undefined,
    selected: u32 = 0,

    pub fn widget(self: *Model) vxfw.Widget {
        return .{
            .userdata = self,
            .eventHandler = Model.eventHandler,
            .drawFn = Model.drawFn,
        };
    }

    fn eventHandler(ptr: *anyopaque, ctx: *vxfw.EventContext, event: vxfw.Event) !void {
        const self: *Model = @ptrCast(@alignCast(ptr));
        switch (event) {
            .init => {
                self.split.lhs = self.lhs.widget();
                self.split.rhs = self.rhs.widget();
            },
            .key_press => |key| {
                if (key.matches('c', .{ .ctrl = true }) or key.matches('q', .{})) {
                    ctx.quit = true;
                    return;
                }
                if (key.codepoint == vaxis.Key.enter) {
                    self.action = "continue";
                    ctx.quit = true;
                    return;
                }
                if (key.matches('r', .{})) {
                    self.action = "remove";
                    ctx.quit = true;
                    return;
                }
                if (key.codepoint == vaxis.Key.up) {
                    if (self.selected > 0) {
                        self.selected -|= 1;
                    }
                    return ctx.consumeAndRedraw();
                }
                if (key.codepoint == vaxis.Key.down) {
                    if (self.selected + 1 < self.menu.len) {
                        self.selected +|= 1;
                    }
                    return ctx.consumeAndRedraw();
                }
            },
            else => {},
        }
    }

    fn drawFn(ptr: *anyopaque, ctx: vxfw.DrawContext) !vxfw.Surface {
        const self: *Model = @ptrCast(@alignCast(ptr));

        self.lhs.text = try Model.buildMenuText(ptr, ctx);
        self.split.lhs = self.lhs.widget();

        self.rhs.text = Model.buildFilesText(ptr, ctx) catch
            try std.fmt.allocPrint(ctx.arena, "error", .{});
        self.split.rhs = self.rhs.widget();

        self.children[0] = .{
            .origin = .{ .row = 0, .col = 0 },
            .surface = try self.header.widget().draw(ctx),
        };
        self.children[1] = .{
            .origin = .{ .row = 2, .col = 0 },
            .surface = try self.split.widget().draw(ctx),
        };

        return .{
            .size = ctx.max.size(),
            .widget = self.widget(),
            .buffer = &.{},
            .children = &self.children,
        };
    }

    fn buildMenuText(ptr: *anyopaque, ctx: vxfw.DrawContext) ![]u8 {
        const self: *Model = @ptrCast(@alignCast(ptr));
        var buf = std.array_list.Managed([]const u8).init(ctx.arena);

        for (self.menu, 0..) |item, i| {
            const text = try std.fmt.allocPrint(ctx.arena, "{s}{s}\n", .{
                if (self.selected == i) "> " else "  ",
                item.dirName,
            });
            try buf.append(text);
        }
        return try std.mem.join(ctx.arena, "", buf.items[0..buf.items.len]);
    }

    fn buildFilesText(ptr: *anyopaque, ctx: vxfw.DrawContext) ![]u8 {
        const self: *Model = @ptrCast(@alignCast(ptr));
        return self.menu[self.selected].listFiles(ctx.arena);
    }
};

const Action = struct {
    name: []const u8 = "",
    selected: []const u8 = "",
};

fn launch(allocator: std.mem.Allocator) !Action {
    const tmpdirs = try pkgtmpdir.list();

    var app = try vxfw.App.init(allocator);
    defer app.deinit();

    var model = try allocator.create(Model);
    defer allocator.destroy(model);

    model.* = .{
        .lhs = .{ .text = "", .text_align = .center },
        .rhs = .{ .text = "" },
        .header = .{ .text = "[q] Quit, [r] Remove, [Enter] Continue Working" },
        .split = .{ .lhs = undefined, .rhs = undefined, .width = 22 },
        .menu = tmpdirs,
    };
    try app.run(model.widget(), .{});

    return Action{
        .name = model.action,
        .selected = model.menu[model.selected].path,
    };
}

pub fn handle() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const action = try launch(allocator);
    std.debug.print("selected: {s}\n", .{action.selected});

    if (std.mem.eql(u8, action.name, "remove")) {
        std.debug.print("remove!\n", .{});
    }
    if (std.mem.eql(u8, action.name, "continue")) {
        std.debug.print("continue!\n", .{});
    }
}
