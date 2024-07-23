const std = @import("std");
const builtin = @import("builtin");
comptime {}

pub usingnamespace if (builtin.zig_version.minor == 9) struct {
    pub fn panic(message: []const u8, _: ?*std.builtin.StackTrace) noreturn {
        std.log.err("panic: {s}", .{message});
        @breakpoint();
        while (true) {}
    }
} else struct {
    pub fn panic(message: []const u8, _: ?*std.builtin.StackTrace, _: ?usize) noreturn {
        std.log.err("panic: {s}", .{message});
        @breakpoint();
        while (true) {}
    }
};

pub usingnamespace if (builtin.zig_version.minor < 12) struct {
    pub const std_options = struct {
        pub const logFn = log;
    };
} else struct {
    pub const std_options = .{
        .logFn = log,
    };
};

extern var reg: *volatile u8;
pub const writer: DimmyWritter = .{ .context = {} };

const DimmyWritter = std.io.Writer(void, error{}, dummyWrite);
fn dummyWrite(context: void, data: []const u8) error{}!usize {
    for (data) |d| {
        reg.* = d;
    }
    _ = context;
    return data.len;
}

pub fn log(
    comptime message_level: std.log.Level,
    comptime scope: @Type(.EnumLiteral),
    comptime format: []const u8,
    args: anytype,
) void {
    const level_prefix = comptime message_level.asText();
    const prefix = comptime level_prefix ++ switch (scope) {
        .default => ": ",
        else => " (" ++ @tagName(scope) ++ "): ",
    };

    writer.print(prefix ++ format ++ "\r\n", args) catch {};
}

extern var run: *volatile bool;

export fn _start() noreturn {
    while (run.*) {
        writer.print("wat", .{}) catch unreachable;
    }
    @panic("wat");
}
