const std = @import("std");
const types = @import("../types.zig");
const common = @import("common.zig");

pub fn parse(allocator: std.mem.Allocator, args: []const [:0]const u8) !types.ParseResult {
    if (args.len == 1 and common.isHelpFlag(std.mem.sliceTo(args[0], 0))) {
        return .{ .command = .{ .help = .login } };
    }

    var opts: types.LoginOptions = .{};
    var i: usize = 0;
    while (i < args.len) : (i += 1) {
        const arg = std.mem.sliceTo(args[i], 0);
        if (std.mem.eql(u8, arg, "--device-auth")) {
            if (opts.device_auth) return common.usageErrorResult(allocator, .login, "duplicate `--device-auth` for `login`.", .{});
            opts.device_auth = true;
            continue;
        }
        if (std.mem.eql(u8, arg, "--skip-api")) {
            if (opts.skip_api) return common.usageErrorResult(allocator, .login, "duplicate `--skip-api` for `login`.", .{});
            opts.skip_api = true;
            continue;
        }
        if (std.mem.startsWith(u8, arg, "--alias=")) {
            if (opts.alias != null) return common.usageErrorResult(allocator, .login, "duplicate `--alias` for `login`.", .{});
            const value = arg["--alias=".len..];
            if (value.len == 0) return common.usageErrorResult(allocator, .login, "missing value for `--alias`.", .{});
            opts.alias = value;
            continue;
        }
        if (std.mem.eql(u8, arg, "--alias")) {
            if (opts.alias != null) return common.usageErrorResult(allocator, .login, "duplicate `--alias` for `login`.", .{});
            if (i + 1 >= args.len) return common.usageErrorResult(allocator, .login, "missing value for `--alias`.", .{});
            i += 1;
            const value = std.mem.sliceTo(args[i], 0);
            if (value.len == 0) return common.usageErrorResult(allocator, .login, "missing value for `--alias`.", .{});
            opts.alias = value;
            continue;
        }
        if (common.isHelpFlag(arg)) return common.usageErrorResult(allocator, .login, "`--help` must be used by itself for `login`.", .{});
        if (std.mem.startsWith(u8, arg, "-")) return common.usageErrorResult(allocator, .login, "unknown flag `{s}` for `login`.", .{arg});
        return common.usageErrorResult(allocator, .login, "unexpected argument `{s}` for `login`.", .{arg});
    }
    return .{ .command = .{ .login = opts } };
}
