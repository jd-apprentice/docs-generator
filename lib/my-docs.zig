const std = @import("std");
const fs = std.fs;

//--------- Constants ---------//
const app_version = "0.1.0";
const docs_files: [2][]const u8 = [2][]const u8{
    "CNAME",
    "index.md",
};
const mkdocs_yaml: *const [10:0]u8 = "mkdocs.yml";
const pipeline_yaml: *const [17:0]u8 = "documentation.yml";
const logo = [_][]const u8{
    \\ ███▄ ▄███▓▓██   ██▓   ▓█████▄  ▒█████   ▄████▄    ██████ 
    \\ ▓██▒▀█▀ ██▒ ▒██  ██▒   ▒██▀ ██▌▒██▒  ██▒▒██▀ ▀█  ▒██    ▒ 
    \\ ▓██    ▓██░  ▒██ ██░   ░██   █▌▒██░  ██▒▒▓█    ▄ ░ ▓██▄   
    \\ ▒██    ▒██   ░ ▐██▓░   ░▓█▄   ▌▒██   ██░▒▓▓▄ ▄██▒  ▒   ██▒
    \\ ▒██▒   ░██▒  ░ ██▒▓░   ░▒████▓ ░ ████▓▒░▒ ▓███▀ ░▒██████▒▒
    \\ ░ ▒░   ░  ░   ██▒▒▒     ▒▒▓  ▒ ░ ▒░▒░▒░ ░ ░▒ ▒  ░▒ ▒▓▒ ▒ ░
    \\ ░  ░      ░ ▓██ ░▒░     ░ ▒  ▒   ░ ▒ ▒░   ░  ▒   ░ ░▒  ░ ░
    \\ ░      ░    ▒ ▒ ░░      ░ ░  ░ ░ ░ ░ ▒  ░        ░  ░  ░  
    \\        ░    ░ ░           ░        ░ ░  ░ ░            ░  
    \\             ░ ░         ░               ░                 
};
const default_content = [_][]const u8{
    \\
};
const mkdocs_conent = [_][]const u8{
    \\ site_name: sample project
    \\ theme:
    \\     name: material
};
const pipeline_content = [_][]const u8{
    \\ name: documentation
    \\
    \\ on:
    \\   workflow_dispatch:
    \\   push:
    \\     branches:
    \\       - main
    \\       - master
    \\     paths:
    \\       - "docs/**"
    \\       - ".github/workflows/ci.yml"
    \\
    \\ permissions:
    \\   contents: write
    \\
    \\ jobs:
    \\   deploy:
    \\     runs-on: ubuntu-latest
    \\     steps:
    \\       - uses: actions/checkout@v4
    \\       - name: Configure Git Credentials
    \\         run: |
    \\           git config user.name github-actions[bot]
    \\           git config user.email 41898282+github-actions[bot]@users.noreply.github.com
    \\       - uses: actions/setup-python@v4
    \\         with:
    \\           python-version: 3.x
    \\       - run: echo "cache_id=$(date --utc '+%V')" >> $GITHUB_ENV
    \\       - uses: actions/cache@v3
    \\         with:
    \\           key: mkdocs-material-${{ env.cache_id }}
    \\           path: .cache
    \\           restore-keys: |
    \\             mkdocs-material-
    \\       - run: pip install mkdocs-material
    \\       - run: mkdocs gh-deploy --force
};

//--------- Functions ---------//
fn printLine() !void {
    std.debug.print("{s}", .{"\n"});
}

fn makeDir(cwd: fs.Dir) !void {
    const folderName: *const [4:0]u8 = "docs";
    try cwd.makeDir(folderName);
    std.debug.print("📁 Created folder: {s}\n", .{folderName});
}

fn makePath(cwd: fs.Dir, path: []const u8) !void {
    try cwd.makePath(path);
    std.debug.print("📁 Created folder: {s}\n", .{path});
}

fn createFile(cwd: fs.Dir, fileName: []const u8, content: [1][]const u8) !void {
    const file = try cwd.createFile(fileName, .{});
    defer file.close();
    for (content) |line| {
        try file.writeAll(line);
    }
    std.debug.print("🗃 Created file: {s}\n", .{fileName});
}

fn about(image: [1][]const u8) !void {
    for (image) |line| {
        std.debug.print("{s}\n", .{line});
    }
    std.debug.print("{s}", .{"Made by jd-apprentice\n"});
    try printLine();
    std.debug.print("{s}", .{"REQUIREMENTS: \n"});
    std.debug.print("{s}", .{"1. Have a custom domain\n"});
    try printLine();
}

fn generateFiles() !void {
    const cwd = fs.cwd();
    var rootDir = try cwd.openDir("./", .{});
    defer rootDir.close();

    try createFile(cwd, mkdocs_yaml, mkdocs_conent);

    try makePath(cwd, ".github/workflows");
    var pipelineDir: fs.Dir = try cwd.openDir(".github/workflows", .{});
    defer pipelineDir.close();
    try pipelineDir.setAsCwd();
    try createFile(cwd, pipeline_yaml, pipeline_content);

    try rootDir.setAsCwd();
    try makeDir(cwd);
    var newDir: fs.Dir = try cwd.openDir("docs", .{});
    defer newDir.close();
    try newDir.setAsCwd();

    for (&docs_files) |file| {
        try createFile(cwd, file, default_content);
        std.debug.print("📰 Created file: {s}\n", .{file});
    }

    //--------- When everything is done, print the instructions ---------//
    try printLine();
    std.debug.print("Files created successfully! 🎉\n", .{});
    try printLine();

    std.debug.print("\n1. Create a CNAME in your DNS manager with your custom domain \n📚READ: https://developers.cloudflare.com/dns/manage-dns-records/how-to/create-dns-records/\n", .{});
    std.debug.print("\n2. Add the custom domain to GitHub Pages \n📚READ: https://docs.github.com/en/pages/configuring-a-custom-domain-for-your-github-pages-site/managing-a-custom-domain-for-your-github-pages-site\n", .{});
    std.debug.print("\n3. Update the CNAME file inside the docs folder with your custom domain\n", .{});
    try printLine();
    std.debug.print("You can create .md files in the docs folder and push to the repository\n", .{});
}

fn validateFiles() !void {
    std.debug.print("TODO\n", .{});
}

fn printHelp() !void {
    std.debug.print("Usage: my-docs --generate\n", .{});
    std.debug.print("Usage: my-docs --validate\n", .{});
    std.process.exit(1);
}

fn printVersion() !void {
    std.debug.print("Version: {s}\n", .{app_version});
}

pub fn main() !void {
    try about(logo);

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    if (args.len < 2) {
        std.debug.print("Usage: my-docs --help\n", .{});
        std.process.exit(1);
    }

    const arg = args[1];
    const help = "--help";
    const generate = "--generate";
    const version = "--version";
    const validate = "--validate";

    const isGenerate = std.mem.eql(u8, arg, generate);
    const isHelp = std.mem.eql(u8, arg, help);
    const isVersion = std.mem.eql(u8, arg, version);
    const isValidate = std.mem.eql(u8, arg, validate);

    if (isHelp) try printHelp();
    if (isVersion) try printVersion();
    if (isValidate) try validateFiles();
    if (isGenerate) try generateFiles();

    try printHelp();
    std.process.exit(0);
}
