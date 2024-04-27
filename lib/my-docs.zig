const std = @import("std");
const fs = std.fs;

//--------- Constants ---------//
const docs_files: [2][]const u8 = [2][]const u8{
    "CNAME",
    "index.md",
};
const mkdocs_yaml: *const [10:0]u8 = "mkdocs.yml";
const pipeline_yaml: *const [6:0]u8 = "documentation.yml";
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
const mkdocs_conent = [_][]const u8{
    \\ site_name: Ciber Inteligencia
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
    std.debug.print("Created folder: {s}\n", .{folderName});
}

fn writeContent(file: fs.File, content: []const u8) !void {
    for (content) |line| {
        try file.writeAll(line);
        std.debug.print("{s}\n", .{line});
    }
}

fn createFile(cwd: fs.Dir, fileName: []const u8, content: [1][]const u8) !void {
    const file = try cwd.createFile(fileName, .{});
    defer file.close();
    try writeContent(file, content);
    std.debug.print("Created file: {s}\n", .{fileName});
}

fn about(image: [1][]const u8) !void {
    for (image) |line| {
        std.debug.print("{s}\n", .{line});
    }
    std.debug.print("{s}", .{"Made by jd-apprentice\n"});
}

//--------- App ---------//
pub fn main() !void {
    try about(logo);

    const cwd = fs.cwd();
    try createFile(cwd, mkdocs_yaml, &mkdocs_conent);
    try createFile(cwd, pipeline_yaml, &pipeline_content);

    try makeDir(cwd);
    var newDir: fs.Dir = try cwd.openDir("docs", .{});
    defer newDir.close();
    try newDir.setAsCwd();

    for (&docs_files) |file| {
        try createFile(cwd, file);
        std.debug.print("Created file: {s}\n", .{file});
    }

    //--------- When everything is done, print the instructions ---------//
    try printLine();
    std.debug.print("Done! Now is time to: ", .{});
    try printLine();

    std.debug.print("1. Create a CNAME in your DNS resolver with <> \n", .{});
    std.debug.print("2. Add the custom domain to GitHub Pages \n", .{});
    try printLine();
    std.debug.print("You can create .md files in the docs folder and push to the repository\n", .{});
}
